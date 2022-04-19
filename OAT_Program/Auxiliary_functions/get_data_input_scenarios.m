function Table = get_data_input_scenarios(d)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

% Reformat data structure
d.Input_Data.Balance = (d.Input_Data.Households - d.Input_Data.Solar + d.Input_Data.El_mobility);

Data_List = fields(d.Input_Data);
for H = 1 : numel(Data_List)
    % Households / Solar / E-mobility
    Table.(Data_List{H}).Values = d.Input_Data.(Data_List{H})/1000;
    switch Data_List{H}
        case 'Households'
            Table.(Data_List{H}).Description = 'Active power histogram household consumption';
            Table.(Data_List{H}).RowName =  'Household active power consumption (kW)';
		% CHANGELOG 1.2, FZ Start
		case 'LV_Grid_Input'
			Table.(Data_List{H}).Description = 'Active power histogram low voltage grid consumption';
            Table.(Data_List{H}).RowName =  'Low voltage grid power consumption (kW)';
		% CHANGELOG 1.2, FZ End
        case 'Solar'
            Table.(Data_List{H}).Description = 'Active power histogram solar power injection';
            Table.(Data_List{H}).RowName =  'Solar power active power injection (kW)';
        case 'El_mobility'
            Table.(Data_List{H}).Description = 'Active power histogram E-mobility consumption';
            Table.(Data_List{H}).RowName =  'E-mobility active power consumption (kW)';
        case 'Balance'
            Table.(Data_List{H}).Description = 'Active power histogram System balance';
            Table.(Data_List{H}).RowName =  'System balance active power (kW)';
    end
    Table.(Data_List{H}).ColumnName = d.Control.Simulation_Description.Scenario(:,1);
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