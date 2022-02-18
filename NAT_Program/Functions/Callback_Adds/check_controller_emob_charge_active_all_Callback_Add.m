function check_controller_emob_charge_active_all_Callback_Add(hObject, ~, handles)
%CHECK_CONTROLLER_EMOB_CHARGE_ACTIVE_ALL_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

idx = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'EMob Ctr.');
data = handles.Current_Settings.Table_Network.Data;
if get(hObject,'Value')
	data(:,idx) = num2cell(true(size(data,1),1));
else
	data(:,idx) = num2cell(false(size(data,1),1));
end

handles.Current_Settings.Table_Network.Data = data;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);
end

