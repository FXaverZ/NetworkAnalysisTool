function handles = get_data_szenarios_load_infeed(handles)
%GET_DATA_SZENARIOS_LOAD_INFEED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.2
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 29.04.2013

fprintf('\nErstelle Szenariendaten...\n');

% Check, if a Subfolder for input-data within the current grid-folder is avaliable:
path = handles.Current_Settings.Simulation.Grids_Path;
if ~isdir([path,filesep,'Load_Infeed_Data_f_Scenarios'])
	mkdir([path,filesep,'Load_Infeed_Data_f_Scenarios']);
end

% Create a Subfolder for the extracted data, containing the extraction-moment:
handles.Current_Settings.Data_Extract.Date_Extraktion = now();
handles.Current_Settings.Simulation.Scenarios_Path = [...
	path,filesep,'Load_Infeed_Data_f_Scenarios',filesep,...
	datestr(handles.Current_Settings.Data_Extract.Date_Extraktion,'yyyy_mm_dd-HH.MM.SS'),...
	];
mkdir(handles.Current_Settings.Simulation.Scenarios_Path);

% Access to the data-object and reset:
d = handles.NAT_Data;
d.Simulation = [];

Scenarios_Settings = handles.Current_Settings.Simulation.Scenarios;
for i=1:Scenarios_Settings.Number
	% Select the current active scenario
	d.Simulation.Active_Scenario = Scenarios_Settings.(['Sc_',num2str(i)]);
	fprintf([d.Simulation.Active_Scenario.Filename,'\n']);
	
	% Check, if the data has to be partitioned:
	if handles.Current_Settings.Simulation.Number_Runs > handles.System.number_max_datasets
		% The data has to be partitioned!
		handles = loaddata_get(handles, 1);
		% get the new (altered in loaddata_get) scenario information:
		Scenarios_Settings.(['Sc_',num2str(i)]) = d.Simulation.Active_Scenario;
	else
		% If not, go through the scenarios in a normal way and store the gathered data in one
		% file:
		handles = loaddata_get(handles);
		% save the extracted data within a seperate file in the grid variants
		% folder:
		name = d.Simulation.Active_Scenario.Filename;
		Load_Infeed_Data = d.Load_Infeed_Data; %#ok<NASGU>
		save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,name,'.mat'],...
			'Load_Infeed_Data');
		clear('Load_Infeed_Data');
	end
	fprintf('\t--> erledigt!\n');
end
% Update the settings:
Scenarios_Settings.Data_avaliable = 1;
% Create variables for saving:
Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
% Save the Settings:
save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,'Scenario_Settings.mat'],...
	'Scenarios_Settings', 'Data_Extract');
handles.Current_Settings.Simulation.Scenarios = Scenarios_Settings;




