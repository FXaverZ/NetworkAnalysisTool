function [handles,NVIEW_Results,NVIEW_Control] = convert_nat_results_to_nview(handles)

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
        [handles,grid_data] = create_grid_structure(handles,data);
    end
    % --------------------------------------------------------------------
    % READ RESULTS AND REFORMAT TO GRID STRUCTURE
    % --------------------------------------------------------------------     
    Scenario_Structure.(['Scenario_', int2str(I)]) = [];
    Scenario_Structure.(['Scenario_', int2str(I)]) = create_result_structure(handles,data,grid_data);
end

% --------------------------------------------------------------------
% READ GRID STRUCTURE FORMAT AND RESHAPE INTO NVIEW FORMAT
% --------------------------------------------------------------------
Grid_List = handles.NVIEW_Control.Simulation_Description.Variants;
No_Scenarios = handles.NVIEW_Control.Simulation_Options.Number_of_Scenarios;

NVIEW_Results = [];
for I = 1 : numel(Grid_List)
    NVIEW_Results.(Grid_List{I}).bus = grid_data.(Grid_List{I}).bus;
    NVIEW_Results.(Grid_List{I}).bus_name = grid_data.(Grid_List{I}).bus_name;
    NVIEW_Results.(Grid_List{I}).branch = grid_data.(Grid_List{I}).branch;
    NVIEW_Results.(Grid_List{I}).branch_name = grid_data.(Grid_List{I}).branch_name;
    
     for J = 1 : numel(handles.NVIEW_Control.Result_Files)      
         % Number of scenarios
         if handles.NVIEW_Control.Simulation_Options.Voltage_Analysis == 1
             NVIEW_Results.(Grid_List{I}).bus_voltages(J,:,:,:,:) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_voltages;
         end
         
         if handles.NVIEW_Control.Simulation_Options.Overcurrent_Analysis == 1
             NVIEW_Results.(Grid_List{I}).branch_values(J,:,:,:,:) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).branch_values;
         end
         
         if handles.NVIEW_Control.Simulation_Options.Loss_Analysis == 1
             NVIEW_Results.(Grid_List{I}).loss_statistics(J,:,:,:) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).electric_losses;
         end   
     end
     
end

% --------------------------------------------------------------------
% Get NVIEW load/infeed input data
% --------------------------------------------------------------------
for J = 1 : numel(handles.NVIEW_Control.Result_Files) 
    NVIEW_Results.Input_Data.Households(:,J) = Scenario_Structure.(['Scenario_', int2str(J)]).Input_Data.Households;
    NVIEW_Results.Input_Data.Solar(:,J) = Scenario_Structure.(['Scenario_', int2str(J)]).Input_Data.Solar;
    NVIEW_Results.Input_Data.El_mobility(:,J) = Scenario_Structure.(['Scenario_', int2str(J)]).Input_Data.El_mobility;
end
% --------------------------------------------------------------------
% Get NVIEW Settings 
% --------------------------------------------------------------------
NVIEW_Control.Result_Information_File = handles.NVIEW_Control.Result_Information_File;
NVIEW_Control.Simulation_Options = handles.NVIEW_Control.Simulation_Options;
NVIEW_Control.Result_Files = handles.NVIEW_Control.Result_Files;
NVIEW_Control.Result_Files_Paths = handles.NVIEW_Control.Result_Files_Paths;
NVIEW_Control.Simulation_Description = handles.NVIEW_Control.Simulation_Description;

end
