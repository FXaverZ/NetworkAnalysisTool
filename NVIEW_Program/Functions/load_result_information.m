function handles = load_result_information(handles)

% Changed by Franz Zeilinger 13.11.2013

% Load result information file
file = handles.NVIEW_Control.Result_Information_File;
load([file.Path,filesep,file.Name,file.Exte]);
rid = Current_Settings;
clear('Current_Settings');

% Read result information parameters
% Parameters = handles.NVIEW_Control.Files.Result_Information.Parameters;
Simulation_Options.Timepoints_per_dataset = rid.Data_Extract.Timepoints_per_dataset;
Simulation_Options.Number_of_datasets = rid.Simulation.Number_Runs;

% What kind of data is used
if rid.Data_Extract.get_Sample_Value
    Simulation_Options.Input_values_used = 'Data_Sample';
elseif rid.Data_Extract.get_Mean_Value
    Simulation_Options.Input_values_used = 'Data_Mean';
elseif rid.Data_Extract.get_Min_Value
    Simulation_Options.Input_values_used = 'Data_Min';    
elseif rid.Data_Extract.get_Max_Value
	Simulation_Options.Input_values_used = 'Data_Max';
elseif rid.Data_Extract.get_95_Quantile_Value
    Simulation_Options.Input_values_used = 'Data_95P_Quantil';
elseif rid.Data_Extract.get_05_Quantile_Value
    Simulation_Options.Input_values_used = 'Data_05P_Quantil';
end

% Are grid variants used and if so, how many?
if rid.Simulation.Use_Grid_Variants == 1
    Simulation_Options.Use_Grid_Variants = 1;
    Simulation_Options.Number_of_Variants = numel(rid.Simulation.Grid_List);
else
    Simulation_Options.Use_Grid_Variants = 0;
    Simulation_Options.Number_of_Variants = 1;
end
% Are scenarios used and if so, how many?
if rid.Simulation.Use_Scenarios == 1
    Simulation_Options.Use_Scenarios = 1;
	Simulation_Options.Number_of_Scenarios = rid.Simulation.Scenarios.Number;
else
    Simulation_Options.Use_Scenarios = 0;
    Simulation_Options.Number_of_scenarios = 1;
end

% What results are available
if rid.Simulation.Voltage_Violation_Analysis == 1 && rid.Simulation.Save_Voltage_Results == 1
    Simulation_Options.Voltage_Analysis = 1; % Voltage analysis results are available
else
    Simulation_Options.Voltage_Analysis = 0;
end
if rid.Simulation.Branch_Violation_Analysis == 1 && rid.Simulation.Save_Branch_Results == 1
    Simulation_Options.Overcurrent_Analysis = 1; % Overcurrent analysis results are available
else
    Simulation_Options.Overcurrent_Analysis = 0;
end
if rid.Simulation.Power_Loss_Analysis == 1 && rid.Simulation.Save_Power_Loss_Results == 1
    Simulation_Options.Loss_Analysis = 1; % Active-power loss analysis are available
else
    Simulation_Options.Loss_Analysis = 0;
end

% save the other options which were present in the NAT at simulation-Time:
Simulation_Options.NAT_Settings = rid;

% Assign Simulation_Options and filenames to handles structure
handles.NVIEW_Control.Simulation_Options = Simulation_Options;

% get the result filenames, first search for all files in the current location along with
% the scenario description
files = dir(file.Path);
files = struct2cell(files);
files = files(1,3:end);
% reset the files-list:
handles.NVIEW_Control.Result_Files = {};
% get the prefix of the restultfilenames of the current settings file (form:
% 'Res_yyyy_mm_dd-HH.MM.SS - Scearnrioname.mat'):
simprefix = regexp(file.Name,' - ','split');
simprefix = simprefix{1};
% get the names of the main scenario files:
if Simulation_Options.Use_Scenarios
	scenario_details = cell(Simulation_Options.Number_of_Scenarios,2);
	for i=1:rid.Simulation.Scenarios.Number
		filename = [simprefix,' - ',rid.Simulation.Scenarios.(['Sc_',num2str(i)]).Filename,'.mat'];
		if ~isempty(find(strcmp(files, filename), 1))
			handles.NVIEW_Control.Result_Files{end+1} = filename;
			scenario_details{i,1} = rid.Simulation.Scenarios.(['Sc_',num2str(i)]).Filename;
			scenario_details{i,2} = rid.Simulation.Scenarios.(['Sc_',num2str(i)]).Description;
		end
	end
	handles.NVIEW_Control.Simulation_Description.Scenario = scenario_details;
else
	errordlg('Single scenario simulation currently not supported!');
	return;
end

if Simulation_Options.Use_Grid_Variants
	variant_details = cell (numel(Simulation_Options.Number_of_Variants,1));
	for i=1:Simulation_Options.Number_of_Variants
		variant_details{i,1} = rid.Simulation.Grid_List{i};
	end
else
	variant_details{1} = rid.Files.Grid.Name;
end

handles.NVIEW_Control.Simulation_Description.Variants = variant_details;