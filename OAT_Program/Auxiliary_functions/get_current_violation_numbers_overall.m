function Table = get_current_violation_numbers_overall(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

Observed_Row = 1; % Actual number of current violations
Table.Values = [];
for i = 1 : numel(cg)
    Table.Values(:,i) = d.(cg{i}).branch_statistics(Observed_Row,:);
end
Table.Values = 100*sum(Table.Values,1)/(cs*ct*cd);
%Changelog 1.5 FZ Start
Table.Name = 'Current violations in % of time';
%Changelog 1.5 FZ Start
Table.ColumnName = d.Control.Simulation_Description.Variants;
for i = 1 : numel(Table.ColumnName)
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
Table.RowName = '';
Table.Description = 'Overall percentage of branches affected by overcurrents';

end