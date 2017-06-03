function [Table_Network, Data_Extract]  = network_table_reset(handles)
%NETWORK_TABLE_RESET Summary of this function goes here
%   Detailed explanation goes here

% Erstellt von:            Franz Zeilinger - 22.03.2013
% Letzte Änderung durch:   Franz Zeilinger - 12.04.2013

if isempty(handles.NAT_Data.Grid)
    return;   
end

Data_Extract = handles.Current_Settings.Data_Extract;
cg = handles.sin.Settings.Grid_name;
% Daten in Tabelle einstellen:
data = {handles.NAT_Data.Grid.(cg).P_Q_Node.Points.P_Q_Name}';
data(:,2) = deal({false});
data(:,3) = deal(handles.System.housholds(1,1));
data(:,4) = deal(handles.System.sola.Selectable(1,1));
data(:,5) = deal(handles.System.wind.Selectable(1,1));

add_data = cell(size(data,1),2);

ColumnName = {'Names', 'Selection', 'Haush. Typ', 'Solaranl.', 'Windkr.anl.'};
ColumnFormat = {'char', 'logical', ...
	handles.System.housholds(:,1)', ...
    handles.System.sola.Selectable(:,1)',...
    handles.System.wind.Selectable(:,1)'};
ColumnEditable = [false, true, true, true, true];
RowName = [];

Table_Network.Data = data;
Table_Network.Additional_Data = add_data;
Table_Network.ColumnName = ColumnName;
Table_Network.ColumnEditable = ColumnEditable;
Table_Network.ColumnFormat = ColumnFormat;
Table_Network.RowName = RowName;

% etwaige Erzeugungsstrukturen löschen:
Data_Extract.Solar.Selectable = handles.System.sola.Selectable;
Data_Extract.Solar.Plants = [];
Data_Extract.Wind.Selectable = handles.System.wind.Selectable;
Data_Extract.Wind.Plants = [];

end

