function Table = create_voltage_max_total_time_table_per_grid (d,Data_List)
%CREATE_VOLTAGE_MEAN_TIME_TABLE_PER_GRID(D,DATA_LIST) Summary of this function goes here
%   Detailed explanation goes here

for i = 1 : numel(Data_List)
    voltage_timeline =...
        zeros(d.Control.Simulation_Options.Timepoints_per_dataset,...
        d.Control.Simulation_Options.Number_of_Scenarios);
    
    for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios
        for t = 1 : d.Control.Simulation_Options.Timepoints_per_dataset
			voltage_timeline(t,s) = ...
				nanmax(squeeze(nanmax(squeeze(nanmax(squeeze(d.(Data_List{i}).bus_voltages(s,:,t,:,:)))))));
        end
    end
    Table.(Data_List{i}).Values = voltage_timeline;
    Table.(Data_List{i}).Description =  ['Total Voltage maximum values for grid ',(Data_List{i}), ' timeline'];
    Table.(Data_List{i}).RowName =  'Maximum voltage level at all nodes [-]';
    Table.(Data_List{i}).XLim= size(Table.(Data_List{i}).Values,1);
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

end

