function Table = create_current_violation_time_table_per_scenario(d,Data_List)

current_violations_timeline = [];

scenario_description = d.Control.Simulation_Description.Scenario(:,1);
for s = 1 : d.Control.Simulation_Options.Number_of_Scenarios
    
    current_violations_timeline =...
        zeros(d.Control.Simulation_Options.Timepoints_per_dataset * d.Control.Simulation_Options.Number_of_datasets,...
        d.Control.Simulation_Options.Number_of_Variants);
    for i = 1 : numel(Data_List)
        
        for ds = 1 : d.Control.Simulation_Options.Number_of_datasets
            id_ = ((ds-1) * d.Control.Simulation_Options.Timepoints_per_dataset) + (1 : d.Control.Simulation_Options.Timepoints_per_dataset);
            current_violations_timeline(id_,i) = 100*nansum(squeeze(d.(Data_List{i}).current_violations(s,ds,:,:)),2)./size(d.(Data_List{i}).branch,1);
        end
    end
    Table.(['Scen_',int2str(s)]).Values = current_violations_timeline;
    Table.(['Scen_',int2str(s)]).Description =  ['Current violations timeline at grids for ',scenario_description{s}];
    Table.(['Scen_',int2str(s)]).RowName =  'Number of overcurrent violations at grid (%)';
    
    Table.(['Scen_',int2str(s)]).XLim= size(Table.(['Scen_',int2str(s)]).Values,1);
    Table.(['Scen_',int2str(s)]).XLabel ='Timepoint';
    Table.(['Scen_',int2str(s)]).XTick = d.Control.Simulation_Options.Timepoints_per_dataset;
    
    if Table.(['Scen_',int2str(s)]).XLim / Table.(['Scen_',int2str(s)]).XTick > 12
        Table.(['Scen_',int2str(s)]).XTick = round(Table.(['Scen_',int2str(s)]).XLim / 12) ;
    elseif Table.(['Scen_',int2str(s)]).XLim / Table.(['Scen_',int2str(s)]).XTick < 6
        Table.(['Scen_',int2str(s)]).XTick = round(Table.(['Scen_',int2str(s)]).XLim / 12) ;
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
