function Scenario_Output = create_result_structure(handles,data,grid_data)

Grid_List = handles.NVIEW_Control.Simulation_Description.Variants;
Timepoints = handles.NVIEW_Control.Simulation_Options.Timepoints_per_dataset;
Datasets = handles.NVIEW_Control.Simulation_Options.Number_of_datasets;

for i = 1 : numel(Grid_List)
    clear res
    % --------------------------------------------------------------------------
    % Bus summary analysis reformat
    % --------------------------------------------------------------------------
    res.bus = grid_data.(Grid_List{i}).bus;
    res.bus_name = grid_data.(Grid_List{i}).bus_name;
        
    if handles.NVIEW_Control.Simulation_Options.Voltage_Analysis == 1
        % Clear variables
        clear dataset_voltage_violation_numbers dataset_violated_nodes_numbers
        
        res.bus_violations = zeros(size(res.bus,1),1);
        
        dataset_voltage_violation_numbers = data.Result.(Grid_List{i}).Voltage_Violation_Summary.Number_of_Violations;
        dataset_violated_nodes_numbers = data.Result.(Grid_List{i}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations;

        res.bus_summary.stat = [ sum(dataset_voltage_violation_numbers),...
                                 100*sum(dataset_voltage_violation_numbers)/(Timepoints*Datasets),...
                                 sum(dataset_violated_nodes_numbers),...
                                 100*sum(dataset_violated_nodes_numbers)/(size(res.bus,1)*Datasets)];
        
        % bus_summary.stat ---------------------------------------
        % 1st column ... sum(Volt.violations)
        % 2nd column ... sum(Volt.violations)/timepoints*dataset
        % 3rd column ... sum(Num.nodes afflicted)
        % 4th column ... sum(Num.nodes afflicted)/bus_no*dataset
        
        res.bus_summary.dataset_voltage_violation_numbers = dataset_voltage_violation_numbers;
        res.bus_summary.dataset_violated_nodes_numbers = dataset_violated_nodes_numbers;
            
        for j = 1 : numel(data.Result.(Grid_List{i}).Voltage_Violation_Summary.Names_of_Nodes_With_Violations)
            nodes_afflicted = [];
            nodes_afflicted = data.Result.(Grid_List{i}).Voltage_Violation_Summary.Names_of_Nodes_With_Violations{j};
            if ~isempty(nodes_afflicted)
                for k = 1 : numel(nodes_afflicted)
                    res.bus_violations( strcmp( grid_data.(Grid_List{i}).bus_name, nodes_afflicted{k} ),1) = ...
                        res.bus_violations( strcmp( grid_data.(Grid_List{i}).bus_name, nodes_afflicted{k} ),1) + 1;
                end
            end
        end
        
        % Define voltages at nodes "Node_Voltages" are a 4D array, where
        % first dim. is the dataset, second is the timepoint, third is the
        % node, and the fourth dim represent the phase values
        
        % Predefine array sizes
        bus_deviations = ...
            nan(size(data.Result.(Grid_List{i}).Node_Voltages,1)*...
                size(data.Result.(Grid_List{i}).Node_Voltages,2)*...
                size(data.Result.(Grid_List{i}).Node_Voltages,3),...
                    size(data.Result.(Grid_List{i}).Node_Voltages,4));       

        
        counter = 0;
        for I = 1 : size(data.Result.(Grid_List{i}).Node_Voltages,1)
            for J = 1 : size(data.Result.(Grid_List{i}).Node_Voltages,2)
                voltage_statistics = [];
                voltage_statistics = ...
                    squeeze(data.Result.(Grid_List{i}).Node_Voltages(I,J,:,:))./...
                    repmat(res.bus(:,3),1,3);
                                
                bus_deviations(counter + (1:size(voltage_statistics,1)),:) = voltage_statistics;
                counter = max(counter + (1:size(voltage_statistics,1)));
            end
        end
        
        
        % Bus deviations, first row are max values, second row are the mean
        % values and third row are the min values
        res.bus_deviations = [nanmax(bus_deviations);
                              nanmean(bus_deviations);
                              nanmin(bus_deviations);];
                          
        
        clear I J counter 
    else
        res.bus_violations = [];
        res.bus_summary = [];
    end
    % --------------------------------------------------------------------------
    % Branch summary analysis reformat
    % --------------------------------------------------------------------------
    res.branch = grid_data.(Grid_List{i}).bus;
    res.branch_name = grid_data.(Grid_List{i}).branch_name;
    if handles.NVIEW_Control.Simulation_Options.Overcurrent_Analysis == 1
        res.branch_violations = zeros(size(res.bus,1),1);
        
        
        clear bv_per_dataset branches_w_bv branches_w_bv_pp branches_afflicted  branch_statistics
        bv_per_dataset = data.Result.(Grid_List{i}).Branch_Violation_Summary.Number_of_Violations;
        branches_w_bv = data.Result.(Grid_List{i}).Branch_Violation_Summary.Number_of_Branches_With_Violations;
        branches_w_bv_pp = data.Result.(Grid_List{i}).Branch_Violation_Summary.Number_of_Branches_With_Violations_percent;
        
        % branch_statistics
        % 1st column ... sum(OC.violations)
        % 2nd column ... sum(OC.violations)/timepoints
        % 3rd column ... mean(Num.branches afflicted)
        % 4th column ... mean(Num.branches afflicted in %)
        % 5th column ... max(Num.branches afflicted)
        % 6th column ...  max(Num.branches afflicted in %)
        
        branch_statistics = [sum(bv_per_dataset)*[1,100] ./ [1,(Timepoints*Datasets)] ,...
            mean(branches_w_bv),mean(branches_w_bv_pp),...
            max(branches_w_bv) , max(branches_w_bv_pp) ];
        
        res.branch_statistics = branch_statistics;
        
        for j = 1 : numel(data.Result.(Grid_List{i}).Branch_Violation_Summary.Names_of_Branches_With_Violations)
            branches_afflicted = [];
            branches_afflicted = data.Result.(Grid_List{i}).Branch_Violation_Summary.Names_of_Branches_With_Violations{j};
            if ~isempty(branches_afflicted)
                for k = 1 : numel(branches_afflicted)
                    res.branch_violations( strcmp( grid_data.(Grid_List{i}).branch_name, branches_afflicted{k} ),1) = ...
                        res.branch_violations( strcmp( grid_data.(Grid_List{i}).branch_name, branches_afflicted{k} ),1) + 1;
                end
            end
        end
    else
        res.branch_violations = [];
        res.branch_statistics = [];
        
    end
    % --------------------------------------------------------------------------
    % Power loss analysis reformat
    % --------------------------------------------------------------------------
    res.loss_statistics = [];
    if handles.NVIEW_Control.Simulation_Options.Loss_Analysis == 1
        % loss statistics
        % 1st column ... max(Losses)
        % 2nd column ... sum(OC.violations)/timepoints
        
        res.loss_statistics = [max(data.Result.(Grid_List{i}).Power_Loss_Summary.Max_Power_Loss_Values(:,end)), ...
            max(data.Result.(Grid_List{i}).Power_Loss_Summary.Std_Power_Loss_Values(:,end))];
        % Loss statistics [maximum active power loss for scenario/grid and all datasets,
        %                  max std of active power losses for scenario/grid and all datasets]
    end

    % --------------------------------------------------------------------------
    % Merge values into NVIEW stucture (outside of the function)
    % --------------------------------------------------------------------------
    Scenario_Output.(Grid_List{i}) = res;
    
end

clear dataset_voltage_violation_numbers dataset_violated_nodes_numbers branches_w_bv_pp branches_w_bv
clear i j k nodes_afflicted voltage_statistics bv_per_dataset branches_afflicted branch_statistics
% --------------------------------------------------------------------------
% Load/infeed analysis reformat
% --------------------------------------------------------------------------
dt = handles.NVIEW_Control.Simulation_Options.Input_values_used;

Scenario_Output.Input_Data.Households = [];
Scenario_Output.Input_Data.Solar = [];
Scenario_Output.Input_Data.El_mobility = [];
for i = 1 : handles.NVIEW_Control.Simulation_Options.Number_of_datasets
    households = []; 
    solar = []; 
    el_mobility = [];
    
    households = data.Load_Infeed_Data.(['Set_', int2str(i)]).Households.(dt);
    solar = data.Load_Infeed_Data.(['Set_', int2str(i)]).Solar.(dt);
    el_mobility = data.Load_Infeed_Data.(['Set_', int2str(i)]).El_Mobility.(dt);
    
    if isempty(solar)
        solar = zeros(size(households));
    end
    if isempty(el_mobility)
        el_mobility = zeros(size(households));
    end
    
    Scenario_Output.Input_Data.Households = [Scenario_Output.Input_Data.Households;
        sum( households(:,1:6:end) + households(:,2:6:end) + households(:,3:6:end),2)];
    Scenario_Output.Input_Data.Solar = [Scenario_Output.Input_Data.Solar;
        sum(solar(:,1:6:end) + solar(:,2:6:end) + solar(:,3:6:end),2)];
    Scenario_Output.Input_Data.El_mobility = [Scenario_Output.Input_Data.El_mobility;
        sum(el_mobility(:,1:6:end) + el_mobility(:,2:6:end) + el_mobility(:,3:6:end),2)];
end

end

