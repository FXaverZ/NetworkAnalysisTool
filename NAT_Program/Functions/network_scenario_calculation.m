function handles = network_scenario_calculation(handles)
%NETWORK_SCENARIO_CALCULATION Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.3
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte �nderung durch:   Franz Zeilinger - 07.11.2013

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
		handles.Current_Settings.Files.Grid.Name];
	r_path = [path,'_nat',filesep,'Results'];
else
	path = handles.Current_Settings.Simulation.Grids_Path;
	r_path = [path,filesep,'Results'];
end
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

% adapt the Scenario-Settings according to the selection:
if ~isempty(handles.Current_Settings.Simulation.Scenarios_Selection)
	Scen_Sel = handles.Current_Settings.Simulation.Scenarios_Selection;
	scen_old = scenar;
	scen_new.Number = numel(Scen_Sel);
	scen_new.Names = cell(1,scen_new.Number);
	for i=1:scen_new.Number
		scen_new.Names{i} = scen_old.Names{Scen_Sel(i)};
		scen_new.(['Sc_',num2str(i)]) = scen_old.(['Sc_',num2str(Scen_Sel(i))]);
	end
	scen_new.Data_avaliable = 1;
	scenar = scen_new;
end

% write_scenario_log(handles,'close');
% Save the current Settings of the tool:
Current_Settings = handles.Current_Settings;
Current_Settings.Simulation.Scenarios = scenar;
save([r_path,filesep,'Res_',simdatestr,' - Settings.mat'],'Current_Settings');

fprintf('\nCalculation of the scenarios...\n');
adapt_input_data_time = [];
for i=1:scenar.Number;
	% get the current scenario:
	cur_scen = scenar.Names{i};
	fprintf([cur_scen,', Scenario ',num2str(i),' of ',num2str(scenar.Number)]);
	% load the input data into the tool (variable 'Load_Infeed_Data'):
	load([s_path,filesep,cur_scen,'.mat']);
	% set the data-object to initial state:
	d.Load_Infeed_Data = [];
	d.Load_Infeed_Data = Load_Infeed_Data;
	d.Simulation.Scenario = scenar.(['Sc_',num2str(i)]);
	clear('Load_Infeed_Data');
	% Check the settings if adaption of the input data is neccesary and possible:
	if isempty (adapt_input_data_time)
		[adapt_input_data_time, error, handles] = check_inputdata_vs_simsettings(handles);
		if error
			return;
		end
	end
	
	% Check, if the data is partitioned
	if scenar.(['Sc_',num2str(i)]).Data_number_parts > 1
		fprintf(['\n\tFilepart 1 of ',num2str(scenar.(['Sc_',num2str(i)]).Data_number_parts)]);
	end
	for j = 1:scenar.(['Sc_',num2str(i)]).Data_number_parts
		if j > 1
			% load the next data set
			fprintf(['\n\tFilepart ',num2str(j),' of ',num2str(scenar.(['Sc_',num2str(i)]).Data_number_parts)]);
			load([s_path,filesep,cur_scen,'_',num2str(j,'%03.0f'),'.mat']);
			% set the data-object to initial state:
			d.Load_Infeed_Data = [];
			d.Load_Infeed_Data = Load_Infeed_Data;
			clear('Load_Infeed_Data');
		end
		% perform the network calculations:
% 		try
			% when needed, adapt the input data according to the new simulation settings:
			if adapt_input_data_time
				handles = adapt_input_data_new_timesettings(handles);
			end
			
			% start the calculation
			if strcmp(handles.Current_Settings.Grid.Type, 'LV')
				handles = network_calculation_LV(handles);
			elseif strcmp(handles.Current_Settings.Grid.Type, 'MV') && ...
					~handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active
				handles = network_calculation_MV(handles);
			elseif strcmp(handles.Current_Settings.Grid.Type, 'MV') && ...
					handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active
				handles = network_calculation_MV_controller_active(handles);
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
% 		catch ME
% 			disp('An error occurred:');
% 			disp(ME.message);
% 			continue;
% 		end
		% save the results:
		if j == 1
			handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdatestr,' - ',cur_scen];
		else
			handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdatestr,' - ',cur_scen,'_',num2str(j,'%03.0f')];
		end
		if scenar.(['Sc_',num2str(i)]).Data_number_parts > 1
			fprintf(['\t\tSaving restults for filepart ',num2str(j),' of ',num2str(scenar.(['Sc_',num2str(i)]).Data_number_parts)]);
		end
		handles = save_simulation_data(handles);
	end
	fprintf('\n================================== \n');
	
end
% write_scenario_log(handles,'close');
% update the saved current settings of the tool:
Current_Settings = handles.Current_Settings;
Current_Settings.Simulation.Scenarios = scenar;
save([r_path,filesep,'Res_',simdatestr,' - Settings.mat'],'Current_Settings');

fprintf('\n================================== \n');
fprintf('CALCULATION SUCCESSFULLY FINISHED! \n');
fprintf('================================== \n');


diary('off');
