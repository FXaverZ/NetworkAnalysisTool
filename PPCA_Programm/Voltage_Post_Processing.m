classdef Voltage_Post_Processing
% VOLTAGE_POST_PROCESSING    Voltage violation post processing  class
% Version:                 1.0
% Erstellt von:            Matej Rejc - 14.05.2013
% Letzte Änderung durch:   Matej Rejc - 14.05.2013
    
    properties 
        Scenarios = [];
        Grid_Variants = [];
        Datasets = [];
        Timepoints = [];
        Result_Filenames = [];
        Result_Filepath = [];
        Scenario_Filepath = [];
        Simulation_Options = [];        
    end
    properties(GetAccess = 'private') 
        Result_Files
        x_axis_value = [];
    end
    
    % Result_Post_Processing method definitions
    methods
        function obj = Voltage_Post_Processing(information_file)
            % Define the information of the results for postprocessing
            inp_info = load(information_file);
            
            obj.Result_Filepath = inp_info.result_filepath;
            obj.Result_Filenames = inp_info.result_filename;
            obj.Scenario_Filepath = inp_info.scenario_filepath;
            obj.Simulation_Options = inp_info.simulation_options;
            
            obj.Scenarios = inp_info.scenarios;
            obj.Grid_Variants = inp_info.variants;
            obj.Datasets = inp_info.datasets;
            obj.Timepoints = inp_info.simulation_options.Timepoints;            
            obj.Result_Files = Load_Result_File(obj);
            
            % If histogram x axis will be shown in % select 2
            % If histogram x axis will be shown in numbers select 1
            obj.x_axis_value = 2;

        end
        % function Result_Post_Processing: create object function
        
        function [table_results,xls_output] = compare_datasets(obj,varargin)
            % Check input varargin
            [param.S, param.G, param.XLS]=input_check(3,2,varargin);
            
            % Load results from .mat files
            [Result, Grid, Load_Infeed_Data] = obj.Result_Files.load(param.S);            
            
             % Load voltage violation results
            if obj.Simulation_Options.Voltage_Violation_Analysis               
                Voltage_Violation_Summary = Result.(obj.Grid_Variants{param.G}).Voltage_Violation_Summary;
                Voltage_Violation_Analysis = Result.(obj.Grid_Variants{param.G}).Voltage_Violation_Analysis;
            end
            % Load saved voltage results
            if obj.Simulation_Options.Save_Voltage_Results
                Node_Voltages = Result.(obj.Grid_Variants{param.G}).Node_Voltages;
            end
            
            % TABLE_RESULTS > SUMMARY : A summary of voltage violations
            table_results.Summary = [...
                Voltage_Violation_Summary.Number_of_Violations,...
                Voltage_Violation_Summary.Number_of_Violations_percent,...
                Voltage_Violation_Summary.Number_of_Nodes_With_Violations,...
                Voltage_Violation_Summary.Number_of_Nodes_With_Violations_percent,...
                ];

            
            %--------------------------------------------------------------
            % §§ xls_results: Summary - a summary of violations in
            % excel sheet form
            % Header definition: name of datasets (one column, obj.Datasets rows)
            header_definition.Row_IDs_for_Datasets = [];
            for cd = 1 : obj.Datasets
                header_definition.Row_IDs_for_Datasets{cd,1} = ['Set ' int2str(cd)];
            end
            header_definition.Row_IDs_for_Datasets = [{'Dataset'};header_definition.Row_IDs_for_Datasets];
            % Add column headers 1st row
            header_definition.Column_IDs_for_Summary{1,1} = 'Number of voltage violations for dataset';
            header_definition.Column_IDs_for_Summary{1,2} = 'Amount of time voltage violations occured in %';
            header_definition.Column_IDs_for_Summary{1,3} = 'Number of nodes where voltage violations occured';
            header_definition.Column_IDs_for_Summary{1,4} = 'Amount of nodes in grid where voltage violations occured in %';
            
                        
            % Create xls_results.Summary table
            xls_results.Summary = [header_definition.Column_IDs_for_Summary;
                num2cell(table_results.Summary)];
            xls_results.Summary = [header_definition.Row_IDs_for_Datasets, xls_results.Summary];
            % ----------------------------------------------------
            
            % §§ xls_results: Violated_nodes - list of nodes where
            % violations occured for each dataset for xls form
            % Uniform display list requires that we preallocate a table
            % where the size equals the maximum number of impacted nodes
            param.max_violations = max(Voltage_Violation_Summary.Number_of_Nodes_With_Violations(:));
            % Add headers to the list of elements
            header_definition.Column_IDs_for_Violated_nodes{1,1} = 'Nodes with voltage violation occurances';
            if param.max_violations > 1
                header_definition.Column_IDs_for_Violated_nodes = ...
                    [header_definition.Column_IDs_for_Violated_nodes, cell(1,param.max_violations-1)];
            end
            
            % §§ table_results: Violated_nodes - list of nodes where
            % violations occured for each dataset
            table_results.Violated_nodes = cell(obj.Datasets,param.max_violations); % Preallocation
            for cd = 1 : obj.Datasets
                if ~isempty(Voltage_Violation_Summary.Names_of_Nodes_With_Violations{cd,1})
                    table_results.Violated_nodes(cd,...
                        1:size(Voltage_Violation_Summary.Names_of_Nodes_With_Violations{cd,1},2)) = ...
                        sort(Voltage_Violation_Summary.Names_of_Nodes_With_Violations{cd,1});
                end
            end
            
            % Create xls_results.Violated_nodes
            xls_results.Violated_nodes = ...
                [header_definition.Column_IDs_for_Violated_nodes;
                table_results.Violated_nodes];
            xls_results.Violated_nodes = ...
                [header_definition.Row_IDs_for_Datasets,xls_results.Violated_nodes];
            % ----------------------------------------------------
            
            % §§ table_results: Voltage_statistics - statistical values of observed
            % node values
            % Check If voltage results were saved. If not, this table
            % result is not created
            if obj.Simulation_Options.Save_Voltage_Results == 1
                % Define rated voltages (PE)
                param.rated_voltage_pe = ...
                    vertcat(Grid.(obj.Grid_Variants{param.G}).All_Node.Points.Rated_Voltage_phase_earth);
                param.rated_voltage_pe = param.rated_voltage_pe(:,1)';
                param.rated_voltage_pe = repmat(param.rated_voltage_pe, obj.Timepoints,1);
                
                % Preallocate table_results.Voltage_statistics
                table_results.Voltage_statistics = zeros(obj.Datasets,5);
                for cd = 1 : obj.Datasets
                    clear id_* idn
                    % Define node voltages in p.u
                    % Values must be in p.u. for max and min search
                    
                    Node_voltages_L1pu = squeeze(Node_Voltages(cd,:,:,1)) ./ param.rated_voltage_pe;
                    Node_voltages_L2pu = squeeze(Node_Voltages(cd,:,:,2)) ./ param.rated_voltage_pe;
                    Node_voltages_L3pu = squeeze(Node_Voltages(cd,:,:,3)) ./ param.rated_voltage_pe;
                    
                    % Max value
                    [table_results.Voltage_statistics(cd,1),id_max] = ...
                        max([max(Node_voltages_L1pu(:)),...
                        max(Node_voltages_L2pu(:)),...
                        max(Node_voltages_L3pu(:))]);
                    % Min value
                    Node_voltages_L1pu(Node_voltages_L1pu == 0)= NaN;
                    Node_voltages_L1pu(Node_voltages_L2pu == 0)= NaN;
                    Node_voltages_L1pu(Node_voltages_L3pu == 0)= NaN;
                    
                    [table_results.Voltage_statistics(cd,2),id_min] = ...
                        min([min(Node_voltages_L1pu(:)),...
                        min(Node_voltages_L2pu(:)),...
                        min(Node_voltages_L3pu(:))]);
                    
                    % Mean value
                    table_results.Voltage_statistics(cd,4) = ...
                        nanmean(reshape([Node_voltages_L1pu,Node_voltages_L2pu,Node_voltages_L3pu],[],1)); % Mean
                    % Std value
                    table_results.Voltage_statistics(cd,5) = ...
                        nanstd(reshape([Node_voltages_L1pu,Node_voltages_L2pu,Node_voltages_L3pu],[],1)); % Std
                    
                    % Max Upp difference calculation
                    [table_results.Voltage_statistics(cd,3),id_upp_max] = ...
                        max( [max(abs(Node_voltages_L1pu(:) - Node_voltages_L2pu(:))),...
                        max(abs(Node_voltages_L1pu(:) - Node_voltages_L3pu(:))),...
                        max(abs(Node_voltages_L2pu(:) - Node_voltages_L3pu(:)))] ); % Max Upp difference
                    
                    % Names of nodes where max/min/max upp values are
                    % Max value at node
                    search_for_extreme_val_nodes = []; idn = [];
                    eval(['search_for_extreme_val_nodes = Node_voltages_L', int2str(id_max) ,'pu;']);
                    idn =  max(search_for_extreme_val_nodes,[],1) == ...
                        table_results.Voltage_statistics(cd,1);
                    table_results.Voltage_statistics_at_Node{cd,1} = ...
                        Grid.(obj.Grid_Variants{param.G}).All_Node.Points(idn).Node_Name;
                    
                    % Min value at node
                    search_for_extreme_val_nodes = []; idn = [];
                    eval(['search_for_extreme_val_nodes = Node_voltages_L', int2str(id_min) ,'pu;']);
                    idn =  min(search_for_extreme_val_nodes,[],1) == ...
                        table_results.Voltage_statistics(cd,2);
                    table_results.Voltage_statistics_at_Node{cd,2} = ...
                        Grid.(obj.Grid_Variants{param.G}).All_Node.Points(idn).Node_Name;
                    
                    % Max upp difference at node
                    idn = [];
                    if id_upp_max == 1 % L1-L2
                        idn = find(max(abs(Node_voltages_L1pu-Node_voltages_L2pu)) == ...
                            table_results.Voltage_statistics(cd,3));
                    elseif id_upp_max == 2 % L1-L3
                        idn = find(max(abs(Node_voltages_L1pu-Node_voltages_L3pu)) == ...
                            table_results.Voltage_statistics(cd,3));
                    elseif id_upp_max == 3 % L2-L3
                        idn = find(max(abs(Node_voltages_L2pu-Node_voltages_L3pu)) == ...
                            table_results.Voltage_statistics(cd,3));
                    end
                    table_results.Voltage_statistics_at_Node{cd,3} = ...
                        Grid.(obj.Grid_Variants{param.G}).All_Node.Points(idn).Node_Name;
                end
                clear id_* idn Node_voltages_L1pu Node_voltages_L2pu
                clear Node_voltages_L3pu search_for_extreme_val_nodes
                
                % Header for Column IDs for Voltage statistics
                header_definition.Column_IDs_for_Voltage_statistics_w_Nodes{1,1} = 'Max. voltage (p.u.)';
                header_definition.Column_IDs_for_Voltage_statistics_w_Nodes{1,2} = 'Max. voltage at node';
                header_definition.Column_IDs_for_Voltage_statistics_w_Nodes{1,3} = 'Min. voltage (p.u.)';
                header_definition.Column_IDs_for_Voltage_statistics_w_Nodes{1,4} = 'Min. voltage at node';
                header_definition.Column_IDs_for_Voltage_statistics_w_Nodes{1,5} = 'Max. phase-phase voltage difference (p.u.)';
                header_definition.Column_IDs_for_Voltage_statistics_w_Nodes{1,6} = 'Max. phase-phase voltage difference at node';
                header_definition.Column_IDs_for_Voltage_statistics_w_Nodes{1,7} = 'Mean voltage (p.u.)';
                header_definition.Column_IDs_for_Voltage_statistics_w_Nodes{1,8} = 'St. dev. voltage (p.u.)';
                
                % Create xls_results.Voltage_statistics table
                xls_results.Voltage_statistics = ...
                    [num2cell(table_results.Voltage_statistics(:,1)),table_results.Voltage_statistics_at_Node(:,1),...
                    num2cell(table_results.Voltage_statistics(:,2)),table_results.Voltage_statistics_at_Node(:,2),...
                    num2cell(table_results.Voltage_statistics(:,3)),table_results.Voltage_statistics_at_Node(:,3),...
                    num2cell(table_results.Voltage_statistics(:,4)),...
                    num2cell(table_results.Voltage_statistics(:,5))];
                
                xls_results.Voltage_statistics = ...
                    [header_definition.Column_IDs_for_Voltage_statistics_w_Nodes;
                    xls_results.Voltage_statistics];
                % Row IDs we do not need, summary already defines them
                % xls_results.Voltage_statistics = ...
                %     [header_definition.Row_IDs_for_Datasets,xls_results.Voltage_statistics];
            else
                xls_results.Voltage_statistics = [];
                table_results.Voltage_statistics = [];
                table_results.Voltage_statistics_at_Node = [];
            end
            % ----------------------------------------------------
            % §§ table_results.NodeHistogram_Violations
            %     Number of violations for each dataset and node
            % 1st dimension is the dataset (cd)
            % 2nd dimension is the node (N)
            %    the Values are the violations or number of nodes
            %    affected for each dataset (the summation through all
            %    timepoints)
            for cd = 1 : obj.Datasets
                table_results.NodeHistogram_Violations(cd,:) = ...
                    nansum(squeeze(Voltage_Violation_Analysis(cd,:,:)),1);
            end
            if obj.x_axis_value == 2
                table_results.NodeHistogram_Violations = ...
                    100*table_results.NodeHistogram_Violations/obj.Timepoints;
            end
            
            % ----------------------------------------------------
            % §§ table_results: Load_infeed_values - values of load,
            % infeed and emobility for specific dataset
            xls_results.Load_infeed_values_at_Violation = [];
            param.take_into_account_Q_infeed = zeros(obj.Datasets,1);
            param.take_into_account_Q_elmob = zeros(obj.Datasets,1);
            % Number of empty rows between sets
            param.empty_row_for_LI_values = 1;
            header_definition.empty_row_for_LI_values = ...
                cell(param.empty_row_for_LI_values,...
                max(Voltage_Violation_Summary.Number_of_Violations)+1);
            for cd = 1 : obj.Datasets
                pliv.load_val = []; % pliv..pretable load/infeed values
                pliv.infeed_val = [];
                pliv.el_mobility_val = [];
                pliv.balance = [];
                pliv.timepoints = [];
                pliv.del_rows = [];
                xls_block = [];
                
                % Load set values
                pliv.load_val = Load_Infeed_Data.(['Set_', int2str(cd) ]).Households.(obj.Simulation_Options.Input_values_used);
                pliv.infeed_val = Load_Infeed_Data.(['Set_', int2str(cd) ]).Solar.(obj.Simulation_Options.Input_values_used);
                pliv.el_mobility_val = Load_Infeed_Data.(['Set_', int2str(cd) ]).El_Mobility.(obj.Simulation_Options.Input_values_used);
                % load_val, infeed_val, el_mobility_val first column equals
                % P, second column equals Q
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
                pliv.balance(:,1) = pliv.load_val(:,1) -...
                    pliv.infeed_val(:,1) + pliv.el_mobility_val(:,1);
                pliv.balance(:,2) = pliv.load_val(:,2) -...
                    pliv.infeed_val(:,2) + pliv.el_mobility_val(:,2);
                
                % voltage violation timepoint index -we search for voltage
                % violations and define the numerical timepoint where
                % violation occured
                pliv.timepoints = find(sum(squeeze(Voltage_Violation_Analysis(cd,:,:)) == 1,2) > 0);
                
                table_results.Load_infeed_values_at_Violation{cd,1} = ...
                    [pliv.timepoints,... % Timepoints
                    pliv.load_val(pliv.timepoints,:),... % Load P, Load Q
                    pliv.infeed_val(pliv.timepoints,:),... % Infeed P, Infeed Q
                    pliv.el_mobility_val(pliv.timepoints,:),... % El mob P, El mob Q
                    pliv.balance(pliv.timepoints,:) ]';
                % §§ table_results: Load_infeed_values_at_Violation{cd ,1)
                % [timepoint 1, timepoint 2  , ...
                %  load P1    , load P2      , ...
                %  load Q1    , load Q2      , ...
                %  infeed P1  , infeed P2    , ...
                %  infeed Q1  , infeed Q2    , ...
                %  el. mob P1 , el. mob P2   , ...
                %  el. mob Q1 , el. mob Q2   , ...
                %  sum P1     , sum P2       , ...
                %  sum Q1     , sum Q2       , ...]
                
                if sum(pliv.infeed_val(:,2)==0) == ...
                        size(pliv.infeed_val,1)
                    param.take_into_account_Q_infeed(cd,1) = 1;
                    % If reactive power is not present at infeed = 1
                end
                if sum(pliv.el_mobility_val(:,2)==0) == ...
                        size(pliv.el_mobility_val,1)
                    param.take_into_account_Q_elmob(cd,1) = 1;
                    % If reactive power is not present at el mobility = 1
                end
                
                if ~isempty(pliv.timepoints)
                    header_definition.Row_IDs_for_LI_values{cd}{1,1} = ['Set ', int2str(cd) ];
                    header_definition.Row_IDs_for_LI_values{cd}{2,1} = 'Timepoint';
                    header_definition.Row_IDs_for_LI_values{cd}{3,1} = 'Households (W)';
                    header_definition.Row_IDs_for_LI_values{cd}{4,1} = 'Households (VA)';
                    header_definition.Row_IDs_for_LI_values{cd}{5,1} = 'Solar infeed (W)';
                    header_definition.Row_IDs_for_LI_values{cd}{6,1} = 'Solar infeed (VA)';
                    header_definition.Row_IDs_for_LI_values{cd}{7,1} = 'El. mobility (W)';
                    header_definition.Row_IDs_for_LI_values{cd}{8,1} = 'El. mobility (VA)';
                    header_definition.Row_IDs_for_LI_values{cd}{9,1} = 'System balance (W)';
                    header_definition.Row_IDs_for_LI_values{cd}{10,1} ='System balance (VA)';
                    
                    header_definition.Column_IDs_for_LI_values{cd}{1,1} = 'Voltage violations at timepoints';
                    header_definition.Column_IDs_for_LI_values{cd} = ...
                        [header_definition.Column_IDs_for_LI_values{cd}{1,1},...
                        cell(1,max(Voltage_Violation_Summary.Number_of_Violations)-1)];
                else
                    header_definition.Column_IDs_for_LI_values{cd}{1,1} = ['Set ', int2str(cd) ];
                    header_definition.Column_IDs_for_LI_values{cd}{1,2} = 'No voltage violations at any timepoint';
                    header_definition.Column_IDs_for_LI_values{cd} = ...
                        [header_definition.Column_IDs_for_LI_values{cd},...
                        cell(1,max(Voltage_Violation_Summary.Number_of_Violations)-2+1)];
                end
                
                if ~isempty(pliv.timepoints)
                    xls_block = cell(size(header_definition.Row_IDs_for_LI_values{cd},1)-1,...
                        max(Voltage_Violation_Summary.Number_of_Violations));
                    xls_block(:,1:size(table_results.Load_infeed_values_at_Violation{cd,1},2)) = ...
                        num2cell(table_results.Load_infeed_values_at_Violation{cd,1});
                    xls_block = [header_definition.Column_IDs_for_LI_values{cd};xls_block];
                    xls_block = [header_definition.Row_IDs_for_LI_values{cd},xls_block];
                    xls_block = [xls_block; header_definition.empty_row_for_LI_values];
                    
                    % If solar/emobility do not have reactive power, the
                    % rows are deleted
                    if param.take_into_account_Q_infeed(cd,1) == 1
                        pliv.del_rows = [pliv.del_rows; 6];
                    end
                    if param.take_into_account_Q_elmob(cd,1) == 1
                        pliv.del_rows = [pliv.del_rows; 8];
                    end
                    xls_block(pliv.del_rows,:) = [];
                else
                    xls_block = header_definition.Column_IDs_for_LI_values{cd};
                    xls_block = [xls_block; header_definition.empty_row_for_LI_values];
                end
                xls_results.Load_infeed_values_at_Violation = ...
                    [xls_results.Load_infeed_values_at_Violation;xls_block];
            end
            clear cd pliv xls_block
            % Last line does not require an empty row
            xls_results.Load_infeed_values_at_Violation(end,:) = [];
            % §§ table_results are in matlab form
            % §§ xls_results are in excel form
            
            if param.XLS == 1
                % -----------------------------------------------------------
                % OUTPUT FOR XLS FILE (DATASET COMPARISON)
                % -----------------------------------------------------------
                % Output for excel files
                % Sheet 1 : - xls_results.Summary,xls_results.Voltage_statistics
                %           - xls_results.Violated_nodes
                
                % Max column size for excel
                sheet1.max_column_size = size([xls_results.Summary, xls_results.Voltage_statistics],2);
                sheet1.max_column_size = max([sheet1.max_column_size,size(xls_results.Violated_nodes,2)]);
                
                % Empty rows between Summary and Violated nodes
                sheet1.empty_rows = 1;
                sheet1.max_row_size = size(table_results.Summary,1) +...
                    sheet1.empty_rows + size(xls_results.Violated_nodes,1);
                
                sheet1.table = cell(sheet1.max_row_size,sheet1.max_column_size);
                % Add summary to sheet1
                inpval = [];
                inpval = [xls_results.Summary];
                % If save voltage results exist
                % Add Voltage_statistics to sheet1
                if obj.Simulation_Options.Save_Voltage_Results == 1
                    inpval = [inpval, xls_results.Voltage_statistics];
                end
                sheet1.curr_row = size(inpval,1); % current row
                sheet1.curr_col = size(inpval,2); % Current column
                
                sheet1.table(1: sheet1.curr_row,1:sheet1.curr_col) = inpval;
                
                % Move current row by "empty spaces"
                sheet1.curr_row = sheet1.curr_row + sheet1.empty_rows;
                
                % Second part is the list of nodes
                inpval = [];
                inpval = xls_results.Violated_nodes;
                sheet1.table(sheet1.curr_row + (1:size(inpval,1)) , 1 : size(inpval,2)) = ...
                    inpval;
                
                if sheet1.max_column_size < 11
                    % If sheet 1 is smaller than main header, expand table
                    header_definition.Row_IDs_for_sheet1 = cell(1,11);
                    sheet1.table = ...
                        [sheet1.table , cell(size(sheet1.table,1),11-size(sheet1.table,2))];
                else
                    header_definition.Row_IDs_for_sheet1 = cell(1,sheet1.max_column_size);
                end
                header_definition.Row_IDs_for_sheet1{1,1} = 'Voltage violation analysis - summary';
                header_definition.Row_IDs_for_sheet1{1,4} = 'Scenario';
                header_definition.Row_IDs_for_sheet1{1,5} = obj.Scenarios{param.S};
                header_definition.Row_IDs_for_sheet1{1,7} = 'Grid';
                header_definition.Row_IDs_for_sheet1{1,8} = obj.Grid_Variants{param.G};
                header_definition.Row_IDs_for_sheet1{1,10} = 'Number of nonconvergences';
                header_definition.Row_IDs_for_sheet1{1,11} = ...
                    int2str(sum(Result.(obj.Grid_Variants{param.G}).Error_Counter(:)));
                % Add main header to table
                sheet1.table = [header_definition.Row_IDs_for_sheet1;sheet1.table];
                
                % -----------------------------------------------------------
                % Output for excel files
                % Sheet 2 : - xls_results.Load_infeed_values_at_Violation
                
                sheet2.table = xls_results.Load_infeed_values_at_Violation;
                sheet2.max_column_size = size(xls_results.Load_infeed_values_at_Violation,2);
                
                if sheet2.max_column_size < 11
                    % If sheet 2 is smaller than main header, expand table
                    header_definition.Row_IDs_for_sheet2 = cell(1,11);
                    sheet2.table = ...
                        [sheet2.table , cell(size(sheet2.table,1),11-size(sheet2.table,2))];
                else
                    header_definition.Row_IDs_for_sheet2 = cell(1,sheet2.max_column_size);
                end
                
                header_definition.Row_IDs_for_sheet2{1,1} = ...
                    'Voltage violation analysis - load/infeed values at voltage violations';
                header_definition.Row_IDs_for_sheet2{1,4} = 'Scenario';
                header_definition.Row_IDs_for_sheet2{1,5} = obj.Scenarios{param.S};
                header_definition.Row_IDs_for_sheet2{1,7} = 'Grid';
                header_definition.Row_IDs_for_sheet2{1,8} = obj.Grid_Variants{param.G};
                header_definition.Row_IDs_for_sheet2{1,10} = 'Number of nonconvergences';
                header_definition.Row_IDs_for_sheet2{1,11} = ...
                    int2str(sum(Result.(obj.Grid_Variants{param.G}).Error_Counter(:)));
                
                % Add main header to table
                sheet2.table = [header_definition.Row_IDs_for_sheet2;sheet2.table];
                
                % Output values for function
                xls_output.Sheet1 =  sheet1.table;
                xls_output.Sheet2 =  sheet2.table;
            else
                xls_output = [];
            end
            
        end
        % compare datasets function
        
        function [table_results,xls_output] = compare_grids(obj,varargin)
            % COMPARE_GRIDS for the S scenario
            if numel(varargin) == 1
                param.S = varargin{1}; % Scenario S selected
                param.XLS = 0; % Do not create xls output
            elseif numel(varargin) == 2
                param.S = varargin{1}; % Scenario S selected
                if strcmp(varargin{2},'xls') == 1
                    param.XLS = 1; % Create xls output
                else
                    param.XLS = 0; % Do not create xls output
                end
            else
                error('ErrorTests:convertTest',...
                    'Error using compare_grids\nToo many input arguments.')
            end
            
            % Run dataset comparison between grids
            for G = 1 : numel(obj.Grid_Variants)
                input_results = []; % input_results ... dataset comparisons
                [input_results,~] = obj.compare_datasets(param.S,G);
                
                % -------------------------------------------------------
                % $$ table_results.GridSummary_Full is a 3D array
                % 1st dimension is dataset (:)
                % 2nd dimension is grid (G)
                % 3rd dimension is value observed (i)
                %   1...number of violations, 2...viol. in %, 3...nodes
                %   affected, 4...nodes affected in %
                
                % §§ table_results.GridSummary_Short is a 3D array
                % 1st dimension is grid (G)
                % 2nd dimension is observed data (i)
                %   1...number of violations, 2...viol. in %, 3...nodes
                %   affected, 4...nodes affected in %
                % 3rd dimension is observed value
                %   1...max value, 2...min value, 3...mean value, 4...sum
                %   value
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
                
                % -------------------------------------------------------
                % §§ table_results.GridVoltage_statistics is a 2D array
                % 1st dimension is grid (G)
                % 2nd dimension is observed value
                %   1...max voltage in all datasets for grid, 2...min
                %   voltage in all datasets for grid, 3...max Upp
                %   difference in all datasets for grid 4...mean voltage in
                %   all datasets for grid, 5...mean std of voltages for all
                %   datasets for grid
                
                % §§ table_results.GridVoltage_statistics_at_Node is a 2D array
                % 1st dimension is grid (G)
                % 2nd dimension is node where extreme value occurs
                %   1...node with max voltage in all datasets for grid,
                % 2...node with min voltage in all datasets for grid,
                % 3...node with max Upp difference in all datasets for grid
                % 4...most common node(s) where max voltages occur
                % 5...most common node(s) where min voltages occur
                % 6...most common node(s) where max Upp diff. occur
                
                if obj.Simulation_Options.Save_Voltage_Results == 1
                    maxGv=[]; id_maxGv=[]; minGv=[];
                    id_minGv=[]; maxGUpp=[]; id_maxGUpp=[];
                    
                    [maxGv,id_maxGv] = max(input_results.Voltage_statistics(:,1));
                    [minGv,id_minGv] =  min(input_results.Voltage_statistics(:,2));
                    [maxGUpp,id_maxGUpp] = max(input_results.Voltage_statistics(:,3));
                    
                    table_results.GridVoltage_statistics(G,:) = ...
                        [maxGv,...
                        minGv,...
                        maxGUpp,...
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
                
                % -------------------------------------------------------
                % §§ table_results.GridHistogram_Violations
                %    Number of violations for each dataset
                % §§ table_results.GridHistogram_Violations_at_Nodes
                %    Number of nodes affected for each dataset
                % 1st dimension is the dataset (cd)
                % 2nd dimension is the grid (G)
                %    the Values are the violations or number of nodes
                %    affected for each dataset
                % §§ table_results.NodeHistogram_Violations
                %    Number of violations for each dataset for each node
                %    for {G} grid
                % Cell dimension is grid
                %    1st dimension in cell is dataset
                %    2nd dimension in cell is node
                
                table_results.GridHistogram_Violations(:,G) = ...
                    input_results.Summary(:,obj.x_axis_value);
                
                table_results.GridHistogram_Violations_at_Nodes(:,G) = ...
                    input_results.Summary(:,obj.x_axis_value+2);
                
                table_results.NodeHistogram_Violations{G} = ...
                    input_results.NodeHistogram_Violations;
            end            
            % --------------------------------------------------------
            % xls_results definition:
            % --------------------------------------------------------
            % $$ xls_results.GridSummary_Full
            %   The values can be displayed numerically or in %
            %   if obj.x_axis_value is set to 2, values are shown in %, if
            %   value is set to 1, values are shown numerically
            
            if obj.x_axis_value == 2
                header_definition.Column_IDs_for_GridSummary_full_1{1,1} = 'Voltage violations in % of time for different grids ';
                header_definition.Column_IDs_for_GridSummary_full_2{1,1} = 'Number of nodes with voltage violations in % of time for different grids ';
            elseif obj.x_axis_value == 1
                header_definition.Column_IDs_for_GridSummary_full_1{1,1} = 'Number of voltage violations for different grids ';
                header_definition.Column_IDs_for_GridSummary_full_2{1,1} = 'Number of nodes with voltage violations for different grids ';
            end
            if numel(obj.Grid_Variants) > 1
                header_definition.Column_IDs_for_GridSummary_full_1(1,2:numel(obj.Grid_Variants)) = ...
                    cell(1,numel(obj.Grid_Variants)-1);
                header_definition.Column_IDs_for_GridSummary_full_2(1,2:numel(obj.Grid_Variants)) = ...
                    cell(1,numel(obj.Grid_Variants)-1);
            end
            header_definition.Column_IDs_for_GridSummary_full_1(2,1: numel(obj.Grid_Variants)) = ...
                obj.Grid_Variants;
            header_definition.Column_IDs_for_GridSummary_full_2(2,1: numel(obj.Grid_Variants)) = ...
                obj.Grid_Variants;
            
            header_definition.Row_IDs_for_Datasets = [];
            for cd = 1 : obj.Datasets
                header_definition.Row_IDs_for_Datasets{cd,1} = ['Set ' int2str(cd)];
            end
            header_definition.Row_IDs_for_Datasets = [{'Dataset'};header_definition.Row_IDs_for_Datasets];
            header_definition.Row_IDs_for_Datasets_for_GridSummary_full = ...
                [{''};header_definition.Row_IDs_for_Datasets];
            
            xls_block = [];
            xls_block = [xls_block,num2cell(squeeze(table_results.GridSummary_Full(:,:,obj.x_axis_value)))];
            xls_block = [xls_block,num2cell(squeeze(table_results.GridSummary_Full(:,:,obj.x_axis_value+2)))];
            
            xls_block = [header_definition.Column_IDs_for_GridSummary_full_1,...
                header_definition.Column_IDs_for_GridSummary_full_2;
                xls_block];
            
            xls_block = [header_definition.Row_IDs_for_Datasets_for_GridSummary_full,xls_block];
            
            xls_results.GridSummary_Full = xls_block;
            clear xls_block
            % -------------------------------------------------------
            
            % $$ xls_results.GridSummary_Short
            %   The values can be displayed numerically or in %
            %   if obj.x_axis_value is set to 2, values are shown in %, if
            %   value is set to 1, values are shown numerically
            if obj.x_axis_value == 2
                header_definition.Column_IDs_for_GridSummary_short_1{1,1} = 'Statistical analysis of voltage violations in % of time for different grids ';
                header_definition.Column_IDs_for_GridSummary_short_1{1,2} = '';
                header_definition.Column_IDs_for_GridSummary_short_1{1,3} = '';
                header_definition.Column_IDs_for_GridSummary_short_1{2,1} = 'Max % of voltage violations at grid';
                header_definition.Column_IDs_for_GridSummary_short_1{2,2} = 'Min % of voltage violations at grid';
                header_definition.Column_IDs_for_GridSummary_short_1{2,3} = 'Mean value of the % of voltage violations at grid';
                
                header_definition.Column_IDs_for_GridSummary_short_2{1,1} = 'Statistical analysis of the % of nodes with voltage violations for different grids ';;
                header_definition.Column_IDs_for_GridSummary_short_2{1,2} = '';
                header_definition.Column_IDs_for_GridSummary_short_2{1,3} = '';
                header_definition.Column_IDs_for_GridSummary_short_2{2,1} = 'Max % of nodes with voltage violations at grid';
                header_definition.Column_IDs_for_GridSummary_short_2{2,2} = 'Min % of nodes with voltage violations at grid';
                header_definition.Column_IDs_for_GridSummary_short_2{2,3} = 'Mean value of the % of nodes with voltage violations at grid';
                
            elseif obj.x_axis_value == 1
                header_definition.Column_IDs_for_GridSummary_short_1{1,1} = 'Statistical analysis of the number of voltage violations for different grids ';
                header_definition.Column_IDs_for_GridSummary_short_1{1,2} = '';
                header_definition.Column_IDs_for_GridSummary_short_1{1,3} = '';
                header_definition.Column_IDs_for_GridSummary_short_1{1,4} = '';
                header_definition.Column_IDs_for_GridSummary_short_1{2,1} = 'Max number of voltage violations at grid';
                header_definition.Column_IDs_for_GridSummary_short_1{2,2} = 'Min number of voltage violations at grid';
                header_definition.Column_IDs_for_GridSummary_short_1{2,3} = 'Mean value of the number of voltage violations at grid';
                header_definition.Column_IDs_for_GridSummary_short_1{2,4} = 'Sum of all number of voltage violations at grid';
                
                header_definition.Column_IDs_for_GridSummary_short_2{1,1} = 'Statistical analysis of the number of nodes with voltage violations for different grids ';;
                header_definition.Column_IDs_for_GridSummary_short_2{1,2} = '';
                header_definition.Column_IDs_for_GridSummary_short_2{1,3} = '';
                header_definition.Column_IDs_for_GridSummary_short_2{2,1} = 'Max number of nodes with voltage violations at grid';
                header_definition.Column_IDs_for_GridSummary_short_2{2,2} = 'Min number of nodes with voltage violations at grid';
                header_definition.Column_IDs_for_GridSummary_short_2{2,3} = 'Mean value of the number of nodes with voltage violations at grid';
            end
            
            header_definition.Row_IDs_for_Grids = [];
            for cg = 1 : numel(obj.Grid_Variants)
                header_definition.Row_IDs_for_Grids{cg,1} = ['Grid: ' obj.Grid_Variants{cg}];
            end
            header_definition.Row_IDs_for_Grids = [{'Grids'};header_definition.Row_IDs_for_Grids];
            header_definition.Row_IDs_for_Grids_for_Summary_short = ...
                [{''};header_definition.Row_IDs_for_Grids];
            
            % Delete NaN values from excel results
            xls_inp1 = []; xls_inp2 = [];
            xls_inp1 = squeeze(table_results.GridSummary_Short(:,obj.x_axis_value,:));
            xls_inp1(:, sum(isnan(xls_inp1),1) == size(xls_inp1,1)) = [];
            xls_inp2 = squeeze(table_results.GridSummary_Short(:,obj.x_axis_value+2,:));
            xls_inp2(:, sum(isnan(xls_inp2),1) == size(xls_inp2,1)) = [];
            
            xls_block = [];
            xls_block = [xls_block,num2cell(xls_inp1)];
            xls_block = [xls_block,num2cell(xls_inp2)];
            
            xls_block = [header_definition.Column_IDs_for_GridSummary_short_1,...
                header_definition.Column_IDs_for_GridSummary_short_2;
                xls_block];
            
            xls_block = [header_definition.Row_IDs_for_Grids_for_Summary_short,xls_block];
            
            xls_results.GridSummary_Short = xls_block;
            clear xls_block xls_inp1 xls_inp2 cg cd
            
            % --------------------------------------------------------
            if obj.Simulation_Options.Save_Voltage_Results == 1
                % $$ xls_results.GridVoltage_statistics
                %   The values can be displayed numerically or in %
                %   if obj.x_axis_value is set to 2, values are shown in %, if
                %   value is set to 1, values are shown numerically
                
                header_definition.Column_IDs_for_GridVoltage_statistics{1,1} = 'Statistical analysis of voltage results for different grids';
                header_definition.Column_IDs_for_GridVoltage_statistics(1,2:11) = cell(1,10);
                
                header_definition.Column_IDs_for_GridVoltage_statistics{2,1} = 'Max voltage value at grid';
                header_definition.Column_IDs_for_GridVoltage_statistics{2,2} = 'Node with max voltage value at grid';
                header_definition.Column_IDs_for_GridVoltage_statistics{2,3} = 'Min voltage value at grid';
                header_definition.Column_IDs_for_GridVoltage_statistics{2,4} = 'Node with min voltage value at grid';
                header_definition.Column_IDs_for_GridVoltage_statistics{2,5} = 'Max Upp difference at grid';
                header_definition.Column_IDs_for_GridVoltage_statistics{2,6} = 'Node with max Upp difference at grid';
                header_definition.Column_IDs_for_GridVoltage_statistics{2,7} = 'Mean value of voltages at grid';
                header_definition.Column_IDs_for_GridVoltage_statistics{2,8} = 'Average st. dev. of voltages at grid';
                
                header_definition.Column_IDs_for_GridVoltage_statistics{2,9} = 'Max voltages occur most often at node(s)';
                header_definition.Column_IDs_for_GridVoltage_statistics{2,10} = 'Min voltages occur most often at node(s)';
                header_definition.Column_IDs_for_GridVoltage_statistics{2,11} = 'Max Upp differences occur most often at node(s)';
                
                
                header_definition.Row_IDs_for_Grids_for_GridVoltage_statistics = ...
                    [{''};header_definition.Row_IDs_for_Grids];
                
                % Merge multiple elements into one, but seperate with
                % commas
                xls_inp1 = []; xls_inp = [];
                xls_inp1 = table_results.GridVoltage_statistics_at_Node;
                for i = 1 : size(xls_inp1,1)
                    for j = 1 : size(xls_inp1,2)
                        if iscell(xls_inp1{i,j})
                            if size(xls_inp1{i,j},1) > 1
                                % If more than one element is listed
                                xls_rep = [];
                                for k = 1 :  size(xls_inp1{i,j},1)
                                    if k == size(xls_inp1{i,j},1)
                                        xls_rep = [xls_rep,xls_inp1{i,j}{k}];
                                    else
                                        xls_rep = [xls_rep,xls_inp1{i,j}{k},','];
                                    end
                                end
                                xls_inp1{i,j} = xls_rep;
                            else
                                xls_inp1{i,j} =  xls_inp1{i,j}{:};
                            end
                            
                        end
                    end
                end
                
                xls_inp = ...
                    [num2cell(table_results.GridVoltage_statistics(:,1)),...
                    xls_inp1(:,1),...
                    num2cell(table_results.GridVoltage_statistics(:,2)),...
                    xls_inp1(:,2),...
                    num2cell(table_results.GridVoltage_statistics(:,3)),...
                    xls_inp1(:,3),...
                    num2cell(table_results.GridVoltage_statistics(:,4)),...
                    num2cell(table_results.GridVoltage_statistics(:,5)),...
                    xls_inp1(:,4),...
                    xls_inp1(:,5),...
                    xls_inp1(:,6)];
                
                xls_block = [];
                xls_block = [xls_block,xls_inp];
                xls_block = ...
                    [header_definition.Column_IDs_for_GridVoltage_statistics;xls_block];
                
                xls_results.GridVoltage_statistics = xls_block;
                clear xls_block xls_inp1 xls_inp xls_rep i j k
            else
                xls_results.GridVoltage_statistics = [];
            end
            
            if param.XLS == 1
                % -----------------------------------------------------------
                % OUTPUT FOR XLS FILE (GRID COMPARISON)
                % -----------------------------------------------------------
                % Output for excel files
                % Sheet 1 : - xls_results.GridSummary_Short,xls_results.GridVoltage_statistics
                
                % Max column size for excel
                sheet1.max_column_size = size([xls_results.GridSummary_Short,xls_results.GridVoltage_statistics],2);
                sheet1.max_row_size = size(xls_results.GridSummary_Short,1);
                
                if ~isempty(xls_results.GridVoltage_statistics)
                    if size(xls_results.GridVoltage_statistics,1) ~= sheet1.max_row_size
                        error('Grid comparison rows do not match for voltage results and grid summary')
                    end
                end
                
                sheet1.table = cell(sheet1.max_row_size,sheet1.max_column_size);
                
                % Add summary to sheet1
                inpval = [];
                inpval = [xls_results.GridSummary_Short];
                
                % If save voltage results exist
                % Add Voltage_statistics to sheet1
                if obj.Simulation_Options.Save_Voltage_Results == 1
                    inpval = [inpval, xls_results.GridVoltage_statistics];
                end
                
                % Add to table
                sheet1.table(1:size(inpval,1), 1 : size(inpval,2)) = ...
                    inpval;
                
                if sheet1.max_column_size < 11
                    % If sheet 1 is smaller than main header, expand table
                    header_definition.Row_IDs_for_sheet1 = cell(1,11);
                    sheet1.table = ...
                        [sheet1.table , cell(size(sheet1.table,1),11-size(sheet1.table,2))];
                else
                    header_definition.Row_IDs_for_sheet1 = cell(1,sheet1.max_column_size);
                end
                
                header_definition.Row_IDs_for_sheet1{1,1} = 'Voltage violation comparison for grids - summary';
                
                if obj.Simulation_Options.Save_Voltage_Results == 1
                    header_definition.Row_IDs_for_sheet1{1,4} = 'Additional voltage analysis comparison for grids';
                    header_definition.Row_IDs_for_sheet1{1,7} = 'Scenario';
                    header_definition.Row_IDs_for_sheet1{1,8} = obj.Scenarios{param.S};
                else
                    header_definition.Row_IDs_for_sheet1{1,4} = 'No additional voltage analysis comparison for grids';
                    header_definition.Row_IDs_for_sheet1{1,7} = 'Scenario';
                    header_definition.Row_IDs_for_sheet1{1,8} = obj.Scenarios{param.S};
                end
                % Add main header to table
                sheet1.table = [header_definition.Row_IDs_for_sheet1;sheet1.table];
                
                % -----------------------------------------------------------
                % Output for excel files
                % Sheet 2 : - xls_results.GridSummary_Full
                
                sheet2.table = xls_results.GridSummary_Full;
                sheet2.max_column_size = size(xls_results.GridSummary_Full,2);
                
                if sheet2.max_column_size < 11
                    % If sheet 2 is smaller than main header, expand table
                    header_definition.Row_IDs_for_sheet2 = cell(1,11);
                    sheet2.table = ...
                        [sheet2.table , cell(size(sheet2.table,1),11-size(sheet2.table,2))];
                else
                    header_definition.Row_IDs_for_sheet2 = cell(1,sheet2.max_column_size);
                end
                
                header_definition.Row_IDs_for_sheet2{1,1} = ...
                    'Voltage violation comparison between grids';
                header_definition.Row_IDs_for_sheet2{1,4} = 'Scenario';
                header_definition.Row_IDs_for_sheet2{1,5} = obj.Scenarios{param.S};
                
                % Add main header to table
                sheet2.table = [header_definition.Row_IDs_for_sheet2;sheet2.table];
                
                % Output values for function
                xls_output.Sheet1 =  sheet1.table;
                xls_output.Sheet2 =  sheet2.table;
            else
                xls_output = [];
            end
            
        end
        % compare grids function
        
        function [table_results,xls_output] = compare_grids_all_scenarios(obj,varargin)
            % COMPARE_GRIDS_ALL_SCENARIOS
            if numel(varargin) == 1
                if strcmp(varargin{1},'xls') == 1
                    param.XLS = 1; % Create xls output
                else
                    param.XLS = 0; % Do not create xls output
                end
            else
                param.XLS = 0;
            end
            
            % Run dataset comparison between grids for all scenarios
            for S = 1 : numel(obj.Scenarios)
                input_results = [];
                xls_input = [];
                [input_results,xls_input] = obj.compare_grids(S,'xls');
                
                eval(['table_scen_', int2str(S), ' = input_results;']);
                eval(['xls_scen_', int2str(S), ' = xls_input;']);
                
                % -----------------------------------------------------
                
                % $$ table_results.CompleteSummary_Full is a 4D array
                % 1st dimension is dataset (:)
                % 2nd dimension is scenario (S)
                % 3rd dimension is grid (G)
                % 4th dimension is value observed (i)
                %   1...number of violations, 2...viol. in %, 3...nodes
                %   affected, 4...nodes affected in %
                table_results.CompleteSummary_Full(:,S,:,:) = ...
                    input_results.GridSummary_Full;
                
                % §§ table_results.CompleteSummary_Short is a 4D array
                % 1st dimension is scenario (S)
                % 2nd dimension is grid (G)
                % 3rd dimension is observed data (i)
                %   1...number of violations, 2...viol. in %, 3...nodes
                %   affected, 4...nodes affected in %
                % 4th dimension is observed value
                %   1...max value, 2...min value, 3...mean value, 4...sum
                %   value
                table_results.CompleteSummary_Short(S,:,:,:) = ...
                    input_results.GridSummary_Short;
                % -----------------------------------------------------
                
                % §§ table_results.CompleteVoltage_statistics is a 3D array
                % 1st dimension is scenario (S)
                % 2nd dimension is grid (G)
                % 3rd dimension is observed value
                %   1...max voltage in all datasets for grid, 2...min
                %   voltage in all datasets for grid, 3...max Upp
                %   difference in all datasets for grid 4...mean voltage in
                %   all datasets for grid, 5...mean std of voltages for all
                %   datasets for grid
                table_results.CompleteVoltage_statistics(S,:,:) = ...
                    input_results.GridVoltage_statistics;
                
                % §§ table_results.GridVoltage_statistics_at_Node is a 3D array
                % 1st dimension is scenario (S)
                % 2nd dimension is grid (G)
                % 3rd dimension is node where extreme value occurs
                %   1...node with max voltage in all datasets for grid,
                % 2...node with min voltage in all datasets for grid,
                % 3...node with max Upp difference in all datasets for grid
                % 4...most common node(s) where max voltages occur
                % 5...most common node(s) where min voltages occur
                % 6...most common node(s) where max Upp diff. occur
                table_results.CompleteVoltage_statistics_at_Node(S,:,:) = ...
                    input_results.GridVoltage_statistics_at_Node;
                
                % -------------------------------------------------------
                % §§ table_results.ScenarioGridHistogram_Violations
                %    Number of violations for each dataset
                % §§ table_results.ScenarioGridHistogram_Violations_at_Nodes
                %    Number of nodes affected for each dataset
                % 1st dimension is the dataset (cd)
                % 2nd dimension is the grid (G)
                % 3rd dimension is the scenario (S)
                %    the Values are the violations or number of nodes
                %    affected for each dataset
                
                % §§ table_results.ScenarioNodeHistogram_Violations
                %    Number of violations for each dataset for each node
                %    for {G} grid and scenario
                % Cell dimension is scenario xgrid
                %   1st dimension is scenario
                %   2nd dimension is grid
                %    1st dimension in cell is dataset
                %    2nd dimension in cell is node
                table_results.ScenarioGridHistogram_Violations(:,:,S) = ...
                    input_results.GridHistogram_Violations;
                table_results.ScenarioGridHistogram_Violations_at_Nodes(:,:,S) = ...
                    input_results.GridHistogram_Violations_at_Nodes;
                
                table_results.ScenarioNodeHistogram_Violations(S,:) = ...
                    input_results.NodeHistogram_Violations;
                % -------------------------------------------------------
                % XLS output creation
                % -------------------------------------------------------
                % Correct the header for all scenario report
                header_definition.Column_IDs_for_sheet1_correction = xls_input.Sheet1(1:2,:);
                header_definition.Column_IDs_for_sheet1_correction{1,1} = 'Voltage violation comparison for grids and scenarios - summary';
                header_definition.Column_IDs_for_sheet1_correction{2,1} = header_definition.Column_IDs_for_sheet1_correction{1,8};
                header_definition.Column_IDs_for_sheet1_correction{1,7} = '';
                header_definition.Column_IDs_for_sheet1_correction{1,8} = '';
                
                xls_input.Sheet1(1:2,:) = header_definition.Column_IDs_for_sheet1_correction;
                if S == 1
                    header_definition.empty_row_between_grid_results = 1;
                    sheet1.curr_row = 0;
                    sheet1.table = [];
                    sheet1.table = [sheet1.table; xls_input.Sheet1];
                else
                    if size(sheet1.table,2) < size(xls_input.Sheet1,2)
                        sheet1.table = [sheet1.table, cell(size(sheet1.table,1),size(xls_input.Sheet1,2) - size(sheet1.table,2))];
                        
                    elseif size(sheet1.table,2) > size(xls_input.Sheet1,2)
                        
                        sheet1.table(sheet1.curr_row + ...
                            (1:size(xls_input.Sheet1,1)),1:size(xls_input.Sheet1,2)) = ...
                            xls_input.Sheet1;
                    else
                        sheet1.table = [sheet1.table; xls_input.Sheet1];
                    end
                    
                end
                % Add empty line
                if S ~= numel(obj.Scenarios)
                    sheet1.table = [sheet1.table;
                        cell(header_definition.empty_row_between_grid_results,size(sheet1.table,2))];
                    sheet1.curr_row = size(sheet1.table,1);
                end
                
                % Sheet 2
                
                if S == 1
                    sheet2.table1 = ...
                        cell(size(table_results.ScenarioGridHistogram_Violations,1),...
                        numel(obj.Grid_Variants) * numel(obj.Scenarios) );
                    
                    sheet2.table2 = ...
                        cell(size(table_results.ScenarioGridHistogram_Violations_at_Nodes,1),...
                        numel(obj.Grid_Variants) * numel(obj.Scenarios) );
                    
                    header_definition.Column_Grid_Scenario_locations = ...
                        repmat(1:numel(obj.Scenarios),numel(obj.Grid_Variants),1) + ...
                        repmat((0:numel(obj.Scenarios):(numel(obj.Grid_Variants) * numel(obj.Scenarios)-1))',...
                        1,numel(obj.Grid_Variants));
                    % rows are grids, columns are scenarios
                    
                    header_definition.Column_IDs_sheet2table1 = cell(3,numel(obj.Grid_Variants) * numel(obj.Scenarios));
                    header_definition.Column_IDs_sheet2table2 = cell(3,numel(obj.Grid_Variants) * numel(obj.Scenarios));
                    
                    if obj.x_axis_value == 2
                        header_definition.Column_IDs_sheet2table1{1,1} = 'Voltage violation comparison between grids and scenarios (in % of time)';
                        header_definition.Column_IDs_sheet2table2{1,1} = 'Comparison of number of nodes with voltage violations in % of time for different grids and scenarios';
                    else
                        header_definition.Column_IDs_sheet2table1{1,1} = 'Voltage violation comparison between grids and scenarios (number of times)';
                        header_definition.Column_IDs_sheet2table2{1,1} = 'Comparison of number of nodes with voltage violations for different grids and scenarios';
                    end
                    
                    for hG = 1 : numel(obj.Scenarios)
                        idg = header_definition.Column_Grid_Scenario_locations(hG,1);
                        header_definition.Column_IDs_sheet2table1{2,idg} = obj.Grid_Variants{hG};
                        for hS = 1 : numel(obj.Grid_Variants)
                            ids = header_definition.Column_Grid_Scenario_locations(hG,hS);
                            header_definition.Column_IDs_sheet2table1{3,ids} = obj.Scenarios{hS};
                        end
                    end
                    header_definition.Column_IDs_sheet2table2(2:3,:)=header_definition.Column_IDs_sheet2table1(2:3,:);
                    clear hS hG idg ids
                    
                    header_definition.Row_IDs_for_Datasets = [];
                    for cd = 1 : obj.Datasets
                        header_definition.Row_IDs_for_Datasets{cd,1} = ['Set ' int2str(cd)];
                    end
                    header_definition.Row_IDs_for_Datasets = [{'Dataset'};header_definition.Row_IDs_for_Datasets];
                    header_definition.Row_IDs_for_Datasets_for_sheet2 = ...
                        [{''};{''};header_definition.Row_IDs_for_Datasets];
                end
                
                
                for G = 1 : numel(obj.Grid_Variants)
                    idx = header_definition.Column_Grid_Scenario_locations(G,S);
                    sheet2.table1(:,idx) = num2cell( table_results.ScenarioGridHistogram_Violations(:,G,S) );
                    sheet2.table2(:,idx) = num2cell( table_results.ScenarioGridHistogram_Violations_at_Nodes(:,G,S) );
                end
            end
            header_definition.empty_column_between_sheet2_tables = 0;
            sheet2.table1 = [header_definition.Column_IDs_sheet2table1 ;sheet2.table1];
            sheet2.table1 = [header_definition.Row_IDs_for_Datasets_for_sheet2 ,sheet2.table1];
            sheet2.table2 = [header_definition.Column_IDs_sheet2table2 ;sheet2.table2];
            sheet2.table2 = [header_definition.Row_IDs_for_Datasets_for_sheet2 ,sheet2.table2];
            
            sheet2.table = [sheet2.table1, cell(size(sheet2.table1,1),...
                header_definition.empty_column_between_sheet2_tables),...
                sheet2.table2];
            
            if param.XLS == 1
                % Output values for function
                xls_output.Sheet1 =  sheet1.table;
                xls_output.Sheet2 =  sheet2.table;
            else
                xls_output=[];
            end
        end % compare_grids_all_scenarios
        
        function display_datasets(obj,varargin)
            % Display datasets function displays dataset comparisons for
            % specified grid G and specified scenario S
            if numel(varargin) == 2
                param.S = varargin{1}; % Scenario S selected
                param.G = varargin{2}; % Grid variant G selected
            else
                error('ErrorTests:convertTest',...
                    'Error using display_datasets\nToo many input arguments.');
            end
            if obj.Datasets == 1
                error('Only one Dataset, cannot compare');
            end
            
            % Create table result values (input_results) using compare_datasets function
            [input_results,~] = obj.compare_datasets(param.S,param.G);
            
            % Prepare the results for plotting - write to table_results
            table_results.voltage_violations = input_results.Summary(:,obj.x_axis_value);
            table_results.nodes_violated = input_results.Summary(:,obj.x_axis_value+2);
            % Prepare voltage results-statistics
            if obj.Simulation_Options.Save_Voltage_Results == 1
                table_results.max_voltage = input_results.Voltage_statistics(:,1);
                table_results.min_voltage = input_results.Voltage_statistics(:,2);
                table_results.max_upp_dif = input_results.Voltage_statistics(:,3);
                table_results.mean_voltag = input_results.Voltage_statistics(:,4);
            end
            % Check if violations are present at datasets
            if sum(abs(table_results.voltage_violations)) == 0
                disp(' No voltage violations at any dataset ');
                return; % Cancel display_datasets function if no violations occur
            end
            
            % Flip dimensions for barh (1 is on top, last dataset on bottom)
            graph_.voltage_violations = flipdim(table_results.voltage_violations,1);
            graph_.nodes_violated = flipdim(table_results.nodes_violated,1);
            if obj.Simulation_Options.Save_Voltage_Results == 1
                graph_.max_voltage = flipdim(table_results.max_voltage,1);
                graph_.min_voltage = flipdim(table_results.min_voltage,1);
                graph_.max_upp_dif = flipdim(table_results.max_upp_dif,1);
                graph_.mean_voltag = flipdim(table_results.mean_voltag,1);
            end
            
            % Axis text defined
            table_labels.datasets = [];
            for i = 1 : obj.Datasets
                table_labels.y.datasets{i,1} = ['Set ' int2str(i)];
            end
            
            if obj.x_axis_value == 2 % Percent
                table_labels.x.voltage_violations = 'Voltage violations in % of time for dataset';
                table_labels.x.nodes_violated = 'Nodes affected by voltage violations for dataset (% of all nodes)';
            else
                table_labels.x.voltage_violations = 'Number of voltage violations for dataset';
                table_labels.x.nodes_violated = 'Number of nodes affected by voltage violations for dataset';
            end
            % Dataset y tick
            table_labels.y.tick = 1;
            if obj.Datasets > 10 && obj.Datasets <= 20
                table_labels.y.tick = round(obj.Datasets/5);
            elseif  obj.Datasets > 20
                table_labels.y.tick = round(obj.Datasets/10);
            end
            
            graph_.x.voltage_violations = table_labels.x.voltage_violations;
            graph_.x.nodes_violated = table_labels.x.nodes_violated;
            graph_.y.datasets = table_labels.y.datasets;
            
            graph_.y.tick = 1: table_labels.y.tick:obj.Datasets;
            graph_.y.datasets = table_labels.y.datasets(graph_.y.tick);
            clear i
            
            % Plot the dataset comparisons for specific grid and specific scenario
            % input value defines the number of subplots
            myplot1 = plot_horizontal_bar(2);
            % datasets(input_values,axis,xlabel,ytick_numerical,ytick_text,scen,grid)
            myplot1 = myplot1.datasets(graph_.voltage_violations, 1,...
                graph_.x.voltage_violations,...
                graph_.y.tick,...
                graph_.y.datasets,...
                param.S, param.G);
            
            myplot1 = myplot1.datasets(graph_.nodes_violated, 2,...
                graph_.x.nodes_violated,...
                graph_.y.tick,...
                graph_.y.datasets);
            
        end
        % function display_datasets
        
        function display_grids(obj,varargin)
            % Display grids function displays a grid comparisons for
            % specified scenario S. The results display the comparisons of all
            % datasets and their impact on specific grids
            if numel(varargin) == 1
                param.S = varargin{1}; % Scenario S selected
            else
                error('ErrorTests:convertTest',...
                    'Error using display_datasets\nToo many input arguments.');
            end
            if numel(obj.Grid_Variants) == 1
                error('Only one Grid, cannot compare');
            end
            
            [input_results,~] = compare_grids(obj,param.S);
            % -------------------------------------------------------
            table_results.summary_violations = ...
                squeeze(input_results.GridSummary_Short(:,obj.x_axis_value,1:3));
            table_results.summary_nodes = ...
                squeeze(input_results.GridSummary_Short(:,obj.x_axis_value+2,1:3));
            % row is the grid observed, and the columns are : max value, min
            % value and mean value
            
            % Check if violations are present at grids
            if sum(abs(table_results.summary_violations(:))) == 0
                disp(' No voltage violations at any grid ');
                return; % Cancel display_datasets function if no violations occur
            end
            
            % Flip dimensions for barh (1 is on top, last dataset on bottom)
            graph_.summary_violations = flipdim(table_results.summary_violations,1);
            graph_.summary_nodes = flipdim(table_results.summary_nodes,1);
            
            % Axis text defined
            table_labels.grids = [];
            for i = 1 : numel(obj.Grid_Variants)
                table_labels.y.grids{i,1} = obj.Grid_Variants{i};
            end
            
            if obj.x_axis_value == 2 % Percent
                table_labels.x.summary_violations = 'Voltage violations in % of time for dataset';
                table_labels.x.summary_nodes = 'Nodes affected by voltage violations for dataset (% of all nodes)';
            else
                table_labels.x.summary_violations = 'Number of voltage violations for dataset';
                table_labels.x.summary_nodes = 'Number of nodes affected by voltage violations for dataset';
            end
            
            % Dataset y tick
            table_labels.y.tick = 1;
            if numel(obj.Grid_Variants) > 10 && numel(obj.Grid_Variants) <= 20
                table_labels.y.tick = round(numel(obj.Grid_Variants)/5);
            elseif  numel(obj.Grid_Variants) > 20
                table_labels.y.tick = round(numel(obj.Grid_Variants)/10);
            end
            
            graph_.x.summary_violations = table_labels.x.summary_violations;
            graph_.x.summary_nodes = table_labels.x.summary_nodes;
            graph_.y.grids = table_labels.y.grids;
            
            graph_.y.tick = 1: table_labels.y.tick:numel(obj.Grid_Variants);
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
                param.S,...
                graph_.legend);
            
            myplot1 = myplot1.grids(graph_.summary_violations, 2,...
                graph_.x.summary_nodes,...
                graph_.y.tick,...
                graph_.y.grids);
        end
        % function display_grids
        
        function display_grids_all_scenarios(obj,varargin)
            % Display grids function displays a grid comparisons for
            % specified scenario S. The results display the comparisons of all
            % datasets and their impact on specific grids
            if numel(varargin) == 1
                if strcmp(varargin{1},'max') == 1
                    selected_observation = 1;
                elseif strcmp(varargin{1},'min') == 1
                    selected_observation = 2;
                elseif strcmp(varargin{1},'mean') == 1
                    selected_observation = 3;
                elseif strcmp(varargin{1},'all') == 1
                    selected_observation = 4;
                    
                else
                    error('ErrorTests:convertTest',...
                        'Unknown input command.');
                end
            else
                error('ErrorTests:convertTest',...
                    'Error using display_grids_all_scenarios\nToo many input arguments.');
            end
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
            
            % Flip dimensions for barh (1 is on top, last dataset on bottom)
            for i = 1 : 3 % Max, min, mean
                graph_.summary_violations{i} = flipdim(table_results.summary_violations_all{i},1);
                graph_.summary_nodes{i} = flipdim(table_results.summary_node_all{i},1);
            end
            
            % Axis text defined
            table_labels.grids = [];
            for i = 1 : numel(obj.Grid_Variants)
                table_labels.y.grids{i,1} = obj.Grid_Variants{i};
            end
            
            if obj.x_axis_value == 2 % Percent
                table_labels.x.summary_violations = 'Voltage violations in % of time for dataset';
                table_labels.x.summary_nodes = 'Nodes affected by voltage violations for dataset (% of all nodes)';
            else
                table_labels.x.summary_violations = 'Number of voltage violations for dataset';
                table_labels.x.summary_nodes = 'Number of nodes affected by voltage violations for dataset';
            end
            
            % Dataset y tick
            table_labels.y.tick = 1;
            if numel(obj.Grid_Variants) > 10  && numel(obj.Grid_Variants) <= 20
                table_labels.y.tick = round(numel(obj.Grid_Variants)/5);
            elseif  numel(obj.Grid_Variants) > 20
                table_labels.y.tick = round(numel(obj.Grid_Variants)/10);
            end
            
            graph_.x.summary_violations = table_labels.x.summary_violations;
            graph_.x.summary_nodes = table_labels.x.summary_nodes;
            graph_.y.grids = table_labels.y.grids;
            
            graph_.y.tick = 1: table_labels.y.tick:numel(obj.Grid_Variants);
            graph_.y.grids = table_labels.y.grids(graph_.y.tick);
            
            for i = 1 : numel(obj.Scenarios)
                graph_.legend{i} = obj.Scenarios{i};
            end
            
            graph_.title{1} = 'Max calculated values for all observed timepoints, grids and all scenarios';
            graph_.title{2} = 'Min calculated values for all observed timepoints, grids and all scenarios';
            graph_.title{3} = 'Mean calculated values for all observed timepoints, grids and all scenarios';
            
            if selected_observation == 4 % Display all (min, max, mean) in two figures
                % Voltage violations - min, max, mean
                myplot1 = plot_horizontal_bar(3);
                myplot1 = myplot1.grids_and_scenarios(graph_.summary_violations{2}, 1,...
                    [],...
                    graph_.y.tick,...
                    graph_.y.grids,...
                    graph_.title{2},...
                    graph_.legend);
                
                myplot1 = myplot1.grids_and_scenarios(graph_.summary_violations{1}, 2,...
                    [],...
                    graph_.y.tick,...
                    graph_.y.grids,...
                    graph_.title{1});
                
                myplot1 = myplot1.grids_and_scenarios(graph_.summary_violations{3}, 3,...
                    graph_.x.summary_violations,...
                    graph_.y.tick,...
                    graph_.y.grids,...
                    graph_.title{3});
                
                % Nodes with violations - min, max, mean
                myplot2 = plot_horizontal_bar(3);
                myplot2 = myplot2.grids_and_scenarios(graph_.summary_nodes{2}, 1,...
                    [],...
                    graph_.y.tick,...
                    graph_.y.grids,...
                    graph_.title{2},...
                    graph_.legend);
                
                myplot2 = myplot2.grids_and_scenarios(graph_.summary_nodes{1}, 2,...
                    [],...
                    graph_.y.tick,...
                    graph_.y.grids,...
                    graph_.title{1});
                
                myplot2 = myplot2.grids_and_scenarios(graph_.summary_nodes{3}, 3,...
                    graph_.x.summary_nodes,...
                    graph_.y.tick,...
                    graph_.y.grids,...
                    graph_.title{3});
            else
                % Display only min or max or mean value
                % Voltage violations - min/ max/ mean
                myplot1 = plot_horizontal_bar(2);
                myplot1 = myplot1.grids_and_scenarios(...
                    graph_.summary_violations{selected_observation}, 1,...
                    graph_.x.summary_violations,...
                    graph_.y.tick,...
                    graph_.y.grids,...
                    graph_.title{selected_observation},...
                    graph_.legend);
                
                myplot1 = myplot1.grids_and_scenarios(...
                    graph_.summary_nodes{selected_observation}, 2,...
                    graph_.x.summary_nodes,...
                    graph_.y.tick,...
                    graph_.y.grids);
            end
        end
        % function display_grids_and_scenarios
        
        function [table_results,xls_output] = display_node_voltage(obj,varargin)
            % display_node_voltage function creates a result table
            %for specifid S,G,D,N and include the voltage
            % analysis results and limits
            if numel(varargin) == 5
                param.S = varargin{1}; % Scenario S selected
                param.G = varargin{2}; % Grid G selected
                param.D = varargin{3}; % Dataset D selected
                param.N = varargin{4}; % Node N selected
                if strcmp(varargin{5},'xls') == 1
                    param.XLS = 1;
                else
                    param.XLS = 0;
                end
            elseif numel(varargin) == 4
                param.S = varargin{1}; % Scenario S selected
                param.G = varargin{2}; % Grid G selected
                param.D = varargin{3}; % Dataset D selected
                param.N = varargin{4}; % Node N selected
                param.XLS = 0;
            else
                error('ErrorTests:convertTest',...
                    'Error using display_node_voltage\nToo many/few input arguments.');
            end
            
            if obj.Simulation_Options.Save_Voltage_Results ~=1
                error('No voltages saved during simulation. To display voltages values must be saved.');
                return
            end
            
            Result = []; Grid = []; Load_Infeed_Data = [];
            load([obj.Result_Filepath,filesep,obj.Result_Filenames{param.S}],...
                'Result','Grid','Load_Infeed_Data');
            % Load the resulting mat file
            
            % Node_Voltages are a 4D array, where 1st dim. are datasets,
            % 2nd the timepoints, 3rd are the nodes, and 4th are the phases
            % ---------------------------------------
            % §§table_results: timeplot: Voltages at Scenario S, Grid G, dataset D
            % and node N for L1, L2, L3 in p.u. Display includes the
            % voltage violations (1=yes, 0=no) and upper and lower limits
            table_results.timeplot_for_node.id_scen = obj.Scenarios{param.S};
            table_results.timeplot_for_node.id_grid = obj.Grid_Variants{param.G};
            table_results.timeplot_for_node.id_dataset = param.D;
            table_results.timeplot_for_node.id_node = param.N;
            
            rated_voltages_pe = ...
                vertcat(Grid.(obj.Grid_Variants{param.G}).All_Node.Points.Rated_Voltage_phase_earth);
            all_voltage_limits = ...
                vertcat(Grid.(obj.Grid_Variants{param.G}).All_Node.Points.Voltage_Limits)/100;
            table_results.timeplot_for_node.voltage_limits_uul = ...
                repmat(all_voltage_limits(param.N,1),obj.Timepoints,1);
            table_results.timeplot_for_node.voltage_limits_ull = ...
                repmat(all_voltage_limits(param.N,2),obj.Timepoints,1);
            table_results.timeplot_for_node.voltages = ...
                squeeze(Result.(obj.Grid_Variants{param.G}).Node_Voltages(param.D,:,param.N,:))./...
                repmat(rated_voltages_pe(param.N,:),obj.Timepoints,1);
            table_results.timeplot_for_node.voltage_violations = ...
                squeeze(Result.(obj.Grid_Variants{param.G}).Voltage_Violation_Analysis(param.D,:,param.N))';
            % -----------------------------------------------------------
            % GRAPH DISPLAY (NODE VOLTAGE FOR S,G,D)
            % -----------------------------------------------------------
            
            graph_.voltages = table_results.timeplot_for_node.voltages;
            graph_.voltage_limits_uul = table_results.timeplot_for_node.voltage_limits_uul;
            graph_.voltage_limits_ull = table_results.timeplot_for_node.voltage_limits_ull;
            graph_.voltage_violations = table_results.timeplot_for_node.voltage_violations;
            
            graph_.input = [graph_.voltages,graph_.voltage_limits_uul,...
                graph_.voltage_limits_ull,graph_.voltage_violations];
            
            graph_.x.label = 'Timepoints';
            graph_.y.label = 'Voltages (phase-earth, p.u.)';
            graph_.title = ['Voltages for grid ', obj.Grid_Variants{param.G},...
                ', scenario ', obj.Scenarios{param.S}, ', dataset ', int2str(param.D), ' and node ',...
                Grid.(obj.Grid_Variants{param.G}).All_Node.Points(param.N).Node_Name   ];
            graph_.legend{1} = 'L1'; graph_.legend{2} = 'L2'; graph_.legend{3} = 'L3';
            graph_.legend{4} = 'Upper/lower voltage limit';
            graph_.legend{5} = 'Voltage violation';
            
            % Line graph for voltages
            myplot1 = plot_line_graphs(1);
            % input: [L1,L2,L3, uul, ull, vviolation]
            % xlabel, ylabel, title, legend
            myplot1.timeplot_for_node(graph_.input,1, graph_.x.label,...
                graph_.y.label, graph_.title, graph_.legend);
            
            if param.XLS == 1
                % -----------------------------------------------------------
                % OUTPUT FOR XLS FILE (NODE VOLTAGE FOR S,G,D)
                % -----------------------------------------------------------
                % §§ xls_results: timeplot_for_node
                % Header definition:
                header_definition.timeplot_for_node_Row_IDs = [];
                header_definition.timeplot_for_node_Row_IDs(:,1) = 1 : obj.Timepoints;
                
                % Add column headers 1st row
                header_definition.timeplot_for_node_Column_IDs = [];
                header_definition.timeplot_for_node_Column_IDs{1,1} = 'Timepoint';
                header_definition.timeplot_for_node_Column_IDs{1,2} = 'Phase L1';
                header_definition.timeplot_for_node_Column_IDs{1,3} = 'Phase L2';
                header_definition.timeplot_for_node_Column_IDs{1,4} = 'Phase L3';
                header_definition.timeplot_for_node_Column_IDs{1,5} = 'Voltage upper limit';
                header_definition.timeplot_for_node_Column_IDs{1,6} = 'Voltage lower limit';
                header_definition.timeplot_for_node_Column_IDs{1,7} = 'Voltage violations';
                
                header_definition.timeplot_for_node_Column_IDs = ...
                    [cell(1,7);header_definition.timeplot_for_node_Column_IDs];
                header_definition.timeplot_for_node_Column_IDs{1,1} = ['Grid ', obj.Grid_Variants{param.G}];
                header_definition.timeplot_for_node_Column_IDs{1,2} = ['Scenario ', obj.Grid_Variants{param.S}];
                header_definition.timeplot_for_node_Column_IDs{1,3} = ['Set ', int2str(param.D)];
                header_definition.timeplot_for_node_Column_IDs{1,4} = ['Node ', int2str(param.N)];
                header_definition.timeplot_for_node_Column_IDs{1,5} = ['Node name: ', Grid.(obj.Grid_Variants{param.G}).All_Node.Points(param.N).Node_Name ];
                header_definition.timeplot_for_node_Column_IDs{1,6} = 'Values in p.u.';
                
                % Create xls_results.timeplot_for_node
                xls_results.timeplot_for_node = ...
                    num2cell([header_definition.timeplot_for_node_Row_IDs,...
                    table_results.timeplot_for_node.voltages,...
                    table_results.timeplot_for_node.voltage_limits_uul,...
                    table_results.timeplot_for_node.voltage_limits_ull,...
                    table_results.timeplot_for_node.voltage_violations]);
                
                xls_results.timeplot_for_node = ...
                    [header_definition.timeplot_for_node_Column_IDs;...
                    xls_results.timeplot_for_node];
                
                % -----------------------------------------------------------
                % Output for excel files
                % Sheet 1 : - xls_results.timeplot_for_node
                xls_output.Sheet1 = xls_results.timeplot_for_node;
            else
                xls_output = [];
            end
        end
        % function display_node_voltage
        
        function [table_results] = display_node_variations_datasets(obj,varargin)
            %Function Display node variations displays the variations of
            %nodes for - G,S,D, all timepoints
            % If the user wants to analyse all datasets instead of just
            % one, the third input should be set to 'all'
            if numel(varargin) == 4
                param.S = varargin{1}; % Scenario S selected
                param.G = varargin{2}; % Grid G selected                
                if ischar(varargin{3})
                    if strcmp(varargin{3},'all') == 1
                        param.D = 1 : obj.Datasets;
                    end
                else
                    param.D = varargin{3}; % Dataset D selected
                end
                if strcmp(varargin{4},'plot')
                    param.PLT = 1; % Plot
                else
                    param.PLT = 0;
                end
            elseif numel(varargin) == 3
                param.S = varargin{1}; % Scenario S selected
                param.G = varargin{2}; % Grid G selected
                if ischar(varargin{3})
                    if strcmp(varargin{3},'all') == 1
                        param.D = 1 : obj.Datasets;
                    end
                else
                    param.D = varargin{3}; % Dataset D selected
                end
                param.PLT = 0; % No plotting
            else
                error('ErrorTests:convertTest',...
                    'Error using display_node_variations_datasets\nToo many/few input arguments.');
            end
            
            if obj.Simulation_Options.Save_Voltage_Results ~=1
                error('No voltages saved during simulation, can not plot');
                return
            end
            % Load results for G,S
            Result = []; Grid = []; Load_Infeed_Data = [];
            load([obj.Result_Filepath,filesep,obj.Result_Filenames{param.S}],...
                'Result','Grid','Load_Infeed_Data');
            
            % Define rated voltages
            rated_voltages_pe = ...
                vertcat(Grid.(obj.Grid_Variants{param.G}).All_Node.Points.Rated_Voltage_phase_earth);
            
            % Write all voltages for all nodes at all timepoints, cells
            % define phases
            table_results.voltages_at_timepoints{1} = ...
                nan( obj.Timepoints * numel(param.D),size(rated_voltages_pe,1) );
            table_results.voltages_at_timepoints{2} = table_results.voltages_at_timepoints{1};
            table_results.voltages_at_timepoints{3} = table_results.voltages_at_timepoints{1};
            
            for j = 1 : numel(param.D)
                for i = 1 : 3
                    table_results.voltages_at_timepoints{i}(obj.Timepoints*(j-1) + (1:obj.Timepoints),:) = ...
                        squeeze(Result.(obj.Grid_Variants{param.G}).Node_Voltages(param.D(j),:,:,i))./repmat( rated_voltages_pe(:,i)',obj.Timepoints,1);
                end
            end
            
            for i = 1 : 3
                % 1st dimension are the ndoes, 2nd dim. is max, min, mean
                % cell location is phase
                table_results.voltageplot_for_nodes{i} = ...
                    [max(table_results.voltages_at_timepoints{i},[],1);
                     min(table_results.voltages_at_timepoints{i},[],1);
                     mean(table_results.voltages_at_timepoints{i},1)]';
            end
            % §§ table_results.voltageplot_for_nodes
            % Cells are the phases
            % 1st column are max values of voltages at node (row), 
            % 2nd column are the min values
            % 3rd column are the mean values
            
            if param.PLT == 1
               %----------------------------------------------------
               % PLOT FUNCTION FOR VOLTAGES
               %----------------------------------------------------               
               graph_.input =  table_results.voltageplot_for_nodes;
               graph_.x.label = 'Nodes';
               graph_.y.label = 'Voltages (phase-earth, p.u.)';
               graph_.legend{1} = 'L1 voltage deviations';
               graph_.legend{2} = 'L2 voltage deviations';
               graph_.legend{3} = 'L3 voltage deviations';
               graph_.legend{4} = 'L1 voltage mean';
               graph_.legend{5} = 'L2 voltage mean';
               graph_.legend{6} = 'L3 voltage mean';
               if numel(param.D) ~= 1
                   graph_.title = ['Voltages for grid ', obj.Grid_Variants{param.G},...
                ', scenario ', obj.Scenarios{param.S}, ', all datasets'];
               else
                   graph_.title = ['Voltages for grid ', obj.Grid_Variants{param.G},...
                ', scenario ', obj.Scenarios{param.S}, ', dataset ', int2str(param.D)];
               end
               
               myplot1 = plot_line_graphs(1);
               myplot1.voltageplot_for_nodes(graph_.input,1,...
                   graph_.x.label,graph_.y.label,...
                   graph_.title,graph_.legend);
            end
            
        end
        % function display_node_variations_datasets
        
        function [table_results] = display_node_variations_scenarios(obj,varargin)
            % display_node_variations_scenarios displays voltage variations
            % for grid G and all datasets in all scenarios
            if numel(varargin) == 2
                param.G = varargin{1}; % Grid G selected
                if strcmp(varargin{2},'plot')
                    param.PLT = 1; % Plot
                else
                    param.PLT = 0;
                end
            elseif numel(varargin) == 1
                param.G = varargin{1}; % Grid G selected
                param.PLT = 0; % No plotting
            else
                error('ErrorTests:convertTest',...
                    'Error using display_node_variations_scenarios\nToo many/few input arguments.');
            end
            
            for S = 1 : numel(obj.Scenarios)
                table_input = [];
                table_input = obj.display_node_variations_datasets(S,param.G,'all') ;

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
            
            if param.PLT == 1
               %----------------------------------------------------
               % PLOT FUNCTION FOR VOLTAGES
               %----------------------------------------------------               
               graph_.input =  table_results.voltageplot_for_nodes;
               graph_.x.label = 'Nodes';
               graph_.y.label = 'Voltages (phase-earth, p.u.)';
               graph_.legend{1} = 'L1 voltage deviations';
               graph_.legend{2} = 'L2 voltage deviations';
               graph_.legend{3} = 'L3 voltage deviations';
               graph_.legend{4} = 'L1 voltage mean';
               graph_.legend{5} = 'L2 voltage mean';
               graph_.legend{6} = 'L3 voltage mean';
               graph_.title = ['Voltages for grid ', obj.Grid_Variants{param.G},...
                   ', all scenarios and all datasets'];               
               
               myplot1 = plot_line_graphs(1);
               myplot1.voltageplot_for_nodes(graph_.input,1,...
                   graph_.x.label,graph_.y.label,...
                   graph_.title,graph_.legend);
            end
            
        end
        % function display_node_variations_scenarios
        
        function [table_results] = display_node_variations_grids(obj,varargin)
            % Compare voltage variations for 
            % all grids for all scenarios and all datasets
            if numel(varargin) == 1
                if strcmp(varargin{1},'plot')
                    param.PLT = 1; % Plot
                else
                    param.PLT = 0;
                end
            elseif numel(varargin) == 0
                param.PLT = 0; % No plotting
            else
                error('ErrorTests:convertTest',...
                    'Error using display_node_variations_scenarios\nToo many/few input arguments.');
            end
            
            for G = 1 : numel(obj.Grid_Variants)
                table_input = [];
                table_input = obj.display_node_variations_scenarios(G);
                
                table_results.voltageplot_for_nodes{G} = table_input.voltageplot_for_nodes;
                % Cell location is the grid
            end
            
            if param.PLT == 1
                graph_.input =  table_results.voltageplot_for_nodes;
                graph_.x.label = 'Nodes';
                graph_.y.label = 'Voltages (phase-earth, p.u.)';
                graph_.legend{1} = 'L1 voltage deviations';
                graph_.legend{2} = 'L2 voltage deviations';
                graph_.legend{3} = 'L3 voltage deviations';
                graph_.legend{4} = 'L1 voltage mean';
                graph_.legend{5} = 'L2 voltage mean';
                graph_.legend{6} = 'L3 voltage mean';
                
                for G = 1 : numel(obj.Grid_Variants)
                    myplot1 = plot_line_graphs(1);
                    graph_.title{G} = ['Voltages for grid ', obj.Grid_Variants{G},...
                        ', all scenarios and all datasets'];
                        myplot1.voltageplot_for_nodes(graph_.input{G},1,...
                        graph_.x.label,graph_.y.label,...
                        graph_.title{G},graph_.legend);
                end
            end
        end
        % function display_node_variations_grids

        function histogram_comparisons_grids_at_scenario(obj,varargin)
            % histogram_comparisons_grids_at_scenario for the S scenario
            if numel(varargin) == 1
                param.S = varargin{1}; % Scenario S selected
            else
                error('ErrorTests:convertTest',...
                    'Error using histogram_comparisons_grids_at_scenario\nToo many input arguments.')
            end
            
            % Load grid results for scenario S
            % Load relevent data from mat file (scenario S, grid G)
            Result = []; Grid = []; Load_Infeed_Data = [];
            load([obj.Result_Filepath,filesep,obj.Result_Filenames{param.S}],...
                'Result','Grid','Load_Infeed_Data');

            table_results.Voltage_violations = [];            
            for G = 1 : numel(obj.Grid_Variants)
                if obj.x_axis_value == 2
                    table_results.Voltage_violations(:,G) = Result.(obj.Grid_Variants{G}).Voltage_Violation_Summary.Number_of_Violations_percent;
                elseif obj.x_axis_value == 1
                    table_results.Voltage_violations(:,G) = Result.(obj.Grid_Variants{G}).Voltage_Violation_Summary.Number_of_Violations;
                end
            end
                        
            graph_.input = table_results.Voltage_violations;
            graph_.Histogram_Limit = max(table_results.Voltage_violations(:));
            graph_.Bins = 20;
            if obj.x_axis_value == 2
                graph_.x.label = 'Voltage violations in % of observed timepoints';
            elseif obj.x_axis_value == 1
               graph_.x.label = 'Number of voltage violations during observations'; 
            end
            graph_.title = ['Histogram of voltage violations for scenario ', obj.Scenarios{param.S}];
            
            myplot1 = plot_histograms(1,obj.Grid_Variants,obj.Scenarios);            
            myplot1.plot_histogram_grids_at_scenario(...
                 graph_.input,1,graph_.Bins,...
                 graph_.Histogram_Limit,...
                 graph_.x.label,...
                 graph_.title);
        end
        % function histogram_comparisons_grids_at_scenario
        
        function histogram_comparisons_scenarios_at_grid(obj,varargin)
            if numel(varargin) == 1
                param.G = varargin{1}; % Scenario S selected
            else
                error('ErrorTests:convertTest',...
                    'Error using histogram_comparisons_scenarios_at_grid\nToo many input arguments.')
            end
            
            % Load grid results for scenario S
            % Load relevent data from mat file (scenario S, grid G)
            table_results.Voltage_violations = [];            
            for S = 1 : numel(obj.Scenarios)
                Result = []; Grid = []; Load_Infeed_Data = [];
                load([obj.Result_Filepath,filesep,obj.Result_Filenames{S}],...
                'Result','Grid','Load_Infeed_Data');
            
                if obj.x_axis_value == 2
                    table_results.Voltage_violations(:,S) = Result.(obj.Grid_Variants{param.G}).Voltage_Violation_Summary.Number_of_Violations_percent;
                elseif obj.x_axis_value == 1
                    table_results.Voltage_violations(:,S) = Result.(obj.Grid_Variants{param.G}).Voltage_Violation_Summary.Number_of_Violations;
                end
            end
            
            graph_.input = table_results.Voltage_violations;
            graph_.Histogram_Limit = max(table_results.Voltage_violations(:));
            graph_.Bins = 20;
            if obj.x_axis_value == 2
                graph_.x.label = 'Voltage violations in % of observed timepoints';
            elseif obj.x_axis_value == 1
               graph_.x.label = 'Number of voltage violations during observations'; 
            end
            graph_.title = ['Histogram of voltage violations for grid ', obj.Grid_Variants{param.G}];
            
            myplot1 = plot_histograms(1,obj.Grid_Variants,obj.Scenarios);            
            myplot1.plot_histogram_scenarios_at_grid(...
                 graph_.input,1,graph_.Bins,...
                 graph_.Histogram_Limit,...
                 graph_.x.label,...
                 graph_.title);            
            
        end
        % function histogram_comparisons_scenarios_at_grid
        
        
        function histogram_comparisons_inputs_at_scenarios(obj,varargin)
            % histogram_comparisons_inputs_at_scenarios for all scenario
            
            
            % Load grid results for scenario S
            for S = 1 : numel(obj.Scenarios)
                Result = []; Grid = []; Load_Infeed_Data = [];
                load([obj.Result_Filepath,filesep,obj.Result_Filenames{S}],...
                    'Result','Grid','Load_Infeed_Data');

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
            %-------------------------------------------------------------
            % Households
            graph_ = [];
            for S = 1 : numel(obj.Scenarios)
                graph_.input(:,S) = table_results.households{S}(:,1)/1000; % to kW
                % Active power of households for S scenario
            end
            
            graph_.Histogram_Limit = max(graph_.input(:));
            graph_.Bins = 20;
            graph_.x.label = 'P (kW)';
            graph_.title = ['Histograms of household active power loads for all scenarios'];
            
            myplot1 = plot_histograms(1,obj.Grid_Variants,obj.Scenarios);            
            myplot1.plot_histogram_inputs_at_scenarios(...
                graph_.input,1,graph_.Bins,...
                graph_.Histogram_Limit,...
                graph_.x.label,...
                graph_.title);
            %------------------------------------------------------
            % Solar
            graph_ = [];
            for S = 1 : numel(obj.Scenarios)
                graph_.input(:,S) = table_results.solar{S}(:,1)/1000; % to kW
                % Active power of households for S scenario
            end            
            graph_.Histogram_Limit = max(graph_.input(:));
            graph_.Bins = 20;
            graph_.x.label = 'P (kW)';
            graph_.title = ['Histograms of solar active power infeeds for all scenarios'];
                        
            myplot2 = plot_histograms(1,obj.Grid_Variants,obj.Scenarios);            
            myplot2.plot_histogram_inputs_at_scenarios(...
                graph_.input,1,graph_.Bins,...
                graph_.Histogram_Limit,...
                graph_.x.label,...
                graph_.title);
            %--------------------------------------------------------
            % El mobility
            graph_ = [];
            for S = 1 : numel(obj.Scenarios)
                graph_.input(:,S) = table_results.solar{S}(:,1)/1000; % to kW
                % Active power of households for S scenario
            end            
            graph_.Histogram_Limit = max(graph_.input(:));
            graph_.Bins = 20;
            graph_.x.label = 'P (kW)';
            graph_.title = ['Histograms of electric mobility active power loads for all scenarios'];
                        
            myplot3 = plot_histograms(1,obj.Grid_Variants,obj.Scenarios);            
            myplot3.plot_histogram_inputs_at_scenarios(...
                graph_.input,1,graph_.Bins,...
                graph_.Histogram_Limit,...
                graph_.x.label,...
                graph_.title);
            %--------------------------------------------------------
            % Balance
            graph_ = [];
            for S = 1 : numel(obj.Scenarios)
                graph_.input(:,S) = table_results.households{S}(:,1) - ...
                    table_results.solar{S}(:,1) + ...
                    table_results.el_mobility{S}(:,1); 
                % Active power of households for S scenario
            end            
            graph_.input = graph_.input/1000; % to kW
            graph_.Histogram_Limit = max(graph_.input(:));
            graph_.Bins = 20;
            graph_.x.label = 'P (kW)';
            graph_.title = ['System sum balance for all scenarios'];
                        
            myplot4 = plot_histograms(1,obj.Grid_Variants,obj.Scenarios);            
            myplot4.plot_histogram_inputs_at_scenarios(...
                graph_.input,1,graph_.Bins,...
                graph_.Histogram_Limit,...
                graph_.x.label,...
                graph_.title);

            
        end
        % function histogram_comparisons_inputs_at_scenarios
        
        
    end % methods
end % classdef

