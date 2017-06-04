function Table = get_data_input_scenarios(handles)

% Transfer handles substructures to internal structures
d = handles.NVIEW_Results.Input_Data;
s = handles.NVIEW_Control;
%----------------------------------------------------------------------------
% Limit the observations to selected lists in <s> and <d>!
Selected_Variants = find(handles.NVIEW_Control.Display_Options.Variants);
Selected_Scenarios = find(handles.NVIEW_Control.Display_Options.Scenarios);

% Limit scenarios to the selected list in <d>. Remove non-relevant columns in d
Data_List = fields(d);
for H = 1 : numel(Data_List)
    d.(Data_List{H}) = d.(Data_List{H})(:,Selected_Scenarios);
end
% Limit scenarios to the selected list in <s>
s.Simulation_Description.Scenario = s.Simulation_Description.Scenario(Selected_Scenarios,:);
s.Simulation_Options.Number_of_Scenarios = size(Selected_Scenarios,1);
%----------------------------------------------------------------------------


cs = s.Simulation_Options.Number_of_Scenarios;
cd = s.Simulation_Options.Number_of_datasets;
cg = s.Simulation_Description.Variants;

% Reformat data structure
d.Balance = (d.Households - d.Solar + d.El_mobility);

Data_List = fields(d);
for H = 1 : numel(Data_List)
    % Households / Solar / E-mobility
    Table.(Data_List{H}).Values = d.(Data_List{H})/1000;
    switch Data_List{H}
        case 'Households'
            Table.(Data_List{H}).Description = 'Household active power consumption histogram';
            Table.(Data_List{H}).RowName =  'Household active power consumption (kW)';
        case 'Solar'
            Table.(Data_List{H}).Description = 'Solar power plants active power injection histogram';
            Table.(Data_List{H}).RowName =  'Solar power plants active power injection (kW)';
        case 'El_mobility'
            Table.(Data_List{H}).Description = 'E-mobility active power consumption histogram';
            Table.(Data_List{H}).RowName =  'E-mobility active power consumption (kW)';
        case 'Balance'
            Table.(Data_List{H}).Description = 'System balance active power histogram';
            Table.(Data_List{H}).RowName =  'System balance active power (kW)';
    end
    Table.(Data_List{H}).ColumnName = s.Simulation_Description.Scenario(:,1);
    for i = 1 : numel(Table.(Data_List{H}).ColumnName)
        if size(Table.(Data_List{H}).ColumnName{i},2) > 12
            Table.(Data_List{H}).ColumnName{i} = [Table.(Data_List{H}).ColumnName{i}(1:12),'...'];
        end
    end
    for i = 1 : numel(Table.(Data_List{H}).ColumnName)
        Table.(Data_List{H}).ColumnName{i} = strrep(Table.(Data_List{H}).ColumnName{i}, '_', ' ');
        if size(Table.(Data_List{H}).ColumnName{i},2) > 12
            Table.(Data_List{H}).ColumnName{i} = [Table.(Data_List{H}).ColumnName{i}(1:12),'...'];
        end
    end

end