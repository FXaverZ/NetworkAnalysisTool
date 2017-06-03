classdef Graph_Definition_Branches < handle    
    % EXCEL_OUTPUT    Voltage violation post processing  class
    % Version:                 1.0
    % Erstellt von:            Matej Rejc - 14.05.2013
    % Letzte Änderung durch:   Matej Rejc - 14.05.2013
    
    properties
        graph_;
    end
    properties(GetAccess = 'private')
        S; % Scenario
        G; % Grid
        B; % Node
        D; % Dataset
    end
    methods
        
        function obj = Graph_Definition_Branches()
            % Clear variables
        end
        
        function display_datasets(obj,ext_obj,input1,input2)

            % Define values for plotting
            graph_.branch_violations = flipdim(input1,1);   
            graph_.branches_violated = flipdim(input2,1);   
            
            % Axis text defined
            table_labels.datasets = [];
            for i = 1 : ext_obj.Datasets
                table_labels.y.datasets{i,1} = ['Set ' int2str(i)];
            end
            
            if ext_obj.x_axis_value == 2 % Percent
                table_labels.x.branch_violations = 'Branch violations in % of time for dataset';
                table_labels.x.branches_violated = 'Branches affected by thermal violations for dataset (% of all nodes)';
            else
                table_labels.x.branch_violations = 'Number of branch violations for dataset';
                table_labels.x.branches_violated = 'Number of branches affected by thermal violations for dataset';
            end
            % Dataset y tick
            table_labels.y.tick = 1;
            if ext_obj.Datasets > 10 && ext_obj.Datasets <= 20
                table_labels.y.tick = round(ext_obj.Datasets/5);
            elseif  ext_obj.Datasets > 20
                table_labels.y.tick = round(ext_obj.Datasets/10);
            end
            
            graph_.x.branch_violations = table_labels.x.branch_violations;
            graph_.x.branches_violated = table_labels.x.branches_violated;
            graph_.y.datasets = table_labels.y.datasets;
            
            graph_.y.tick = 1: table_labels.y.tick:ext_obj.Datasets;
            graph_.y.datasets = table_labels.y.datasets(graph_.y.tick);
            clear i
            
            % Plot the dataset comparisons for specific grid and specific scenario
            % input value defines the number of subplots
            myplot1 = plot_horizontal_bar(2);
            % datasets(input_values,axis,xlabel,ytick_numerical,ytick_text,scen,grid)
            myplot1 = myplot1.datasets(graph_.branch_violations, 1,...
                graph_.x.branch_violations,...
                graph_.y.tick,...
                graph_.y.datasets,...
                obj.S, obj.G);
            
            myplot1 = myplot1.datasets(graph_.branches_violated, 2,...
                graph_.x.branches_violated,...
                graph_.y.tick,...
                graph_.y.datasets);
        end
        
        function display_grids(obj,ext_obj,input1,input2)
        
            % Flip dimensions for barh (1 is on top, last dataset on bottom)
            graph_.summary_violations = flipdim(input1,1);
            graph_.summary_nodes = flipdim(input2,1);
            
            % Axis text defined
            table_labels.grids = [];
            for i = 1 : numel(ext_obj.Grid_Variants)
                table_labels.y.grids{i,1} = ext_obj.Grid_Variants{i};
            end     
            table_labels.y.grids = flipdim(table_labels.y.grids,1);
            if ext_obj.x_axis_value == 2 % Percent
                table_labels.x.summary_violations = 'Branch violations in % of time for dataset';
                table_labels.x.summary_nodes = 'Branches affected by thermal violations for dataset (% of all nodes)';
            else
                table_labels.x.summary_violations = 'Number of branch violations for dataset';
                table_labels.x.summary_nodes = 'Number of branches affected by thermal violations for dataset';
            end            
            % Dataset y tick
            table_labels.y.tick = 1;
            if numel(ext_obj.Grid_Variants) > 10 && numel(ext_obj.Grid_Variants) <= 20
                table_labels.y.tick = round(numel(ext_obj.Grid_Variants)/5);
            elseif  numel(ext_obj.Grid_Variants) > 20
                table_labels.y.tick = round(numel(ext_obj.Grid_Variants)/10);
            end            
            graph_.x.summary_violations = table_labels.x.summary_violations;
            graph_.x.summary_nodes = table_labels.x.summary_nodes;
            graph_.y.grids = table_labels.y.grids;
            graph_.y.tick = 1: table_labels.y.tick:numel(ext_obj.Grid_Variants);
            graph_.y.grids = table_labels.y.grids(graph_.y.tick);            
            graph_.legend{1} = 'Max';
            graph_.legend{2} = 'Min';
            graph_.legend{3} = 'Mean';
            
            myplot1 = plot_horizontal_bar(2);            
            % grid(input_values,axis,xlabel,ytick_numerical,ytick_text,scen,grid)
            myplot1 = myplot1.grids(graph_.summary_violations, 1,...
                graph_.x.summary_violations,...
                graph_.y.tick,...
                graph_.y.grids,...
                obj.S,...
                graph_.legend);
            
            myplot1 = myplot1.grids(graph_.summary_violations, 2,...
                graph_.x.summary_nodes,...
                graph_.y.tick,...
                graph_.y.grids);        
        end
        
        function display_grids_all_scenarios(obj,ext_obj,input1,input2)
            
            % Flip dimensions for barh (1 is on top, last dataset on bottom)
            for i = 1 : 3 % Max, min, mean
                graph_.summary_violations{i} = flipdim(input1{i},1);
                graph_.summary_nodes{i} = flipdim(input2{i},1);
            end
            
            % Axis text defined
            table_labels.grids = [];
            for i = 1 : numel(ext_obj.Grid_Variants)
                table_labels.y.grids{i,1} = ext_obj.Grid_Variants{i};
            end
            table_labels.y.grids = flipdim(table_labels.y.grids,1);
            
            if ext_obj.x_axis_value == 2 % Percent
                table_labels.x.summary_violations = 'Branch violations in % of time for dataset';
                table_labels.x.summary_nodes = 'Branches affected by thernal violations for dataset (% of all nodes)';
            else
                table_labels.x.summary_violations = 'Number of branch violations for dataset';
                table_labels.x.summary_nodes = 'Number of branches affected by thermal violations for dataset';
            end
            
            % Dataset y tick
            table_labels.y.tick = 1;
            if numel(ext_obj.Grid_Variants) > 10  && numel(ext_obj.Grid_Variants) <= 20
                table_labels.y.tick = round(numel(ext_obj.Grid_Variants)/5);
            elseif  numel(ext_obj.Grid_Variants) > 20
                table_labels.y.tick = round(numel(ext_obj.Grid_Variants)/10);
            end
            
            graph_.x.summary_violations = table_labels.x.summary_violations;
            graph_.x.summary_nodes = table_labels.x.summary_nodes;
            graph_.y.grids = table_labels.y.grids;
            
            graph_.y.tick = 1: table_labels.y.tick:numel(ext_obj.Grid_Variants);
            graph_.y.grids = table_labels.y.grids(graph_.y.tick);
            
            for i = 1 : numel(ext_obj.Scenarios)
                graph_.legend{i} = ext_obj.Scenarios{i};
            end
            
            graph_.title{1} = 'Max calculated values for all observed timepoints, grids and all scenarios';
            graph_.title{2} = 'Min calculated values for all observed timepoints, grids and all scenarios';
            graph_.title{3} = 'Mean calculated values for all observed timepoints, grids and all scenarios';
            
            for i = 1 : 3
                myplot1 = plot_horizontal_bar(2);
                myplot1 = myplot1.grids_and_scenarios(...
                    graph_.summary_violations{i}, 1,...
                    graph_.x.summary_violations,...
                    graph_.y.tick,...
                    graph_.y.grids,...
                    graph_.title{i},...
                    graph_.legend);
                
                myplot1 = myplot1.grids_and_scenarios(...
                    graph_.summary_nodes{i}, 2,...
                    graph_.x.summary_nodes,...
                    graph_.y.tick,...
                    graph_.y.grids);
            end
        end
        
        function display_branch_values(obj,ext_obj,input)
  
            graph_.input = input;
            
            graph_.x.label = 'Timepoints';
            graph_.y.label = 'Currents (A)';
            graph_.title = ['Current for grid ', ext_obj.Grid_Variants{obj.G},...
                ', scenario ', ext_obj.Scenarios{obj.S}, ', dataset ', int2str(obj.D), ' and branch ',obj.B   ];
            graph_.legend{1} = 'L1'; graph_.legend{2} = 'L2'; graph_.legend{3} = 'L3';
            graph_.legend{4} = 'Thermal limit';
            graph_.legend{5} = 'Branch violation';
            
            % Line graph for voltages
            myplot1 = plot_line_graphs(1);
            % input: [L1,L2,L3, thermal_lim, bviolation]
            % xlabel, ylabel, title, legend
            myplot1.timeplot_for_branch(graph_.input,1, graph_.x.label,...
                graph_.y.label, graph_.title, graph_.legend);
        end
                
        function histogram_comparisons_grids_at_scenario(obj,ext_obj,input)
            graph_.input = input;
            graph_.Histogram_Limit = max(input(:));
            graph_.Bins = 20;
            if ext_obj.x_axis_value == 2
                graph_.x.label = 'Branch violations in % of observed timepoints for the observed scenario load profiles';
            elseif ext_obj.x_axis_value == 1
               graph_.x.label = 'Number of branch violations during observations for the observed scenario load profiles'; 
            end
            graph_.title = ['Histogram of branch violations for scenario ', ext_obj.Scenarios{obj.S}];
            
            myplot1 = plot_histograms(1,ext_obj.Grid_Variants,ext_obj.Scenarios);            
            myplot1.plot_histogram_grids_at_scenario(...
                 graph_.input,1,graph_.Bins,...
                 graph_.Histogram_Limit,...
                 graph_.x.label,...
                 graph_.title);            
        end
        
        function histogram_comparisons_scenarios_at_grid(obj,ext_obj,input)
            
            graph_.input = input;
            graph_.Histogram_Limit = max(input(:));
            graph_.Bins = 20;
            if ext_obj.x_axis_value == 2
                graph_.x.label = 'Branch violations in % of observed timepoints for the observed scenario load profiles';
            elseif ext_obj.x_axis_value == 1
                graph_.x.label = 'Number of branch violations during observations for the observed scenario load profiles';
            end
            graph_.title = ['Histogram of branch violations for grid ', ext_obj.Grid_Variants{obj.G}];
            
            myplot1 = plot_histograms(1,ext_obj.Grid_Variants,ext_obj.Scenarios);
            myplot1.plot_histogram_scenarios_at_grid(...
                graph_.input,1,graph_.Bins,...
                graph_.Histogram_Limit,...
                graph_.x.label,...
                graph_.title);
        end
        
        function histogram_comparisons_inputs_at_scenarios(obj,ext_obj,input)
            
            % Households
            graph_ = [];
            for S = 1 : numel(ext_obj.Scenarios)
                graph_.input(:,S) = input.households{S}(:,1)/1000; % to kW
                % Active power of households for S scenario
            end
            
            graph_.Histogram_Limit = max(graph_.input(:));
            graph_.Bins = 20;
            graph_.x.label = 'P (kW)';
            graph_.title = ['Histograms of household active power loads for all scenarios'];
            
            myplot1 = plot_histograms(1,ext_obj.Grid_Variants,ext_obj.Scenarios);            
            myplot1.plot_histogram_inputs_at_scenarios(...
                graph_.input,1,graph_.Bins,...
                graph_.Histogram_Limit,...
                graph_.x.label,...
                graph_.title);
            %------------------------------------------------------
            % Solar
            graph_ = [];
            for S = 1 : numel(ext_obj.Scenarios)
                graph_.input(:,S) = input.solar{S}(:,1)/1000; % to kW
            end     
            if sum(isnan(graph_.input)) ~= numel(graph_.input)
                graph_.Histogram_Limit = max(graph_.input(:));
                graph_.Bins = 20;
                graph_.x.label = 'P (kW)';
                graph_.title = ['Histograms of solar active power infeeds for all scenarios'];
                
                myplot2 = plot_histograms(1,ext_obj.Grid_Variants,ext_obj.Scenarios);
                myplot2.plot_histogram_inputs_at_scenarios(...
                    graph_.input,1,graph_.Bins,...
                    graph_.Histogram_Limit,...
                    graph_.x.label,...
                    graph_.title);
            else
                disp('No solar generation at any scenario')
            end
            %--------------------------------------------------------
            % El mobility
            graph_ = [];
            for S = 1 : numel(ext_obj.Scenarios)
                graph_.input(:,S) = input.el_mobility{S}(:,1)/1000; % to kW
                % Active power of households for S scenario
            end    
            if sum(isnan(graph_.input)) ~= numel(graph_.input)
                graph_.Histogram_Limit = max(graph_.input(:));
                graph_.Bins = 20;
                graph_.x.label = 'P (kW)';
                graph_.title = ['Histograms of electric mobility active power loads for all scenarios'];
                
                myplot3 = plot_histograms(1,ext_obj.Grid_Variants,ext_obj.Scenarios);
                myplot3.plot_histogram_inputs_at_scenarios(...
                    graph_.input,1,graph_.Bins,...
                    graph_.Histogram_Limit,...
                    graph_.x.label,...
                    graph_.title);
            else
                disp('No e-mobility at any scenario')
            end
            %--------------------------------------------------------
            % Balance
            graph_ = [];
            for S = 1 : numel(ext_obj.Scenarios)
                graph_.input(:,S) = nansum([input.households{S}(:,1),-input.solar{S}(:,1),input.el_mobility{S}(:,1)],2); 
                % Active power of households for S scenario
            end            
            graph_.input = graph_.input/1000; % to kW
            graph_.Histogram_Limit = max(graph_.input(:));
            graph_.Bins = 20;
            graph_.x.label = 'P (kW)';
            graph_.title = ['System sum balance for all scenarios'];
                        
            myplot4 = plot_histograms(1,ext_obj.Grid_Variants,ext_obj.Scenarios);            
            myplot4.plot_histogram_inputs_at_scenarios(...
                graph_.input,1,graph_.Bins,...
                graph_.Histogram_Limit,...
                graph_.x.label,...
                graph_.title);           
            
        end
        
        function scenario(obj,S)
            obj.S = S;
        end
        % set scenario
        function grid(obj,G)
            obj.G = G;
        end
        % set grid
        
        function branch(obj,B)
            obj.B = B;
        end
        % set node
        
        function dataset(obj,D)
            obj.D = D;
        end
        % set dataset
    end
end