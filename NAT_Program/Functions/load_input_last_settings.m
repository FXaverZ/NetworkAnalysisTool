function handles = load_input_last_settings(handles)
%LOAD_INPUT_LAST_SETTINGS Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 04.11.2013
% Letzte Änderung durch:   Franz Zeilinger - 09.04.2014

% Einstellungen und Systemvariablen auslesen:
settin = handles.Current_Settings;
system = handles.System;
d = handles.NAT_Data;
handles.text_message_main_handler.add_line('Try to load loaddata...');
handles.text_message_main_handler.level_up();
% load one set of the loaddata according to the current settings:
if handles.Current_Settings.Simulation.Use_Scenarios
	handles.text_message_main_handler.add_line('Load loaddata for scenarios...');
	% try to load the last scenario-data-sets:
	load([settin.Simulation.Scenarios_Path,filesep,'Scenario_Settings.mat']);
	settin.Simulation.Scenarios = Scenarios_Settings;
	% Deactivate a maybe given scenario selection (because the old scenarios are not
	% present any more):
	handles.Current_Settings.Simulation.Scenarios_Selection = [];
	% load the data of the first scenario (% loading of 'Load_Infeed_Data' and
	% 'Data_Extract'):
	load([settin.Simulation.Scenarios_Path,filesep, settin.Simulation.Scenarios.Names{1},'.mat']);
	% indicate, that data is available:
	settin.Simulation.Scenarios.Data_avaliable = 1;
else
	handles.text_message_main_handler.add_line('Load automatic saved loaddata...');
	% automatisch gespeicherte Last- und Einspeisedaten laden:
	file = settin.Files.Auto_Load_Feed_Data;
	file.Path = [settin.Files.Grid.Path,filesep,settin.Files.Grid.Name,'_files'];
	% Laden von 'Load_Infeed_Data', 'Data_Extract':
	load('-mat', [file.Path,filesep,file.Name,file.Exte]);
end

% save the loaded data in the gui-structure:
d.Load_Infeed_Data = Load_Infeed_Data;
d.Data_Extract = Data_Extract;
settin.Data_Extract = Data_Extract;
% adapt number of simulation runs (according to available data):
settin.Simulation.Number_Runs = d.Data_Extract.Number_Data_Sets;

% clear the loaded data:
clear('Load_Infeed_Data', 'Data_Extract', 'Scenario_Settings');

if isfield(d.Load_Infeed_Data, 'Table_Network')
	% if just one dataset is available, relevant data can be shown
	% directly
	settin.Table_Network = d.Load_Infeed_Data.Table_Network;
else
	% if more datasets are available, just show the information about the first
	% data-set:
	d_set_names = fields(d.Load_Infeed_Data);
	settin.Table_Network = d.Load_Infeed_Data.(d_set_names{1}).Table_Network;
end
% Anzahl der jeweiligen Haushalte ermitteln:
% !!!HAS TO BE REFACTORED!!!
% This part of the code is absolutly strange but has worked till now...
for i=1:size(system.housholds,1)
	settin.Data_Extract.Households.(system.housholds{i,1}).Number = ...
		sum(strcmp(system.housholds{i,1},settin.Table_Network.Data(:,3)));
end

handles.text_message_main_handler.add_line('... done.');

% Einstellungen übernehmen:
handles.Current_Settings = settin;
end

