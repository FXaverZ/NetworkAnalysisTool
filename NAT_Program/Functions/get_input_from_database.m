function handles = get_input_from_database(handles)
%GET_INPUT_FROM_DATABASE Summary of this function goes here
%   Detailed explanation goes here

% Lastdaten einlesen und in Struktur speichern:
if handles.Current_Settings.Simulation.Use_Scenarios
	handles = get_data_szenarios_load_infeed(handles);
else
	% clear the NAT_Data simulation field (so the default extraction settings of the
	% default scenario are used):
	handles.NAT_Data.Simulation = [];
	% Save the extraction-moment:
	handles.Current_Settings.Data_Extract.Date_Extraktion = now();
	% Check, if the data has to be partitioned:
	if handles.Current_Settings.Simulation.Number_Runs > handles.System.number_max_datasets
		% The data has to be partitioned!
		errordlg('Partitioned data for no scenario-simulation currently not supported!');
		% bisherige Daten l�schen:
		handles.NAT_Data.Load_Infeed_Data = [];
		return;
	else
		% get the data:
		handles = loaddata_get(handles);
	end
	% Die Daten + zugeh�rige Einstellungen in aktuelles Netzverzeichnis speichern:
	Load_Infeed_Data = handles.NAT_Data.Load_Infeed_Data; %#ok<NASGU>
	% Speicherort = aktulles Netzfile
	file = handles.Current_Settings.Files.Auto_Load_Feed_Data;
	% Check, if a Subfolder for input-data is avaliable:
	file.Path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_nat',filesep,...
		'Load_Infeed_Data',filesep,...
		datestr(handles.Current_Settings.Data_Extract.Date_Extraktion,'yyyy_mm_dd-HH.MM.SS')];
	if ~isdir([file.Path])
		mkdir([file.Path]);
	end
	% Save the files (on load-infeed file and one settings file:
	save([file.Path,filesep,file.Name,file.Exte],...
		'Load_Infeed_Data');
	Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
	System = handles.System; %#ok<NASGU>
	save([file.Path,filesep,'Data_Settings.mat'],'Data_Extract','System');
	handles.Current_Settings.Files.Auto_Load_Feed_Data = file;
end
end
