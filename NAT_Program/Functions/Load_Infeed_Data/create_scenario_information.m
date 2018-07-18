function  create_scenario_information(handles)
% CREATE_SCENARIO_INFORMATION - relevant information regarding the
% simulation is stored, i.e. the names of scenarios, variants and the
% number of datasets

% Handles >  Current_Settings > Simulation
simulation_info = handles.Current_Settings.Simulation;

% simulation_options
% is voltage_violation_analysis performed?
% is branch violation analysis performed?
% is power loss analysis performed?
simulation_options.Voltage_Violation_Analysis = simulation_info.Voltage_Violation_Analysis;
simulation_options.Branch_Violation_Analysis = simulation_info.Branch_Violation_Analysis;
simulation_options.Power_Loss_Analysis = simulation_info.Power_Loss_Analysis;

% are voltages saved?
% are branch results saved?
% are power losses saved?
simulation_options.Save_Voltage_Results = simulation_info.Save_Voltage_Results;
simulation_options.Save_Branch_Results = simulation_info.Save_Branch_Results;
simulation_options.Save_Power_Loss_Results = simulation_info.Save_Power_Loss_Results;

% Are grid variants used?
% Are scenarios used?
simulation_options.Use_Grid_Variants = simulation_info.Use_Grid_Variants;
simulation_options.Use_Scenarios = simulation_info.Use_Scenarios;

% What kind of data is used

if handles.Current_Settings.Data_Extract.get_Sample_Value
    simulation_options.Input_values_used = 'Data_Sample';
elseif handles.Current_Settings.Data_Extract.get_Mean_Value
    simulation_options.Input_values_used = 'Data_Mean';
elseif handles.Current_Settings.Data_Extract.get_Min_Value
    simulation_options.Input_values_used = 'Data_Min';    
elseif handles.Current_Settings.Data_Extract.get_Max_Value
    simulation_options.Input_values_used = 'Data_Max';    
elseif handles.Current_Settings.Data_Extract.get_95_Quantile_Value
    simulation_options.Input_values_used = 'Data_95P_Quantil';
elseif handles.Current_Settings.Data_Extract.get_05_Quantile_Value
    simulation_options.Input_values_used = 'Data_05P_Quantil';
end
% -- changelog v1.1b ##### (start) // 20130506
% Check for datasets
load_infeed_data_fields = fields(handles.NAT_Data.Load_Infeed_Data);
% Check if households/solar/el. mobility exist (we require one, first check
% households, if those do not exist, check solar or el mobility
if ~isempty(handles.NAT_Data.Load_Infeed_Data.(load_infeed_data_fields{1}).Households.(simulation_options.Input_values_used))
    simulation_options.Timepoints = ...
        size(handles.NAT_Data.Load_Infeed_Data.(load_infeed_data_fields{1}).Households.(simulation_options.Input_values_used),1);
else
    if ~isempty(handles.NAT_Data.Load_Infeed_Data.(load_infeed_data_fields{1}).Solar.(simulation_options.Input_values_used))
        simulation_options.Timepoints = ...
            size(handles.NAT_Data.Load_Infeed_Data.(load_infeed_data_fields{1}).Solar.(simulation_options.Input_values_used),1);
        
    elseif ~isempty(handles.NAT_Data.Load_Infeed_Data.(load_infeed_data_fields{1}).El_Mobility.(simulation_options.Input_values_used))
        simulation_options.Timepoints = ...
            size(handles.NAT_Data.Load_Infeed_Data.(load_infeed_data_fields{1}).El_Mobility.(simulation_options.Input_values_used),1);
    end
end
% -- changelog v1.1b ##### (end) // 20130506
simulation_options.Current_Settings = handles.Current_Settings;

% Save dataset number
datasets = simulation_info.Number_Runs;
% save scenario names  
  % ***How to save if no scenarios defined?
if simulation_info.Use_Scenarios
    scenarios = simulation_info.Scenarios.Names;
    scenario_filepath = simulation_info.Scenarios_Path;
else
    scenarios = [];
    scenario_filepath = [];
end
% Save grid variants
if simulation_info.Use_Grid_Variants
    for h = 1 : numel(simulation_info.Grid_List)
        variants{h} = simulation_info.Grid_List{h}(1:end-4);
        
    end
else
    % if no grid variants, only one grid active - we save the active grid
    % name
    variants = handles.Current_Settings.Files.Grid.Name(1:end-4);
end

% File information Files > Save > Result
file = handles.Current_Settings.Files.Save.Result;

% Save filepath for information - folder with results
result_filepath = file.Path;

% Save simdate
simdate = handles.Current_Settings.Files.Save.Result.Simdate;

% Save result filenames
if handles.Current_Settings.Simulation.Use_Scenarios 
    % If scenarios are used
        for h = 1 : numel(handles.Current_Settings.Simulation.Scenarios.Names)
        result_filename{h} = ['Res_',simdate,' - ',handles.Current_Settings.Simulation.Scenarios.Names{h},file.Exte];
    end
else
    % If no scenarios are used
    result_filename = [file.Name,file.Exte];
end


% save the information
save([result_filepath,filesep,file.Scen_info,file.Exte],'scenarios',...
        'variants','datasets','result_filepath','result_filename',...
        'scenario_filepath','simulation_options');

end