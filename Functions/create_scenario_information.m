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