function handles = refresh_display_NAT_main_gui(handles)
%REFRESH_DISPLAY_NAT_MAIN_GUI    Summary of this function goes here
%    Detailed explanation goes here

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%      Einstellungen - Auslesen der Daten
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Worstcases eintragen:
set(handles.popup_hh_worstcase, ...
	'Value', handles.Current_Settings.Data_Extract.Worstcase_Housholds);

% Einstellungen der Wochentage und Jahreszeiten anpassen:
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
% Einstellungen für Zeitreihen aktivieren:
if handles.Current_Settings.Data_Extract.get_Time_Series
	set(handles.push_time_series_settings, 'Enable','On');
	set(handles.check_get_time_series, 'Value',1);
else
	set(handles.push_time_series_settings, 'Enable','Off');
	set(handles.check_get_time_series, 'Value',0);
end
% Befüllen des Pop-Up-Menüs:
set(handles.popup_time_resolution, 'String', handles.System.time_resolutions(:,1),...
	'Value', handles.Current_Settings.Data_Extract.Time_Resolution);
% Checkboxen für Behandlung der Daten setzen:
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
	
	set(handles.uipanel_detail_component,...
		'Title', ['Details für ',...
		handles.Current_Settings.Table_Network.Data{row,1},':']);
	set(handles.text_hh_typ, 'Visible', 'on');
	set(handles.popup_pqnode_hh_typ,...
		'Visible', 'on',...
		'Value', find(strcmp(...
		    handles.Current_Settings.Table_Network.Data{row,3},...
		    handles.System.housholds(:,1))));
	set(handles.check_pqnode_active,...
		'Visible', 'on',...
		'Value', handles.Current_Settings.Table_Network.Data{row,2});
else
	set(handles.check_pqnode_active, 'Visible', 'off');
	set(handles.popup_pqnode_hh_typ, 'Visible', 'off');
	set(handles.text_hh_typ, 'Visible', 'off');
	set(handles.uipanel_detail_component,...
		'Title', 'Kein Netzknoten ausgewählt');
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
else
	set(handles.static_text_network_path_name, 'String', 'Kein Netz geladen!');
	set(handles.uipanel_detail_component,'Title','Kein Netz geladen!');
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

% Wenn eine gültige Datenbank geladen wurde, die Schaltfläche "Lastdaten laden..."
% aktivieren:
if isfield(handles.Current_Settings.Load_Database,'setti')
    set(handles.push_load_data_get, 'Enable','on');
else
	set(handles.push_network_calculation_start, 'Enable','off');
    set(handles.push_load_data_get, 'Enable','off');
end
% Wenn Lastdaten vorhanden sind, Netzberechnungen erlauben...
if isfield(handles, 'Result')
	if isfield(handles.Result, 'Households')
		set(handles.push_network_calculation_start, 'Enable','on');
	else
		set(handles.push_network_calculation_start, 'Enable','off');
	end
	if isfield(handles.Result, 'Displayable')
		set(handles.push_data_show, 'Enable','on');
	else
		set(handles.push_data_show, 'Enable','off');
    end
else
    set(handles.push_network_calculation_start, 'Enable','off');
    set(handles.push_data_show, 'Enable','off');
end
