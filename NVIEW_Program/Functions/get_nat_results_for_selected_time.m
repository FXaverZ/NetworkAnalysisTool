function Selected_Time_Results = get_nat_results_for_selected_time(handles,Selected_Timestamps)

for I = 1 : numel(handles.NVIEW_Control.Result_Files)
    % clear data structure and filename variable
    clear data; file.Name = []; file.Path = [];
    % Define filename from handles structure at i-th iteration
    file.Name = handles.NVIEW_Control.Result_Files{I};
    file.Path = handles.NVIEW_Control.Result_Files_Paths{I};
    file.Exte = '.mat';
    % If the results are partitioned
    if ~ischar(file.Name)
        % Merge partial files for individual scenario
        data = group_partitioned_results(handles, file);
    else        
        % Load data structure from stored mat file
        data = load([file.Path,filesep,file.Name,file.Exte]);
    end
    % --------------------------------------------------------------------
    % CREATE GRID STRUCTURE. DEFINE BUS/BRANCH ARRAYS FOR GRID VARIANTS
    % --------------------------------------------------------------------        
    if I == 1
        grid_data = create_grid_structure(handles,data);
    end
    % --------------------------------------------------------------------
    % READ RESULTS AND REFORMAT TO GRID STRUCTURE
    % --------------------------------------------------------------------     
    Scenario_Structure.(['Scenario_', int2str(I)]) = [];
    Scenario_Structure.(['Scenario_', int2str(I)]) = create_result_structure_for_selected_time(handles,data,grid_data,Selected_Timestamps);
end

% --------------------------------------------------------------------
% READ GRID STRUCTURE FORMAT AND RESHAPE INTO NVIEW FORMAT
% --------------------------------------------------------------------
Grid_List = handles.NVIEW_Control.Simulation_Description.Variants;

Selected_Time_Results = [];
for I = 1 : numel(Grid_List)
    Selected_Time_Results.(Grid_List{I}).bus = grid_data.(Grid_List{I}).bus;
    Selected_Time_Results.(Grid_List{I}).bus_name = grid_data.(Grid_List{I}).bus_name;
    Selected_Time_Results.(Grid_List{I}).branch = grid_data.(Grid_List{I}).branch;
    Selected_Time_Results.(Grid_List{I}).branch_name = grid_data.(Grid_List{I}).branch_name;
    
    Selected_Time_Results.(Grid_List{I}).bus_violations = [];
    Selected_Time_Results.(Grid_List{I}).bus_statistics = [];
    Selected_Time_Results.(Grid_List{I}).bus_violated_at_datasets = [];    
    Selected_Time_Results.(Grid_List{I}).bus_violations_at_datasets = [];
    Selected_Time_Results.(Grid_List{I}).bus_deviations = nan(handles.NVIEW_Control.Simulation_Options.Number_of_Scenarios,3,3);  
    
    Selected_Time_Results.(Grid_List{I}).branch_violations = [];
    Selected_Time_Results.(Grid_List{I}).branch_statistics = [];
    Selected_Time_Results.(Grid_List{I}).loss_statistics = [];

    
     for J = 1 : numel(handles.NVIEW_Control.Result_Files)      
         % Number of scenarios
         if handles.NVIEW_Control.Simulation_Options.Voltage_Analysis == 1
             Selected_Time_Results.(Grid_List{I}).bus_violations(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_violations(:,1);
             
             Selected_Time_Results.(Grid_List{I}).bus_statistics(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_summary.stat;
             
             Selected_Time_Results.(Grid_List{I}).bus_violations_at_datasets(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_summary.dataset_voltage_violation_numbers;

             Selected_Time_Results.(Grid_List{I}).bus_violated_at_datasets(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_summary.dataset_violated_nodes_numbers;

             Selected_Time_Results.(Grid_List{I}).bus_deviations(J,1,:) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_deviations(1,:);

             Selected_Time_Results.(Grid_List{I}).bus_deviations(J,2,:) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_deviations(2,:);
             
             Selected_Time_Results.(Grid_List{I}).bus_deviations(J,3,:) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_deviations(3,:);
             % 2d array, first dim. are the max, mean, min values, second
             % dim. are the phases - MERGED FOR ALL SCENARIOS
         end
         
         if handles.NVIEW_Control.Simulation_Options.Overcurrent_Analysis == 1
             Selected_Time_Results.(Grid_List{I}).branch_violations(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).branch_violations(:,1);
             
             Selected_Time_Results.(Grid_List{I}).branch_statistics(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).branch_statistics;
         end
         
         if handles.NVIEW_Control.Simulation_Options.Loss_Analysis == 1
             Selected_Time_Results.(Grid_List{I}).loss_statistics(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).loss_statistics;
         end   
     end     
end

% --------------------------------------------------------------------
% Get NVIEW load/infeed input data
% --------------------------------------------------------------------
for J = 1 : numel(handles.NVIEW_Control.Result_Files) 
    Selected_Time_Results.Input_Data.Households(:,J) = Scenario_Structure.(['Scenario_', int2str(J)]).Input_Data.Households;
    Selected_Time_Results.Input_Data.Solar(:,J) = Scenario_Structure.(['Scenario_', int2str(J)]).Input_Data.Solar;
    Selected_Time_Results.Input_Data.El_mobility(:,J) = Scenario_Structure.(['Scenario_', int2str(J)]).Input_Data.El_mobility;
end

end
