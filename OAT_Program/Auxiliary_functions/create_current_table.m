function Table = create_current_table(handles,d)

% Table output functions
current_violations_numbers_overall = get_current_violation_numbers_overall(d);
current_violation_numbers_scenarios = get_current_violation_numbers_scenarios(d);
violated_branch_numbers_overall = get_violated_branch_numbers_overall(d);
violated_branch_numbers_scenarios = get_violated_branch_numbers_scenarios(d);
branch_loading_analysis_overall = get_branch_loading_analysis_overall(d);
branch_loading_analysis_scenarios = get_branch_loading_analysis_scenarios(d);

% Values ID
Table = []; RoundEps = 1e-2;
Table.Values = [ nan(1,size(current_violations_numbers_overall.Values,2));
                 current_violations_numbers_overall.Values;
                 current_violation_numbers_scenarios.Values;
                 nan(1,size(current_violation_numbers_scenarios.Values,2));
                 nan(1,size(current_violation_numbers_scenarios.Values,2));
                 violated_branch_numbers_overall.Values;
                 violated_branch_numbers_scenarios.Values
                 nan(1,size(current_violation_numbers_scenarios.Values,2));
                 nan(1,size(current_violation_numbers_scenarios.Values,2));
                 branch_loading_analysis_overall.Values;
                 branch_loading_analysis_scenarios.Values];

 Table.Values = Table.Values - mod(Table.Values ,RoundEps);

% Grid ID
Table.ColumnName = [{''};current_violations_numbers_overall.ColumnName];
% Scenario ID
Table.RowName = [{upper(current_violations_numbers_overall.Name)};
                 {'All scenarios observed'}
                 current_violation_numbers_scenarios.RowName;
                 {''};
                 {upper(violated_branch_numbers_overall.Name)};
                 {'All scenarios observed'};
                 violated_branch_numbers_scenarios.RowName;
                 {''};
                 {upper(branch_loading_analysis_overall.Name)};
                 {'All scenarios observed'};
                 branch_loading_analysis_scenarios.RowName;
                 ];

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
tid_ = 2+size([ current_violations_numbers_overall.Values;
                        current_violation_numbers_scenarios.Values;
                        nan(1,size(current_violation_numbers_scenarios.Values,2))],1) + [0,1];
                    
rowIdx_loop = [1,2,tid_,(max(tid_) + 1 + size([violated_branch_numbers_overall.Values; violated_branch_numbers_scenarios.Values],1) + [0,1]) ];
                    
for rowIdx = 1 : numel(rowIdx_loop)
    rowIdx = rowIdx_loop(rowIdx);
    for colIdx = 1 : size(Table.Values_Str,2)
        Table.Values_Str{rowIdx,colIdx} = ['<html><b>', Table.Values_Str{rowIdx,colIdx}, '</b></html>'];
    end
end

Table.Description =['Current analysis_',d.Control.ID];

end
