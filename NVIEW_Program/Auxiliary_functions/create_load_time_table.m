function Table = create_load_time_table(d,Data_List)

Table = []; sorted_values = [];
for i = 1 : numel(Data_List)    
    d.Input_Data.(Data_List{i}) = d.Input_Data.(Data_List{i})/1000; % to kW
    
    switch Data_List{i}
        case 'Households'
            Table.(Data_List{i}).Description = 'Household active power consumption timeline';
            Table.(Data_List{i}).RowName =  'Household active power consumption (kW)';
        case 'Solar'
            Table.(Data_List{i}).Description = 'Solar power plants active power injection timeline';
            Table.(Data_List{i}).RowName =  'Solar power plants active power injection (kW)';
        case 'El_mobility'
            Table.(Data_List{i}).Description = 'E-mobility active power consumption timeline';
            Table.(Data_List{i}).RowName =  'E-mobility active power consumption (kW)';
        case 'Balance'
            Table.(Data_List{i}).Description = 'System balance active power timeline';
            Table.(Data_List{i}).RowName =  'System balance active power (kW)';
    end    
    
    for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios
        sorted_values.(Data_List{i})(:,s) = d.Input_Data.(Data_List{i})(:,s);
    end
    Table.(Data_List{i}).Values = sorted_values.(Data_List{i});
    

    Table.(Data_List{i}).XLim= size(sorted_values.(Data_List{i}),1);
    Table.(Data_List{i}).XLabel ='Timepoint';
    Table.(Data_List{i}).XTick = d.Control.Simulation_Options.Timepoints_per_dataset;
    
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
