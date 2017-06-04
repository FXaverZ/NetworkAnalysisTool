function check_pqnode_active_Callback_Add (hObject, handles)
% hObject    handle to check_pqnode_active (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

av_cur = get(hObject, 'Value');

% Where is the "active"-Flag Column:
idx_ac = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Active');
% Which row is currently selected?
row = handles.Current_Settings.Table_Network.Selected_Row;

if av_cur
	handles.Current_Settings.Table_Network.Data{row,idx_ac} = true;
else
	handles.Current_Settings.Table_Network.Data{row,idx_ac} = false;
end

% update GUI:
handles = refresh_display_NAT_main_gui(handles);

% update handles structure:
guidata(hObject, handles);
end

