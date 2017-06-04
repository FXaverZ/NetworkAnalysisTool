function Table = get_violated_branch_list(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

for g = 1 : size(cg,1)
    clear current_violations branches_affected
    current_violations = d.(cg{g}).current_violations;
    branches_affected = [];
    for s = 1 : cs
        branches_affected{s,1} = [];
        for ds = 1 : cd
            for t = 1 : ct
                branches_affected{s,1} = [branches_affected{s,1};find(squeeze(current_violations(s,ds,t,:))==1)];
                
            end
        end
        branches_affected{s,1} = unique(branches_affected{s,1});
        Table.Values{s,g} = d.(cg{g}).branch_name(branches_affected{s,1} );
    end
end

Table.Name = 'List of branches affected by overcurrents';
Table.ColumnName = d.Control.Simulation_Description.Variants;
for i = 1 : numel(Table.ColumnName)
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
Table.RowName = d.Control.Simulation_Description.Scenario(:,1);
for i = 1 : numel(Table.RowName)
    Table.RowName{i} = strrep(Table.RowName{i}, '_', ' ');    
    if size(Table.RowName{i},2) > 12
        Table.RowName{i} = [Table.RowName{i}(1:12),'...'];
    end
end
Table.Description = 'List of branches affected by overcurrents (overall)';

% Excel output
max_rows = 0;
cg = size(Table.Values,2);
cs = size(Table.Values,1);
for s = 1 : cs
    for g = 1 : cg
        max_rows = max([max_rows,size(Table.Values{s,g},1)]);
    end
end

Excel_Table = cell(max_rows,cs*cg);
Excel_Header = cell(2,cs*cg);
for g = 1 : cg
    for s = 1 : cs
        if s == 1
            Excel_Header{1,(g-1)*cs + s} = d.Control.Simulation_Description.Variants{g};
        end
        Excel_Header{2,(g-1)*cs + s} = d.Control.Simulation_Description.Scenario{s,1};
        
        Excel_Table(1:size(Table.Values{s,g},1),(g-1)*cs + s ) = Table.Values{s,g};
    end
end

Table.Values_Excel = [Excel_Header; Excel_Table];