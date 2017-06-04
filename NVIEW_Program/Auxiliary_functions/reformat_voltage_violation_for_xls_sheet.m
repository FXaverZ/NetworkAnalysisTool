function Table = reformat_voltage_violation_for_xls_sheet(d,Grid_List)


Table.Values = [];
Table.Excel_Header = [];
for g = 1 : numel(Grid_List)
    grid_table = ...
        zeros(d.Control.Simulation_Options.Number_of_datasets*d.Control.Simulation_Options.Timepoints_per_dataset, d.Control.Simulation_Options.Number_of_Scenarios);
      
    for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios
        for ds = 1 : d.Control.Simulation_Options.Number_of_datasets
            id_ = (ds-1) * d.Control.Simulation_Options.Timepoints_per_dataset + (1:d.Control.Simulation_Options.Timepoints_per_dataset);
            grid_table(id_,s) =  100*nansum(squeeze(d.(Grid_List{g}).voltage_violations(s,ds,:,:)),2)/size(d.(Grid_List{g}).bus,1);
        end
    end
    % Values
    Table.Values = [Table.Values,grid_table];
    Table.Excel_Header = [Table.Excel_Header,[[Grid_List{g},cell(1,size(d.Control.Simulation_Description.Scenario,1)-1)]; [ d.Control.Simulation_Description.Scenario(:,1)' ] ] ];
end
Table.Excel_Header = [cell(2,size(Table.Excel_Header,2));Table.Excel_Header];

Table.Main_Header = 'VOLTAGE VIOLATIONS IN % PER TIMEPOINT/DATASET';
Table.Description = 'Voltage violations (table)';

Table.Values_Cell = num2cell(Table.Values);

