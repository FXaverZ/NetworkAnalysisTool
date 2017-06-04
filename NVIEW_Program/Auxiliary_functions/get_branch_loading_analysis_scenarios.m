function Table = get_branch_loading_analysis_scenarios(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

for i = 1 : numel(cg)
    for s = 1 : cs
        Table.Values(s,i) = nanmean(nanmean(squeeze(d.(cg{i}).branch_loading_analysis(s,:,:))));
    end
end
    
Table.Name = 'Average branch loading conditions in % of current limit';
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
Table.Description = 'Average branch loading conditions seperated by scenarios';

end