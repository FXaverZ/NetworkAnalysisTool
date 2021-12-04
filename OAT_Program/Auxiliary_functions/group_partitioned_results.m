function data = group_partitioned_results(handles, file)

J = 1;
% Load data structure from stored mat file
clear data
data = load([file.Path{1,J},filesep,file.Name{1,J},'.mat']);
Grid_List = fields(data.Result);
Result_List = fields(data.Result.(Grid_List{1}));

for J = 2 : numel(file.Name)
    % data.Grid is ok
    % data.Debug no grouping
    
    % data.Load_Infeed_Data, merge sets!
    Load_Infeed_Data_Fields = [];
    Current_Sets = [];
    Load_Infeed_Data_Fields = fields(data.Load_Infeed_Data);
    Current_Sets = str2double( strrep(Load_Infeed_Data_Fields,'Set_',''));
    Current_Sets = max(Current_Sets);
    
    clear ext_data
    ext_data = load([file.Path{1,J},filesep,file.Name{1,J},'.mat']);
    
    Ext_Load_Infeed_Data_Fields = [];
    Ext_Load_Infeed_Data_Fields = fields(ext_data.Load_Infeed_Data);
    
    for k = 1 : numel(Ext_Load_Infeed_Data_Fields)
        data.Load_Infeed_Data.(['Set_',int2str(k+Current_Sets)]) =  ext_data.Load_Infeed_Data.(Ext_Load_Infeed_Data_Fields{k});
    end
    clear Current_Sets Ext_Load_Infeed_Data_Fields k  Load_Infeed_Data_Fields
    
    % Merge data.Results
    for k = 1 : numel(Grid_List)
        clear idds* edds*
        idds = size(data.Result.(Grid_List{k}).Voltage_Violation_Analysis,1);
        edds = size(ext_data.Result.(Grid_List{k}).Voltage_Violation_Analysis,1);
        
        % Full results
        data.Result.(Grid_List{k}).Voltage_Violation_Analysis(idds+1:idds+edds,:,:) = ext_data.Result.(Grid_List{k}).Voltage_Violation_Analysis;
        data.Result.(Grid_List{k}).Branch_Violation_Analysis(idds+1:idds+edds,:,:) = ext_data.Result.(Grid_List{k}).Branch_Violation_Analysis;
        data.Result.(Grid_List{k}).Power_Loss_Analysis(idds+1:idds+edds,:,:) = ext_data.Result.(Grid_List{k}).Power_Loss_Analysis;
        data.Result.(Grid_List{k}).Power_Loss_Values(idds+1:idds+edds,:,:) = ext_data.Result.(Grid_List{k}).Power_Loss_Values;
        data.Result.(Grid_List{k}).Error_Counter(idds+1:idds+edds,:) = ext_data.Result.(Grid_List{k}).Error_Counter;
        data.Result.(Grid_List{k}).Node_Voltages(idds+1:idds+edds,:,:,:) = ext_data.Result.(Grid_List{k}).Node_Voltages;
        data.Result.(Grid_List{k}).Branch_Values(idds+1:idds+edds,:,:,:) = ext_data.Result.(Grid_List{k}).Branch_Values;
        
        % Voltage Violation Summary
        data.Result.(Grid_List{k}).Voltage_Violation_Summary.Number_of_Violations(idds+1:idds+edds,:) = ...
            ext_data.Result.(Grid_List{k}).Voltage_Violation_Summary.Number_of_Violations;
        
        data.Result.(Grid_List{k}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations(idds+1:idds+edds,:) = ...
            ext_data.Result.(Grid_List{k}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations;
        
        data.Result.(Grid_List{k}).Voltage_Violation_Summary.Names_of_Nodes_With_Violations(idds+1:idds+edds,:) = ...
            ext_data.Result.(Grid_List{k}).Voltage_Violation_Summary.Names_of_Nodes_With_Violations;
        
        % Branch_Violation_Summary
        data.Result.(Grid_List{k}).Branch_Violation_Summary.Number_of_Violations(idds+1:idds+edds,:) = ...
            ext_data.Result.(Grid_List{k}).Branch_Violation_Summary.Number_of_Violations;
        
        data.Result.(Grid_List{k}).Branch_Violation_Summary.Number_of_Branches_With_Violations(idds+1:idds+edds,:) = ...
            ext_data.Result.(Grid_List{k}).Branch_Violation_Summary.Number_of_Branches_With_Violations;
        
        data.Result.(Grid_List{k}).Branch_Violation_Summary.Names_of_Branches_With_Violations(idds+1:idds+edds,:) = ...
            ext_data.Result.(Grid_List{k}).Branch_Violation_Summary.Names_of_Branches_With_Violations;
        
        % Power_Loss_Summary
        data.Result.(Grid_List{k}).Power_Loss_Summary.Std_Power_Loss_Values(idds+1:idds+edds,:) = ...
            ext_data.Result.(Grid_List{k}).Power_Loss_Summary.Std_Power_Loss_Values;
        data.Result.(Grid_List{k}).Power_Loss_Summary.Max_Power_Loss_Values(idds+1:idds+edds,:) = ...
            ext_data.Result.(Grid_List{k}).Power_Loss_Summary.Max_Power_Loss_Values;
        data.Result.(Grid_List{k}).Power_Loss_Summary.Min_Power_Loss_Values(idds+1:idds+edds,:) = ...
            ext_data.Result.(Grid_List{k}).Power_Loss_Summary.Min_Power_Loss_Values;
        
    end
    clear ext_data
end

for k = 1 : numel(Grid_List)
    % Voltage Violation Summary
    data.Result.(Grid_List{k}).Voltage_Violation_Summary.Number_of_Violations_percent = ...
        100*data.Result.(Grid_List{k}).Voltage_Violation_Summary.Number_of_Violations / handles.NVIEW_Control.Simulation_Options.Timepoints_per_dataset;
    data.Result.(Grid_List{k}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations_percent = ...
        100*data.Result.(Grid_List{k}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations/numel(data.Result.(Grid_List{k}).Voltage_Violation_Summary.All_Node_Names);
    
    % Branch_Violation_Summary
    data.Result.(Grid_List{k}).Branch_Violation_Summary.Number_of_Violations_percent = ...
        100*data.Result.(Grid_List{k}).Branch_Violation_Summary.Number_of_Violations / handles.NVIEW_Control.Simulation_Options.Timepoints_per_dataset;
    data.Result.(Grid_List{k}).Branch_Violation_Summary.Number_of_Branches_With_Violations_percent = ...
        100*data.Result.(Grid_List{k}).Branch_Violation_Summary.Number_of_Branches_With_Violations/numel(data.Result.(Grid_List{k}).Branch_Violation_Summary.Branch_Names);
end


end