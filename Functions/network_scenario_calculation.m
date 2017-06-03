function handles = network_scenario_calculation(handles)
%NETWORK_SCENARIO_CALCULATION Summary of this function goes here
%   Detailed explanation goes here

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
	fprintf(['\t\t\t',cur_scen,', Szenario ',num2str(i),' von ',num2str(scenar.Number)]);
	% load the input data into the tool (variable 'Load_Infeed_Data'):
	load([s_path,filesep,cur_scen,'.mat']);
	d.Load_Infeed_Data = Load_Infeed_Data;
	% perform the network calculations:
    try
        % -- changelog v1.1b ##### (start) // 20130425        
        handles = network_calculation(handles);
        handles = post_voltage_violation_report(handles);
        handles = post_branch_violation_report(handles);
        handles = grid_power_loss_comparison(handles);
        % -- changelog v1.1b ##### (start) // 20130425

	catch ME
		disp('Ein Fehler ist aufgetreten:');
		disp(ME.message);
		disp('Simulationsergbnis wird ausgespart, keine Daten für dieses Szenario!');
		continue;
	end
	% save the results:
	handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdate,' - ',cur_scen];
	handles = save_simulation_data(handles);
end

diary('off');

