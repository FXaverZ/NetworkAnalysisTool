function handles = network_scenario_calculation(handles)
%NETWORK_SCENARIO_CALCULATION Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.2
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 29.04.2013

% Access to the data via the data object:
d = handles.NAT_Data;

scenar = handles.Current_Settings.Simulation.Scenarios;
s_path = handles.Current_Settings.Simulation.Scenarios_Path;
% Path for the result files:
r_path = [handles.Current_Settings.Simulation.Grids_Path,filesep,'Results'];
if ~isdir(r_path);
	mkdir(r_path);
end

handles.Current_Settings.Files.Save.Result.Path = r_path;
simdate = datestr(now,'yyyy-mm-dd_HH-MM-SS');

% Save the outputs to the console:
diary([r_path,filesep,'Res_',simdate,' - log.txt']);
diary('on');
scenar.Names = sort(scenar.Names);
fprintf('\nBerechne die Szenarien...\n');
for i=1:scenar.Number;
	cur_scen = scenar.Names{i};
	fprintf([cur_scen,', Szenario ',num2str(i),' von ',num2str(scenar.Number)]);
	% load the input data into the tool (variable 'Load_Infeed_Data'):
	load([s_path,filesep,cur_scen,'.mat']);
	d.Load_Infeed_Data = [];
	d.Load_Infeed_Data = Load_Infeed_Data;
	% perform the network calculations:
	try
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
	catch ME
		disp('Ein Fehler ist aufgetreten:');
		disp(ME.message);
		continue;
	end
	% save the results:
	handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdate,' - ',cur_scen];
	handles = save_simulation_data(handles);
	fprintf('\n================================== \n');
end
fprintf('\n================================== \n');
fprintf('CALCULATION SUCCESSFULLY FINSIHED! \n');
fprintf('================================== \n');

diary('off');

