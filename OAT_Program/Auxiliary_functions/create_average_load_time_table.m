function Table = create_average_load_time_table(d,Data_List)

Table = []; sorted_values = [];
for i = 1 : numel(Data_List)    
    d.Input_Data.(Data_List{i}) = d.Input_Data.(Data_List{i})/1000; % to kW
    
    switch Data_List{i}
        case 'Households'
            Table.(Data_List{i}).Description = 'Household average active power consumption timeline';
            Table.(Data_List{i}).RowName =  'Average household active power consumption (kW)';
		% CHANGELOG 1.2, FZ Start
		case 'LV_Grid_Input'
			Table.(Data_List{i}).Description = 'Low voltage grid average active power consumption timeline';
            Table.(Data_List{i}).RowName =  'Low voltage grid power consumption (kW)';
		% CHANGELOG 1.2, FZ End
        case 'Solar'
            Table.(Data_List{i}).Description = 'Solar power plants average active power injection timeline';
            Table.(Data_List{i}).RowName =  'Average solar power plants active power injection (kW)';
        case 'El_mobility'
            Table.(Data_List{i}).Description = 'E-mobility average active power consumption timeline';
            Table.(Data_List{i}).RowName =  'Average E-mobility active power consumption (kW)';
        case 'Balance'
            Table.(Data_List{i}).Description = 'System balance average active power timeline';
            Table.(Data_List{i}).RowName =  'Average system balance active power (kW)';
    end    
    
    for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios
        data_observed_timepoint = [];
        data_observed_timepoint = squeeze( reshape(d.Input_Data.(Data_List{i})(:,s),[],d.Control.Simulation_Options.Number_of_datasets) );
        for t = 1 : size(data_observed_timepoint,1)
            sorted_values.(Data_List{i})(t,s) = nanmean(data_observed_timepoint(t,:));
            %sorted_values.(Data_List{i})(s,t,:)=[nanmin(data_observed_timepoint(t,:)),nanmean(data_observed_timepoint(t,:)),nanmax(data_observed_timepoint(t,:)),nanstd(data_observed_timepoint(t,:))];
        end
    end
    
    Table.(Data_List{i}).Values = sorted_values.(Data_List{i});
 
    Table.(Data_List{i}).XLim = d.Control.Simulation_Options.Timepoints_per_dataset;
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
