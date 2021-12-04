function push_network_load_allocation_reset_Callback_Add(hObject, handles)
% hObject    Link zur Grafik  push_network_load_allocation_reset (siehe GCBO)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Tabelle mit Default-Werten befüllen:
[handles.Current_Settings.Table_Network, ...
    handles.Current_Settings.Data_Extract] = network_table_reset(handles);

if strcmp(handles.Current_Settings.Grid.Type, 'LV')
	% Anzahl der jeweiligen Haushalte ermitteln:
	if ~isempty(handles.Current_Settings.Table_Network)
		for i=1:size(handles.System.housholds,1)
			handles.Current_Settings.Data_Extract.Households.(handles.System.housholds{i,1}).Number = ...
				sum(strcmp(...
				handles.System.housholds{i,1},...
				handles.Current_Settings.Table_Network.Data(:,strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Haush. Typ'))));
		end
	end
elseif strcmp(handles.Current_Settings.Grid.Type, 'MV')
	% Adjust Number of Grids (in this case, delete the numbers):
	handles.Current_Settings.Data_Extract.LV_Grids_Number = [];
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);
end

