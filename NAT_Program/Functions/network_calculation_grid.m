function handles = network_calculation_grid(handles)
%NETWORK_CALCULATION_GRID Summary of this function goes here
%   Detailed explanation goes here

% Because scenarios are not used create path to results (Grid_folder_nat\Results)
r_path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_nat',filesep,'Results'];
if ~isdir(r_path);
	mkdir(r_path);
end
handles.Current_Settings.Files.Save.Result.Path = r_path;

% clear previous results:
handles.NAT_Data.Result = [];

% Sim date saved in handles
simdate = datestr(now,'yyyy-mm-dd_HH-MM-SS');
handles.Current_Settings.Files.Save.Result.Simdate = simdate;
handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdate,' - Data'];

% save output of the console:
diary([r_path,filesep,'Res_',simdate,' - log.txt']);
diary('on');

if handles.Current_Settings.Simulation.Use_Scenarios
	% Check the settings if adaption of the input data is neccesary and possible:
	adapt_input_data_time = [];
	if isempty (adapt_input_data_time)
		[adapt_input_data_time, error, handles] = check_inputdata_vs_simsettings(handles);
		if error
			return;
		end
	end
	
	% when needed, adapt the input data according to the new simulation settings:
	if adapt_input_data_time
		handles = adapt_input_data_new_timesettings(handles);
	end
end

% start the calculation
if strcmp(handles.Current_Settings.Grid.Type, 'LV')
	handles = network_calculation_LV(handles);
elseif strcmp(handles.Current_Settings.Grid.Type, 'MV')
	handles = network_calculation_MV(handles);
end

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

