function handles = refresh_display_NAT_main_gui(handles)
%REFRESH_DISPLAY_NAT_MAIN_GUI    Summary of this function goes here
%    Detailed explanation goes here

% Version:                 1.1
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 09.04.2014

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
if isfield(handles.Current_Settings.Table_Network, 'Selected_Row') && ...
		~isempty(handles.Current_Settings.Table_Network.Selected_Row)
	
	% the current selected row:
	row = handles.Current_Settings.Table_Network.Selected_Row;
	% Where are the names of the PQ-Nodes:
	idx_na = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Names');
	% Where is the "active"-Flag Column:
	idx_ac = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Active');
	
	% Update the gui elements (activate them + show the information of the currently
	% selected PQ-node):
	set(handles.uipanel_detail_component,...
		'Title', ['Details for ',...
		handles.Current_Settings.Table_Network.Data{row,idx_na},':']);
	set(handles.check_pqnode_active, ...
			'Visible', 'on',...
			'Enable',  'on',...
			'Value',   handles.Current_Settings.Table_Network.Data{row,idx_ac});
	set(handles.text_pqnode_hh_typ, 'Visible', 'on');
	set(handles.popup_pqnode_hh_typ,'Visible', 'on');
	set(handles.text_pqnode_wi_typ, 'Visible', 'on');
	set(handles.text_pqnode_pv_typ, 'Visible', 'on');
	
	if strcmp(handles.Current_Settings.Grid.Type,'LV')
		% Where is the additional data?
		idx_pv_add = strcmp(handles.Current_Settings.Table_Network.Additional_Data_Content, 'PV_Plant_Name');
		% Where are the households?
		idx_hh = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Housh.type');
		
		% Get the PV-Plant Information:
		plant_pv_name = handles.Current_Settings.Table_Network.Additional_Data{idx_pv_add,1};
		sel_pv = find(strcmp(plant_pv_name,...
			handles.Current_Settings.Data_Extract.Solar.Selectable(:,2)));
		if isempty(sel_pv)
			sel_pv = 1;
		end
		
		set(handles.text_pqnode_hh_typ, 'String', 'Hh. Type');
		set(handles.popup_pqnode_hh_typ, 'String', handles.System.housholds(:,1));
		set(handles.popup_pqnode_hh_typ,...
			'Value', find(strcmp(...
			handles.Current_Settings.Table_Network.Data{row,idx_hh},...
			handles.System.housholds(:,1))));
		set(handles.popup_pqnode_pv_typ, 'Visible', 'on', 'Value', sel_pv);
		set(handles.text_pqnode_pv_installed_power_unit, 'Visible', 'on');
		set(handles.edit_pqnode_pv_installed_power, 'Visible', 'on');

		set(handles.push_pqnode_pv_parameters, 'Visible', 'on');
		if sel_pv > 1
			set(handles.edit_pqnode_pv_installed_power, 'Enable', 'on',...
				'String', ...
				handles.Current_Settings.Data_Extract.Solar.Plants.(plant_pv_name).Power_Installed);
			set(handles.push_pqnode_pv_parameters, 'Enable', 'on');
		else
			set(handles.push_pqnode_pv_parameters, 'Enable', 'off');
			set(handles.edit_pqnode_pv_installed_power, 'Enable', 'off');
		end
		set(handles.popup_pqnode_wi_typ, 'Visible', 'on');
		set(handles.text_pqnode_pv_typ, 'String', 'PV Gen.');
		set(handles.popup_pqnode_wi_typ, 'Visible', 'on');
		set(handles.edit_pqnode_wi_installed_power, 'Visible', 'on');
		set(handles.text_pqnode_wi_installed_power_unit, 'Visible', 'on');
		set(handles.push_pqnode_wi_parameters, 'Visible', 'on');
		set(handles.text_pqnode_wi_typ, 'String', 'Wind Gen.');
		
	elseif strcmp(handles.Current_Settings.Grid.Type,'MV')
		% Where are the LV-grids?
		idx_lv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
		
		set(handles.text_pqnode_hh_typ, 'String', 'LV Grid');
		set(handles.text_pqnode_pv_typ, 'String', 'PV?');
		set(handles.text_pqnode_wi_typ, 'String', 'El. Mob.?');
		set(handles.popup_pqnode_hh_typ, 'String', handles.Current_Settings.Table_Network.ColumnFormat{idx_lv});
		set(handles.popup_pqnode_hh_typ,...
			'Value', find(strcmp(...
			handles.Current_Settings.Table_Network.Data{row,idx_lv},...
			handles.Current_Settings.Table_Network.ColumnFormat{idx_lv})));
		set(handles.check_pqnode_emob_present, 'Visible', 'on');
		set(handles.check_pqnode_pv_present, 'Visible', 'on');
		
		set(handles.popup_pqnode_pv_typ, 'Visible', 'off');
		set(handles.edit_pqnode_pv_installed_power, 'Visible', 'off');
		set(handles.text_pqnode_pv_installed_power_unit, 'Visible', 'off');
		set(handles.push_pqnode_pv_parameters, 'Visible', 'off');
		set(handles.popup_pqnode_wi_typ, 'Visible', 'off');
		set(handles.edit_pqnode_wi_installed_power, 'Visible', 'off');
		set(handles.text_pqnode_wi_installed_power_unit, 'Visible', 'off');
		set(handles.push_pqnode_wi_parameters, 'Visible', 'off');
	end
else
	set(handles.check_pqnode_active, 'Visible', 'off');
	set(handles.popup_pqnode_hh_typ, 'Visible', 'off');
	set(handles.text_pqnode_hh_typ, 'Visible', 'off');
	set(handles.uipanel_detail_component,...
		'Title', 'No grid node selected');
	set(handles.text_pqnode_pv_typ, 'Visible', 'off');
	set(handles.popup_pqnode_pv_typ, 'Visible', 'off');
	set(handles.edit_pqnode_pv_installed_power, 'Visible', 'off');
	set(handles.text_pqnode_pv_installed_power_unit, 'Visible', 'off');
	set(handles.push_pqnode_pv_parameters, 'Visible', 'off');
	set(handles.popup_pqnode_wi_typ, 'Visible', 'off');
	set(handles.text_pqnode_wi_typ, 'Visible', 'off');
	set(handles.popup_pqnode_wi_typ, 'Visible', 'off');
	set(handles.edit_pqnode_wi_installed_power, 'Visible', 'off');
	set(handles.text_pqnode_wi_installed_power_unit, 'Visible', 'off');
	set(handles.push_pqnode_wi_parameters, 'Visible', 'off');
	set(handles.check_pqnode_emob_present, 'Visible', 'off');
	set(handles.check_pqnode_pv_present, 'Visible', 'off');
end


%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	else
		set(handles.push_network_load_random_allocation, 'Enable','on');

	end
	set(handles.push_network_load_allocation_reset, 'Enable','on');
	set(handles.push_load_data_get,'Enable','on');
	set(handles.check_simulation_start_after_data_extraction,'Enable','on');
else
	set(handles.static_text_network_path_name, 'String', 'No grid loaded!');
	set(handles.uipanel_detail_component,'Title','No grid loaded!');
	set(handles.push_network_load_allocation_reset, 'Enable','off');
	set(handles.push_network_load_random_allocation, 'Enable','off');
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
		set(handles.push_network_calculation_start, 'Enable','off');
	end
else
	set(handles.push_network_calculation_start, 'Enable','off');
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
	if isempty(handles.Current_Settings.Simulation.Scenarios_Selection);
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

