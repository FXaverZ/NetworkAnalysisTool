function Table = get_voltage_violation_numbers_overall(handles,d,s)

%----------------------------------------------------------------------------
% Limit the observations to selected lists in <s> and <d>!
Selected_Variants = find(handles.NVIEW_Analysis_Selection.Variants);
Selected_Scenarios = find(handles.NVIEW_Analysis_Selection.Scenarios);

% Get list of grid variants and select the ones from the list
SelectedVariantList = s.Simulation_Description.Variants;
SelectedVariantList = SelectedVariantList(Selected_Variants);

% Limit scenarios to the selected list in <d>. Remove non-relevant columns in d
Data_List = fields(d);
d_ = [];
for H = 1 : numel(Data_List)
    if ~isempty(find(strcmp(SelectedVariantList,Data_List{H})))
        d_.(Data_List{H}) = d.(Data_List{H});
    end
end
clear d; d = d_; clear d_ Data_List H

% Limit scenarios for each grid
Data_List = fields(d);
for H = 1 : numel(Data_List)
    d.(Data_List{H}).bus_violations = d.(Data_List{H}).bus_violations(:,Selected_Scenarios);
    d.(Data_List{H}).bus_statistics = d.(Data_List{H}).bus_statistics(:,Selected_Scenarios);
    d.(Data_List{H}).bus_violated_at_datasets = d.(Data_List{H}).bus_violated_at_datasets(:,Selected_Scenarios);
    d.(Data_List{H}).bus_deviations = d.(Data_List{H}).bus_deviations(Selected_Scenarios,:,:);
    d.(Data_List{H}).bus_violations_at_datasets = d.(Data_List{H}).bus_violations_at_datasets(:,Selected_Scenarios);
    d.(Data_List{H}).branch_violations = d.(Data_List{H}).branch_violations(:,Selected_Scenarios);
    d.(Data_List{H}).branch_statistics = d.(Data_List{H}).branch_statistics(:,Selected_Scenarios);
%     d.(Data_List{H}).loss_statistics = d.(Data_List{H}).loss_statistics(:,Selected_Scenarios);
end


% Limit scenarios to the selected list in <s>
s.Simulation_Description.Scenario = s.Simulation_Description.Scenario(Selected_Scenarios,:);
s.Simulation_Description.Variants = s.Simulation_Description.Variants(Selected_Variants,:);
s.Simulation_Options.Number_of_Scenarios = size(Selected_Scenarios,1);
s.Simulation_Options.Number_of_Variants = size(Selected_Variants,1);

%----------------------------------------------------------------------------

cs = s.Simulation_Options.Number_of_Scenarios;
cd = s.Simulation_Options.Number_of_datasets;
ct = s.Simulation_Options.Timepoints_per_dataset;
cg = s.Simulation_Description.Variants;


Observed_Row = 1; % Actual number of voltage violations
Table.Values = [];
for i = 1 : numel(cg)
    Table.Values(:,i) = d.(cg{i}).bus_statistics(Observed_Row,:);
end
Table.Values = 100*sum(Table.Values,1)/(cs*ct*cd);
Table.Name = 'Voltage violations in % of time';
Table.ColumnName = s.Simulation_Description.Variants;
for i = 1 : numel(Table.ColumnName)
    if size(Table.ColumnName{i},2) > 12
        Table.ColumnName{i} = [Table.ColumnName{i}(1:12),'...'];
    end
end
Table.RowName = '';
Table.Description = 'Overall percentage of grid nodes affected by voltage violations';

end