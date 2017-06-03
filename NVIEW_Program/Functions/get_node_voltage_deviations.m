function Table = get_node_voltage_deviations(handles,d,s)

cs = s.Simulation_Options.Number_of_Scenarios;
cd = s.Simulation_Options.Number_of_datasets;
ct = s.Simulation_Options.Timepoints_per_dataset;
cg = s.Simulation_Description.Variants;

for i = 1 : numel(cg)
    Table.Values{i} = d.(cg{i}).bus_deviations;
end
Table.Description = 'Voltage deviations at grid nodes';
Table.ColumnName = s.Simulation_Description.Variants;
for i = 1 : numel(Table.ColumnName)
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
Table.RowName = [{'L1 voltage deviations'};{'L2 voltage deviations'};{'L3 voltage deviations'};{'Mean value voltage deviations'}];

end