function handles = get_data_szenarios_load_infeed(handles)
%GET_DATA_SZENARIOS_LOAD_INFEED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.2
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 29.04.2013

path = handles.Current_Settings.Simulation.Grids_Path;
if ~isdir([path,filesep,'Load_Infeed_Data_f_Scenarios'])
	mkdir([path,filesep,'Load_Infeed_Data_f_Scenarios']);
end
Scenarios_Settings = handles.Current_Settings.Simulation.Scenarios;

% Access to the data object:
d = handles.NAT_Data;
d.Simulation = [];
fprintf('\nErstelle Szenariendaten...\n');
for i=1:Scenarios_Settings.Number
	d.Simulation.Active_Scenario = Scenarios_Settings.(['Sc_',num2str(i)]);
	fprintf([d.Simulation.Active_Scenario.Filename,'\n']);
	handles = loaddata_get(handles);
	% save the extracted data within a seperate file in the grid variants
	% folder:
	name = d.Simulation.Active_Scenario.Filename;
	Load_Infeed_Data = d.Load_Infeed_Data; %#ok<NASGU>
	Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
	
	save([path,filesep,'Load_Infeed_Data_f_Scenarios',filesep,name,'.mat'],...
		'Load_Infeed_Data','Data_Extract');
end
fprintf('\t--> erledigt!\n');
% Save the current settings of the scenarios for later use:
handles.Current_Settings.Simulation.Scenarios_Path =...
	[path,filesep,'Load_Infeed_Data_f_Scenarios'];
handles.Current_Settings.Simulation.Scenarios.Data_avaliable = 1;
% Update the settings:
Scenarios_Settings = handles.Current_Settings.Simulation.Scenarios; %#ok<NASGU>
save([path,filesep,'Load_Infeed_Data_f_Scenarios',filesep,'Scenario_Settings.mat'],...
		'Scenarios_Settings');



