classdef Branch_Post_Processing
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
        function obj = Branch_Post_Processing(information_file)
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
            if obj.Simulation_Options.Branch_Violation_Analysis               
                Branch_Violation_Summary = Result.(obj.Grid_Variants{G}).Branch_Violation_Summary;
                Branch_Violation_Analysis = Result.(obj.Grid_Variants{G}).Branch_Violation_Analysis;
            end
            
            % Load saved branch results
            if obj.Simulation_Options.Save_Branch_Results
                Branch_values = Result.(obj.Grid_Variants{G}).Branch_Values;
            end
            
            % TABLE_RESULTS > SUMMARY : A summary of voltage violations
            table_results.Summary = [...
                Branch_Violation_Summary.Number_of_Violations,...
                Branch_Violation_Summary.Number_of_Violations_percent,...
                Branch_Violation_Summary.Number_of_Branches_With_Violations,...
                Branch_Violation_Summary.Number_of_Branches_With_Violations_percent,...
                ];
            
            % TABLE_RESULTS > VIOLATED_BRANCHES : A list of branches where
            % violations occured for each dataset   
            table_results.Violated_branches = cell(obj.Datasets,...
                max(Branch_Violation_Summary.Number_of_Branches_With_Violations(:)));
            % Preallocation of cell array
            for cd = 1 : obj.Datasets
                if ~isempty(Branch_Violation_Summary.Names_of_Branches_With_Violations{cd,1})
                    table_results.Violated_branches(...
                        cd,1:size(Branch_Violation_Summary.Names_of_Branches_With_Violations{cd,1},2)) = ...
                            sort(Branch_Violation_Summary.Names_of_Branches_With_Violations{cd,1});
                end
            end
            
            % TABLE_RESULTS > BRANCHHISTOGRAM_VIOLATIONS : Number of
            % violations at each branch
            for cd = 1 : obj.Datasets
                table_results.BranchHistogram_Violations(cd,:) = ...
                    nansum(squeeze(Branch_Violation_Analysis(cd,:,:)),1);
            end
            if obj.x_axis_value == 2
                table_results.BranchHistogram_Violations = 100*table_results.BranchHistogram_Violations/obj.Timepoints;
            end
            % array 1dim (dataset) 2dim(node), values are the violations
            % for each dataset (all timepoints)
                        
            % TABLE_RESULTS > LOAD_INFEED_VALUES : Values of load,
            % infeed and e-mobility for specific dataset
            for cd = 1 : obj.Datasets
                % pliv..pretable load/infeed values
                pliv = [];                 
                % Load set values
                pliv.load_val = Load_Infeed_Data.(['Set_', int2str(cd) ]).Households.(obj.Simulation_Options.Input_values_used);
                pliv.infeed_val = Load_Infeed_Data.(['Set_', int2str(cd) ]).Solar.(obj.Simulation_Options.Input_values_used);
                pliv.el_mobility_val = Load_Infeed_Data.(['Set_', int2str(cd) ]).El_Mobility.(obj.Simulation_Options.Input_values_used);
                % first column equals P, second column equals Q
                pliv.load_val = [sum(pliv.load_val(:,1:2:end),2),sum(pliv.load_val(:,2:2:end),2) ];
                pliv.infeed_val = [sum(pliv.infeed_val(:,1:2:end),2),sum(pliv.infeed_val(:,2:2:end),2)];
                pliv.el_mobility_val = [sum(pliv.el_mobility_val(:,1:2:end),2),sum(pliv.el_mobility_val(:,2:2:end),2)];
                % Set zeros if no solar or el.mobility values to the array
                if isempty(pliv.infeed_val)
                    pliv.infeed_val = zeros(size(pliv.load_val));
                end
                if isempty(pliv.el_mobility_val)
                    pliv.el_mobility_val = zeros(size(pliv.load_val));
                end
                % Balance P and Q
                pliv.balance(:,1) = pliv.load_val(:,1) - pliv.infeed_val(:,1) + pliv.el_mobility_val(:,1);
                pliv.balance(:,2) = pliv.load_val(:,2) - pliv.infeed_val(:,2) + pliv.el_mobility_val(:,2);
                % look for the numerical timepoint where violations occured
                pliv.timepoints = find(sum(squeeze(Branch_Violation_Analysis(cd,:,:)) == 1,2) > 0);
                table_results.Load_infeed_values_at_Violation{cd,1} = [...
                    pliv.timepoints,...                         % [timepoint 1, timepoint 2  , ...
                    pliv.load_val(pliv.timepoints,:),...        %  load P1    , load P2      , ... ;  load Q1    , load Q2      , ...
                    pliv.infeed_val(pliv.timepoints,:),...      %  infeed P1  , infeed P2    , ... ;  infeed Q1  , infeed Q2      , ...
                    pliv.el_mobility_val(pliv.timepoints,:),... %  el. mob P1 , el. mob P2   , ... ;  el. mob Q1 , el. mob Q2      , ...
                    pliv.balance(pliv.timepoints,:),...         %  sum P1     , sum P2       , ... ;  sum Q1     , sum Q2      , ...
                    ]';                
            end
            
            % OUTPUT FOR EXCEL FILE (DATASET COMPARISON)            
            if excel_ == 1
                obj.Excel_Table = Excel_Output_Branches();
                obj.Excel_Table.scenario(S);
                obj.Excel_Table.grid(G);
                obj.Excel_Table.compare_datasets(obj,table_results);                
                excel_results.sheet1 = obj.Excel_Table.Sheet.Sheet1; % summary
                excel_results.sheet2 = obj.Excel_Table.Sheet.Sheet2; % load infeed
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
               
                % TABLE_RESULTS > GRIDSUMMARY_FULL 
                % TABLE_RESULTS > GRIDSUMMARY_SHORT
                for i = 1 : 4
                    input_results.Summary2 = input_results.Summary;
                    input_results.Summary2(input_results.Summary2(:,i)==0,i) = NaN;
                    table_results.GridSummary_Full(:,G,i) = input_results.Summary(:,i);
                    if i >= 2 % If percent values are calculated or if nodes are observed
                        table_results.GridSummary_Short(G,i,:) = ...
                            [max(input_results.Summary2(:,i)),min(input_results.Summary2(:,i)),...
                            nanmean(input_results.Summary2(:,i)),...
                            NaN]; % we cannot sum percent values or number of nodes affected
                    else
                        table_results.GridSummary_Short(G,i,:) = ...
                            [max(input_results.Summary2(:,i)),min(input_results.Summary2(:,i)),...
                            nanmean(input_results.Summary2(:,i)),nansum(input_results.Summary2(:,i))];
                    end
                end
     
                % table_results.GridSummary_full 
                % 1dim is dataset(:), 2dim is G, 3dim is value 
                %  (1-number of viol., 2-viol in %, 3-nodes affected, 4-nodes affected in %)
                % table_results.GridSummary_short 
                % 1dim is G, 2dim is observation 
                %  (1-number of viol., 2-viol in %, 3-branches affected, 4-branches affected in %)
                % 3dim is value 
                %  (1-max, 2-min, 3-mean, 4-sum) 
                
                % TABLE RESULTS > GRIDHISTOGRAM_VIOLATIONS
                % TABLE RESULTS > GRIDHISTOGRAM_VIOLATIONS_AT_NODES
                % TABLE RESULTS > NODEHISTOGRAM_VIOLATIONS                                
                table_results.GridHistogram_Violations(:,G) = ...
                    input_results.Summary(:,obj.x_axis_value);                
                table_results.GridHistogram_Violations_at_Branches(:,G) = ...
                    input_results.Summary(:,obj.x_axis_value+2);                
                table_results.BranchHistogram_Violations{G} = ...
                    input_results.BranchHistogram_Violations;
                % 1 dim is dataset, 2dim is grid
            end  
            
            % OUTPUT FOR EXCEL FILE (DATASET COMPARISON)
            if excel_ == 1
                obj.Excel_Table = Excel_Output_Branches();
                obj.Excel_Table.scenario(S);                 
                obj.Excel_Table.compare_grids(obj,table_results);                   
                excel_results.sheet1 = obj.Excel_Table.Sheet.Sheet1; % grid summary
                excel_results.sheet2 = obj.Excel_Table.Sheet.Sheet2; % grid summary expended
            else
                excel_results.sheet1 = [];
                excel_results.sheet2 = [];
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
                % TABLE RESULTS > COMPLETESUMMARY_FULL
                % TABLE RESULTS > COMPLETESUMMARY_SHORT
                table_results.CompleteSummary_Full(:,S,:,:) = input_results.GridSummary_Full;
                table_results.CompleteSummary_Short(S,:,:,:) = input_results.GridSummary_Short;

                table_results.ScenarioGridHistogram_Violations(:,:,S) = input_results.GridHistogram_Violations;
                table_results.ScenarioGridHistogram_Violations_at_Branches(:,:,S) = input_results.GridHistogram_Violations_at_Branches;                
                table_results.ScenarioNodeHistogram_Violations(S,:) = input_results.BranchHistogram_Violations;
                
                xls_results.(['S_', int2str(S)]).ScenarioGridHistogram_Violations = ...
                    table_results.ScenarioGridHistogram_Violations;
                xls_results.(['S_', int2str(S)]).ScenarioGridHistogram_Violations_at_Branches = ...
                    table_results.ScenarioGridHistogram_Violations_at_Branches;
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
                obj.Excel_Table = Excel_Output_Branches();
                obj.Excel_Table.compare_grids_all_scenarios(obj,xls_results);                   
                excel_results.sheet1 = obj.Excel_Table.Sheet.Sheet1; % gridscen_summary
                excel_results.sheet2 = obj.Excel_Table.Sheet.Sheet2; % gridscen_summary comparison
            else
                excel_results.sheet1 = [];
                excel_results.sheet2 = [];
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
            table_results.branch_violations = input_results.Summary(:,obj.x_axis_value);
            table_results.branches_violated = input_results.Summary(:,obj.x_axis_value+2);
            
            % Check if violations are present at datasets
            if sum(abs(table_results.branch_violations)) == 0
                disp(' No branch violations at any dataset ');
                return; % Cancel display_datasets function if no violations occur
            end
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Branches;
            % Define scenario and grid
            obj.Graph_Data.scenario(S);
            obj.Graph_Data.grid(G);            
            % Plot horizontal bar graph
            obj.Graph_Data.display_datasets(obj, table_results.branch_violations,table_results.branches_violated);
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
            
            table_results.summary_violations = ...
                squeeze(input_results.GridSummary_Short(:,obj.x_axis_value,1:3));
            table_results.summary_nodes = ...
                squeeze(input_results.GridSummary_Short(:,obj.x_axis_value+2,1:3));
            % row is the grid observed, and the columns are : max value, min
            % value and mean value
            
            % Check if violations are present at grids
            if nansum(abs(table_results.summary_violations(:))) == 0 
                disp(' No branch violations at any grid ');
                return; % Cancel display_datasets function if no violations occur
            end
            
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Branches;
            % Define scenario and grid
            obj.Graph_Data.scenario(S);
            % Plot horizontal bar graph
            obj.Graph_Data.display_grids(obj, table_results.summary_violations,table_results.summary_nodes);
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
            for i = 1 : 3 % max, min, mean
                table_results.summary_violations_all{i} = squeeze(input_results.CompleteSummary_Short(:,:,obj.x_axis_value,i))';
                table_results.summary_node_all{i} = squeeze(input_results.CompleteSummary_Short(:,:,obj.x_axis_value+2,i))';
            end
            
            if sum(abs(table_results.summary_node_all{1}(:))) == 0
                disp(' No branch violations at any grid and scenario ');
                return; % Cancel display_datasets function if no violations occur
            end
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Branches;
            % Plot horizontal bar graph
            obj.Graph_Data.display_grids_all_scenarios(obj,...
                table_results.summary_violations_all,table_results.summary_node_all);
                    
        end
        % function display_grids_and_scenarios
        
        function [table_results,excel_results] = display_branch_values(obj,varargin)
            % display_node_voltage function creates a result table
            %for specifid S,G,D,B and include the branch
            % analysis results and limits
            
            % Check input varargin
            [S,G,D,B,excel_] = input_check(5,4,varargin); % Scenario, excel_output
            
            if obj.Simulation_Options.Save_Branch_Results ~=1
                error('No branch values saved during simulation. To display branches, values must be saved.');
                return
            end
            
             % Load results from .mat files
            [Result, Grid, ~] = obj.Result_Files.load(S);            

            % Node_Voltages are a 4D array, where 1st dim. are datasets,
            % 2nd the timepoints, 3rd are the nodes, and 4th are the phases
            % ---------------------------------------
            % §§table_results: timeplot: Voltages at Scenario S, Grid G, dataset D
            % and node N for L1, L2, L3 in p.u. Display includes the
            % voltage violations (1=yes, 0=no) and upper and lower limits
            table_results.timeplot_for_branches.id_scen = obj.Scenarios{S};
            table_results.timeplot_for_branches.id_grid = obj.Grid_Variants{G};
            table_results.timeplot_for_branches.id_dataset = D;
            table_results.timeplot_for_branches.id_branch = B;
            %-------------------------------------------------------------
            % Values saved in Branch_Values - W, VAr, VA and A: [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie]
            % (4 values per phase and phase-ground)
            Itherm = vertcat(Grid.(obj.Grid_Variants{G}).Branches.Grouped.Current_Limits);
            Stherm = vertcat(Grid.(obj.Grid_Variants{G}).Branches.Grouped.App_Power_Limits);
            table_results.timeplot_for_branches.Itherm = repmat(Itherm(B,1),obj.Timepoints,1);
            table_results.timeplot_for_branches.Stherm = repmat(Stherm(B,1),obj.Timepoints,1);
            table_results.timeplot_for_branches.currents = ...
                squeeze(Result.(obj.Grid_Variants{G}).Branch_Values(D,:,B,[4:4:12])); % Currents for L1, L2, L3
            table_results.timeplot_for_branches.app_power = ...
                squeeze(Result.(obj.Grid_Variants{G}).Branch_Values(D,:,B,[3:4:12])); % S for L1, L2, L3
            table_results.timeplot_for_branches.act_power = ...
                squeeze(Result.(obj.Grid_Variants{G}).Branch_Values(D,:,B,[1:4:12])); % P for L1, L2, L3
            table_results.timeplot_for_branches.react_power = ...
                squeeze(Result.(obj.Grid_Variants{G}).Branch_Values(D,:,B,[2:4:12])); % Q for L1, L2, L3
                        
            table_results.timeplot_for_branches.branch_violations = ...
                squeeze(Result.(obj.Grid_Variants{G}).Branch_Violation_Analysis(D,:,B))';
            
            % Currents
            table_results.graph_values = [...
                table_results.timeplot_for_branches.currents,...
                table_results.timeplot_for_branches.Itherm,...
                table_results.timeplot_for_branches.branch_violations];
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Branches;
            obj.Graph_Data.scenario(S);
            obj.Graph_Data.grid(G);
            obj.Graph_Data.dataset(D);
            obj.Graph_Data.branch(Grid.(obj.Grid_Variants{G}).Branches.Grouped(B).Branch_Name);
            % Plot horizontal bar graph
            obj.Graph_Data.display_branch_values(obj,table_results.graph_values);
 
            % OUTPUT FOR EXCEL FILE
            if excel_ == 1
                obj.Excel_Table = Excel_Output_Branches();
                obj.Excel_Table.scenario(S);
                obj.Excel_Table.grid(G);
                obj.Excel_Table.dataset(D);
                obj.Excel_Table.branch(Grid.(obj.Grid_Variants{G}).Branches.Grouped(B).Branch_Name);
                
                obj.Excel_Table.display_branch_values(obj,table_results.graph_values);
                excel_results.sheet1 = obj.Excel_Table.Sheet.Sheet1; % voltage_over_time
            else
                excel_results.sheet1 = [];
            end
        end
        % function display_branch_values
      

        function histogram_comparisons_grids_at_scenario(obj,varargin)
            % histogram_comparisons_grids_at_scenario for the S scenario
            
            % Check input varargin
            [S, nan_] = input_check_hist(2,1,varargin); % Scenario, grid, excel_output
            
            % Load results from .mat files
            [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(S);
            
            table_results.Branch_violations = [];
            for G = 1 : numel(obj.Grid_Variants)
                if obj.x_axis_value == 2
                    table_results.Branch_violations(:,G) = Result.(obj.Grid_Variants{G}).Branch_Violation_Summary.Number_of_Violations_percent;
                elseif obj.x_axis_value == 1
                    table_results.Branch_violations(:,G) = Result.(obj.Grid_Variants{G}).Branch_Violation_Summary.Number_of_Violations;
                end
            end
            
            if nan_ == 1
                table_results.Branch_violations(table_results.Branch_violations==0) = NaN;
                if sum(isnan(table_results.Branch_violations(:))) == numel(table_results.Branch_violations)
                    disp('No branch violations at any grid for the selected scenario');
                    return
                end
            else
                if sum(abs(table_results.Branch_violations(:))) == 0
                    disp('No branch violations at any grid for the selected scenario');
                    return
                end
            end
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Branches;
            % Define scenario and grid
            obj.Graph_Data.scenario(S);            
            obj.Graph_Data.histogram_comparisons_grids_at_scenario(obj,table_results.Branch_violations);
        end
        % function histogram_comparisons_grids_at_scenario
        
        function histogram_comparisons_scenarios_at_grid(obj,varargin)
            [G,nan_] = input_check_hist(2,1,varargin); % Scenario, grid, excel_output
            
            % Load grid results for scenario S
            % Load relevent data from mat file (scenario S, grid G)
            table_results.Branch_violations = [];     
            
            for S = 1 : numel(obj.Scenarios)
                % Load results from .mat files
                [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(S);
                if obj.x_axis_value == 2
                    table_results.Branch_violations(:,S) = Result.(obj.Grid_Variants{G}).Branch_Violation_Summary.Number_of_Violations_percent;
                elseif obj.x_axis_value == 1
                    table_results.Branch_violations(:,S) = Result.(obj.Grid_Variants{G}).Branch_Violation_Summary.Number_of_Violations;
                end
            end
            if nan_ == 1
                table_results.Branch_violations(table_results.Branch_violations==0) = NaN;
                if sum(isnan(table_results.Branch_violations(:))) == numel(table_results.Branch_violations)
                    disp('No branch violations at any scenario for the selected grid');
                    return
                end
            else
                if sum(abs(table_results.Branch_violations(:))) == 0
                    disp('No branch violations at any scenario for the selected grid');
                    return
                end
            end
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Branches;
            % Define scenario and grid
            obj.Graph_Data.grid(G);
            obj.Graph_Data.histogram_comparisons_scenarios_at_grid(obj,table_results.Branch_violations);
            
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

