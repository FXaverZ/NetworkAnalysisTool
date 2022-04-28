function handles = edit_pqnode_hh_number(handles,row_act,input_string)
%EDIT_PQNODE_HH_NUMBER Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.1
% Erstellt von:            Franz Zeilinger - 16.12.2014
% Letzte Änderung durch:   Franz Zeilinger - 17.12.2014

% get number of households out of input string
Number_HHs = ...
	str2double(input_string);

% check, if a valid number was given:
if isnan(Number_HHs) || Number_HHs < 1
	errordlg('Invalid data format! Please give a natural number of households ...',...
		'Editing number households ...');
else
	Table_Network = handles.Current_Settings.Table_Network;
	
	Number_HHs = round(Number_HHs);
	idx_hh_num = strcmp(Table_Network.ColumnName,'Hh. Number');
	Table_Network.Data{row_act,idx_hh_num} = Number_HHs;
	
	% adapt the HH-typ:
	idx_hh = strcmp(Table_Network.ColumnName, 'Housh.type');
	if Number_HHs == 1
		Table_Network.Data{row_act,idx_hh} = handles.System.housholds{1,1};
	elseif Number_HHs > 1
		% if more households are present, set typ to 'multiple households' and adapt the
		% additional data:
		Table_Network.Data{row_act,idx_hh} = handles.System.housholds{end,1};
		Table_Network.Additional_Data{row_act,idx_hh} = cell(1,Number_HHs);
		% fill the household-Entrys with the first typ in the list:
		[Table_Network.Additional_Data{row_act,idx_hh}{:}] = deal(handles.System.housholds{1,1});
	end
	handles.Current_Settings.Table_Network = Table_Network;
end
end

