classdef Graph_Definition_Losses < handle    
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
        
        function display_datasets(obj,ext_obj,input1)

            % Define values for plotting
            graph_.losses = flipdim(input1,1);   
            
            % Axis text defined
            table_labels.datasets = [];
            for i = 1 : ext_obj.Datasets
                table_labels.y.datasets{i,1} = ['Set ' int2str(i)];
            end
            
            table_labels.x.losses = 'Active-power electric losses - Sum (Wh)';
            
            % Dataset y tick
            table_labels.y.tick = 1;
            if ext_obj.Datasets > 10 && ext_obj.Datasets <= 20
                table_labels.y.tick = round(ext_obj.Datasets/5);
            elseif  ext_obj.Datasets > 20
                table_labels.y.tick = round(ext_obj.Datasets/10);
            end
            
            graph_.x.losses = table_labels.x.losses;
            graph_.y.datasets = table_labels.y.datasets;
            
            graph_.y.tick = 1: table_labels.y.tick:ext_obj.Datasets;
            graph_.y.datasets = table_labels.y.datasets(graph_.y.tick);
            clear i
            
            % Plot the dataset comparisons for specific grid and specific scenario
            % input value defines the number of subplots
            myplot1 = plot_horizontal_bar(1);
            % datasets(input_values,axis,xlabel,ytick_numerical,ytick_text,scen,grid)
            myplot1 = myplot1.datasets(graph_.losses, 1,...
                graph_.x.losses,...
                graph_.y.tick,...
                graph_.y.datasets,...
                obj.S, obj.G);
            
        end
        
        function display_grids(obj,ext_obj,input1)
        
            % Flip dimensions for barh (1 is on top, last dataset on bottom)
            graph_.losses = flipdim(input1,1);
            
            % Axis text defined
            table_labels.grids = [];
            for i = 1 : numel(ext_obj.Grid_Variants)
                table_labels.y.grids{i,1} = ext_obj.Grid_Variants{i};
            end     
            table_labels.y.grids = flipdim(table_labels.y.grids,1);
            table_labels.x.losses = 'Sum of active-power losses for scenario (Wh)';
            
                            % Dataset y tick
            table_labels.y.tick = 1;
            if numel(ext_obj.Grid_Variants) > 10 && numel(ext_obj.Grid_Variants) <= 20
                table_labels.y.tick = round(numel(ext_obj.Grid_Variants)/5);
            elseif  numel(ext_obj.Grid_Variants) > 20
                table_labels.y.tick = round(numel(ext_obj.Grid_Variants)/10);
            end            
            graph_.x.losses = table_labels.x.losses;
            graph_.y.grids = table_labels.y.grids;
            graph_.y.tick = 1: table_labels.y.tick:numel(ext_obj.Grid_Variants);
            graph_.y.grids = table_labels.y.grids(graph_.y.tick);            
                 
            myplot1 = plot_horizontal_bar(1);            
            % grid(input_values,axis,xlabel,ytick_numerical,ytick_text,scen,grid)
            myplot1 = myplot1.grids(graph_.losses, 1,...
                graph_.x.losses,...
                graph_.y.tick,...
                graph_.y.grids,...
                [],[]);            
        end
        
        function display_grids_all_scenarios(obj,ext_obj,input1)
            
            % Flip dimensions for barh (1 is on top, last dataset on bottom)
            graph_.summary_all = flipdim(input1,1);
            
            % Axis text defined
            table_labels.grids = [];
            for i = 1 : numel(ext_obj.Grid_Variants)
                table_labels.y.grids{i,1} = ext_obj.Grid_Variants{i};
            end
            table_labels.y.grids = flipdim(table_labels.y.grids,1);            
            table_labels.x.losses = 'Sum of active-power losses (Wh)';
            
            % Dataset y tick
            table_labels.y.tick = 1;
            if numel(ext_obj.Grid_Variants) > 10  && numel(ext_obj.Grid_Variants) <= 20
                table_labels.y.tick = round(numel(ext_obj.Grid_Variants)/5);
            elseif  numel(ext_obj.Grid_Variants) > 20
                table_labels.y.tick = round(numel(ext_obj.Grid_Variants)/10);
            end
            
            graph_.x.losses = table_labels.x.losses;
            graph_.y.grids = table_labels.y.grids;
            
            graph_.y.tick = 1: table_labels.y.tick:numel(ext_obj.Grid_Variants);
            graph_.y.grids = table_labels.y.grids(graph_.y.tick);
            
            for i = 1 : numel(ext_obj.Scenarios)
                graph_.legend{i} = ext_obj.Scenarios{i};
            end
            
            myplot1 = plot_horizontal_bar(1);
            myplot1 = myplot1.grids_and_scenarios(...
                graph_.summary_all, 1,...
                graph_.x.losses,...
                graph_.y.tick,...
                graph_.y.grids,...
                [],...
                graph_.legend);
                
        end
        
                
        function histogram_comparisons_grids_at_scenario(obj,ext_obj,input)
            graph_.input = input;
            graph_.Histogram_Limit = max(input(:));
            graph_.Bins = 20;
            
            graph_.x.label = 'Max active-power losses (Wh/h) for datasets';
            
            graph_.title = ['Histogram of max. active-power losses for scenario ', ext_obj.Scenarios{obj.S}];
            
            myplot1 = plot_histograms(1,ext_obj.Grid_Variants,ext_obj.Scenarios);            
            myplot1.plot_histogram_grids_at_scenario(...
                 graph_.input,1,graph_.Bins,...
                 graph_.Histogram_Limit,...
                 graph_.x.label,...
                 graph_.title,[]);            
        end
        
        function histogram_comparisons_scenarios_at_grid(obj,ext_obj,input)
            
            graph_.input = input;
            graph_.Histogram_Limit = max(input(:));
            graph_.Bins = 20;
            graph_.x.label = 'Max active-power losses (Wh/h) for datasets';
            graph_.title = ['Histogram of max. active-power losses for for grid ', ext_obj.Grid_Variants{obj.G}];
            
            myplot1 = plot_histograms(1,ext_obj.Grid_Variants,ext_obj.Scenarios);
            myplot1.plot_histogram_scenarios_at_grid(...
                graph_.input,1,graph_.Bins,...
                graph_.Histogram_Limit,...
                graph_.x.label,...
                graph_.title,[]);
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