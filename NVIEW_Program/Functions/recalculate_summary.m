function data = recalculate_summary(handles,data,timeperiod,obj_type)

% Grid values
gv_ = fields(data.Result);
if strcmp(obj_type,'voltage')
    for i = 1 : numel(gv_)
        for cd = 1 : handles.NVIEW_Control.Simulation_Options.Number_of_datasets
            % Iterate through all datasets
            
            % The squeezed values for dataset cd and topology (cg) are saved in
            % voltage_violation_results
            voltage_violation_results = [];
            voltage_violations_at_timepoints = [];
            voltage_violations_at_nodes_ids = [];
            node_names = [];
            
            % Voltage violations
            voltage_violation_results = squeeze( data.Result.(gv_{i}).Voltage_Violation_Analysis(cd,timeperiod,:) );
            voltage_violations_at_timepoints = sum(voltage_violation_results == 1 & ~isnan(voltage_violation_results),2) > 0;
            % Violations at nodes
            voltage_violations_at_nodes_ids = sum(voltage_violation_results == 1 & ~isnan(voltage_violation_results),1) > 0;
            % Node name
            node_names = data.Result.(gv_{i}).Voltage_Violation_Summary.All_Node_Names;
            
            % Write to data structure!
            data.Result.(gv_{i}).Voltage_Violation_Summary.Number_of_Violations(cd,1) = NaN;
            data.Result.(gv_{i}).Voltage_Violation_Summary.Number_of_Violations(cd,1) = sum(voltage_violations_at_timepoints);
            data.Result.(gv_{i}).Voltage_Violation_Summary.Number_of_Violations_percent(cd,1) = NaN;
            data.Result.(gv_{i}).Voltage_Violation_Summary.Number_of_Violations_percent(cd,1) = 100*sum(voltage_violations_at_timepoints) / numel(timeperiod);
            data.Result.(gv_{i}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations(cd,1) = NaN;
            data.Result.(gv_{i}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations(cd,1) = sum(voltage_violations_at_nodes_ids);
            data.Result.(gv_{i}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations_percent(cd,1) = NaN;
            data.Result.(gv_{i}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations_percent(cd,1) = 100*sum(voltage_violations_at_nodes_ids) /...
                numel(data.Result.(gv_{i}).Voltage_Violation_Summary.All_Node_Names);
            data.Result.(gv_{i}).Voltage_Violation_Summary.Names_of_Nodes_With_Violations{cd,1} = [];
            data.Result.(gv_{i}).Voltage_Violation_Summary.Names_of_Nodes_With_Violations{cd,1} = node_names(voltage_violations_at_nodes_ids);
            
        end
        data.Result.(gv_{i}).Voltage_Violation_Analysis = data.Result.(gv_{i}).Voltage_Violation_Analysis(:,timeperiod,:);
        data.Result.(gv_{i}).Node_Voltages = data.Result.(gv_{i}).Node_Voltages(:,timeperiod,:,:);
        data.Result.(gv_{i}).Error_Counter = data.Result.(gv_{i}).Error_Counter(:,timeperiod);
    end
    
elseif strcmp(obj_type,'branch')
    for i = 1 : numel(gv_)
        for cd = 1 : handles.NVIEW_Control.Simulation_Options.Number_of_datasets
            % Iterate through all datasets
            
            % The squeezed values for dataset cd and topology (cg) are saved in
            % branch_violation_results
            branch_violation_results = [];
            branch_violations_at_timepoints = [];
            branch_violations_at_branch_ids = [];
            branch_names = [];
            
            % Voltage violations
            branch_violation_results = squeeze( data.Result.(gv_{i}).Branch_Violation_Analysis(cd,timeperiod,:) );
            branch_violations_at_timepoints = sum(branch_violation_results == 1 & ~isnan(branch_violation_results),2) > 0;
            % Violations at nodes
            branch_violations_at_branch_ids = sum(branch_violation_results == 1 & ~isnan(branch_violation_results),1) > 0;
            % Node name
            branch_names = data.Result.(gv_{i}).Branch_Violation_Summary.Branch_Names;
            
            % Write to data structure!
            data.Result.(gv_{i}).Branch_Violation_Summary.Number_of_Violations(cd,1) = NaN;
            data.Result.(gv_{i}).Branch_Violation_Summary.Number_of_Violations(cd,1) = sum(branch_violations_at_timepoints);
            data.Result.(gv_{i}).Branch_Violation_Summary.Number_of_Violations_percent(cd,1) = NaN;
            data.Result.(gv_{i}).Branch_Violation_Summary.Number_of_Violations_percent(cd,1) = 100*sum(branch_violations_at_timepoints) / numel(timeperiod);
            data.Result.(gv_{i}).Branch_Violation_Summary.Number_of_Branches_With_Violations(cd,1) = NaN;
            data.Result.(gv_{i}).Branch_Violation_Summary.Number_of_Branches_With_Violations(cd,1) = sum(branch_violations_at_branch_ids);
            data.Result.(gv_{i}).Branch_Violation_Summary.Number_of_Branches_With_Violations_percent(cd,1) = NaN;
            data.Result.(gv_{i}).Branch_Violation_Summary.Number_of_Branches_With_Violations_percent(cd,1) = 100*sum(branch_violations_at_branch_ids) /...
                numel(data.Result.(gv_{i}).Branch_Violation_Summary.Branch_Names);
            data.Result.(gv_{i}).Branch_Violation_Summary.Names_of_Branches_With_Violations{cd,1} = [];
            data.Result.(gv_{i}).Branch_Violation_Summary.Names_of_Branches_With_Violations{cd,1} = branch_names(branch_violations_at_branch_ids);
        end
        data.Result.(gv_{i}).Branch_Violation_Analysis = data.Result.(gv_{i}).Branch_Violation_Analysis(:,timeperiod,:);
        data.Result.(gv_{i}).Branch_Values = data.Result.(gv_{i}).Branch_Values(:,timeperiod,:,:);
        
    end
    
elseif strcmp(obj_type,'losses')
    for i = 1 : numel(gv_)
        for cd = 1 : handles.NVIEW_Control.Simulation_Options.Number_of_datasets
            
            Result.(gv_{i}).Power_Loss_Summary.Max_Power_Loss_Values(cd,:) = ...
                max(squeeze(data.Result.(gv_{i}).Power_Loss_Analysis(cd,timeperiod,:)));
            Result.(gv_{i}).Power_Loss_Summary.Min_Power_Loss_Values(cd,:) = ...
                min(squeeze(data.Result.(gv_{i}).Power_Loss_Analysis(cd,timeperiod,:)));
            Result.(gv_{i}).Power_Loss_Summary.Std_Power_Loss_Values(cd,:) = ...
                std(squeeze(data.Result.(gv_{i}).Power_Loss_Analysis(cd,timeperiod,:)));
        end
        
        Result.(gv_{i}).Power_Loss_Analysis = data.Result.(gv_{i}).Power_Loss_Analysis(:,timeperiod,:);
        Result.(gv_{i}).Power_Loss_Values = data.Result.(gv_{i}).Power_Loss_Values(:,timeperiod,:);
    end
    
    
elseif strcmp(obj_type,'load/infeed')
    dt = handles.NVIEW_Control.Simulation_Options.Input_values_used;
    
    for cd = 1 : handles.NVIEW_Control.Simulation_Options.Number_of_datasets
        fields_ = [];
        fields_ = fields(data.Load_Infeed_Data.(['Set_', int2str(cd)]));
        fields_ = setdiff(fields_,'Table_Network');
        
        for ch = 1 : numel(fields_)
            if ~isempty(data.Load_Infeed_Data.(['Set_', int2str(cd)]).(fields_{ch}).(dt))
                data.Load_Infeed_Data.(['Set_', int2str(cd)]).(fields_{ch}).(dt) = data.Load_Infeed_Data.(['Set_', int2str(cd)]).(fields_{ch}).(dt)(timeperiod,:);
            end
        end
    end
end

end