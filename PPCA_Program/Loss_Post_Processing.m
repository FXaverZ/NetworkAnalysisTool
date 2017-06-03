classdef Loss_Post_Processing
% BRANCH_POST_PROCESSING    Branch violation post processing class
% Version:                 1.0
% Erstellt von:            Matej Rejc - 14.05.2013
% Letzte Änderung durch:   Matej Rejc - 14.05.2013
    
    properties 
        Scenarios;
        Grid_Variants;
        Datasets;
        Timepoints;
        Result_Filenames;
        Result_Filepath;
        Simulation_Options;
        x_axis_value;
        Result_Files;
        Excel_Table;
        Graph_Data;
    end
    
    % Result_Post_Processing method definitions
    methods
        function obj = Loss_Post_Processing(information_file)
            % Define the information of the results for postprocessing
            inp_info = load(information_file);
           
            obj.Result_Filepath = information_file(1:find(information_file == '\',1,'last')-1);
            obj.Result_Filenames = inp_info.result_filename;
            obj.Simulation_Options = inp_info.simulation_options;
            
            obj.Scenarios = inp_info.scenarios;
            obj.Grid_Variants = inp_info.variants;
            obj.Datasets = inp_info.datasets;
            obj.Timepoints = inp_info.simulation_options.Timepoints;            
            obj.Result_Files = Load_Result_File(obj);
            obj.Excel_Table = [];
            
            % If histogram x axis will be shown in % select 2
            % If histogram x axis will be shown in numbers select 1
            obj.x_axis_value = 2;

        end
        % function Result_Post_Processing: create object function
        
        function [table_results,excel_results] = compare_datasets(obj,varargin)
            % Check input varargin
            [S, G, excel_] = input_check(3,2,varargin); % Scenario, grid, excel_output
            
            % Load results from .mat files
            [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(S);  
            
             % Load branch violation results
            if obj.Simulation_Options.Save_Power_Loss_Results               
                Loss_Analysis = Result.(obj.Grid_Variants{G}).Power_Loss_Analysis;
                Voltage_Levels = Grid.(obj.Grid_Variants{G}).Branches.grouped_voltage_level_val;
            end            
            % Last column of last dimension is total power losses, the
            % first to end-1 columns are losses at voltage levels
            
            % TABLE_RESULTS > SUMMARY : A summary of power losses
            for i = 1 : size(Loss_Analysis,3)
                table_results.Summary(:,i) = sum(squeeze(Loss_Analysis(:,:,i)),2);                
            end
                       
            % TABLE_RESULTS > BRANCHHISTOGRAM_VIOLATIONS : Number of
            % violations at each branch
            for cd = 1 : obj.Datasets
                table_results.BranchHistogram_Violations(cd,:) =  squeeze(Loss_Analysis(cd,:,end));
            end
            % array 1dim (dataset) 2dim(losses)
            table_results.Voltage_Levels = Voltage_Levels;
            % OUTPUT FOR EXCEL FILE (DATASET COMPARISON)            
            if excel_ == 1
                obj.Excel_Table = Excel_Output_Losses();
                obj.Excel_Table.scenario(S);
                obj.Excel_Table.grid(G);
                obj.Excel_Table.voltage_levels(Voltage_Levels);
                obj.Excel_Table.compare_datasets(obj,table_results);                
                excel_results.sheet1 = obj.Excel_Table.Sheet.Sheet1; % summary
            else
                excel_results.sheet1 = []; % summary
                excel_results.sheet2 = []; % load infeed
            end
        end
        % compare datasets function
        
        function [table_results,excel_results] = compare_grids(obj,varargin)
            % Check input varargin
            [S, excel_] = input_check(2,1,varargin); % Scenario, excel_output
            
            % Run dataset comparison between grids
            for G = 1 : numel(obj.Grid_Variants)
                input_results = []; % input_results ... dataset comparisons
                [input_results,~] = obj.compare_datasets(S,G);
               
                % TABLE_RESULTS > GRIDSUMMARY
                table_results.GridSummary(:,G ) = ...
                    [sum(input_results.Summary(:,end));     % Sum of datasets Wh
                     mean(input_results.Summary(:,end));    % Mean of sum of datasets Wh
                     std(input_results.Summary(:,end));     % STD
                     max(input_results.BranchHistogram_Violations(:))]; % Max losses at timepoint
                % Rows are 1...sum losses of all datasets, 2...mean of sums for datasets
                % 3...std of sums for datasets, 4...max losses at one
                % timepoint
                % Columns are grids
                
            end  
            
            % OUTPUT FOR EXCEL FILE (DATASET COMPARISON)
            if excel_ == 1
                obj.Excel_Table = Excel_Output_Losses();
                obj.Excel_Table.scenario(S);                 
                obj.Excel_Table.compare_grids(obj,table_results);                   
                excel_results.sheet1 = obj.Excel_Table.Sheet.Sheet1; % grid summary
            else
                excel_results.sheet1 = [];
            end
           
        end
        % compare grids function
        
        function [table_results,excel_results] = compare_grids_all_scenarios(obj,varargin)            
             % Check input varargin
            [excel_] = input_check(1,0,varargin); % Scenario, excel_output
            
            % Run dataset comparison between grids for all scenarios
            for S = 1 : numel(obj.Scenarios)
                input_results = [];
                xls_input = [];
                [input_results,xls_input] = obj.compare_grids(S,'xls'); 
                
                xls_results.(['S_', int2str(S)]) = xls_input;
                % TABLE RESULTS > COMPLETESUMMARY
                table_results.CompleteSummary(S,:,:) = input_results.GridSummary;
                
                % table_results.CompleteSummary_Full (1dim is dataset, 2dim
                % is S, 3dim is G, 4dim is value
                %   (1-number of viol., 2-viol in %, 3-nodes affected,
                %   4-nodes affected in %
                                
                % table_results.CompleteSummary_Short (1dim is scenario,
                % 2dim is G, 3dim is (1-numb. of viol., 2-viol in %,
                % 3-nodes affected, 4-nodes affected in %), 4dim is value
                %   (1-max value, 2-min value, 3-mean value, 4-sum value)
                              
                % table_results.ScenarioGridHistogram_Violations
                % table_results.ScenarioGridHistogram_Violations_at_Nodes
                %    Number of violations for each dataset                
                %    Number of nodes affected for each dataset
                % 1dim is dataset, 2dim is G, 3dim is S. Values are the
                % violations or numbers of nodes affected for each dataset
                                
                % table_results.ScenarioNodeHistogram_Violations
                % Number of violations for each dataset for each node
                % for {G} grid and scenario - % Cell dimension is scenario xgrid                
                % 1dim is S, 2dim is G, 1dim in cell is dataset, 2dim in cell is node
            end                
            % OUTPUT FOR EXCEL FILE
            if excel_ == 1
                obj.Excel_Table = Excel_Output_Losses();
                obj.Excel_Table.compare_grids_all_scenarios(obj,xls_results);                   
                excel_results.sheet1 = obj.Excel_Table.Sheet.Sheet1; % gridscen_summary
            else
                excel_results.sheet1 = [];
            end            
        end % compare_grids_all_scenarios
        
        function display_datasets(obj,varargin)
            % Display datasets function displays dataset comparisons for
            % specified grid G and specified scenario S
            % Check input varargin
            [S,G] = input_check(2,2,varargin); % Scenario, grid
            
            if obj.Datasets == 1
                error('Only one Dataset, cannot compare');
            end
            
            % Create table result values (input_results) using compare_datasets function
            [input_results,~] = obj.compare_datasets(S,G);
            
            % Prepare the results for plotting - write to table_results
            table_results.Losses = input_results.Summary;
            table_results.Voltage_Levels = input_results.Voltage_Levels;
            
            
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Losses;
            % Define scenario and grid
            obj.Graph_Data.scenario(S);
            obj.Graph_Data.grid(G);            
            % Plot horizontal bar graph
            obj.Graph_Data.display_datasets(obj, table_results.Losses(:,end));
        end
        % function display_datasets
        
        function display_grids(obj,varargin)
            % Display grids function displays a grid comparisons for
            % specified scenario S. The results display the comparisons of all
            % datasets and their impact on specific grids
            S = input_check(1,1,varargin); % Scenario

            if numel(obj.Grid_Variants) == 1
                error('Only one Grid, cannot compare');
            end
            % Import results for scenario
            [input_results,~] = compare_grids(obj,S);
            
            table_results.losses = input_results.GridSummary;
            % Rows are 1...sum losses of all datasets, 2...mean of sums for datasets
            % 3...std of sums for datasets, 4...max losses at one
            % timepoint
            
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Losses;
            % Define scenario and grid
            obj.Graph_Data.scenario(S);
            % Plot horizontal bar graph
            obj.Graph_Data.display_grids(obj, table_results.losses(1,:)');
        end
        % function display_grids
        
        function display_grids_all_scenarios(obj)
            % Display grids function displays a grid comparisons for
            % specified scenario S. The results display the comparisons of all
            % datasets and their impact on specific grids
            if numel(obj.Grid_Variants) == 1 || numel(obj.Scenarios) == 1
                error('Only one Grid or Scenario, cannot compare');
            end
            
            [input_results,~] = obj.compare_grids_all_scenarios;
            
            % We transp. the array so grids are the rows and scenarios the
            % columns
            table_results.summary_all = squeeze(input_results.CompleteSummary(:,1,:)); 
            % Sum of all losses for all scenarios and all grids

            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Losses;
            % Plot horizontal bar graph
            obj.Graph_Data.display_grids_all_scenarios(obj,...
                table_results.summary_all);
                    
        end
        % function display_grids_and_scenarios
        
        function histogram_comparisons_grids_at_scenario(obj,varargin)
            % histogram_comparisons_grids_at_scenario for the S scenario
            
            % Check input varargin
            [S, nan_] = input_check_hist(2,1,varargin); % Scenario, grid, excel_output
            
            % Load results from .mat files
            [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(S);
            
            table_results.Losses = [];
            for G = 1 : numel(obj.Grid_Variants)
                table_results.Losses(:,G) = Result.(obj.Grid_Variants{G}).Power_Loss_Summary.Max_Power_Loss_Values(:,end);
            end % (:,end) so that the entire network losses can be observed
                        
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Losses;
            % Define scenario and grid
            obj.Graph_Data.scenario(S);            
            obj.Graph_Data.histogram_comparisons_grids_at_scenario(obj,table_results.Losses);
        end
        % function histogram_comparisons_grids_at_scenario
        
        function histogram_comparisons_scenarios_at_grid(obj,varargin)
            [G,nan_] = input_check_hist(2,1,varargin); % Scenario, grid, excel_output
            
            % Load grid results for scenario S
            % Load relevent data from mat file (scenario S, grid G)
            table_results.Losses = [];
            for S = 1 : numel(obj.Scenarios)
                % Load results from .mat files
                [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(S);
                table_results.Losses(:,S) = Result.(obj.Grid_Variants{G}).Power_Loss_Summary.Max_Power_Loss_Values(:,end);
            end % Last column is the entire grid
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Losses;
            % Define scenario and grid
            obj.Graph_Data.grid(G);
            obj.Graph_Data.histogram_comparisons_scenarios_at_grid(obj,table_results.Losses);
            
        end
        % function histogram_comparisons_scenarios_at_grid
        
        
        function histogram_comparisons_inputs_at_scenarios(obj,varargin)
            % histogram_comparisons_inputs_at_scenarios for all scenario
            [nan_] = input_check_hist(1,0,varargin); % Scenario, grid, excel_output
            % Load grid results for scenario S
            for S = 1 : numel(obj.Scenarios)
                % Load results from .mat files
                [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(S);

                table_results.households{S} = zeros(obj.Timepoints*obj.Datasets,1);
                table_results.solar{S} = zeros(obj.Timepoints*obj.Datasets,1);
                table_results.el_mobility{S} = zeros(obj.Timepoints*obj.Datasets,1);
                
                for D = 1 : obj.Datasets
                    households = []; solar = []; el_mobility = [];
                    households = Load_Infeed_Data.(['Set_', int2str(D)]).Households.(obj.Simulation_Options.Input_values_used);
                    solar = Load_Infeed_Data.(['Set_', int2str(D)]).Solar.(obj.Simulation_Options.Input_values_used);
                    el_mobility = Load_Infeed_Data.(['Set_', int2str(D)]).El_Mobility.(obj.Simulation_Options.Input_values_used);
                    
                    if isempty(solar)
                        solar = zeros(size(households));
                    end
                    if isempty(el_mobility)
                        el_mobility = zeros(size(households));
                    end
                    
                    table_results.households{S}( obj.Timepoints*(D-1) + (1: obj.Timepoints),1) = ...
                        sum( households(:,1:6:end) + households(:,2:6:end) + households(:,3:6:end),2);
                    table_results.solar{S}( obj.Timepoints*(D-1) + (1: obj.Timepoints),1) = ...
                        sum(solar(:,1:6:end) + solar(:,2:6:end) + solar(:,3:6:end),2);
                    table_results.el_mobility{S}( obj.Timepoints*(D-1) + (1: obj.Timepoints),1) = ...
                        sum(el_mobility(:,1:6:end) + el_mobility(:,2:6:end) + el_mobility(:,3:6:end),2);
                end
            end
            clear households  solar el_mobility D S Result
            
            if nan_ == 1
                for S = 1 : numel(obj.Scenarios)
                    table_results.solar{S}(table_results.solar{S}==0) = NaN;
                    table_results.el_mobility{S}(table_results.el_mobility{S}==0) = NaN;
                end
            end
            
            % Create Graph definition object
           obj.Graph_Data = Graph_Definition;
           % Define scenario and grid
           obj.Graph_Data.histogram_comparisons_inputs_at_scenarios(obj,table_results);
            
        end
        % function histogram_comparisons_inputs_at_scenarios
        
        
    end % methods
end % classdef

