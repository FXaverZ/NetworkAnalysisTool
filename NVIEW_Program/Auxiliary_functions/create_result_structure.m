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
    res.bus_voltages = [];
    
    if handles.NVIEW_Control.Simulation_Options.Voltage_Analysis == 1
        % Clear variables
        res.bus_voltages = data.Result.(Grid_List{i}).Node_Voltages;
    end
    
    % --------------------------------------------------------------------------
    % Branch summary analysis reformat
    % --------------------------------------------------------------------------
    res.branch = grid_data.(Grid_List{i}).bus;
    res.branch_name = grid_data.(Grid_List{i}).branch_name;
    res.branch_values = [];
    
    if handles.NVIEW_Control.Simulation_Options.Overcurrent_Analysis == 1
        res.branch_values = data.Result.(Grid_List{i}).Branch_Values;
    end
    
    % --------------------------------------------------------------------------
    % Power loss analysis reformat
    % --------------------------------------------------------------------------
    res.electric_losses = [];
    if handles.NVIEW_Control.Simulation_Options.Loss_Analysis == 1
        res.electric_losses = data.Result.(Grid_List{i}).Power_Loss_Values;
    end

    % --------------------------------------------------------------------------
    % Merge values into NVIEW stucture (outside of the function)
    % --------------------------------------------------------------------------
    Scenario_Output.(Grid_List{i}) = res;
end

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

