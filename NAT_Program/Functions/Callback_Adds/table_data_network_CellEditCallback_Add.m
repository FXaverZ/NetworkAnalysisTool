function table_data_network_CellEditCallback_Add (hObject, eventdata, handles)
% --- Wird ausgeführt, wenn die Daten in table_data_network verändert werden
% hObject    Link zur Grafik table_data_network (siehe GCBO)
% eventdata  Struktur mit den folgenden Feldern (see UITABLE)
%     Indices: Zeilen- und Spaltenindex der aktuell geänderten Zellen
%	  PreviousData: Daten der Zellen vor der Änderung
%	  EditData: String(s), durch den Nutzer eingegeben
%	  NewData: EditData oder die daraus konvertierten Daten gemäß den
%	      Spalten-Eigenschaften. Leer, wenn nichts eingegeben wurde...
%	  Error: Error-String, falls die Konversion von EditData zu einen passenden
%	      Format von Data nicht möglich war.
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Wo wurde was geändert?
row_act = eventdata.Indices(1);
col = eventdata.Indices(2);
% Daten aktualisieren:
handles.Current_Settings.Table_Network.Data = ...
	get(handles.table_data_network, 'Data');

% Where is the "active"-Flag Column:
idx_ac = find(strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Active'));

if col == idx_ac && eventdata.EditData
	handles.Current_Settings.Table_Network.Data{row_act, col} = true;
elseif col == idx_ac && ~eventdata.EditData
	handles.Current_Settings.Table_Network.Data{row_act, col} = false;
end

% Where are the pv-plants in the Table_Network data:
idx_pv = find(strcmp(handles.Current_Settings.Table_Network.ColumnName, 'PV-Plant'));
if col == idx_pv
	% Where is the additional data?
	idx_pv_add = strcmp(handles.Current_Settings.Table_Network.Additional_Data_Content, 'PV_Plant_Name');
	
	settin = handles.Current_Settings.Data_Extract.Solar;
	add_data = handles.Current_Settings.Table_Network.Additional_Data;
	
	sel = find(strcmp(handles.Current_Settings.Table_Network.Data{row_act,col}, ...
		settin.Selectable(:,1)));
	
	if sel == size(settin.Selectable,1)
		% letzter Eintrag ausgewählt, also muss eine neue Anlage hinzugefügt werden:
		if isstruct(settin.Plants)
			n_pl = numel(fieldnames(settin.Plants));
			name = ['Plant_',num2str(n_pl+1)];
		else
			name = 'Plant_1';
		end
		settin.Plants.(name) = handles.System.sola.Default_Plant;
		add_data{row_act,idx_pv_add} = name;
		settin.Selectable{end+1,1} = settin.Selectable{end,1};
		settin.Selectable{end-1,2} = name;
		settin.Plants.(name) = ...
			Configuration_PV_Parameters(handles,'Parameters',settin.Plants.(name));
		settin.Plants.(name).Number = 1;
		typ = handles.System.sola.Typs{settin.Plants.(name).Typ,1};
		long_na = [typ(1:4),' - ',...
			num2str(settin.Plants.(name).Power_Installed),' kWp - ',...
			num2str(settin.Plants.(name).Orientation),'° - ',...
			num2str(settin.Plants.(name).Inclination),'°'];
		settin.Selectable{end-1,1} = long_na;
		handles.Current_Settings.Table_Network.ColumnFormat{4} = settin.Selectable(:,1)';
		handles.Current_Settings.Table_Network.Data{row_act,4} = long_na;
	elseif sel == 1
		% keine Anlage mehr ausgewählt, Anlagenanzahl reduzieren:
		name_old = add_data{row_act,idx_pv_add};
		long_na = settin.Selectable{sel,1};
		if ~isempty(name_old)
			% Fall andere Anlagen zuvor angewählt war, deren Anzahl verringern:
			settin.Plants.(name_old).Number = settin.Plants.(name_old).Number - 1;
		end
		add_data{row_act,idx_pv_add} = [];
		handles.Current_Settings.Table_Network.Data{row_act,4} = long_na;
	else
		name = settin.Selectable{sel,2};
		long_na = settin.Selectable{sel,1};
		name_old = add_data{row_act,idx_pv_add};
		if ~isempty(name_old)
			% Fall andere Anlagen zuvor angewählt war, deren Anzahl verringern:
			settin.Plants.(name_old).Number = settin.Plants.(name_old).Number - 1;
		end
		% ausgewählte Anlage setzen:
		settin.Plants.(name).Number = settin.Plants.(name).Number + 1;
		add_data{row_act,idx_pv_add} = name;
		handles.Current_Settings.Table_Network.Data{row_act,4} = long_na;
	end
	
	handles.Current_Settings.Data_Extract.Solar = settin;
	handles.Current_Settings.Table_Network.Additional_Data = add_data;
end

handles.Current_Settings.Table_Network.Selected_Row = row_act;

% update GUI:
handles = refresh_display_NAT_main_gui(handles);

% update handles structure:
guidata(hObject, handles);
end

