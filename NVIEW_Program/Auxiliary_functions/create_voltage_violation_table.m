function Table = create_voltage_violation_table(handles,d)

% Table output functions
voltage_violation_numbers_overall = get_voltage_violation_numbers_overall(d); 
voltage_violation_numbers_scenarios = get_voltage_violation_numbers_scenarios(d);
violated_node_numbers_overall = get_violated_node_numbers_overall(d);
violated_node_numbers_scenarios = get_violated_node_numbers_scenarios(d);
node_voltage_deviations = get_node_voltage_deviations(d); 

% Values ID
Table = []; RoundEps = 1e-2;
Table.Values = [ nan(1,size(voltage_violation_numbers_overall.Values,2));
                 voltage_violation_numbers_overall.Values;
                 voltage_violation_numbers_scenarios.Values;
                 nan(1,size(voltage_violation_numbers_scenarios.Values,2));
                 nan(1,size(voltage_violation_numbers_scenarios.Values,2));
                 violated_node_numbers_overall.Values;
                 violated_node_numbers_scenarios.Values];

 Table.Values = Table.Values - mod(Table.Values ,RoundEps);

% Add deviations
for i = 1 : numel(node_voltage_deviations.ColumnName)
    for j = 1 : 3
        max_volt(j,i) = node_voltage_deviations.Values{i}(1,j);
        mean_volt(j,i) = node_voltage_deviations.Values{i}(2,j);
        min_volt(j,i) = node_voltage_deviations.Values{i}(3,j);
    end
end

Table.Values = [Table.Values; 
                nan(1,size(voltage_violation_numbers_scenarios.Values,2));
                nan(1,size(voltage_violation_numbers_scenarios.Values,2));
                max_volt;
                nan(1,size(voltage_violation_numbers_scenarios.Values,2));
                nan(1,size(voltage_violation_numbers_scenarios.Values,2));
                mean_volt;
                nan(1,size(voltage_violation_numbers_scenarios.Values,2));
                nan(1,size(voltage_violation_numbers_scenarios.Values,2));
                min_volt
               ];

% Grid ID
Table.ColumnName = [{''};voltage_violation_numbers_overall.ColumnName];
% Scenario ID
Table.RowName = [{upper(voltage_violation_numbers_overall.Name)};
                 {'All scenarios observed'}
                 voltage_violation_numbers_scenarios.RowName;
                 {''};
                 {upper(violated_node_numbers_overall.Name)};
                 {'All scenarios observed'}
                 violated_node_numbers_scenarios.RowName ];

 end_of_rounding = size(Table.RowName,1);
% Add deviations
Table.RowName = [Table.RowName;
                 {''};
                 {'MAXIMUM VOLTAGE VALUES IN PER UNIT (ALL SCENARIOS)'};
                 {'L1'};
                 {'L2'};
                 {'L3'};
                 {''};
                 {'MEAN VOLTAGE VALUES IN PER UNIT (ALL SCENARIOS)'};
                 {'L1'};
                 {'L2'};
                 {'L3'};
                 {''};
                 {'MINIMUM VOLTAGE VALUES IN PER UNIT (ALL SCENARIOS)'};
                 {'L1'};
                 {'L2'};
                 {'L3'};];

% Convert numerical values to strings             
for rowIdx = 1 : size(Table.Values,1)
    for colIdx = 1 : size(Table.Values,2)
        if ~isnan(Table.Values(rowIdx,colIdx))
            if rowIdx <= end_of_rounding
                Table.Values_Str{rowIdx,colIdx} =  num2str(Table.Values(rowIdx,colIdx),'%.2f');
            else
                Table.Values_Str{rowIdx,colIdx} =  num2str(Table.Values(rowIdx,colIdx),'%.3f');
            end
        else
            Table.Values_Str{rowIdx,colIdx} = '';
        end
    end
end
Table.Values_Str = [Table.RowName, Table.Values_Str];
Table.Excel_table = Table.Values_Str; % Excel output

% Select "identifier" and "overall" row and define html bold to the text
rowIdx_loop = [1,2,2+size([ voltage_violation_numbers_overall.Values;
                        voltage_violation_numbers_scenarios.Values;
                        nan(1,size(voltage_violation_numbers_scenarios.Values,2))],1) + [0,1]];
                    
rowIdx_loop = [rowIdx_loop,max(rowIdx_loop) + size([ violated_node_numbers_overall.Values;
                        violated_node_numbers_scenarios.Values;],1) + [0,5,10] + 1];

for rowIdx = 1 : numel(rowIdx_loop)
    rowIdx = rowIdx_loop(rowIdx);
    for colIdx = 1 : size(Table.Values_Str,2)
        Table.Values_Str{rowIdx,colIdx} = ['<html><b>', Table.Values_Str{rowIdx,colIdx}, '</b></html>'];
    end
end

Table.Description =['Voltage analysis_',d.Control.ID];

end
