function handles = get_data_szenarios_load_infeed(handles)
%GET_DATA_SZENARIOS_LOAD_INFEED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.5.2
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 11.07.2018

mh = handles.text_message_main_handler;
wb = handles.waitbar_main_handler;

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


log_path = [handles.Current_Settings.Simulation.Scenarios_Path,filesep,...
	datestr(handles.Current_Settings.Data_Extract.Date_Extraktion,'yyyy_mm_dd-HH.MM.SS'),...
	' - Log.log'];
mh.mark_sub_log(log_path);

mh.add_line('Loading data for multiple scenario simulation...');
mh.level_up();

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

wb.add_end_position('scenario_counter',scen_new.Number);
for scenario_counter=1:scen_old.Number
	% check, if the current scenario is selected:
	if isempty(find(scenario_counter==Scen_Sel, 1))
		% this scenario will not be treated
		continue;
	end
	scen_cou = scen_cou + 1;
	wb.update_counter('scenario_counter', scen_cou);
	
	% Select the current active scenario
	d.Simulation.Active_Scenario = scen_old.(['Sc_',num2str(scenario_counter)]);
	mh.add_line('Scenario "',d.Simulation.Active_Scenario.Filename,'"');
	mh.level_up();
	
	try
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
			Load_Infeed_Data = d.Load_Infeed_Data; 
			save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,name,'.mat'],...
				'Load_Infeed_Data','Load_Infeed_Data','-v7.3');
			clear('Load_Infeed_Data');
		end
	catch ME
		if strcmp(ME.identifier,'NAT:LoadDataGet:CanceledByUser')
			% bisherige Daten löschen:
			handles.NAT_Data.Load_Infeed_Data = [];
			mh.stop_sub_log(log_path);
			mh.level_down();
			return;
		else
			rethrow(ME)
		end
	end
	% get the new (altered in loaddata_get) scenario information:
	scen_new.(['Sc_',num2str(scen_cou)]) = d.Simulation.Active_Scenario;
	scen_old.(['Sc_',num2str(scenario_counter)]) = d.Simulation.Active_Scenario;
	scen_new.Names{scen_cou} = scen_old.Names{scenario_counter};
	mh.level_down();
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

mh.stop_sub_log(log_path);



