function Table = get_electric_losses_overall(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

Table.Values = [];
for i = 1 : numel(cg)
    Table.Values(:,i) = nansum(nansum(d.(cg{i}).electric_losses_at_dataset,1))/1000;
end


Table.Name = 'Electric losses in kWh/h';
Table.ColumnName = d.Control.Simulation_Description.Variants;
for i = 1 : numel(Table.ColumnName)
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
Table.RowName = '';
Table.Description = 'Overall electric grid losses';

end