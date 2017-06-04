function handles = network_scenario_calculation(handles)
%NETWORK_SCENARIO_CALCULATION Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.3
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 07.11.2013

% check, if simulation makes sense:
if ~(handles.Current_Settings.Simulation.Voltage_Violation_Analysis || ...
		handles.Current_Settings.Simulation.Branch_Violation_Analysis || ...
		handles.Current_Settings.Simulation.Power_Loss_Analysis)
	fprintf('\nNo active analysis function! Abort simulation...\n')
	return;
end

% clear previous results:
handles.NAT_Data.Result = [];

% Access to the data via the data object:
d = handles.NAT_Data;
scenar = handles.Current_Settings.Simulation.Scenarios;
s_path = handles.Current_Settings.Simulation.Scenarios_Path;

% Check and maybe create path for the result files:
if isempty(handles.Current_Settings.Simulation.Grid_List)
	path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_files'];
else
	path = handles.Current_Settings.Simulation.Grids_Path;
end
r_path = [path,filesep,'Results'];
if ~isdir(r_path);
	mkdir(r_path);
end

handles.Current_Settings.Files.Save.Result.Path = r_path;
% Sim date saved in handles
handles.Current_Settings.Files.Save.Result.Simdate = now;
simdatestr = datestr(now,'yyyy_mm_dd-HH.MM.SS');

% Save the outputs to the console:
diary([r_path,filesep,'Res_',simdatestr,' - log.txt']);
diary('on');
% sort the scenarios:
scenar.Names = sort(scenar.Names);
fprintf('\nBerechne die Szenarien...\n');
for i=1:scenar.Number;
	% 	if i == 1
	% 		% The log file and matlab scenario information is created at first
	% 		% calculation
	%
	% 		% write_scenario_log - create info txt file about the scenarios
	% 		handles.Current_Settings.Files.Save.Result.Log_file = ...
	% 			['Res_',simdatestr,' - Scen_log.txt'];
	% 		write_scenario_log(handles,'create');
	%
	% 		% create_scenario_information - Creates .mat file with all relevant
	% 		% information regarding the simulation - necessary for final result
	% 		% comparisons and analyses
	% 		handles.Current_Settings.Files.Save.Result.Scen_info = ...
	% 			['Res_',simdatestr,' - information'];
	% 		create_scenario_information(handles);
	% 	end
	
	cur_scen = scenar.Names{i};
	fprintf([cur_scen,', Szenario ',num2str(i),' von ',num2str(scenar.Number)]);
	% load the input data into the tool (variable 'Load_Infeed_Data'):
	load([s_path,filesep,cur_scen,'.mat']);
	% set the data-object to initial state:
	d.Load_Infeed_Data = [];
	d.Load_Infeed_Data = Load_Infeed_Data;
	clear('Load_Infeed_Data');
	
	% Check, if the data is partinioted
	if scenar.(['Sc_',num2str(i)]).Data_number_parts > 1
		fprintf(['\n\tTeildatei 1 von ',num2str(scenar.(['Sc_',num2str(i)]).Data_number_parts)]);
	end
	for j = 1:scenar.(['Sc_',num2str(i)]).Data_number_parts
		if j > 1
			% load the next data set
			fprintf(['\n\tTeildatei ',num2str(j),' von ',num2str(scenar.(['Sc_',num2str(i)]).Data_number_parts)]);
			load([s_path,filesep,cur_scen,'_',num2str(j,'%03.0f'),'.mat']);
			% set the data-object to initial state:
			d.Load_Infeed_Data = [];
			d.Load_Infeed_Data = Load_Infeed_Data;
			clear('Load_Infeed_Data');
		end
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
			disp('An error occurred:');
			disp(ME.message);
			continue;
		end
		% save the results:
		if j == 1
			handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdatestr,' - ',cur_scen];
		else
			handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdatestr,' - ',cur_scen,'_',num2str(j,'%03.0f')];
		end
		if scenar.(['Sc_',num2str(i)]).Data_number_parts > 1
			fprintf(['\t\tSpeichere Ergebnisse von Teildatensatz ',num2str(j),' von ',num2str(scenar.(['Sc_',num2str(i)]).Data_number_parts)]);
		end
		handles = save_simulation_data(handles);
	end
	fprintf('\n================================== \n');
	
end
% write_scenario_log(handles,'close');
% Save the current Settings of the tool:
Current_Settings = handles.Current_Settings; %#ok<NASGU>
save([r_path,filesep,'Res_',simdatestr,' - Settings.mat'],'Current_Settings');

fprintf('\n================================== \n');
fprintf('CALCULATION SUCCESSFULLY FINISHED! \n');
fprintf('================================== \n');


diary('off');

