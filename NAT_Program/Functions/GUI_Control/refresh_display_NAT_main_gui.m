function handles = refresh_display_NAT_main_gui(handles)
%REFRESH_DISPLAY_NAT_MAIN_GUI    Summary of this function goes here
%    Detailed explanation goes here

% Version:                 1.2
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 25.04.2018

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%      Einstellungen - Auslesen der Daten
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% update worst cases:
set(handles.popup_hh_worstcase, ...
	'Value', handles.Current_Settings.Data_Extract.Worstcase_Housholds);
set(handles.popup_gen_worstcase, ...
	'Value', handles.Current_Settings.Data_Extract.Worstcase_Generation);

% update settings of weekdays and seasons:
for i=1:3
	set(handles.(['radio_season_',num2str(i)]),...
		'Value',handles.Current_Settings.Data_Extract.Season(i));
	set(handles.(['radio_weekday_',num2str(i)]),...
		'Value',handles.Current_Settings.Data_Extract.Weekday(i));
	% Bei Zeitreihen Eingaben einschränken:
	if handles.Current_Settings.Data_Extract.get_Time_Series
		set(handles.(['radio_weekday_',num2str(i)]),...
			'Enable','Off');
	else
		set(handles.(['radio_weekday_',num2str(i)]),...
			'Enable','On');
	end
end

% update settings of the time series:
if handles.Current_Settings.Data_Extract.get_Time_Series
	set(handles.push_time_series_settings, 'Enable','On');
	set(handles.check_get_time_series, 'Value',1);
else
	set(handles.push_time_series_settings, 'Enable','Off');
	set(handles.check_get_time_series, 'Value',0);
end

if handles.Current_Settings.Start_Simulation_after_Extraction
	set(handles.check_simulation_start_after_data_extraction, 'Value', 1);
else
	set(handles.check_simulation_start_after_data_extraction, 'Value', 0);
end

% update the pop-up-menues:
tim_res_sel = find(cell2mat(handles.System.time_resolutions(:,2)) == handles.Current_Settings.Data_Extract.Time_Resolution);
set(handles.popup_time_resolution, 'Value',...
	tim_res_sel);
set(handles.popup_pqnode_pv_typ, 'String',  ...
	handles.Current_Settings.Data_Extract.Solar.Selectable(:,1));
set(handles.popup_pqnode_wi_typ, 'String',  ...
	handles.Current_Settings.Data_Extract.Wind.Selectable(:,1));

% update the checkboxes for settings of data treatment:
if handles.Current_Settings.Data_Extract.Time_Resolution == 1
	set(handles.check_extract_sample_value,'Value',1,'Enable','off');
	handles.Current_Settings.Data_Extract.get_Sample_Value = 1;
	set(handles.check_extract_mean_value,'Value',0,'Enable','off');
	handles.Current_Settings.Data_Extract.get_Mean_Value = 0;
	set(handles.check_extract_min_value,'Value',0,'Enable','off');
	handles.Current_Settings.Data_Extract.get_Min_Value = 0;
	set(handles.check_extract_max_value,'Value',0,'Enable','off');
	handles.Current_Settings.Data_Extract.get_Max_Value = 0;
	set(handles.check_extract_95_quantile_value,'Value',0,'Enable','off');
	handles.Current_Settings.Data_Extract.get_95_Quantile_Value = 0;
	set(handles.check_extract_05_quantile_value,'Value',0,'Enable','off');
	handles.Current_Settings.Data_Extract.get_05_Quantile_Value = 0;
else
	set(handles.check_extract_sample_value,...
		'Value',handles.Current_Settings.Data_Extract.get_Sample_Value,...
		'Enable','on');
	set(handles.check_extract_mean_value,...
		'Value',handles.Current_Settings.Data_Extract.get_Mean_Value,...
		'Enable','on');
	set(handles.check_extract_min_value,...
		'Value',handles.Current_Settings.Data_Extract.get_Min_Value,...
		'Enable','on');
	set(handles.check_extract_max_value,...
		'Value',handles.Current_Settings.Data_Extract.get_Max_Value,...
		'Enable','on');
	set(handles.check_extract_95_quantile_value,...
		'Value',handles.Current_Settings.Data_Extract.get_95_Quantile_Value,...
		'Enable','on');
	set(handles.check_extract_05_quantile_value,...
		'Value',handles.Current_Settings.Data_Extract.get_05_Quantile_Value,...
		'Enable','on');
end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Update the PQ-Node field
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
handles = refresh_display_PQNodefield(handles);
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

set(handles.check_no_output, 'Value', handles.Current_Settings.Simulation.No_GUI_output)

if ~isempty(handles.Current_Settings.Files.Grid.Name)
	str = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,...
		handles.Current_Settings.Files.Grid.Exte];
	if length(str) > 85
		idx = strfind(str, '\');
		if numel(idx) > 4
			str = [str(1:idx(2)),' ... ',str(idx(end-1):end)];
		end
	end
	set(handles.static_text_network_path_name, 'String', str);
	if strcmp(handles.Current_Settings.Grid.Type, 'MV') && ...
			isempty(handles.Current_Settings.Data_Extract.LV_Grids_List)
		set(handles.push_network_load_random_allocation, 'Enable','off');
		set(handles.push_network_table_import_export, 'Enable','off');
	else
		set(handles.push_network_load_random_allocation, 'Enable','on');
		set(handles.push_network_table_import_export, 'Enable','on');
		
	end
	set(handles.push_network_load_allocation_reset, 'Enable','on');
	set(handles.push_load_data_get,'Enable','on');
	set(handles.check_simulation_start_after_data_extraction,'Enable','on');
else
	set(handles.static_text_network_path_name, 'String', 'No grid loaded!');
	set(handles.uipanel_detail_component,'Title','No grid loaded!');
	set(handles.push_network_load_allocation_reset, 'Enable','off');
	set(handles.push_network_load_random_allocation, 'Enable','off');
	set(handles.push_network_table_import_export, 'Enable','off');
	set(handles.push_load_data_get,'Enable','off');
	set(handles.check_simulation_start_after_data_extraction,'Enable','off');
end

if ~isempty(handles.Current_Settings.Table_Network)
	ntw = handles.Current_Settings.Table_Network;
	
	set(handles.table_data_network, ...
		'Data', ntw.Data, ...
		'ColumnName', ntw.ColumnName,...
		'ColumnFormat', ntw.ColumnFormat,...
		'ColumnEditable', ntw.ColumnEditable,...
		'ColumnWidth', ntw.ColumnWidth,...
		'RowName', ntw.RowName);
	set(handles.push_load_data_get,'Enable','on');
	set(handles.check_simulation_start_after_data_extraction,'Enable','on');
else
	set(handles.push_load_data_get,'Enable','off');
	set(handles.check_simulation_start_after_data_extraction,'Enable','off');
end

% Wenn Lastdaten vorhanden sind, Netzberechnungen erlauben...
if ~isempty(handles.NAT_Data.Load_Infeed_Data)
	datatyps = {...
		'Sample_Value',...
		'Mean_Value',...
		'Max_Value',...
		'Min_Value',...
		'05_Quantile_Value',...
		'95_Quantile_Value',...
		};
	buttons = {...
		'sample_value',...
		'mean_value',...
		'max_value',...
		'min_value',...
		'05q_value',...
		'95q_value',...
		};
	
	num_active_datatyps = 0;
	% adopt possible selection of data typs based on available load- and infeed data:
	for a=1:numel(datatyps)
		if handles.NAT_Data.Data_Extract.(['get_',datatyps{a}])
			set(handles.(['radio_simulate_',buttons{a}]), 'Enable', 'on', 'Value', handles.Current_Settings.Simulation.(['use_',datatyps{a}]));
			num_active_datatyps = num_active_datatyps + handles.Current_Settings.Simulation.(['use_',datatyps{a}]);
		else
			set(handles.(['radio_simulate_',buttons{a}]), 'Enable', 'off', 'Value', 0);
		end
	end
	
	if num_active_datatyps < 1
		% no datatype which is actice is selected, select the first one..
		for a=1:numel(datatyps)
			if handles.NAT_Data.Data_Extract.(['get_',datatyps{a}])
				handles.Current_Settings.Simulation.(['use_',datatyps{a}]) = 1;
				set(handles.(['radio_simulate_',buttons{a}]), 'Enable', 'on', 'Value', handles.Current_Settings.Simulation.(['use_',datatyps{a}]));
				break;
			end
		end
	end
	
	% which data typ has to be simulated?
	if handles.Current_Settings.Simulation.use_Sample_Value
		handles.Current_Settings.Simulation.Data_typ = '_Sample';
	end
	if handles.Current_Settings.Simulation.use_Mean_Value
		handles.Current_Settings.Simulation.Data_typ = '_Mean';
	end
	if handles.Current_Settings.Simulation.use_Max_Value
		handles.Current_Settings.Simulation.Data_typ = '_Max';
	end
	if handles.Current_Settings.Simulation.use_Min_Value
		handles.Current_Settings.Simulation.Data_typ = '_Min';
	end
	if handles.Current_Settings.Simulation.use_05_Quantile_Value
		handles.Current_Settings.Simulation.Data_typ = '_05P_Quantil';
	end
	if handles.Current_Settings.Simulation.use_95_Quantile_Value
		handles.Current_Settings.Simulation.Data_typ = '_95P_Quantil';
	end
	
	% activate simulation-button when
	% - in the handles-structure a field named 'sin' is available (that means, that a
	%   communication to SINCAL is there)
	% and when
	%   + no scenarios should be simulated, one data-set is there
	%   or
	%   + when scenarios should be simulated, the data available-flag is set
	if isfield(handles, 'sin') && ...
			(...
			( ~handles.Current_Settings.Simulation.Use_Scenarios && ...
			(isfield(handles.NAT_Data.Load_Infeed_Data, 'Households') || ...
			isfield(handles.NAT_Data.Load_Infeed_Data.Set_1, 'Households'))...
			)...
			|| ...
			( handles.Current_Settings.Simulation.Use_Scenarios && ...
			handles.Current_Settings.Simulation.Scenarios.Data_avaliable...
			)...
			)
		set(handles.push_network_calculation_start, 'Enable','on');
	else
		set(handles.push_network_calculation_start, 'Enable', 'off');
		% Deactivate selection of data typs
		set(handles.radio_simulate_sample_value, 'Enable', 'off', 'Value', 0);
		set(handles.radio_simulate_mean_value, 'Enable', 'off', 'Value', 0);
		set(handles.radio_simulate_min_value, 'Enable', 'off', 'Value', 0);
		set(handles.radio_simulate_max_value, 'Enable', 'off', 'Value', 0);
		set(handles.radio_simulate_05q_value, 'Enable', 'off', 'Value', 0);
		set(handles.radio_simulate_95q_value, 'Enable', 'off', 'Value', 0);
		
	end
else
	set(handles.push_network_calculation_start, 'Enable','off');
	% Deactivate selection of data typs
	set(handles.radio_simulate_sample_value, 'Enable', 'off', 'Value', 0);
	set(handles.radio_simulate_mean_value, 'Enable', 'off', 'Value', 0);
	set(handles.radio_simulate_min_value, 'Enable', 'off', 'Value', 0);
	set(handles.radio_simulate_max_value, 'Enable', 'off', 'Value', 0);
	set(handles.radio_simulate_05q_value, 'Enable', 'off', 'Value', 0);
	set(handles.radio_simulate_95q_value, 'Enable', 'off', 'Value', 0);
end

% Eingabefelder aktualisieren:
set(handles.edit_simulation_number_runs,...
	'String', num2str(handles.Current_Settings.Simulation.Number_Runs));

% Wurden Variantennetz geladen, Buttons deaktivieren und Anzahl darstellen:
set(handles.check_use_variants, 'Value', handles.Current_Settings.Simulation.Use_Grid_Variants);
if ~isempty(handles.Current_Settings.Simulation.Grid_List) && handles.Current_Settings.Simulation.Use_Grid_Variants
	set(handles.edit_network_number_variants, 'String', num2str(numel(handles.Current_Settings.Simulation.Grid_List)));
else
	set(handles.edit_network_number_variants, 'String', 'Singlesim.');
end

set(handles.check_use_scenarios, 'Value', handles.Current_Settings.Simulation.Use_Scenarios);
if handles.Current_Settings.Simulation.Use_Scenarios
	if handles.Current_Settings.Data_Extract.MV_input_generation_in_progress
		set(handles.push_load_data_get,'String', 'Resume loading...');
	else
		set(handles.push_load_data_get,'String', 'Load Scenariodata...');
	end
	set(handles.push_network_select_scenario,'Enable', 'on');
	if isempty(handles.Current_Settings.Simulation.Scenarios_Selection)
		set(handles.edit_simulation_number_scenarios,'String',...
			num2str(handles.Current_Settings.Simulation.Scenarios.Number));
	else
		set(handles.edit_simulation_number_scenarios,'String',...
			num2str(sum(handles.Current_Settings.Simulation.Scenarios_Selection>=1)));
	end
else
	if handles.Current_Settings.Data_Extract.MV_input_generation_in_progress
		set(handles.push_load_data_get,'String', 'Resume loading...');
	else
		set(handles.push_load_data_get,'String', 'Load Loaddata...');
	end
	set(handles.edit_simulation_number_scenarios,'String','Singlesim.');
	set(handles.push_network_select_scenario,'Enable', 'off');
end

% Analysefunktionen Steuerung:
set(handles.check_analysis_branch_violation, ...
	'Value',handles.Current_Settings.Simulation.Branch_Violation_Analysis);
if handles.Current_Settings.Simulation.Branch_Violation_Analysis
	set(handles.check_analysis_branch_data_save,...
		'Value',handles.Current_Settings.Simulation.Save_Branch_Results,...
		'Enable','on');
else
	set(handles.check_analysis_branch_data_save,'Value',0,'Enable','off');
end

set(handles.check_analysis_voltage_violation,...
	'Value',handles.Current_Settings.Simulation.Voltage_Violation_Analysis);
if handles.Current_Settings.Simulation.Voltage_Violation_Analysis
	set(handles.check_analysis_voltage_data_save,...
		'Value',handles.Current_Settings.Simulation.Save_Voltage_Results,...
		'Enable','on');
else
	set(handles.check_analysis_voltage_data_save,'Value',0,'Enable','off');
end

set(handles.check_analysis_power_loss,...
	'Value',handles.Current_Settings.Simulation.Power_Loss_Analysis)
if handles.Current_Settings.Simulation.Power_Loss_Analysis
	set(handles.check_analysis_power_loss_data_save,...
		'Value',handles.Current_Settings.Simulation.Save_Power_Loss_Results,...
		'Enable','on');
else
	set(handles.check_analysis_power_loss_data_save,'Value',0,'Enable','off')
end

if strcmp(handles.Current_Settings.Grid.Type,'LV')
	set(handles.radio_network_type_lv, 'Value', 1);
	set(handles.radio_network_type_mv, 'Value', 0);
elseif  strcmp(handles.Current_Settings.Grid.Type,'MV')
	set(handles.radio_network_type_lv, 'Value', 0);
	set(handles.radio_network_type_mv, 'Value', 1);
end

set(handles.check_controller_emob_charge_active, ...
	'Value', handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active);
if handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active
	set(handles.push_controller_emob_charge_settings, 'Enable', 'on');
	set(handles.check_controller_emob_charge_active_all, 'Enable', 'on');
else
	set(handles.push_controller_emob_charge_settings, 'Enable', 'off');
	set(handles.check_controller_emob_charge_active_all, 'Enable', 'off');
end
end

