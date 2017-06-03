function [Table_Network, Data_Extract]  = network_table_reset(handles)
%NETWORK_TABLE_RESET Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.2
% Erstellt von:            Franz Zeilinger - 22.03.2013
% Letzte Änderung durch:   Franz Zeilinger - 11.11.2013

Data_Extract = handles.Current_Settings.Data_Extract;

if isempty(handles.NAT_Data.Grid)
	Table_Network = [];
    return;   
end

% what is the current opened grid:
cg = handles.sin.Settings.Grid_name;

% fill table with data, search for the correct position, use for this the column names
% spezified in the default settings: 
ColumnName = handles.System.table_settings.lv.ColumnName;
%create an empty cell array:
data = cell(numel({handles.NAT_Data.Grid.(cg).P_Q_Node.Points.P_Q_Name}'),numel(handles.System.table_settings.lv.ColumnName));
% node names:
idx = strcmp(ColumnName, 'Names');
data(:,idx) = {handles.NAT_Data.Grid.(cg).P_Q_Node.Points.P_Q_Name}';
idx = strcmp(ColumnName, 'Active');
data(:,idx) = num2cell(ones(size(data,1),1));
idx = strcmp(ColumnName, 'Housh.type');
data(:,idx) = deal(handles.System.housholds(1,1));
idx = strcmp(ColumnName, 'PV-Plant');
data(:,idx) = deal(handles.System.sola.Selectable(1,1));
idx = strcmp(ColumnName, 'El. Mob.');
data(:,idx) = num2cell(zeros(size(data,1),1));

add_data = cell(size(data,1),numel(handles.System.table_settings.lv.Additional_Data_Content));

% ColumnFormat = {...
% 	'char', ...
% 	'logical', ...
% 	handles.System.housholds(:,1)', ...
%     handles.System.sola.Selectable(:,1)',...
%     'numeric'};
% ColumnEditable = [false, true, true, true, true];

Table_Network.Data = data;
Table_Network.Additional_Data = add_data;
Table_Network.Additional_Data_Content = handles.System.table_settings.lv.Additional_Data_Content;
Table_Network.ColumnName = handles.System.table_settings.lv.ColumnName;
Table_Network.ColumnEditable =  handles.System.table_settings.lv.ColumnEditable;
Table_Network.ColumnFormat = handles.System.table_settings.lv.ColumnFormat;
Table_Network.RowName = [];

% etwaige Erzeugungsstrukturen löschen:
Data_Extract.Solar.Selectable = handles.System.sola.Selectable;
Data_Extract.Solar.Plants = [];
Data_Extract.Wind.Selectable = handles.System.wind.Selectable;
Data_Extract.Wind.Plants = [];

end

