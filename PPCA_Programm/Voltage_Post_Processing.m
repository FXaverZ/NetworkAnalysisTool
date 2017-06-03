classdef Voltage_Post_Processing
% VOLTAGE_POST_PROCESSING    Voltage violation post processing  class
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
        function obj = Voltage_Post_Processing(information_file)
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
            
             % Load voltage violation results
            if obj.Simulation_Options.Voltage_Violation_Analysis               
                Voltage_Violation_Summary = Result.(obj.Grid_Variants{G}).Voltage_Violation_Summary;
                Voltage_Violation_Analysis = Result.(obj.Grid_Variants{G}).Voltage_Violation_Analysis;
            end
            % Load saved voltage results
            if obj.Simulation_Options.Save_Voltage_Results
                Node_Voltages = Result.(obj.Grid_Variants{G}).Node_Voltages;
            end
            
            % TABLE_RESULTS > SUMMARY : A summary of voltage violations
            table_results.Summary = [...
                Voltage_Violation_Summary.Number_of_Violations,...
                Voltage_Violation_Summary.Number_of_Violations_percent,...
                Voltage_Violation_Summary.Number_of_Nodes_With_Violations,...
                Voltage_Violation_Summary.Number_of_Nodes_With_Violations_percent,...
                ];
            
            % TABLE_RESULTS > VIOLATED_NODES : A list of nodes where
            % violations occured for each dataset   
            table_results.Violated_nodes = cell(obj.Datasets,...
                max(Voltage_Violation_Summary.Number_of_Nodes_With_Violations(:)));
            % Preallocation of cell array
            for cd = 1 : obj.Datasets
                if ~isempty(Voltage_Violation_Summary.Names_of_Nodes_With_Violations{cd,1})
                    table_results.Violated_nodes(...
                        cd,1:size(Voltage_Violation_Summary.Names_of_Nodes_With_Violations{cd,1},2)) = ...
                            sort(Voltage_Violation_Summary.Names_of_Nodes_With_Violations{cd,1});
                end
            end
            
            % TABLE_RESULTS > VOLTAGE_STATISTICS : Voltage value analysis
            if obj.Simulation_Options.Save_Voltage_Results == 1
                % Define rated voltages (PE)
                Unom_pe = vertcat(Grid.(obj.Grid_Variants{G}).All_Node.Points.Rated_Voltage_phase_earth);
                Unom_pe = Unom_pe(:,1)';
                Unom_pe = repmat(Unom_pe, obj.Timepoints,1);                
                % Preallocate table_results.Voltage_statistics
                table_results.Voltage_statistics = zeros(obj.Datasets,5);
                for cd = 1 : obj.Datasets
                    clear id_* idn
                    % Values must be in p.u. for max and min search                    
                    Node_voltages_L1pu = squeeze(Node_Voltages(cd,:,:,1)) ./ Unom_pe;
                    Node_voltages_L1pu(Node_voltages_L1pu == 0)= NaN;
                    Node_voltages_L2pu = squeeze(Node_Voltages(cd,:,:,2)) ./ Unom_pe;
                    Node_voltages_L1pu(Node_voltages_L2pu == 0)= NaN;
                    Node_voltages_L3pu = squeeze(Node_Voltages(cd,:,:,3)) ./ Unom_pe;
                    Node_voltages_L1pu(Node_voltages_L3pu == 0)= NaN;
                    % Max value
                    [table_results.Voltage_statistics(cd,1),id_max] = ...
                        max([max(Node_voltages_L1pu(:)),max(Node_voltages_L2pu(:)),max(Node_voltages_L3pu(:))]);
                    % Min value
                    [table_results.Voltage_statistics(cd,2),id_min] = ...
                        min([min(Node_voltages_L1pu(:)),min(Node_voltages_L2pu(:)),min(Node_voltages_L3pu(:))]);
                    % Mean value
                    table_results.Voltage_statistics(cd,4) = ...
                        nanmean(reshape([Node_voltages_L1pu,Node_voltages_L2pu,Node_voltages_L3pu],[],1)); 
                    % Std value
                    table_results.Voltage_statistics(cd,5) = ...
                        nanstd(reshape([Node_voltages_L1pu,Node_voltages_L2pu,Node_voltages_L3pu],[],1));
                    % Max Upp difference calculation
                    [table_results.Voltage_statistics(cd,3),id_upp_max] = ...
                        max( [max(abs(Node_voltages_L1pu(:) - Node_voltages_L2pu(:))),...
                              max(abs(Node_voltages_L1pu(:) - Node_voltages_L3pu(:))),...
                              max(abs(Node_voltages_L2pu(:) - Node_voltages_L3pu(:)))] );
                    % Max value at node
                    search_for_extreme_val_nodes = []; idn = [];
                    eval(['search_for_extreme_val_nodes = Node_voltages_L', int2str(id_max) ,'pu;']);
                    idn =  max(search_for_extreme_val_nodes,[],1) == table_results.Voltage_statistics(cd,1);
                    table_results.Voltage_statistics_at_Node{cd,1} = Grid.(obj.Grid_Variants{G}).All_Node.Points(idn).Node_Name;
                    % Min value at node
                    search_for_extreme_val_nodes = []; idn = [];
                    eval(['search_for_extreme_val_nodes = Node_voltages_L', int2str(id_min) ,'pu;']);
                    idn =  min(search_for_extreme_val_nodes,[],1) == table_results.Voltage_statistics(cd,2);
                    table_results.Voltage_statistics_at_Node{cd,2} = Grid.(obj.Grid_Variants{G}).All_Node.Points(idn).Node_Name;
                    % Max upp difference at node
                    idn = [];
                    if id_upp_max == 1 % L1-L2
                        idn = find(max(abs(Node_voltages_L1pu-Node_voltages_L2pu)) == table_results.Voltage_statistics(cd,3));
                    elseif id_upp_max == 2 % L1-L3
                        idn = find(max(abs(Node_voltages_L1pu-Node_voltages_L3pu)) == table_results.Voltage_statistics(cd,3));
                    elseif id_upp_max == 3 % L2-L3
                        idn = find(max(abs(Node_voltages_L2pu-Node_voltages_L3pu)) == table_results.Voltage_statistics(cd,3));
                    end
                    table_results.Voltage_statistics_at_Node{cd,3} = Grid.(obj.Grid_Variants{G}).All_Node.Points(idn).Node_Name;
                end                
                clear id_* idn Node_voltages_L* search_for_extreme_val_nodes Unom_pe
            else
                table_results.Voltage_statistics = [];
                table_results.Voltage_statistics_at_Node = [];
            end
            
            % TABLE_RESULTS > NODEHISTOGRAM_VIOLATIONS : Number of
            % violations at each node
            for cd = 1 : obj.Datasets
                table_results.NodeHistogram_Violations(cd,:) = ...
                    nansum(squeeze(Voltage_Violation_Analysis(cd,:,:)),1);
            end
            if obj.x_axis_value == 2
                table_results.NodeHistogram_Violations = 100*table_results.NodeHistogram_Violations/obj.Timepoints;
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
                pliv.timepoints = find(sum(squeeze(Voltage_Violation_Analysis(cd,:,:)) == 1,2) > 0);
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
                obj.Excel_Table = Excel_Output_Voltages();
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
                %  (1-number of viol., 2-viol in %, 3-nodes affected, 4-nodes affected in %)
                % 3dim is value 
                %  (1-max, 2-min, 3-mean, 4-sum) 

                % TABLE RESULTS > GRIDVOLTAGE_STATISTICS
                % TABLE_RESULTS > GRIDVOLTAGE_STATISTICS_AT_NODE                
                if obj.Simulation_Options.Save_Voltage_Results == 1
                    maxGv=[]; id_maxGv=[]; minGv=[];
                    id_minGv=[]; maxGUpp=[]; id_maxGUpp=[];
                    
                    [maxGv,id_maxGv] = max(input_results.Voltage_statistics(:,1));
                    [minGv,id_minGv] =  min(input_results.Voltage_statistics(:,2));
                    [maxGUpp,id_maxGUpp] = max(input_results.Voltage_statistics(:,3));
                    
                    table_results.GridVoltage_statistics(G,:) = [...
                        maxGv, minGv,maxGUpp,...
                        mean(input_results.Voltage_statistics(:,4)),...
                        mean(input_results.Voltage_statistics(:,5))];
                    
                    table_results.GridVoltage_statistics_at_Node{G,1} = ...
                        input_results.Voltage_statistics_at_Node{id_maxGv,1};
                    table_results.GridVoltage_statistics_at_Node{G,2} = ...
                        input_results.Voltage_statistics_at_Node{id_minGv,2};
                    table_results.GridVoltage_statistics_at_Node{G,3} = ...
                        input_results.Voltage_statistics_at_Node{id_maxGUpp,3};
                    
                    for i = 1 : size(input_results.Voltage_statistics_at_Node,2)
                        unique_node = []; all_nodes = [];
                        unique_node = unique(input_results.Voltage_statistics_at_Node(:,i));
                        all_nodes = input_results.Voltage_statistics_at_Node(:,i);
                        number_of_occurances_at_node = zeros(numel(unique_node),1);
                        for j = 1 : numel(unique_node)
                            number_of_occurances_at_node(j,1) = ...
                                sum(strcmp(all_nodes,unique_node{j,1}));
                        end
                        table_results.GridVoltage_statistics_at_Node{G,3+i} = ...
                            unique_node(number_of_occurances_at_node == max(number_of_occurances_at_node));
                    end
                else
                    table_results.GridVoltage_statistics = [];
                    table_results.GridVoltage_statistics_at_Node = [];
                end
                clear maxGUpp maxGv minGv id_minGv id_maxGv id_maxGUpp
                clear number_of_occurances_at_node unique_node all_nodes i j
                % table_results.GridVoltage_statistics 
                % 1dim is G, 2dim is value
                %  (1-max at all datasets, 2-min at all datasets, 
                %   3-max Upp at all datasets, 4-mean voltage, 5-mean std voltage)
                
                % table_results.GridVoltage_statistics_at_Node 
                % 1dim is G, 2dim is node where extreme value occurs
                %  (1-max at all datasets, 2-min at all datasets, 
                %   3-max Upp at all datasets, 4-most common node(s) 
                %   where max voltages occur, 5-most common node(s) 
                %   where min voltages occur, 6-most common node(s) 
                %   where max Upp diff. occur
                
                % TABLE RESULTS > GRIDHISTOGRAM_VIOLATIONS
                % TABLE RESULTS > GRIDHISTOGRAM_VIOLATIONS_AT_NODES
                % TABLE RESULTS > NODEHISTOGRAM_VIOLATIONS                                
                table_results.GridHistogram_Violations(:,G) = ...
                    input_results.Summary(:,obj.x_axis_value);                
                table_results.GridHistogram_Violations_at_Nodes(:,G) = ...
                    input_results.Summary(:,obj.x_axis_value+2);                
                table_results.NodeHistogram_Violations{G} = ...
                    input_results.NodeHistogram_Violations;
                % 1 dim is dataset, 2dim is grid
            end  
            
            % OUTPUT FOR EXCEL FILE (DATASET COMPARISON)
            if excel_ == 1
                obj.Excel_Table = Excel_Output_Voltages();
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
                table_results.CompleteVoltage_statistics(S,:,:) = input_results.GridVoltage_statistics;
                table_results.CompleteVoltage_statistics_at_Node(S,:,:) = input_results.GridVoltage_statistics_at_Node;

                table_results.ScenarioGridHistogram_Violations(:,:,S) = input_results.GridHistogram_Violations;
                table_results.ScenarioGridHistogram_Violations_at_Nodes(:,:,S) = input_results.GridHistogram_Violations_at_Nodes;                
                table_results.ScenarioNodeHistogram_Violations(S,:) = input_results.NodeHistogram_Violations;
                
                xls_results.(['S_', int2str(S)]).ScenarioGridHistogram_Violations = ...
                    table_results.ScenarioGridHistogram_Violations;
                xls_results.(['S_', int2str(S)]).ScenarioGridHistogram_Violations_at_Nodes = ...
                    table_results.ScenarioGridHistogram_Violations_at_Nodes;
                % table_results.CompleteSummary_Full (1dim is dataset, 2dim
                % is S, 3dim is G, 4dim is value
                %   (1-number of viol., 2-viol in %, 3-nodes affected,
                %   4-nodes affected in %
                                
                % table_results.CompleteSummary_Short (1dim is scenario,
                % 2dim is G, 3dim is (1-numb. of viol., 2-viol in %,
                % 3-nodes affected, 4-nodes affected in %), 4dim is value
                %   (1-max value, 2-min value, 3-mean value, 4-sum value)
                
                % table_results.CompleteVoltage_statistics (1dim is S, 2dim
                % is G, 3dim is observation (1-max voltage in all sets for
                % G, 2-min, 3-max Upp, 4-mean voltage in all sets for G,
                % 5-std)
                  
                % table_results.GridVoltage_statistics_at_Node (1dim is S,
                % 2dim is G, 3dim is node where extreme value occurs 
                %   (1-node with max voltage in all sets for G, 2-node with
                %   min voltage, 3-node with max Upp diff., 4-most common
                %   node where max voltages occur, 5-most common node where
                %   min voltages occur, 6-most common node where max Upp
                %   diff occur)
                
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
                obj.Excel_Table = Excel_Output_Voltages();
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
            table_results.voltage_violations = input_results.Summary(:,obj.x_axis_value);
            table_results.nodes_violated = input_results.Summary(:,obj.x_axis_value+2);
            
            % Check if violations are present at datasets
            if sum(abs(table_results.voltage_violations)) == 0
                disp(' No voltage violations at any dataset ');
                return; % Cancel display_datasets function if no violations occur
            end
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Voltages;
            % Define scenario and grid
            obj.Graph_Data.scenario(S);
            obj.Graph_Data.grid(G);            
            % Plot horizontal bar graph
            obj.Graph_Data.display_datasets(obj, table_results.voltage_violations,table_results.nodes_violated);
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
                disp(' No voltage violations at any grid ');
                return; % Cancel display_datasets function if no violations occur
            end
            
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Voltages;
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
                disp(' No voltage violations at any grid and scenario ');
                return; % Cancel display_datasets function if no violations occur
            end
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Voltages;
            % Plot horizontal bar graph
            obj.Graph_Data.display_grids_all_scenarios(obj,...
                table_results.summary_violations_all,table_results.summary_node_all);
                    
        end
        % function display_grids_and_scenarios
        
        function [table_results,excel_results] = display_node_voltage(obj,varargin)
            % display_node_voltage function creates a result table
            %for specifid S,G,D,N and include the voltage
            % analysis results and limits
            
            % Check input varargin
            [S,G,D,N,excel_] = input_check(5,4,varargin); % Scenario, excel_output
            
            if obj.Simulation_Options.Save_Voltage_Results ~=1
                error('No voltages saved during simulation. To display voltages values must be saved.');
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
            table_results.timeplot_for_node.id_scen = obj.Scenarios{S};
            table_results.timeplot_for_node.id_grid = obj.Grid_Variants{G};
            table_results.timeplot_for_node.id_dataset = D;
            table_results.timeplot_for_node.id_node = N;
            
            rated_voltages_pe = vertcat(Grid.(obj.Grid_Variants{G}).All_Node.Points.Rated_Voltage_phase_earth);
            all_voltage_limits = vertcat(Grid.(obj.Grid_Variants{G}).All_Node.Points.Voltage_Limits)/100;
            table_results.timeplot_for_node.voltage_limits_uul = repmat(all_voltage_limits(N,1),obj.Timepoints,1);
            table_results.timeplot_for_node.voltage_limits_ull = repmat(all_voltage_limits(N,2),obj.Timepoints,1);
            table_results.timeplot_for_node.voltages = ...
                squeeze(Result.(obj.Grid_Variants{G}).Node_Voltages(D,:,N,:))./...
                repmat(rated_voltages_pe(N,:),obj.Timepoints,1);
            table_results.timeplot_for_node.voltage_violations = ...
                squeeze(Result.(obj.Grid_Variants{G}).Voltage_Violation_Analysis(D,:,N))';
            table_results.graph_values = [...
                table_results.timeplot_for_node.voltages,...
                table_results.timeplot_for_node.voltage_limits_uul,...
                table_results.timeplot_for_node.voltage_limits_ull,...
                table_results.timeplot_for_node.voltage_violations];
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Voltages;
            obj.Graph_Data.scenario(S);
            obj.Graph_Data.grid(G);
            obj.Graph_Data.dataset(D);
            obj.Graph_Data.node(Grid.(obj.Grid_Variants{G}).All_Node.Points(N).Node_Name);
            % Plot horizontal bar graph
            obj.Graph_Data.display_node_voltage(obj,table_results.graph_values);
 
            % OUTPUT FOR EXCEL FILE
            if excel_ == 1
                obj.Excel_Table = Excel_Output_Voltages();
                obj.Excel_Table.scenario(S);
                obj.Excel_Table.grid(G);
                obj.Excel_Table.dataset(D);
                obj.Excel_Table.node(Grid.(obj.Grid_Variants{G}).All_Node.Points(N).Node_Name);
                
                obj.Excel_Table.display_node_voltage(obj,table_results.graph_values);
                excel_results.sheet1 = obj.Excel_Table.Sheet.Sheet1; % voltage_over_time
            else
                excel_results.sheet1 = [];
            end
        end
        % function display_node_voltage
        
        function [table_results] = display_node_variations_datasets(obj,varargin)
            %Function Display node variations displays the variations of
            %nodes for - G,S,D, all timepoints
            % If the user wants to analyse all datasets instead of just
            % one, the third input should be set to 'all'
            [S,G,D,plot_] = input_check_plot(obj, 4,3, varargin);
            
            if obj.Simulation_Options.Save_Voltage_Results ~=1
                error('No voltages saved during simulation, can not plot');
                return
            end
            
            % Load results from .mat files
            [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(S);  
            
            % Define rated voltages
            rated_voltages_pe = vertcat(Grid.(obj.Grid_Variants{G}).All_Node.Points.Rated_Voltage_phase_earth);
            % Write all voltages for all nodes at all timepoints, cells define phases
            table_results.voltages_at_timepoints{1} = nan( obj.Timepoints * numel(D),size(rated_voltages_pe,1) );
            table_results.voltages_at_timepoints{2} = table_results.voltages_at_timepoints{1};
            table_results.voltages_at_timepoints{3} = table_results.voltages_at_timepoints{1};
            
            for j = 1 : numel(D)
                for i = 1 : 3
                    table_results.voltages_at_timepoints{i}(obj.Timepoints*(j-1) + (1:obj.Timepoints),:) = ...
                        squeeze(Result.(obj.Grid_Variants{G}).Node_Voltages(D(j),:,:,i))./repmat( rated_voltages_pe(:,i)',obj.Timepoints,1);
                end
            end            
            for i = 1 : 3
                % 1st dimension are the ndoes, 2nd dim. is max, min, mean
                % cell location is phase
                table_results.voltageplot_for_nodes{i} = ...
                    [max(table_results.voltages_at_timepoints{i},[],1);
                     min(table_results.voltages_at_timepoints{i},[],1);
                     nanmean(table_results.voltages_at_timepoints{i},1)]';
            end
            % §§ table_results.voltageplot_for_nodes
            % Cells are the phases
            % 1st column are max values of voltages at node (row), 
            % 2nd column are the min values
            % 3rd column are the mean values
            if plot_ == 1
                % Create Graph definition object
                obj.Graph_Data = Graph_Definition_Voltages;
                % Define scenario and grid
                obj.Graph_Data.scenario(S);
                obj.Graph_Data.grid(G);
                obj.Graph_Data.dataset(D);
                % Plot horizontal bar graph
                obj.Graph_Data.display_node_variations_datasets(obj, table_results.voltageplot_for_nodes);
            end
        end
        % function display_node_variations_datasets
        
        function [table_results] = display_node_variations_scenarios(obj,varargin)
            % display_node_variations_scenarios displays voltage variations
            % for grid G and all datasets in all scenarios
            [G,plot_] = input_check_plot(obj,2,1, varargin);

            for S = 1 : numel(obj.Scenarios)
                table_input = [];
                table_input = obj.display_node_variations_datasets(S,G,'all') ;
                if S == 1
                    table_results.voltages_at_timepoints{1} = ...
                        nan(size(table_input.voltages_at_timepoints{1},1) * numel(obj.Scenarios),...
                        size(table_input.voltages_at_timepoints{1},2) );
                    table_results.voltages_at_timepoints{2} = ...
                        table_results.voltages_at_timepoints{1};
                    table_results.voltages_at_timepoints{3} = ...
                        table_results.voltages_at_timepoints{1};
                end                
                for i = 1 : 3
                    table_results.voltages_at_timepoints{i}(...
                        size(table_input.voltages_at_timepoints{1},1)*(S-1) +...
                        (1:size(table_input.voltages_at_timepoints{1},1)),:) = ...
                        table_input.voltages_at_timepoints{i};
                end
            end
            for i = 1 : 3
                % 1st dimension are the ndoes, 2nd dim. is max, min, mean
                % cell location is phase
                table_results.voltageplot_for_nodes{i} = ...
                    [max(table_results.voltages_at_timepoints{i},[],1);
                     min(table_results.voltages_at_timepoints{i},[],1);
                     nanmean(table_results.voltages_at_timepoints{i},1)]';
            end
            % §§ table_results.voltageplot_for_nodes
            % Cells are the phases
            % 1st column are max values of voltages at node (row), 
            % 2nd column are the min values
            % 3rd column are the mean values
            
            if plot_ == 1
                % Create Graph definition object
                obj.Graph_Data = Graph_Definition_Voltages;
                % Define scenario and grid
                obj.Graph_Data.grid(G);
                % Plot horizontal bar graph
                obj.Graph_Data.display_node_variations_scenarios(obj, table_results.voltageplot_for_nodes);
            end

            
        end
        % function display_node_variations_scenarios
        
        function [table_results] = display_node_variations_grids(obj,varargin)
            % Compare voltage variations for 
            % all grids for all scenarios and all datasets            
            plot_ = input_check_plot(obj,1,0, varargin);
            
            for G = 1 : numel(obj.Grid_Variants)
                table_input = [];
                table_input = obj.display_node_variations_scenarios(G);                
                table_results.voltageplot_for_nodes{G} = table_input.voltageplot_for_nodes;
                % Cell location is the grid
            end            
            if plot_ == 1
                % Create Graph definition object
                obj.Graph_Data = Graph_Definition_Voltages;
                obj.Graph_Data.display_node_variations_grids(obj,table_results.voltageplot_for_nodes);
            end
        end
        % function display_node_variations_grids

        function histogram_comparisons_grids_at_scenario(obj,varargin)
            % histogram_comparisons_grids_at_scenario for the S scenario
            
            % Check input varargin
            [S, nan_] = input_check_hist(2,1,varargin); % Scenario, grid, excel_output
            
            % Load results from .mat files
            [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(S);
            
            table_results.Voltage_violations = [];
            for G = 1 : numel(obj.Grid_Variants)
                if obj.x_axis_value == 2
                    table_results.Voltage_violations(:,G) = Result.(obj.Grid_Variants{G}).Voltage_Violation_Summary.Number_of_Violations_percent;
                elseif obj.x_axis_value == 1
                    table_results.Voltage_violations(:,G) = Result.(obj.Grid_Variants{G}).Voltage_Violation_Summary.Number_of_Violations;
                end
            end
            
            if nan_ == 1
                table_results.Voltage_violations(table_results.Voltage_violations==0) = NaN;
                if sum(isnan(table_results.Voltage_violations(:))) == numel(table_results.Voltage_violations)
                    disp('No voltage violations at any grid for the selected scenario');
                    return
                end
            else
                if sum(abs(table_results.Voltage_violations(:))) == 0
                    disp('No voltage violations at any grid for the selected scenario');
                    return
                end
            end
            
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Voltages;
            % Define scenario and grid
            obj.Graph_Data.scenario(S);            
            obj.Graph_Data.histogram_comparisons_grids_at_scenario(obj,table_results.Voltage_violations);
        end
        % function histogram_comparisons_grids_at_scenario
        
        function histogram_comparisons_scenarios_at_grid(obj,varargin)
            [G,nan_] = input_check_hist(2,1,varargin); % Scenario, grid, excel_output
            
            % Load grid results for scenario S
            % Load relevent data from mat file (scenario S, grid G)
            table_results.Voltage_violations = [];     
            
            for S = 1 : numel(obj.Scenarios)
                % Load results from .mat files
                [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(S);
                if obj.x_axis_value == 2
                    table_results.Voltage_violations(:,S) = Result.(obj.Grid_Variants{G}).Voltage_Violation_Summary.Number_of_Violations_percent;
                elseif obj.x_axis_value == 1
                    table_results.Voltage_violations(:,S) = Result.(obj.Grid_Variants{G}).Voltage_Violation_Summary.Number_of_Violations;
                end
            end
            if nan_ == 1
                table_results.Voltage_violations(table_results.Voltage_violations==0) = NaN;
                if sum(isnan(table_results.Voltage_violations(:))) == numel(table_results.Voltage_violations)
                    disp('No voltage violations at any scenario for the selected grid');
                    return
                end
            else
                if sum(abs(table_results.Voltage_violations(:))) == 0
                    disp('No voltage violations at any scenario for the selected grid');
                    return
                end
            end
            % Create Graph definition object
            obj.Graph_Data = Graph_Definition_Voltages;
            % Define scenario and grid
            obj.Graph_Data.grid(G);
            obj.Graph_Data.histogram_comparisons_scenarios_at_grid(obj,table_results.Voltage_violations);
            
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
           obj.Graph_Data = Graph_Definition_Voltages;
           % Define scenario and grid
           obj.Graph_Data.histogram_comparisons_inputs_at_scenarios(obj,table_results);
            
        end
        % function histogram_comparisons_inputs_at_scenarios
        
        
    end % methods
end % classdef

