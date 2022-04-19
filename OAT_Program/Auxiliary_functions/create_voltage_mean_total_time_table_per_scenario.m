function Table = create_voltage_mean_total_time_table_per_scenario (d,Data_List)
%CREATE_VOLTAGE_MEAN_TOTAL_TIME_TABLE_PER_SCEN Summary of this function goes here
%   Detailed explanation goes here

scenario_description = d.Control.Simulation_Description.Scenario(:,1);
for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios
    
    sorted_values.(['Scen_',int2str(s)]) = ...
        zeros(d.Control.Simulation_Options.Timepoints_per_dataset,...
              d.Control.Simulation_Options.Number_of_Variants);
          
    for i = 1 : numel(Data_List)  
         for t = 1 : d.Control.Simulation_Options.Timepoints_per_dataset
            sorted_values.(['Scen_',int2str(s)])(t,i) = ...
                nanmean(nanmean(squeeze(squeeze(nanmean(squeeze(d.(Data_List{i}).bus_voltages(s,:,t,:,:)))))));
         end
    end
        
    Table.(['Scen_',int2str(s)]).Values = sorted_values.(['Scen_',int2str(s)]);
    Table.(['Scen_',int2str(s)]).Description =  ['Total Voltage mean values for scenario ',scenario_description{s}];
    Table.(['Scen_',int2str(s)]).RowName =  'Mean voltage level at all nodes [-]';
    Table.(['Scen_',int2str(s)]).XLim= size(Table.(['Scen_',int2str(s)]).Values,1);
    Table.(['Scen_',int2str(s)]).XLabel ='Timepoint';
    Table.(['Scen_',int2str(s)]).XTick = d.Control.Simulation_Options.Timepoints_per_dataset;
    Table.(['Scen_',int2str(s)]).XTick = round(Table.(['Scen_',int2str(s)]).XLim / 10);
    if Table.(['Scen_',int2str(s)]).XLim / Table.(['Scen_',int2str(s)]).XTick < 10
        Table.(['Scen_',int2str(s)]).XTick = 1;
    end
    Table.Fields{s,1} = ['Scen_',int2str(s)];
end


Table.ColumnName = d.Control.Simulation_Description.Variants(:,1);
for i = 1 : numel(Table.ColumnName)
    Table.ColumnName{i} = strrep(Table.ColumnName{i}, '_', ' ');
%     if size(Table.ColumnName{i},2) > 12
%         Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
%     end
end

end

