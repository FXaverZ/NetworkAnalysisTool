function handles = refresh_display_NAT_main_gui(handles)
%REFRESH_DISPLAY_NAT_MAIN_GUI    Summary of this function goes here
%    Detailed explanation goes here

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte �nderung durch:   Franz Zeilinger - 17.04.2013

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%      Einstellungen - Auslesen der Daten
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Worstcases eintragen:
set(handles.popup_hh_worstcase, ...
	'Value', handles.Current_Settings.Data_Extract.Worstcase_Housholds);
set(handles.popup_gen_worstcase, ...
	'Value', handles.Current_Settings.Data_Extract.Worstcase_Generation);

% Einstellungen der Wochentage und Jahreszeiten anpassen:
for i=1:3
	set(handles.(['radio_season_',num2str(i)]),...
		'Value',handles.Current_Settings.Data_Extract.Season(i));
	set(handles.(['radio_weekday_',num2str(i)]),...
		'Value',handles.Current_Settings.Data_Extract.Weekday(i));
	% Bei Zeitreihen Eingaben einschr�nken:
	if handles.Current_Settings.Data_Extract.get_Time_Series
		set(handles.(['radio_weekday_',num2str(i)]),...
			'Enable','Off');
	else
		set(handles.(['radio_weekday_',num2str(i)]),...
			'Enable','On');
	end
end
% Einstellungen f�r Zeitreihen aktivieren:
if handles.Current_Settings.Data_Extract.get_Time_Series
	set(handles.push_time_series_settings, 'Enable','On');
	set(handles.check_get_time_series, 'Value',1);
else
	set(handles.push_time_series_settings, 'Enable','Off');
	set(handles.check_get_time_series, 'Value',0);
end
% Bef�llen der Pop-Up-Men�s:
set(handles.popup_time_resolution, 'String', handles.System.time_resolutions(:,1),...
	'Value', handles.Current_Settings.Data_Extract.Time_Resolution);
set(handles.popup_pqnode_pv_typ, 'String',  ...
	handles.Current_Settings.Data_Extract.Solar.Selectable(:,1));
set(handles.popup_pqnode_wi_typ, 'String',  ...
	handles.Current_Settings.Data_Extract.Wind.Selectable(:,1));

% Checkboxen f�r Behandlung der Daten setzen:
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

% if isempty(handles.Current_Settings.Table_Network)
% 	set(handles.popup_pqnode_hh_typ, 'Visible', 'off');
% 	set(handles.check_pqnode_active, 'Visible', 'off');
% end
if isfield(handles.Current_Settings.Table_Network, 'Selected_Row') && ...
		~isempty(handles.Current_Settings.Table_Network.Selected_Row)
	row = handles.Current_Settings.Table_Network.Selected_Row;
	plant_pv_name = handles.Current_Settings.Table_Network.Additional_Data{row,1};
	sel_pv = find(strcmp(plant_pv_name,...
		handles.Current_Settings.Data_Extract.Solar.Selectable(:,2)));
	if isempty(sel_pv)
		sel_pv = 1;
	end
	
	set(handles.uipanel_detail_component,...
		'Title', ['Details f�r ',...
		handles.Current_Settings.Table_Network.Data{row,1},':']);
	set(handles.text_pqnode_hh_typ, 'Visible', 'on');
	set(handles.popup_pqnode_hh_typ,...
		'Visible', 'on',...
		'Value', find(strcmp(...
		    handles.Current_Settings.Table_Network.Data{row,2},...
		    handles.System.housholds(:,1))));
% 	set(handles.check_pqnode_active,...
% 		'Visible', 'on',...
% 		'Value', handles.Current_Settings.Table_Network.Data{row,2});
	set(handles.text_pqnode_pv_typ, 'Visible', 'on');
	set(handles.popup_pqnode_pv_typ, 'Visible', 'on', 'Value', sel_pv);
	set(handles.edit_pqnode_pv_installed_power, 'Visible', 'on');
	set(handles.text_pqnode_pv_installed_power_unit, 'Visible', 'on');
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
	set(handles.text_pqnode_wi_typ, 'Visible', 'on');
	set(handles.popup_pqnode_wi_typ, 'Visible', 'on');
	set(handles.edit_pqnode_wi_installed_power, 'Visible', 'on');
	set(handles.text_pqnode_wi_installed_power_unit, 'Visible', 'on');
	set(handles.push_pqnode_wi_parameters, 'Visible', 'on');
	
else
	set(handles.check_pqnode_active, 'Visible', 'off');
	set(handles.popup_pqnode_hh_typ, 'Visible', 'off');
	set(handles.text_pqnode_hh_typ, 'Visible', 'off');
	set(handles.uipanel_detail_component,...
		'Title', 'Kein Netzknoten ausgew�hlt');
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
end

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
	set(handles.push_network_load_allocation_reset, 'Enable','on');
	set(handles.push_network_load_random_allocation, 'Enable','on');
else
	set(handles.static_text_network_path_name, 'String', 'Kein Netz geladen!');
	set(handles.uipanel_detail_component,'Title','Kein Netz geladen!');
	set(handles.push_network_calculation_start, 'Enable','off');
	set(handles.push_network_load_allocation_reset, 'Enable','off');
	set(handles.push_network_load_random_allocation, 'Enable','off');
end

if ~isempty(handles.Current_Settings.Table_Network)
	ntw = handles.Current_Settings.Table_Network;
	
	set(handles.table_data_network, ...
		'Data', ntw.Data, ...
		'ColumnName', ntw.ColumnName,...
		'ColumnFormat', ntw.ColumnFormat,...
		'ColumnEditable', ntw.ColumnEditable,...
		'RowName', ntw.RowName);
end

% Wenn eine g�ltige Datenbank geladen wurde, die Schaltfl�che "Lastdaten laden..."
% aktivieren:
if isfield(handles.Current_Settings.Load_Database,'setti')
    set(handles.push_load_data_get, 'Enable','on');
else
	set(handles.push_network_calculation_start, 'Enable','off');
    set(handles.push_load_data_get, 'Enable','off');
end
% Wenn Lastdaten vorhanden sind, Netzberechnungen erlauben...
if ~isempty(handles.NAT_Data.Load_Infeed_Data)
	if (isfield(handles.NAT_Data.Load_Infeed_Data, 'Households') || ...
			isfield(handles.NAT_Data.Load_Infeed_Data.Set_1, 'Households')) ...
			&& isfield(handles, 'sin') ||...
			(handles.Current_Settings.Simulation.Use_Scenarios && ...
			handles.Current_Settings.Simulation.Scenarios.Data_avaliable)
		set(handles.push_network_calculation_start, 'Enable','on');
	else
		set(handles.push_network_calculation_start, 'Enable','off');
	end
	if isfield(handles.NAT_Data.Result, 'Displayable')
		set(handles.push_data_show, 'Enable','on');
	else
		set(handles.push_data_show, 'Enable','off');
	end
else
	set(handles.push_network_calculation_start, 'Enable','off');
	set(handles.push_data_show, 'Enable','off');
end

% Eingabefelder aktualisieren:
set(handles.edit_simulation_number_runs,...
	'String', num2str(handles.Current_Settings.Simulation.Number_Runs));

% Wurden Variantennetz geladen, Buttons deaktivieren und Anzahl darstellen:
if ~isempty(handles.Current_Settings.Simulation.Grid_List)
	set(handles.edit_network_number_variants, 'String', num2str(numel(handles.Current_Settings.Simulation.Grid_List)));
else
	set(handles.edit_network_number_variants, 'String', 'Einzels.');
end

set(handles.check_use_scenarios, 'Value', handles.Current_Settings.Simulation.Use_Scenarios);
set(handles.check_use_variants, 'Value', handles.Current_Settings.Simulation.Use_Grid_Variants);
if handles.Current_Settings.Simulation.Use_Scenarios
	set(handles.push_load_data_get,'String', 'Szenariendaten laden...');
	set(handles.edit_simulation_number_scenarios,'String',...
		num2str(handles.Current_Settings.Simulation.Scenarios.Number));
else
	set(handles.push_load_data_get,'String', 'Lastdaten laden...');
	set(handles.edit_simulation_number_scenarios,'String','Einzels.');
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

end
