function Table = get_node_voltage_deviations(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

for i = 1 : numel(cg)
    Table_inp_max = zeros(size(d.(cg{i}).bus_deviations,1),size(d.(cg{i}).bus_deviations,3));
    Table_inp_mean = zeros(size(d.(cg{i}).bus_deviations,1),size(d.(cg{i}).bus_deviations,3));
    Table_inp_min = zeros(size(d.(cg{i}).bus_deviations,1),size(d.(cg{i}).bus_deviations,3));
    for j = 1 : cs
        Table_inp_max(j,:) = d.(cg{i}).bus_deviations(j,1,:);
        Table_inp_mean(j,:) = d.(cg{i}).bus_deviations(j,2,:);
        Table_inp_min(j,:) = d.(cg{i}).bus_deviations(j,3,:);
    end
    
    Table.Values{i} = [nanmax(Table_inp_max,[],1); nanmean(Table_inp_mean,1); nanmin(Table_inp_min,[],1)];
end

Table.Description = 'Voltage deviations at grid nodes';
Table.ColumnName = d.Control.Simulation_Description.Variants;
for i = 1 : numel(Table.ColumnName)
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
Table.RowName = [{'L1 voltage deviations'};{'L2 voltage deviations'};{'L3 voltage deviations'};{'Mean value voltage deviations'}];

end