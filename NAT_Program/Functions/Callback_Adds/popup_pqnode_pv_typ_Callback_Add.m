function popup_pqnode_pv_typ_Callback_Add (hObject, handles)
%POPUP_PQNODE_PV_TYP_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

% Where are the pv-plants in the Table_Network data:
idx_pv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'PV-Plant');
% Where is the additional data?
idx_pv_add = strcmp(handles.Current_Settings.Table_Network.Additional_Data_Content, 'PV_Plant_Name');
% get the settings:
settin = handles.Current_Settings.Data_Extract.Solar;
row_act = handles.Current_Settings.Table_Network.Selected_Row;
add_data = handles.Current_Settings.Table_Network.Additional_Data;
sel = get(hObject,'Value');
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
	long_na = pvplant2str(handles,settin.Plants.(name));
	settin.Selectable{end-1,1} = long_na;
	handles.Current_Settings.Table_Network.ColumnFormat{idx_pv} = settin.Selectable(:,1)';
	handles.Current_Settings.Table_Network.Data{row_act,idx_pv} = long_na;
elseif sel == 1
	% keine Anlage mehr ausgewählt, Anlagenanzahl reduzieren:
	name_old = add_data{row_act,2};
	long_na = settin.Selectable{sel,1};
	if ~isempty(name_old)
		% Fall andere Anlagen zuvor angewählt war, deren Anzahl verringern:
		settin.Plants.(name_old).Number = settin.Plants.(name_old).Number - 1;
	end
	add_data{row_act,1} = [];
	handles.Current_Settings.Table_Network.Data{row_act,idx_pv} = long_na;
else
	name = settin.Selectable{sel,2};
	long_na = settin.Selectable{sel,1};
	name_old = add_data{row_act,2};
	if ~isempty(name_old)
		% Fall andere Anlagen zuvor angewählt war, deren Anzahl verringern:
		settin.Plants.(name_old).Number = settin.Plants.(name_old).Number - 1;
	end
	% ausgewählte Anlage setzen:
	settin.Plants.(name).Number = settin.Plants.(name).Number + 1;
	add_data{row_act,idx_pv_add} = name;
	handles.Current_Settings.Table_Network.Data{row_act,idx_pv} = long_na;
end

handles.Current_Settings.Data_Extract.Solar = settin;
handles.Current_Settings.Table_Network.Additional_Data = add_data;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren
guidata(hObject, handles);

end

