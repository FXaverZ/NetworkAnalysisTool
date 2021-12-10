function push_pqnode_pv_parameters_Callback_Add (hObject, ~, handles)
%PUSH_PQNODE_PV_PARAMETERS_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

settin = handles.Current_Settings.Data_Extract.Solar;
add_data = handles.Current_Settings.Table_Network.Additional_Data;
row_act = handles.Current_Settings.Table_Network.Selected_Row;

% Where are the pv-plants in the Table_Network data:
idx_pv = find(strcmp(handles.Current_Settings.Table_Network.ColumnName, 'PV-Plant'));
% Where is the additional data?
idx_pv_add = strcmp(handles.Current_Settings.Table_Network.Additional_Data_Content, 'PV_Plant_Name');

name = add_data{row_act,idx_pv_add};
settin.Plants.(name) = ...
	Configuration_PV_Parameters(handles,'Parameters',settin.Plants.(name));
settin.Plants.(name).Number = sum(strcmp(add_data(:,idx_pv_add),name));
typ = handles.System.sola.Typs{settin.Plants.(name).Typ,1};
long_na = [typ(1:4),' - ',...
	num2str(settin.Plants.(name).Power_Installed/1000,'%.2f'),' kWp - ',...
	num2str(settin.Plants.(name).Orientation,'%.2f'),'° - ',...
	num2str(settin.Plants.(name).Inclination,'%.2f'),'°'];
idx_sel = strcmp(settin.Selectable(:,2), name);
settin.Selectable{idx_sel,1} = long_na;

handles.Current_Settings.Table_Network.ColumnFormat{idx_pv} = settin.Selectable(:,1)';
handles.Current_Settings.Table_Network.Data{row_act,idx_pv} = long_na;
handles.Current_Settings.Data_Extract.Solar = settin;
% update handles structure:
guidata(hObject, handles);

% update GUI:
handles = refresh_display_NAT_main_gui(handles);
end

