function popup_pqnode_hh_typ_Callback_Add (hObject, handles)
% hObject    handle to popup_pqnode_hh_typ (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

sel = get(hObject,'Value');
str = get(hObject,'String');
str = str{sel};

if strcmp(handles.Current_Settings.Grid.Type, 'LV')
	% Where are the households in the network table?
	idx = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Housh.type');
else
	% Where are the LV-Grids?
	idx = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
end
% Which row is currently selected:
row = handles.Current_Settings.Table_Network.Selected_Row;

% Adapt the selection in the network table:
handles.Current_Settings.Table_Network.Data{row,idx} = str;

% update GUI:
handles = refresh_display_NAT_main_gui(handles);

% update handles structure:
guidata(hObject, handles);
end

