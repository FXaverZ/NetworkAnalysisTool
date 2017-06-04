function Table = get_violated_node_numbers_scenarios(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

Observed_Row = 4; % Actual number of nodes affected by violationss
Table.Values = [];
for i = 1 : numel(cg)
    Table.Values(:,i) = d.(cg{i}).bus_statistics(Observed_Row,:);
end
Table.Name = 'Percentage of nodes where voltage violations occured';
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
Table.Description = 'Number of grid nodes affected by voltage violations seperated by scenarios';

end