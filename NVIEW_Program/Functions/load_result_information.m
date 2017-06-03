function handles = load_result_information(handles)

% Load result information file
file = handles.NVIEW_Control.Result_Information_File;
rid = load([file.Path,filesep,file.Name,file.Exte]);

% Read result information parameters
% Parameters = handles.NVIEW_Control.Files.Result_Information.Parameters;
Simulation_Options.Timepoints_per_dataset = rid.simulation_options.Timepoints;
Simulation_Options.Number_of_datasets = rid.datasets;
Simulation_Options.Input_values_used = rid.simulation_options.Input_values_used;

% Are grid variants used and if so, how many?
if rid.simulation_options.Use_Grid_Variants == 1
    Simulation_Options.Use_Grid_Variants = 1;
    Simulation_Options.Number_of_Variants = numel(rid.variants);
else
    Simulation_Options.Use_Grid_Variants = 0;
    Simulation_Options.Number_of_Variants = 1;
end
% Are scenarios used and if so, how many?
if rid.simulation_options.Use_Scenarios == 1
    Simulation_Options.Use_Scenarios = 1;
    Simulation_Options.Number_of_Scenarios = numel(rid.scenarios);
else
    Simulation_Options.Use_Scenarios = 0;
    Simulation_Options.Number_of_scenarios = 1;
end
% What results are available

if rid.simulation_options.Voltage_Violation_Analysis == 1 && rid.simulation_options.Save_Voltage_Results == 1
    Simulation_Options.Voltage_Analysis = 1; % Voltage analysis results are available
else
    Simulation_Options.Voltage_Analysis = 0;
end
if rid.simulation_options.Branch_Violation_Analysis == 1 && rid.simulation_options.Save_Branch_Results == 1
    Simulation_Options.Overcurrent_Analysis = 1; % Overcurrent analysis results are available
else
    Simulation_Options.Overcurrent_Analysis = 0;
end
if rid.simulation_options.Power_Loss_Analysis == 1 && rid.simulation_options.Save_Power_Loss_Results == 1
    Simulation_Options.Loss_Analysis = 1; % Active-power loss analysis are available
else
    Simulation_Options.Loss_Analysis = 0;
end

% Assign Simulation_Options and filenames to handles structure
handles.NVIEW_Control.Simulation_Options = Simulation_Options;
handles.NVIEW_Control.Result_Files = rid.result_filename;

% Load scenario/grid details if available from the txt log file
if ~isempty(handles.NVIEW_Control.Scen_Grid_Information_File.Name)
    ftext = text_scan(handles.NVIEW_Control.Scen_Grid_Information_File.Path,...
                      [handles.NVIEW_Control.Scen_Grid_Information_File.Name,handles.NVIEW_Control.Scen_Grid_Information_File.Exte]);
    
    % Scan through text file for information data
    % hash_sep defines the information details into multiple parts
    hash_sep = zeros(size(ftext,1),1);    
    scen_definition_start = zeros(size(ftext,1),1);    
    variant_definition_start = zeros(size(ftext,1),1);    
    for i = 1 : size(ftext,1)
        if strncmp('##',ftext(i,1:2),2)
            hash_sep(i,1) = 1;
        end
        if strncmp('##Scenario definition',ftext(i,1:21),21)
            scen_definition_start(i,1) = 1;
        elseif strncmp('##Variant definition',ftext(i,1:20),20)
            variant_definition_start(i,1) = 1;
        end
    end
    % Convert search indiciis to numerical format
    hash_sep = find(hash_sep);
    scen_definition_start = find(scen_definition_start);
    variant_definition_start = find(variant_definition_start);
    
    % Scenario definition
    scen_definition = ftext(scen_definition_start : hash_sep(find(hash_sep==scen_definition_start,1)+1) -1,: );
    % Variant definition
    variant_definition = ftext(variant_definition_start : hash_sep(find(hash_sep==variant_definition_start,1)+1) -1,: );

    % Reformat to cell structure 
    for i = 2 : size(scen_definition,1)    
        seper = [];
        seper = find(scen_definition(i,:)==';');
        scenario_details{i-1,1} = scen_definition(i,1:seper(1)-1); % First column is the scenario name
        scenario_details{i-1,2} = scen_definition(i,seper(1)+1:seper(2)-1); % Second column is the scenario overview
    end
    % Currently only scenarios have detailed information, variants do not
    % have any other info besides the name!
    for i = 2 : size(variant_definition,1)    
        seper = [];
        seper = find(variant_definition(i,:)==';');
        variant_details{i-1,1} = variant_definition(i,1:seper(1)-1); % First column is the scenario name
        %variant_details{i-1,2} = variant_definition(i,seper(1)+1:seper(2)-1); % Second column is the scenario overview
    end
    clear hash_sep scen_definition_start variant_definition_start i ftext seper

    % Write to handles structure
    handles.NVIEW_Control.Simulation_Description.Scenario = scenario_details;
    handles.NVIEW_Control.Simulation_Description.Variants = variant_details;    
end

return