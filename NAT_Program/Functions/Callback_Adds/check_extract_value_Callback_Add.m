function check_extract_value_Callback_Add (hObject, handles, typ)
%CHECK_EXTRACT_VALUE_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

switch typ
	case '05_quantile_value'
		handles.Current_Settings.Data_Extract.get_05_Quantile_Value = get(hObject, 'Value');
	case '95_quantile_value'
		handles.Current_Settings.Data_Extract.get_95_Quantile_Value = get(hObject, 'Value');
	case 'max_value'
		handles.Current_Settings.Data_Extract.get_Max_Value = get(hObject, 'Value');
	case 'mean_value'
		handles.Current_Settings.Data_Extract.get_Mean_Value = get(hObject, 'Value');
	case 'min_value'
		handles.Current_Settings.Data_Extract.get_Min_Value = get(hObject, 'Value');
	case 'sample_value'
		handles.Current_Settings.Data_Extract.get_Sample_Value = get(hObject, 'Value');
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);
end

