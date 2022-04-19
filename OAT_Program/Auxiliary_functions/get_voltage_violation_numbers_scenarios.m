function Table = get_voltage_violation_numbers_scenarios(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

Observed_Row = 2; % Actual number of voltage violations
Table.Values = [];
for i = 1 : numel(cg)
    Table.Values(:,i) = d.(cg{i}).bus_statistics(Observed_Row,:);
end
Table.Name = 'Voltage violations in % of time';
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
Table.Description = 'Voltage violations seperated by scenarios';

end