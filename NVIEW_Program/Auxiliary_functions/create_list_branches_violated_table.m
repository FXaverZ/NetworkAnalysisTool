function Table = create_list_branches_violated_table(handles,d,violated_branch_list)

% Table output functions
violated_branch_list_overall = violated_branch_list;
violated_branch_list_overall.Values = [];
RowSize = 0;
for g = 1 : size(violated_branch_list.Values,2)
    violated_branch_list_overall.Values{1,g} = [];
    for s = 1 : size(violated_branch_list.Values,1)
        violated_branch_list_overall.Values{1,g} = [violated_branch_list_overall.Values{1,g};violated_branch_list.Values{s,g}];
    end
     violated_branch_list_overall.Values{1,g} = unique( violated_branch_list_overall.Values{1,g});
     RowSize = max([RowSize,size(violated_branch_list_overall.Values{1,g},1)]);
end
violated_branch_list_overall.RowName = 'Overall list';
clear g s

% Values ID
Table = [];
Table.Values = cell(1+RowSize,1+size(violated_branch_list_overall.Values,2));

for g = 1 : size(violated_branch_list_overall.Values,2)
    Table.Values(2:1+size(violated_branch_list_overall.Values{1,g},1),g+1) = violated_branch_list_overall.Values{1,g};
end


% Grid ID
Table.ColumnName = [{''};violated_branch_list_overall.ColumnName];

% HEADER ID
Table.RowName = cell(1,size(Table.Values,2));
Table.RowName{1,1} = upper(violated_branch_list_overall.Description);

Table.Values_Str = [Table.RowName; Table.Values];

% Select "identifier" and "overall" row and define html bold to the text
rowIdx_loop = 1;
                 
for rowIdx = 1 : numel(rowIdx_loop)
    rowIdx = rowIdx_loop(rowIdx);
    for colIdx = 1 : size(Table.Values_Str,2)
        Table.Values_Str{rowIdx,colIdx} = ['<html><b>', Table.Values_Str{rowIdx,colIdx}, '</b></html>'];
    end
end

Table.Description =['List_branches_affected_',d.Control.ID];

end
