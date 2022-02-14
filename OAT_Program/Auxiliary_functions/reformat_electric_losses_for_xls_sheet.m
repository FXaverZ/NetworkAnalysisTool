function Table = reformat_electric_losses_for_xls_sheet(d,Grid_List)


Table.Values = [];
Table.Excel_Header = [];
for g = 1 : numel(Grid_List)
    grid_table = ...
        zeros(d.Control.Simulation_Options.Number_of_datasets*d.Control.Simulation_Options.Timepoints_per_dataset, d.Control.Simulation_Options.Number_of_Scenarios);
      
    for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios
        for ds = 1 : d.Control.Simulation_Options.Number_of_datasets
            id_ = (ds-1) * d.Control.Simulation_Options.Timepoints_per_dataset + (1:d.Control.Simulation_Options.Timepoints_per_dataset);
            grid_table(id_,s) =  squeeze(d.(Grid_List{g}).electric_losses(s,ds,:))/1000;
        end
    end
    % Values
    Table.Values = [Table.Values,grid_table];
    Table.Excel_Header = [Table.Excel_Header,[[Grid_List{g},cell(1,size(d.Control.Simulation_Description.Scenario,1)-1)]; [ d.Control.Simulation_Description.Scenario(:,1)' ] ] ];
end
Table.Excel_Header = [cell(2,size(Table.Excel_Header,2));Table.Excel_Header];

Table.Main_Header = 'ELECTRIC LOSSES IN kWh/h PER TIMEPOINT/DATASET';
Table.Description = 'Electric losses (table)';

Table.Values_Cell = num2cell(Table.Values);

