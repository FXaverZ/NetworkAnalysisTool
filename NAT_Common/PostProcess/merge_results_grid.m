function [Result, Debug] = merge_results_grid (Result,...
    Debug, Raw_Results, cur_grd, number_datasets)
%MERGE_RESULTS_GRID Summary of this function goes here
%   Detailed explanation goes here

tmp_result         = Result.(cur_grd);
tmp_add_result     = Raw_Results.Result.(cur_grd);

number_datasets_current   = size(tmp_result.Branch_Values,1);
number_datasets_available = size(tmp_add_result.Branch_Values,1);
number_datasets_after_add = number_datasets_current + number_datasets_available;
if number_datasets < number_datasets_after_add
    number_datasets_add = number_datasets - number_datasets_current;
    if number_datasets_add < 1
        return;
    end
else
    number_datasets_add = number_datasets_available;
end

na = number_datasets_add;
nc = number_datasets_current;

tmp_result.Branch_Values(nc+1:nc+na,:,:,:) = tmp_add_result.Branch_Values;
tmp_result.Branch_Values_to(nc+1:nc+na,:,:,:) = tmp_add_result.Branch_Values_to;
tmp_result.Branch_Violation_Analysis(nc+1:nc+na,:,:) = tmp_add_result.Branch_Violation_Analysis;
tmp_result.Branch_Violation_Summary.Names_of_Branches_With_Violations(nc+1:nc+na,:) = ...
    tmp_add_result.Branch_Violation_Summary.Names_of_Branches_With_Violations;
tmp_result.Branch_Violation_Summary.Number_of_Branches_With_Violations(nc+1:nc+na,:) = ...
    tmp_add_result.Branch_Violation_Summary.Number_of_Branches_With_Violations;
tmp_result.Branch_Violation_Summary.Number_of_Branches_With_Violations_percent(nc+1:nc+na,:) = ...
    tmp_add_result.Branch_Violation_Summary.Number_of_Branches_With_Violations_percent;
tmp_result.Branch_Violation_Summary.Number_of_Violations(nc+1:nc+na,:) = ...
    tmp_add_result.Branch_Violation_Summary.Number_of_Violations;
tmp_result.Branch_Violation_Summary.Number_of_Violations_percent(nc+1:nc+na,:) = ...
    tmp_add_result.Branch_Violation_Summary.Number_of_Violations_percent;
tmp_result.Error_Counter(nc+1:nc+na,:) = tmp_add_result.Error_Counter;
tmp_result.Node_Voltages(nc+1:nc+na,:,:,:) = tmp_add_result.Node_Voltages;
tmp_result.Power_Loss_Analysis(nc+1:nc+na,:,:) = tmp_add_result.Power_Loss_Analysis;
tmp_result.Power_Loss_Summary.Max_Power_Loss_Values(nc+1:nc+na,:) = ...
    tmp_add_result.Power_Loss_Summary.Max_Power_Loss_Values;
tmp_result.Power_Loss_Summary.Min_Power_Loss_Values(nc+1:nc+na,:) = ...
    tmp_add_result.Power_Loss_Summary.Min_Power_Loss_Values;
tmp_result.Power_Loss_Summary.Std_Power_Loss_Values(nc+1:nc+na,:) = ...
    tmp_add_result.Power_Loss_Summary.Std_Power_Loss_Values;
tmp_result.Power_Loss_Values(nc+1:nc+na,:,:) = tmp_add_result.Power_Loss_Values;
tmp_result.Voltage_Violation_Analysis(nc+1:nc+na,:,:) = tmp_add_result.Voltage_Violation_Analysis;
tmp_result.Voltage_Violation_Summary.Number_of_Violations(nc+1:nc+na,:) = ...
    tmp_add_result.Voltage_Violation_Summary.Number_of_Violations;
tmp_result.Voltage_Violation_Summary.Number_of_Violations_percent(nc+1:nc+na,:) = ...
    tmp_add_result.Voltage_Violation_Summary.Number_of_Violations_percent;
tmp_result.Voltage_Violation_Summary.Names_of_Nodes_With_Violations(nc+1:nc+na,:) = ...
    tmp_add_result.Voltage_Violation_Summary.Names_of_Nodes_With_Violations;
tmp_result.Voltage_Violation_Summary.Number_of_Nodes_With_Violations(nc+1:nc+na,:) = ...
    tmp_add_result.Voltage_Violation_Summary.Number_of_Nodes_With_Violations;
tmp_result.Voltage_Violation_Summary.Number_of_Nodes_With_Violations_percent(nc+1:nc+na,:) = ...
    tmp_add_result.Voltage_Violation_Summary.Number_of_Nodes_With_Violations_percent;

Result.(cur_grd) = tmp_result;

end

