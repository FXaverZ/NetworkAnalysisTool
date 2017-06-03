function handles = network_calculation_grid(handles)
%NETWORK_CALCULATION_GRID Summary of this function goes here
%   Detailed explanation goes here

% Because scenarios are not used create path to results (Grid_folder\Results)
r_path = [handles.Current_Settings.Files.Grid.Path,filesep,'Results'];
if ~isdir(r_path);
	mkdir(r_path);
end
handles.Current_Settings.Files.Save.Result.Path = r_path;

% clear previous results:
handles.NAT_Data.Result = [];

% 	handles.Current_Settings.Files.Save.Result.Scen_info = ...
% 		['Res_',simdate,' - information'];
% 	% Save result information file (variants, number of datasets,
% 	% scenario=[])
% 	create_scenario_information(handles);

% Sim date saved in handles
simdate = datestr(now,'yyyy-mm-dd_HH-MM-SS');
handles.Current_Settings.Files.Save.Result.Simdate = simdate;
handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdate,' - Data'];

% save output of the console:
diary([r_path,filesep,'Res_',simdate,' - log.txt']);
diary('on');

% start the calculation
handles = network_calculation(handles);
if  handles.Current_Settings.Simulation.Voltage_Violation_Analysis
	handles = post_voltage_violation_report(handles);
end
if handles.Current_Settings.Simulation.Branch_Violation_Analysis
	handles = post_branch_violation_report(handles);
end
if handles.Current_Settings.Simulation.Power_Loss_Analysis
	handles = post_active_power_loss_report(handles);
end

% save the results:
handles = save_simulation_data(handles);
% save the settings:
Current_Settings = handles.Current_Settings; %#ok<NASGU>
save([r_path,filesep,'Res_',simdate,' - Settings.mat'],'Current_Settings');

diary('off');

end

