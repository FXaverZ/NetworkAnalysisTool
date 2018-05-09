function handles = get_data_szenarios_load_infeed(handles)
%GET_DATA_SZENARIOS_LOAD_INFEED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.5.1
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 04.05.2018

mh = handles.text_message_main_handler;
mh.add_line('Loading data for multiple scenario simulation...');
mh.level_up();

% Check, if a Subfolder for input-data within the current grid-folder is avaliable:
if handles.Current_Settings.Simulation.Use_Grid_Variants && ~isempty(handles.Current_Settings.Simulation.Grid_List)
	path = handles.Current_Settings.Simulation.Grids_Path;
else
	path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_nat'];
end
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

diary([handles.Current_Settings.Simulation.Scenarios_Path,filesep,...
	datestr(handles.Current_Settings.Data_Extract.Date_Extraktion,'yyyy_mm_dd-HH.MM.SS'),...
	' - Log.txt']);

fprintf('\nErstelle Szenariendaten...\n');

% Mark the type of the grid for this data:
handles.Current_Settings.Data_Extract.Grid_type = handles.Current_Settings.Grid.Type;

% Access to the data-object and reset:
d = handles.NAT_Data;
d.Simulation = [];

% adapt the Scenario-Settings according to the selection:
scen_old = handles.Current_Settings.Simulation.Scenarios;
if ~isempty(handles.Current_Settings.Simulation.Scenarios_Selection)
	Scen_Sel = handles.Current_Settings.Simulation.Scenarios_Selection;
else
	Scen_Sel = 1:scen_old.Number;
end
scen_new.Number = numel(Scen_Sel);
scen_new.Names = cell(1,scen_new.Number);
scen_cou = 0;
for i=1:scen_old.Number
	% check, if the current scenario is selected:
	if isempty(find(i==Scen_Sel, 1))
		% this scenario will not be treated
		continue;
	end
	% Select the current active scenario
	d.Simulation.Active_Scenario = scen_old.(['Sc_',num2str(i)]);
	fprintf([d.Simulation.Active_Scenario.Filename,'\n']);
	scen_cou = scen_cou + 1;
	
	% Check, if the data has to be partitioned:
	if handles.Current_Settings.Simulation.Number_Runs > handles.System.number_max_datasets
		% The data has to be partitioned!
		handles = loaddata_get(handles, 1);
	else
		% If not, go through the scenarios in a normal way and store the gathered data in one
		% file:
		handles = loaddata_get(handles);
		% save the extracted data within a seperate file in the grid variants
		% folder:
		name = d.Simulation.Active_Scenario.Filename;
		Load_Infeed_Data = d.Load_Infeed_Data; %#ok<NASGU>
		save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,name,'.mat'],...
			'Load_Infeed_Data','Load_Infeed_Data','-v7.3');
		clear('Load_Infeed_Data');
	end
	% get the new (altered in loaddata_get) scenario information:
	scen_new.(['Sc_',num2str(scen_cou)]) = d.Simulation.Active_Scenario;
	scen_old.(['Sc_',num2str(i)]) = d.Simulation.Active_Scenario;
	scen_new.Names{scen_cou} = scen_old.Names{i};
	fprintf('\t--> erledigt!\n');
end

% Update the settings:
scen_new.Data_avaliable = 1;
scen_old.Data_avaliable = 1;

% Create variables for saving:
Scenarios_Settings = scen_new; %#ok<NASGU>
Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
System = handles.System; %#ok<NASGU>

% Save the Settings:
save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,'Scenario_Settings.mat'],...
	'Scenarios_Settings', 'Data_Extract', 'System');

% Update the Current settings:
handles.Current_Settings.Simulation.Scenarios = scen_old;

diary('off');



