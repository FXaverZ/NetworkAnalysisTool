function edit_pqnode_hh_number_Callback_Add(hObject, ~, handles)
%EDIT_PQNODE_HH_NUMBER_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

% the current selected row:
row_act = handles.Current_Settings.Table_Network.Selected_Row;
input_string = get(hObject,'String');

handles = edit_pqnode_hh_number(handles,row_act,input_string);

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
% handles-Structure aktualisieren:
guidata(hObject, handles);
end

