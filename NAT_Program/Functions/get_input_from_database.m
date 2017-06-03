function handles = get_input_from_database(handles)
%GET_INPUT_FROM_DATABASE Summary of this function goes here
%   Detailed explanation goes here

% Lastdaten einlesen und in Struktur speichern:
if handles.Current_Settings.Simulation.Use_Scenarios
	handles = get_data_szenarios_load_infeed(handles);
else
	handles.NAT_Data.Simulation = [];
	% Set the default scenario:
	handles.NAT_Data.Simulation.Active_Scenario = ...
		handles.Current_Settings.Simulation.Scenarios.(['Sc_',num2str(2)]);
	handles = loaddata_get(handles);
	% Die Daten + zugehörige Einstellungen in aktuelles Netzverzeichnis speichern:
	Load_Infeed_Data = handles.NAT_Data.Load_Infeed_Data; %#ok<NASGU>
	Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
	% Speicherort = aktulles Netzfile
	file = handles.Current_Settings.Files.Auto_Load_Feed_Data;
	file.Path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_files'];
	save([file.Path,filesep,file.Name,file.Exte],...
		'Load_Infeed_Data', 'Data_Extract');
end
end

