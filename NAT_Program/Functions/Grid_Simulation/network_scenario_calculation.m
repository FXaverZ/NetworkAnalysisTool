function handles = network_scenario_calculation(handles)
%NETWORK_SCENARIO_CALCULATION Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.5
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 11.07.2018

mh = handles.text_message_main_handler;
wb = handles.waitbar_main_handler;

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
if ~isfolder(r_path)
	mkdir(r_path);
end

handles.Current_Settings.Files.Save.Result.Path = r_path;
% Sim date saved in handles
handles.Current_Settings.Files.Save.Result.Simdate = now;
simdatestr = datestr(now,'yyyy_mm_dd-HH.MM.SS');

% Save the outputs to the console:
log_path = [r_path,filesep,'Res_',simdatestr,' - Log.log'];
mh.mark_sub_log(log_path);
mh.add_line('Performing Scenario based grid simulations...');
mh.add_info('Using Input data from "',s_path,'".');
mh.add_info('Grid(s) are from Type "',handles.Current_Settings.Grid.Type,'".');

% adapt the Scenario-Settings according to the selection:
if ~isempty(handles.Current_Settings.Simulation.Scenarios_Selection)
	Scen_Sel = handles.Current_Settings.Simulation.Scenarios_Selection;
	scen_old = scenar;
	scen_new.Number = numel(Scen_Sel);
	scen_new.Names = cell(1,scen_new.Number);
	for scenario_counter=1:scen_new.Number
		scen_new.Names{scenario_counter} = scen_old.Names{Scen_Sel(scenario_counter)};
		scen_new.(['Sc_',num2str(scenario_counter)]) = scen_old.(['Sc_',num2str(Scen_Sel(scenario_counter))]);
	end
	scen_new.Data_avaliable = 1;
	scenar = scen_new;
end

% Save the current Settings of the tool:
Current_Settings = handles.Current_Settings;
Current_Settings.Simulation.Scenarios = scenar;
save([r_path,filesep,'Res_',simdatestr,' - Settings.mat'],'Current_Settings');

adapt_input_data_time = [];
error_scen_counter = 0;
error_scen_all_counter = 0;

wb.start();
linemarker_scen_sim_started = mh.mark_current_displayline();
scenario_counter_timer = tic();
wb.add_end_position('scenario_counter', scenar.Number);
for scenario_counter=1:scenar.Number
	wb.update_counter('scenario_counter', scenario_counter);
	
	% get the current scenario:
	cur_scen = scenar.Names{scenario_counter};
	mh.add_line('Using data of "', cur_scen,'", Scenario ',num2str(scenario_counter),' of ',num2str(scenar.Number));
	mh.level_up();
	% load the input data into the tool (variable 'Load_Infeed_Data'):
	load([s_path,filesep,cur_scen,'.mat']);
	% set the data-object to initial state:
	d.Load_Infeed_Data = [];
	d.Load_Infeed_Data = Load_Infeed_Data;
	d.Simulation.Scenario = scenar.(['Sc_',num2str(scenario_counter)]);
	clear('Load_Infeed_Data');
	% Check the settings if adaption of the input data is neccesary and possible:
	if isempty (adapt_input_data_time)
		[adapt_input_data_time, error, handles] = check_inputdata_vs_simsettings(handles);
		if error
			errorstr = 'Settings of inputdata and simulation are not compatible! Abort simulation...';
			mh.add_error(errorstr);
			errordlg(errorstr);
			return;
		end
	end
	
	% Check, if the data is partitioned
	if scenar.(['Sc_',num2str(scenario_counter)]).Data_number_parts > 1
		mh.add_line('Filepart 1 of ',num2str(scenar.(['Sc_',num2str(scenario_counter)]).Data_number_parts));
	end
	for j = 1:scenar.(['Sc_',num2str(scenario_counter)]).Data_number_parts
		if j > 1
			% load the next data set
			mh.add_line('Filepart ',num2str(j),' of ',num2str(scenar.(['Sc_',num2str(scenario_counter)]).Data_number_parts));
			load([s_path,filesep,cur_scen,'_',num2str(j,'%03.0f'),'.mat']);
			% set the data-object to initial state:
			d.Load_Infeed_Data = [];
			d.Load_Infeed_Data = Load_Infeed_Data;
			clear('Load_Infeed_Data');
		end
		% perform the network calculations:
		% when needed, adapt the input data according to the new simulation settings:
		if adapt_input_data_time
			handles = adapt_input_data_new_timesettings(handles);
		end

		try
			% start the calculation
			if strcmp(handles.Current_Settings.Grid.Type, 'LV')
				if handles.Current_Settings.Simulation.No_GUI_output
					handles = network_calculation_LV_silent (handles);
				else
					handles = network_calculation_LV (handles);
				end
			elseif strcmp(handles.Current_Settings.Grid.Type, 'MV') && ...
					~handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active
				if handles.Current_Settings.Simulation.No_GUI_output
					handles = network_calculation_MV_silent(handles);
				else
					handles = network_calculation_MV(handles);
				end
			elseif strcmp(handles.Current_Settings.Grid.Type, 'MV') && ...
					handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active
				handles = network_calculation_MV_controller_active(handles);
			end
		catch ME
			if strcmp(ME.identifier,'NAT:NetworkCalculationLV:CanceledByUser')
				mh.stop_sub_log(log_path);
				return;
			else
				rethrow(ME)
			end
		end
		
		if handles.Current_Settings.Simulation.Voltage_Violation_Analysis
			handles = post_voltage_violation_report(handles);
		end
		if handles.Current_Settings.Simulation.Branch_Violation_Analysis
			handles = post_branch_violation_report(handles);
		end
		if handles.Current_Settings.Simulation.Power_Loss_Analysis
			handles = post_active_power_loss_report(handles);
		end
		
		% save the results:
		mh.level_down();
		if j == 1
			handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdatestr,' - ',cur_scen];
		else
			handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdatestr,' - ',cur_scen,'_',num2str(j,'%03.0f')];
		end
		if scenar.(['Sc_',num2str(scenario_counter)]).Data_number_parts > 1
			mh.add_line('Saving restults for filepart ',num2str(j),' of ',num2str(scenar.(['Sc_',num2str(scenario_counter)]).Data_number_parts));
		end
		handles = save_simulation_data(handles);
	end
	mh.level_down();
	
	mh.set_display_back_to_marker(linemarker_scen_sim_started, true);
	if error_scen_counter > 0
		mh.add_error('During the calculations ',error_scen_all_counter,' errors in ',...
			error_scen_counter, ' scenarios occured.');
	end
	
	mh.add_line('Calculations for "', cur_scen,'" (Scenario ',scenario_counter,' of ',scenar.Number,') finished.');
	mh.level_up();
	
	error_all_count = 0;
	for grid_counter = 1:numel(handles.Current_Settings.Simulation.Grid_List)
		error_all_count = error_all_count + sum(sum(handles.NAT_Data.Result.(handles.Current_Settings.Simulation.Grid_List{grid_counter}(1:end-4)).Error_Counter));
	end
	if error_all_count > 0
		mh.add_error('During the calculations ',...
			error_all_count,' errors occured!');
		error_scen_counter = error_scen_counter + 1;
		error_scen_all_counter = error_scen_all_counter + error_all_count;
	end
	t = toc(scenario_counter_timer);
	if scenario_counter < scenar.Number
		mh.add_line('Runtime: ',...
			sec2str(t),...
			'. Remaining: ',...
			sec2str(t/(scenario_counter/scenar.Number) - t));
	else
		mh.add_line('Runtime: ',...
			sec2str(t),...
			'.');
	end
	mh.level_down();
end
% write_scenario_log(handles,'close');
% update the saved current settings of the tool:
Current_Settings = handles.Current_Settings;
Current_Settings.Simulation.Scenarios = scenar;
save([r_path,filesep,'Res_',simdatestr,' - Settings.mat'],'Current_Settings');
mh.set_display_back_to_marker(linemarker_scen_sim_started, true);
mh.add_line('Runtime for all scenarios: ',sec2str(t),'.');
if error_scen_counter > 0
	mh.add_error('During the calculations ',error_scen_all_counter,' errors in ',...
		error_scen_counter, ' scenarios occured.');
	mh.add_line('... Calculations finished!');
else
	mh.add_line('... Calculations succesfully finished!');
end
mh.stop_sub_log(log_path);

