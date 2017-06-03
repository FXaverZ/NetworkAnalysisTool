function table_data_network_CellSelectionCallback_Add (hObject, eventdata, handles)
%TABLE_DATA_NETWORK_CELLSELECTIONCALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

if numel(eventdata.Indices) > 0
	handles.Current_Settings.Table_Network.Selected_Row = eventdata.Indices(1);
	
	% das entsprechende Element in SINCAL GUI markieren (falls dieses offen ist):
	if isfield(handles, 'sin')
		handles.sin.gui_select_element(...
			handles.NAT_Data.Grid.(handles.sin.Settings.Grid_name).P_Q_Node.ids(eventdata.Indices(1)));
	end
else
	handles.Current_Settings.Table_Network.Selected_Row = [];
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

