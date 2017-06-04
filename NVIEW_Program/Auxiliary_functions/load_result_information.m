function handles = load_result_information(handles)

% Clear variables
clear Current_Settings
% Load result information file
file = handles.NVIEW_Control.Result_Information_File;
load([file.Path,filesep,file.Name,file.Exte]);

% Read result information parameters
% Parameters = handles.NVIEW_Control.Files.Result_Information.Parameters;
Simulation_Options.Timepoints_per_dataset = Current_Settings.Simulation.Timepoints;
Simulation_Options.Number_of_datasets = Current_Settings.Simulation.Number_Runs;

% What kind of data is used
if Current_Settings.Data_Extract.get_Sample_Value
    Simulation_Options.Input_values_used = 'Data_Sample';
elseif Current_Settings.Data_Extract.get_Mean_Value
    Simulation_Options.Input_values_used = 'Data_Mean';
elseif Current_Settings.Data_Extract.get_Min_Value
    Simulation_Options.Input_values_used = 'Data_Min';
elseif Current_Settings.Data_Extract.get_Max_Value
    Simulation_Options.Input_values_used = 'Data_Max';
elseif Current_Settings.Data_Extract.get_95_Quantile_Value
    Simulation_Options.Input_values_used = 'Data_95P_Quantil';
elseif Current_Settings.Data_Extract.get_05_Quantile_Value
    Simulation_Options.Input_values_used = 'Data_05P_Quantil';
end


% Are grid variants used and if so, how many?
if Current_Settings.Simulation.Use_Grid_Variants == 1
    Simulation_Options.Use_Grid_Variants = 1;
    Simulation_Options.Number_of_Variants = numel(Current_Settings.Simulation.Grid_List);
else
    Simulation_Options.Use_Grid_Variants = 0;
    Simulation_Options.Number_of_Variants = 1;
end
% Are scenarios used and if so, how many?
if Current_Settings.Simulation.Use_Scenarios == 1
    Simulation_Options.Use_Scenarios = 1;
    Simulation_Options.Number_of_Scenarios = Current_Settings.Simulation.Scenarios.Number;
else
    Simulation_Options.Use_Scenarios = 0;
    Simulation_Options.Number_of_scenarios = 1;
end


% What results are available
if Current_Settings.Simulation.Voltage_Violation_Analysis == 1 && Current_Settings.Simulation.Save_Voltage_Results == 1
    Simulation_Options.Voltage_Analysis = 1; % Voltage analysis results are available
else
    Simulation_Options.Voltage_Analysis = 0;
end
if Current_Settings.Simulation.Branch_Violation_Analysis == 1 && Current_Settings.Simulation.Save_Branch_Results == 1
    Simulation_Options.Overcurrent_Analysis = 1; % Overcurrent analysis results are available
else
    Simulation_Options.Overcurrent_Analysis = 0;
end
if Current_Settings.Simulation.Power_Loss_Analysis == 1 && Current_Settings.Simulation.Save_Power_Loss_Results == 1
    Simulation_Options.Loss_Analysis = 1; % Active-power loss analysis are available
else
    Simulation_Options.Loss_Analysis = 0;
end

% save the other options which were present in the NAT at simulation-Time:
Simulation_Options.NAT_Settings = Current_Settings;


% Assign Simulation_Options and filenames to handles structure
handles.NVIEW_Control.Simulation_Options = Simulation_Options;

% Check if the information file is the result of a merger or is a
% singla simulation result file

% File is not a result of merging different result setting files
% get the result filenames, first search for all files in the current location along with
% the scenario description
files = dir(file.Path);

files = struct2cell(files);
files = files(1,cell2mat(files(3,:)) ~= 0);
% reset the files-list:
handles.NVIEW_Control.Result_Files = {};
handles.NVIEW_Control.Result_Files_Paths = {};
% get the prefix of the restultfilenames of the current settings file (form:
% 'Res_yyyy_mm_dd-HH.MM.SS - Scearnrioname.mat'):
simprefix = regexp(file.Name,' - ','split');
simprefix = simprefix{1};

FileList = [];
FileName = [];
FilePath = [];
for i=1:Current_Settings.Simulation.Scenarios.Number
    FileList{i,1} = [file.Path,filesep,simprefix,' - ',Current_Settings.Simulation.Scenarios.(['Sc_',num2str(i)]).Filename,'.mat'];
    FileName{i,1} = [simprefix,' - ',Current_Settings.Simulation.Scenarios.(['Sc_',num2str(i)]).Filename];
    FilePath{i,1} = file.Path;
end

% Check if the results are partitioned or unpartitioned
Result_Files = [];
Result_Files_Paths = [];

for i = 1 : numel(FileName)
    search_id = [];
    search_id = strncmp(files,FileName{i,1}, size(FileName{i,1},2));
    files_found = [];
    files_found = files(search_id);
    for j = 1 : numel(files_found)
        [~, files_found{1,j}, ~] = fileparts(files_found{1,j});
    end
    if numel(files_found) == 1
        Result_Files{i,1} = files_found{1,1};
        Result_Files_Paths{i,1} = FilePath{i,1};
    else        
        for j = 1 : numel(files_found)
            Result_Files{i,1}{1,j} = files_found{1,j};
            Result_Files_Paths{i,1}{1,j} = FilePath{i,1};
        end
    end
end
clear i j files_found search_id FileList FileName FilePath

% get the names of the main scenario files:
if Simulation_Options.Use_Scenarios
    scenario_details = cell(Simulation_Options.Number_of_Scenarios,2);
    handles.NVIEW_Control.Result_Files = Result_Files;
    handles.NVIEW_Control.Result_Files_Paths = Result_Files_Paths;
    for i=1:Current_Settings.Simulation.Scenarios.Number
        scenario_details{i,1} = Current_Settings.Simulation.Scenarios.(['Sc_',num2str(i)]).Filename;
        scenario_details{i,2} = Current_Settings.Simulation.Scenarios.(['Sc_',num2str(i)]).Description;
    end
    handles.NVIEW_Control.Simulation_Description.Scenario = scenario_details;
else
    errordlg('Single scenario simulation currently not supported!');
    return;
end

% get variant details
if Simulation_Options.Use_Grid_Variants
    variant_details_full(:,1) = Current_Settings.Simulation.Grid_List;
    % Remove file extension
    for i = 1 : size(variant_details_full,1)
        vf = [];
        [~, vf.Name, vf.Exte] = fileparts(variant_details_full{i,1});
        variant_details{i,1} = vf.Name;
    end
else
    variant_details{1,1} = 'Single_variant_simulation';
end

    
handles.NVIEW_Control.Simulation_Description.Variants = variant_details;

return