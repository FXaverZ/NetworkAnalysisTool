function [handles,NVIEW_Results,NVIEW_Control] = convert_nat_results_to_nview(handles)

% Create file structure where result files will be defined and subsequently
% loaded
file.Path = handles.NVIEW_Control.Result_Information_File.Path;
file.Name = [];
file.Exte = '.mat';

for I = 1 : numel(handles.NVIEW_Control.Result_Files)
    % clear data structure and filename variable
    clear data; file.Name = []; 
    % Define filename from handles structure at i-th iteration
    file.Name = handles.NVIEW_Control.Result_Files{I};
    % Load data structure from stored mat file
    data = load([file.Path,filesep,file.Name]);
    
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
    Scenario_Structure.(['Scenario_', int2str(I)]) = create_result_structure(handles,data,grid_data);
end

% --------------------------------------------------------------------
% READ GRID STRUCTURE FORMAT AND RESHAPE INTO NVIEW FORMAT
% --------------------------------------------------------------------
Grid_List = handles.NVIEW_Control.Simulation_Description.Variants;

NVIEW_Results = [];
for I = 1 : numel(Grid_List)
    NVIEW_Results.(Grid_List{I}).bus = grid_data.(Grid_List{I}).bus;
    NVIEW_Results.(Grid_List{I}).bus_name = grid_data.(Grid_List{I}).bus_name;
    NVIEW_Results.(Grid_List{I}).branch = grid_data.(Grid_List{I}).branch;
    NVIEW_Results.(Grid_List{I}).branch_name = grid_data.(Grid_List{I}).branch_name;
    NVIEW_Results.(Grid_List{I}).bus_violations = [];
    NVIEW_Results.(Grid_List{I}).bus_statistics = [];
    NVIEW_Results.(Grid_List{I}).bus_violated_at_datasets = [];    
    NVIEW_Results.(Grid_List{I}).bus_violations_at_datasets = [];
    NVIEW_Results.(Grid_List{I}).bus_deviations = nan(3,3);  
    
    NVIEW_Results.(Grid_List{I}).branch_violations = [];
    NVIEW_Results.(Grid_List{I}).branch_statistics = [];
    NVIEW_Results.(Grid_List{I}).loss_statistics = [];

    
     for J = 1 : numel(handles.NVIEW_Control.Result_Files)         
         if handles.NVIEW_Control.Simulation_Options.Voltage_Analysis == 1
             NVIEW_Results.(Grid_List{I}).bus_violations(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_violations(:,1);
             
             NVIEW_Results.(Grid_List{I}).bus_statistics(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_summary.stat;
             
             NVIEW_Results.(Grid_List{I}).bus_violations_at_datasets(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_summary.dataset_voltage_violation_numbers;

             NVIEW_Results.(Grid_List{I}).bus_violated_at_datasets(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_summary.dataset_violated_nodes_numbers;

             NVIEW_Results.(Grid_List{I}).bus_deviations(1,:) = ...
                 nanmax([NVIEW_Results.(Grid_List{I}).bus_deviations(1,:);
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_deviations(1,:)]);

             NVIEW_Results.(Grid_List{I}).bus_deviations(2,:) = ...
                 nanmean([NVIEW_Results.(Grid_List{I}).bus_deviations(2,:);
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_deviations(2,:)]); 
             
             NVIEW_Results.(Grid_List{I}).bus_deviations(3,:) = ...
                 nanmin([NVIEW_Results.(Grid_List{I}).bus_deviations(3,:);
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).bus_deviations(3,:)]);             
             % 2d array, first dim. are the max, mean, min values, second
             % dim. are the phases - MERGED FOR ALL SCENARIOS

         end
         
         if handles.NVIEW_Control.Simulation_Options.Overcurrent_Analysis == 1
             NVIEW_Results.(Grid_List{I}).branch_violations(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).branch_violations(:,1);
             
             NVIEW_Results.(Grid_List{I}).branch_statistics(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).branch_statistics;
         end
         
         if handles.NVIEW_Control.Simulation_Options.Loss_Analysis == 1
             NVIEW_Results.(Grid_List{I}).loss_statistics(:,J) = ...
                 Scenario_Structure.(['Scenario_', int2str(J)]).(Grid_List{I}).loss_statistics;
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
% Get NVIEW Settings for possible NVIEW save!
% --------------------------------------------------------------------
NVIEW_Control.Result_Information_File = handles.NVIEW_Control.Result_Information_File;
NVIEW_Control.Scen_Grid_Information_File = handles.NVIEW_Control.Scen_Grid_Information_File;
NVIEW_Control.Simulation_Options = handles.NVIEW_Control.Simulation_Options;
NVIEW_Control.Result_Files = handles.NVIEW_Control.Result_Files;
NVIEW_Control.Simulation_Description = handles.NVIEW_Control.Simulation_Description;

% --------------------------------------------------------------------
% Store NVIEW result filename
% --------------------------------------------------------------------

file = [];
file.Path = handles.NVIEW_Control.NVIEW_Result_Information_File.Path;
file.Name = [];
exclude_text = 'information';
if strcmp(handles.NVIEW_Control.Result_Information_File.Name(end-size(exclude_text,2)+1:end), exclude_text)
    file.Name = [handles.NVIEW_Control.Result_Information_File.Name(1: end-size(exclude_text,2)),'NVIEW'];
end
file.Exte = handles.NVIEW_Control.NVIEW_Result_Information_File.Exte;

% Store path to NVIEW result file, update handles structure!
handles.NVIEW_Control.NVIEW_Result_Information_File = file;


% Store information to function output
NVIEW_Control.NVIEW_Result_Information_File = handles.NVIEW_Control.NVIEW_Result_Information_File;
end
