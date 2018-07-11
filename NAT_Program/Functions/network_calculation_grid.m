function handles = network_calculation_grid(handles)
%NETWORK_CALCULATION_GRID Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.1
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 11.07.2018

mh = handles.text_message_main_handler;
wb = handles.waitbar_main_handler;

% Because scenarios are not used create path to results (Grid_folder_nat\Results)
r_path = [handles.Current_Settings.Files.Grid.Path,filesep,...
	handles.Current_Settings.Files.Grid.Name,'_nat',filesep,'Results'];
if ~isdir(r_path)
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
logpath = [r_path,filesep,'Res_',simdate,' - log.txt'];
mh.mark_sub_log(logpath);
mh.add_line('Performing single scenario simulation...');
mh.add_info('Grid(s) are from Type "',handles.Current_Settings.Grid.Type,'".');

% start the calculation
wb.start();
if strcmp(handles.Current_Settings.Grid.Type, 'LV')
	try
		handles = network_calculation_LV(handles);
	catch ME
		if strcmp(ME.identifier,'NAT:NetworkCalculationLV:CanceledByUser')
			mh.stop_sub_log(logpath);
			return;
		else
			rethrow(ME)
		end
	end
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
mh.level_down();
mh.add_line('... Calculations finished!');
mh.stop_sub_log(logpath);
end

