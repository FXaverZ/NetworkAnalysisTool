function Table = create_current_violation_time_table_per_grid(d,Data_List)

current_violations_timeline = [];

for i = 1 : numel(Data_List)
    current_violations_timeline =...
        zeros(d.Control.Simulation_Options.Timepoints_per_dataset * d.Control.Simulation_Options.Number_of_datasets,...
        d.Control.Simulation_Options.Number_of_Scenarios);
    
    for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios
        for ds = 1 : d.Control.Simulation_Options.Number_of_datasets
            id_ = ((ds-1) * d.Control.Simulation_Options.Timepoints_per_dataset) + (1 : d.Control.Simulation_Options.Timepoints_per_dataset);
            current_violations_timeline(id_,s) = nansum(squeeze(d.(Data_List{i}).current_violations(s,ds,:,:)),2);
        end
    end
    Table.(Data_List{i}).Values = 100*current_violations_timeline./size(d.(Data_List{i}).branch,1);
    Table.(Data_List{i}).Description =  ['Current violations at ',(Data_List{i}), ' timeline'];
    Table.(Data_List{i}).RowName =  'Number of overcurrent violations at grid (%)';
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
