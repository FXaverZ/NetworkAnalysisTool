function [Table_Network, Data_Extract]  = network_table_reset(handles)
%NETWORK_TABLE_RESET Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.4
% Erstellt von:            Franz Zeilinger - 22.03.2013
% Letzte Änderung durch:   Franz Zeilinger - 11.12.2014

Data_Extract = handles.Current_Settings.Data_Extract;

if isempty(handles.NAT_Data.Grid)
	Table_Network = [];
	return;
end

% what is the current opened grid:
cg = handles.sin.Settings.Grid_name;

% fill table with data, search for the correct position, use for this the column names
% spezified in the default settings:
if strcmp(handles.Current_Settings.Grid.Type, 'LV')
	ColumnName = handles.System.table_settings.lv.ColumnName;
	AddDataName = handles.System.table_settings.lv.Additional_Data_Content;
	
	%create an empty cell array:
	data = cell(numel({handles.NAT_Data.Grid.(cg).P_Q_Node.Points.P_Q_Name}'),numel(handles.System.table_settings.lv.ColumnName));
	% node names:
	idx = strcmp(ColumnName, 'Names');
	data(:,idx) = {handles.NAT_Data.Grid.(cg).P_Q_Node.Points.P_Q_Name}';
	% node activation
	idx = strcmp(ColumnName, 'Active');
	data(:,idx) = num2cell(true(size(data,1),1));
	idx = strcmp(ColumnName, 'Housh.type');
	data(:,idx) = deal(handles.System.housholds(1,1));
	idx = strcmp(ColumnName, 'Hh. Number');
	[data{:,idx}] = deal(1);
	idx = strcmp(ColumnName, 'PV-Plant');
	data(:,idx) = deal(handles.System.sola.Selectable(1,1));
	idx = strcmp(ColumnName, 'El. Mob.');
	data(:,idx) = num2cell(zeros(size(data,1),1));
	
	% fill the additional dData array with default values:
	add_data = cell(size(data,1),numel(handles.System.table_settings.lv.Additional_Data_Content));
	idx = strcmp(AddDataName, 'HHs_Selection');
	add_data(:,idx) = deal({handles.System.housholds(1,1)});
	idx = strcmp(AddDataName, 'HHs_Pool');
	[add_data{:,idx}] = deal([]);
	
	Table_Network.Data = data;
	Table_Network.Additional_Data = add_data;
	Table_Network.Additional_Data_Content = handles.System.table_settings.lv.Additional_Data_Content;
	Table_Network.ColumnName = handles.System.table_settings.lv.ColumnName;
	Table_Network.ColumnEditable =  handles.System.table_settings.lv.ColumnEditable;
	Table_Network.ColumnFormat = handles.System.table_settings.lv.ColumnFormat;
	Table_Network.ColumnWidth = handles.System.table_settings.lv.ColumnWidth;
	Table_Network.RowName = [];
	
	% etwaige Erzeugungsstrukturen löschen:
	Data_Extract.Solar.Selectable = handles.System.sola.Selectable;
	Data_Extract.Solar.Plants = [];
	Data_Extract.Wind.Selectable = handles.System.wind.Selectable;
	Data_Extract.Wind.Plants = [];
	
elseif strcmp(handles.Current_Settings.Grid.Type, 'MV')
	ColumnName = handles.System.table_settings.mv.ColumnName;
	%create an empty cell array:
	data = cell(numel({handles.NAT_Data.Grid.(cg).P_Q_Node.Points.P_Q_Name}'),numel(handles.System.table_settings.mv.ColumnName));
	
	% node names:
	idx = strcmp(ColumnName, 'Names');
	data(:,idx) = {handles.NAT_Data.Grid.(cg).P_Q_Node.Points.P_Q_Name}';
	% node activation
	idx = strcmp(ColumnName, 'Active');
	data(:,idx) = num2cell(true(size(data,1),1));
	
	idx = strcmp(ColumnName, 'LV-Grid');
	Table_Network.ColumnFormat = handles.System.table_settings.mv.ColumnFormat;
	Table_Network.ColumnFormat{idx} = [handles.System.lv_grids(1,2),handles.Current_Settings.Data_Extract.LV_Grids_List'];
	data(:,idx) = deal(handles.System.lv_grids(1,2));
	
	idx = strcmp(ColumnName, 'PV?');
	data(:,idx) = num2cell(false(size(data,1),1));
	idx = strcmp(ColumnName, 'El. Mob?');
	data(:,idx) = num2cell(false(size(data,1),1));
	idx = strcmp(ColumnName, 'EMob Ctr.');
	data(:,idx) = num2cell(true(size(data,1),1));
	
	Table_Network.Data = data;
	Table_Network.Additional_Data = [];
	Table_Network.Additional_Data_Content = {};
	Table_Network.ColumnName = handles.System.table_settings.mv.ColumnName;
	Table_Network.ColumnEditable = handles.System.table_settings.mv.ColumnEditable;
	Table_Network.ColumnWidth = handles.System.table_settings.mv.ColumnWidth;
	Table_Network.RowName = [];
end
end

