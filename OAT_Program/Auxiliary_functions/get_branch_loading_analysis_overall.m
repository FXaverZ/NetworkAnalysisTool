function Table = get_branch_loading_analysis_overall(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

for i = 1 : numel(cg)
        Table.Values(1,i) = nanmean(nanmean(nanmean(squeeze(d.(cg{i}).branch_loading_analysis))));
end
    
Table.Name = 'Average branch loading conditions in % of current limit';
Table.ColumnName = d.Control.Simulation_Description.Variants;
for i = 1 : numel(Table.ColumnName)
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
Table.RowName = '';
Table.Description = 'Average branch loading conditions';

end