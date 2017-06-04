function Table = create_loss_table(handles,d)

% Table output functions
electric_losses_overall = get_electric_losses_overall(d);
electric_losses_scenario = get_electric_losses_scenarios(d);

% Values ID
Table = []; RoundEps = 1e-2;
Table.Values = [ nan(1,size(electric_losses_overall.Values,2));
                 electric_losses_overall.Values;
                 electric_losses_scenario.Values;
                 ];

 Table.Values = Table.Values - mod(Table.Values ,RoundEps);

% Grid ID
Table.ColumnName = [{''};electric_losses_overall.ColumnName];
% Scenario ID
Table.RowName = [{upper(electric_losses_overall.Name)};
                 {'All scenarios observed'}
                 electric_losses_scenario.RowName;];
Table.RowName{1,1} = strrep(Table.RowName{1,1},'KWH/H','kWh/h');

 end_of_rounding = size(Table.RowName,1);

% Convert numerical values to strings             
for rowIdx = 1 : size(Table.Values,1)
    for colIdx = 1 : size(Table.Values,2)
        if ~isnan(Table.Values(rowIdx,colIdx))
            if rowIdx <= end_of_rounding
                Table.Values_Str{rowIdx,colIdx} =  num2str(Table.Values(rowIdx,colIdx),'%.2f');
            else
                Table.Values_Str{rowIdx,colIdx} =  num2str(Table.Values(rowIdx,colIdx),'%.3f');
            end
        else
            Table.Values_Str{rowIdx,colIdx} = '';
        end
    end
end
Table.Values_Str = [Table.RowName, Table.Values_Str];
Table.Excel_table = Table.Values_Str; % Excel output

%Changelog 1.5 FZ Start
% convert strings containing numbers to number format (for correct
% representation in excel):
for i=1:size(Table.Excel_table,1)
	for j=2:numel(Table.Excel_table(i,:))
		num = sscanf(Table.Excel_table{i,j},'%f');
		if ~isempty(num)
			Table.Excel_table{i,j} = num;
		end
	end
end
clear i j num
%Changelog 1.5 FZ Start

% Select "identifier" and "overall" row and define html bold to the text
rowIdx_loop = [1,2];

for rowIdx = 1 : numel(rowIdx_loop)
    rowIdx = rowIdx_loop(rowIdx);
    for colIdx = 1 : size(Table.Values_Str,2)
        Table.Values_Str{rowIdx,colIdx} = ['<html><b>', Table.Values_Str{rowIdx,colIdx}, '</b></html>'];
    end
end

Table.Description =['Loss analysis_',d.Control.ID];

end
