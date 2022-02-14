function Table = create_electric_losses_sum_time_table_per_grid(d,Data_List)

for i = 1 : numel(Data_List)
    sorted_values.(Data_List{i}) = ...
        zeros(d.Control.Simulation_Options.Timepoints_per_dataset,...
              d.Control.Simulation_Options.Number_of_Scenarios);
    
    for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios        
        for t = 1 : d.Control.Simulation_Options.Timepoints_per_dataset
            sorted_values.(Data_List{i})(t,s) = ...
                nansum(squeeze(d.(Data_List{i}).electric_losses(s,:,t)) );
        end
    end

    
    Table.(Data_List{i}).Values = sorted_values.(Data_List{i})/1000;
    Table.(Data_List{i}).Description =  ['Electric losses sum for all datasets at ',(Data_List{i}), ' timeline'];
    Table.(Data_List{i}).RowName =  'Electric losses at dataset (kWh/h)';
    Table.(Data_List{i}).XLim= size(Table.(Data_List{i}).Values,1);
    Table.(Data_List{i}).XLabel ='Timepoint';
    Table.(Data_List{i}).XTick = round(Table.(Data_List{i}).XLim / 10);
    
    if Table.(Data_List{i}).XLim / Table.(Data_List{i}).XTick < 10
       Table.(Data_List{i}).XTick = 1;
    end
    
end


Table.ColumnName = d.Control.Simulation_Description.Scenario(:,1);
for i = 1 : numel(Table.ColumnName)
    Table.ColumnName{i} = strrep(Table.ColumnName{i}, '_', ' ');
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
