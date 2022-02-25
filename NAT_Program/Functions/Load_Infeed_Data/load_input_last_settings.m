function handles = load_input_last_settings(handles)
%LOAD_INPUT_LAST_SETTINGS Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.1
% Erstellt von:            Franz Zeilinger - 04.11.2013
% Letzte Änderung durch:   Franz Zeilinger - 17.01.2019

% Einstellungen und Systemvariablen auslesen:
settin = handles.Current_Settings;
system = handles.System;
d = handles.NAT_Data;
mh = handles.text_message_main_handler;

mh.add_line('Try to load loaddata...');
mh.level_up();
% load one set of the loaddata according to the current settings:
if handles.Current_Settings.Simulation.Use_Scenarios
	mh.add_line('Load loaddata for scenarios.');
	% try to load the last scenario-data-sets:
	load([settin.Simulation.Scenarios_Path,filesep,'Scenario_Settings.mat'],'Scenarios_Settings','Data_Extract');
	% check, if the data is sutiable for the active grid type:
	if ~strcmp(settin.Grid.Type, Data_Extract.Grid_type)
		errorstr = 'Grid types of active grid an data to be loaded are not equal!';
		exception = MException(...
			'NAT:LoadInputLastSettings:GridtypeNotCompatible',...
			errorstr);
		throw(exception);
	end
	settin.Simulation.Scenarios = Scenarios_Settings;
	% Deactivate a maybe given scenario selection (because the old scenarios are not
	% present any more):
	settin.Simulation.Scenarios_Selection = [];
	% load the data of the first scenario (% loading of 'Load_Infeed_Data'):
	load([settin.Simulation.Scenarios_Path,filesep, settin.Simulation.Scenarios.Names{1},'.mat'],'Load_Infeed_Data');
	% indicate, that data is available:
	settin.Simulation.Scenarios.Data_avaliable = 1;
else
	mh.add_line('Load automatic saved loaddata.');
	% automatisch gespeicherte Last- und Einspeisedaten laden:
	file = settin.Files.Auto_Load_Feed_Data;
	% Laden von 'Load_Infeed_Data':
	load('-mat', [file.Path,filesep,file.Name,file.Exte],'Load_Infeed_Data');
	% Laden von 'Data_Extract' und 'System'
	load('-mat', [file.Path,filesep,file.Data_Settings,file.Exte],'Data_Extract','System');
end

% save the loaded data in the gui-structure:
d.Load_Infeed_Data = Load_Infeed_Data;
d.Data_Extract = Data_Extract;
% settin.Data_Extract = Data_Extract;
% adapt number of simulation runs (according to available data):
settin.Simulation.Number_Runs = d.Data_Extract.Number_Data_Sets;
% Wieviele Zeitpunkte werden berechnet?
settin.Simulation.Timepoints = d.Data_Extract.Timepoints_per_dataset;

% clear the loaded data:
clear('Load_Infeed_Data', 'Data_Extract', 'Scenario_Settings', 'System');

if isfield(d.Load_Infeed_Data, 'Table_Network')
	% if just one dataset is available, relevant data can be shown
	% directly
	settin.Table_Network = d.Load_Infeed_Data.Table_Network;
else
	% if more datasets are available, just show the information about the first
	% data-set:
	d_set_names = fields(d.Load_Infeed_Data);
	settin.Table_Network = d.Load_Infeed_Data.(d_set_names{1}).Table_Network;
	% check, if a solar structure is available in the loaded data an load
	% this data for displaying in the GUI:
	if isfield(d.Load_Infeed_Data.(d_set_names{1}),'Solar_Plants')
		settin.Data_Extract.Solar = d.Load_Infeed_Data.(d_set_names{1}).Solar_Plants;
	end
end
% Anzahl der jeweiligen Haushalte ermitteln:
% !!!HAS TO BE REFACTORED!!!
% This part of the code is absolutly strange but has worked till now...
for i=1:size(system.housholds,1)
	settin.Data_Extract.Households.(system.housholds{i,1}).Number = ...
		sum(strcmp(system.housholds{i,1},settin.Table_Network.Data(:,3)));
end

% Einstellungen übernehmen:
handles.Current_Settings = settin;

mh.level_down();
mh.add_line('... Load data successfully loaded!');
end

