function [break_condition,break_text] = check_file_simulation_parameters(SelectedPaths,SelectedFiles)
% csfc ... Current_Settings_Files_Check
csfc.scenarios = cell(1);
csfc.variants = cell(1);
csfc.datasets = [];
csfc.Input_values_used = [];
csfc.Timepoints = [];
csfc.CalcParameters = [];
               
for i = 1 : numel(SelectedFiles)
    Current_Settings = [];
    load([SelectedPaths{i,1}, SelectedFiles{i,1}]);
    csfc.scenarios{i,1} = Current_Settings.Simulation.Scenarios.Names;
    csfc.variants{i,1} = Current_Settings.Simulation.Grid_List;
    csfc.datasets(i,1) = Current_Settings.Simulation.Number_Runs;
    csfc.Timepoints(i,1) = Current_Settings.Simulation.Timepoints;
    
    csfc.Input_values_used(i,1) = ...
        find([Current_Settings.Simulation.use_Sample_Value,Current_Settings.Simulation.use_Mean_Value,...
        Current_Settings.Simulation.use_Min_Value, Current_Settings.Simulation.use_Max_Value,...
        Current_Settings.Simulation.use_95_Quantile_Value,Current_Settings.Simulation.use_05_Quantile_Value]);
    
    csfc.CalcParameters(i,:) = ... 
        [Current_Settings.Simulation.Voltage_Violation_Analysis, Current_Settings.Simulation.Save_Voltage_Results, ...
         Current_Settings.Simulation.Branch_Violation_Analysis, Current_Settings.Simulation.Save_Branch_Results,...
         Current_Settings.Simulation.Power_Loss_Analysis, Current_Settings.Simulation.Save_Power_Loss_Results];
end
clear Current_Settings i

break_condition = 0;
break_text = [];
for i = 2 : numel(SelectedFiles)
    if size(csfc.variants{1,1},2) ~= size(csfc.variants{i,1},2)
        break_condition = 1;
        break_text = 'grid variants';
    else
        % Variants
        for j = 1 : size(csfc.variants{1,1},2)
            if ~strcmp( csfc.variants{1,1}{j}, csfc.variants{i,1}{j})
                break_condition = 1;
                if isempty(break_text)
                    break_text = 'grid variants';
                end
            end
        end
    end
    
    % Datasets
    if csfc.datasets(i,1) ~= csfc.datasets(1,1)
        break_condition = 2;
        if isempty(break_text)
            break_text = 'datasets';
        else
            break_text = [break_text, '/datasets';];
        end
    end
    
    % Input values used
    if csfc.Input_values_used(i,1) ~= csfc.Input_values_used(1,1)
        break_condition = 3;
        if isempty(break_text)
            break_text = 'input values used';
        else
            break_text = [break_text, '/input values used';];
        end
    end
    
    % Timepoints
    if csfc.Timepoints(i,1) ~= csfc.Timepoints(1,1)
        break_condition = 4;
        if isempty(break_text)
            break_text = 'timepoints';
        else
            break_text = [break_text, '/timepoints';];
        end
    end
    
    % Calc. parameters
    if abs(sum(csfc.CalcParameters(i,:) - csfc.CalcParameters(1,:))) > 0
        break_condition = 5;
        if isempty(break_text)
            break_text = 'calculation parameters';
        else
            break_text = [break_text, '/calculation parameters';];
        end
    end
    
end

end
