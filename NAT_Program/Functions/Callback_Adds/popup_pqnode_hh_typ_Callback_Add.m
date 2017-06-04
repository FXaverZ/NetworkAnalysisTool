function popup_pqnode_hh_typ_Callback_Add (hObject, handles)
% hObject    handle to popup_pqnode_hh_typ (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

sel = get(hObject,'Value');
str = get(hObject,'String');
str = str{sel};

% Where are the households in the network table?
idx_hh = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Housh.type');
% Which row is currently selected:
row = handles.Current_Settings.Table_Network.Selected_Row;

% Adapt the selection in the network table:
handles.Current_Settings.Table_Network.Data{row,idx_hh} = str;

% update GUI:
handles = refresh_display_NAT_main_gui(handles);

% update handles structure:
guidata(hObject, handles);
end

