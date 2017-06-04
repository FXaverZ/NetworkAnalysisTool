function Table = create_electric_losses_time_table_per_grid(d,Data_List)

electric_losses_timeline = [];

for i = 1 : numel(Data_List)
    electric_losses_timeline =...
        zeros(d.Control.Simulation_Options.Timepoints_per_dataset * d.Control.Simulation_Options.Number_of_datasets,...
        d.Control.Simulation_Options.Number_of_Scenarios);
    
    for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios
        for ds = 1 : d.Control.Simulation_Options.Number_of_datasets
            id_ = ((ds-1) * d.Control.Simulation_Options.Timepoints_per_dataset) + (1 : d.Control.Simulation_Options.Timepoints_per_dataset);
            electric_losses_timeline(id_,s) = squeeze(d.(Data_List{i}).electric_losses(s,ds,:));
        end
    end
    Table.(Data_List{i}).Values = electric_losses_timeline/1000;
    Table.(Data_List{i}).Description =  ['Electric losses at ',(Data_List{i}), ' timeline'];
    Table.(Data_List{i}).RowName =  'Electric losses (kWh/h)';
    Table.(Data_List{i}).XLim= size(Table.(Data_List{i}).Values,1);
    Table.(Data_List{i}).XLabel ='Timepoint';
    Table.(Data_List{i}).XTick = d.Control.Simulation_Options.Timepoints_per_dataset
    
    if Table.(Data_List{i}).XLim / Table.(Data_List{i}).XTick > 12
        Table.(Data_List{i}).XTick = round(Table.(Data_List{i}).XLim / 12) ;
    elseif Table.(Data_List{i}).XLim / Table.(Data_List{i}).XTick < 6
        Table.(Data_List{i}).XTick = round(Table.(Data_List{i}).XLim / 12) ;
    end
end


Table.ColumnName = d.Control.Simulation_Description.Scenario(:,1);
for i = 1 : numel(Table.ColumnName)
    Table.ColumnName{i} = strrep(Table.ColumnName{i}, '_', ' ');
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
