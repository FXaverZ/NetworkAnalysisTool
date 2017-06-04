function Table = get_violated_branch_numbers_overall(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

Observed_Row = 3; % Actual number of nodes affected by violationss
Table.Values = [];
for i = 1 : numel(cg)
    Table.Values(:,i) = d.(cg{i}).branch_statistics(Observed_Row,:);
end
Table.Values = 100*sum(Table.Values,1)/(cs*cd*size(d.(cg{i}).bus,1));
Table.Name = '% of branches with overcurrents';
Table.ColumnName = d.Control.Simulation_Description.Variants;
for i = 1 : numel(Table.ColumnName)
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
Table.RowName = '';
Table.Description = 'Overall number of branches affected by overcurrents';

end