% NAT_MAIN    Netzanalyse- und Simulationstool, Hauptprogramm 

% Version:                 3.7
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 24.04.2013

% Last Modified by GUIDE v2.5 24-Apr-2013 16:32:33

function varargout = NAT_main(varargin)
% NAT_MAIN    Netzanalyse- und Simulationstool, Hauptprogramm

% Beginn Initializationscode - NICHT EDITIEREN!
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NAT_main_OpeningFcn, ...
                   'gui_OutputFcn',  @NAT_main_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
% Ende Initializationscode - NICHT EDITIEREN!
end

function check_extract_05_quantile_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_05_quantile_value (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_05_Quantile_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_95_quantile_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_95_quantile_value (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_95_Quantile_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_max_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_max_value (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_Max_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_mean_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_mean_value (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_Mean_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_min_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_min_value (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_Min_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_sample_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_sample_value (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_Sample_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_get_time_series_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_output_mean_value (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_Time_Series = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_pqnode_active_Callback(hObject, eventdata, handles)
% hObject    handle to check_pqnode_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function check_use_scenarios_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_use_scenarios (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Simulation.Use_Scenarios = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function check_use_variants_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_use_scenarios (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Simulation.Use_Grid_Variants = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function edit_simulation_number_runs_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik edit_simulation_number_runs (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

Number_Runs = ...
	str2double(get(hObject,'String'));
if isnan(Number_Runs)
	errordlg('Ungültiges Zahlenformat!', 'Angabe Anzahl Einzelsimulationen ...');
else
	Number_Runs = round(Number_Runs);
	handles.Current_Settings.Simulation.Number_Runs = Number_Runs;
end
% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function menue_data_load_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik menue_data_load (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% aktuellen Speicherort für Konfigurationen auslesen:
file = handles.Current_Settings.Files.Save.Result;
% Userabfrage nach Speicherort
[file.Name,file.Path] = uigetfile([...
	{'*.mat','Simulationsdaten'};...
	{'*.*','Alle Dateien'}],...
	'Laden von Simulationsdaten...',...
	[file.Path,filesep]);
% Überprüfen, ob gültiger Speicherort angegeben wurde:
if ~isequal(file.Name,0) && ~isequal(file.Path,0)
	% Falls, ja, Entfernen der Dateierweiterung vom Dateinamen:
	[~, file.Name, file.Exte] = fileparts(file.Name);
	% leztes Zeichen ("/") im Pfad entfernen:
	file.Path = file.Path(1:end-1);
	% Daten laden und Einstellungen dieser Daten wiederherstellen:
	load('-mat', [file.Path,filesep,file.Name,file.Exte]);
	handles.NAT_Data.Result = Result;
	handles.Current_Settings = Result.Current_Settings;
	% aktuellen Speicherort übernehmen:
	handles.Current_Settings.Files.Save.Result = file;
	
	% Netz zurücksetzen:
	handles.Current_Settings.Files.Grid.Name = [];
	if isfield(handles,'sin')
		handles = rmfield(handles,'sin');
	end
	try
		db = handles.Current_Settings.Load_Database;
		load([db.Path,filesep,db.Name,filesep,db.Name,'.mat']);
		handles.Current_Settings.Database.setti = setti;
		handles.Current_Settings.Database.files = files;
		
	catch ME
		% alte Datenbankeinstellungen entfernen:
		if isfield(handles.Current_Settings.Database,'setti')
			handles.Current_Settings.Database = rmfield(...
				handles.Current_Settings.Database,'setti');
		end
		if isfield(handles.Current_Settings.Database,'files')
			handles.Current_Settings.Database = rmfield(...
				handles.Current_Settings.Database,'files');
		end
		
		% User informieren:
		helpdlg({'Simulationsdaten erfolgreich geladen.',...
			'Datenbank konnte nicht geladen werden,',...
			'bitte Datenbankpfad erneut angeben!'});
		disp('Fehler beim Laden der Datenbankeinstellungen:');
		disp(ME.message);
	end
end

% Anzeigen aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function menue_data_save_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik menue_data_save (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% aktuellen Speicherort für Simulationsdaten auslesen:
file = handles.Current_Settings.Files.Save.Result;
% Userabfrage nach Speicherort
[file.Name,file.Path] = uiputfile([...
	{'*.mat','Simulationsdaten'};...
	{'*.*','Alle Dateien'}],...
	'Speicherort für aktuelle Simulationsdaten...',...
	[file.Path,filesep,file.Name,file.Exte]);
% Überprüfen, ob gültiger Speicherort angegeben wurde:
if ~isequal(file.Name,0) && ~isequal(file.Path,0)
	% Falls, ja, Entfernen der Dateierweiterung vom Dateinamen:
	[~, file.Name, file.Exte] = fileparts(file.Name);
	% leztes Zeichen ("/") im Pfad entfernen:
	file.Path = file.Path(1:end-1);
	% aktuellen Speicherort übernehmen:
	handles.Current_Settings.Files.Save.Result = file;
	handles = save_simulation_data(handles);
end

% User informieren:
helpdlg('Simulationsdaten erfolgreich gespeichert');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function menue_file_close_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_close (siehe GCBO)
% eventdata	 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

NAT_main_gui_CloseRequestFcn(hObject, eventdata, handles);

function NAT_main_gui_CloseRequestFcn(hObject, ~, handles) %#ok<INUSL>
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

user_response = questdlg(['Soll das Programm beendet und die aktuellen',...
	' Eintellungen gespeichert werden?'],'Beenden?',...
	'Speichern & Beenden', 'Beenden', 'Abbrechen', 'Abbrechen');
switch user_response
	case 'Abbrechen'
		% nichts unternehmen
	case 'Beenden'
		% Kein speichern der akutellen Einstellungen, nur beenden des Programms:
		if isfield(handles, 'sin')
			handles.sin.close_file;
			handles.sin.close_database;
		end
		delete(handles.NAT_main_gui);
	case 'Speichern & Beenden'
		% Konfiguration speichern:
		Current_Settings = handles.Current_Settings;
		System = handles.System; %#ok<NASGU>
		file = Current_Settings.Files.Last_Conf;
		% Falls Pfad der Konfigurationsdatei nicht vorhanden ist, Ordner erstellen:
		if ~isdir(file.Path)
			mkdir(file.Path);
		end
		save([file.Path,filesep,file.Name,file.Exte],'Current_Settings','System');
		if isfield(handles, 'sin')
			handles.sin.close_file;
			handles.sin.close_database;
		end
		delete(handles.NAT_main_gui);
end

function NAT_main_OpeningFcn(hObject, ~, handles, varargin)
% Funktion wird vor Sichtbarwerden des Hauptfensters ausgeführt: 
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)
% varargin   Übergabevariablen an Access_Tool (see VARARGIN)

% Wo ist "NAT_main.m" zu finden?
[~, Source_File] = fileattrib('NAT_main.m');
% Ordner, in dem "NAT_main.m" sich befindet, enthält Programm:
if ischar(Source_File)
	fprintf([Source_File,' - Current Directory auf Datei setzen, in der sich ',...
		'''NAT_main.m'' befindet!\n']);
	% Fenster schließen:
	delete(handles.NAT_main_gui);
	return;
end
Path = fileparts(Source_File.Name);

% Subfolder in Search-Path aufnehmen (damit alle Funktionen gefunden werden
% können)
addpath(genpath(Path));
handles.Current_Settings.Files.Main_Path = Path;

% Default-Einstellungen laden
handles = get_default_values(handles);
% Datenobjekt erzeugen:
handles.NAT_Data = NAT_Data();

% GUI-Elemente mit Inhalten füllen:
% Wochentage und Jahreszeiten anpassen:
seas = handles.System.seasons;
week = handles.System.weekdays;
for i=1:3
	set(handles.(['radio_season_',num2str(i)]),'String',seas{i,2});
	set(handles.(['radio_weekday_',num2str(i)]),'String',week{i,2});
end
% Worst-Cases:
set(handles.popup_hh_worstcase, 'String', handles.System.wc_households(:,1));
set(handles.popup_gen_worstcase, 'String', handles.System.wc_generation(:,1));
% Haushaltstypen:
set(handles.popup_pqnode_hh_typ, 'String', handles.System.housholds(:,1));

% Versuch, die Einstellungen des letzen Durchlaufs zu laden:
try
	file = handles.Current_Settings.Files.Last_Conf;
	load('-mat', [file.Path,filesep,file.Name,file.Exte]);
	handles.Current_Settings = Current_Settings;
	handles.System = System;
	try
		% Netzdaten laden:
		handles = network_load (handles);
	catch ME
		disp('Fehler beim Laden des Netzes:');
		disp(ME.message);
	end
catch ME
	disp('Fehler beim Laden der Konfigurationsdatei:');
	disp(ME.message);
end

% ESEA-Logo anzeigen:
logo=imread('Figures\siemenslogo.jpg','jpg');   % Einlesen der Grafik
image(logo,'Parent',handles.axes_logo);           % Darstellen des Logos
axis image;                                       % Grafik entzerren
axis off;                                         % Achsenbezeichnung ausschalten

% Anzeige des Hauptfensters aktualisieren:
handles = refresh_display_NAT_main_gui (handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function varargout = NAT_main_OutputFcn(hObject, eventdata, handles) %#ok<STOUT,INUSD>

function popup_gen_worstcase_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik popup_hh_worstcase (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Worstcase_Generation = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren
guidata(hObject, handles);

function popup_hh_worstcase_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik popup_hh_worstcase (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Worstcase_Housholds = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren
guidata(hObject, handles);

function popup_pqnode_hh_typ_Callback(hObject, eventdata, handles)
% hObject    handle to popup_pqnode_hh_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function popup_pqnode_pv_typ_Callback(hObject, eventdata, handles)
% hObject    handle to popup_pqnode_pv_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

settin = handles.Current_Settings.Data_Extract.Solar;
row_act = handles.Current_Settings.Table_Network.Selected_Row;
add_data = handles.Current_Settings.Table_Network.Additional_Data;
sel = get(hObject,'Value');
if sel == size(settin.Selectable,1)
	% letzter Eintrag ausgewählt, also muss eine neue Anlage hinzugefügt werden:
	if isstruct(settin.Plants)
		n_pl = numel(fieldnames(settin.Plants));
		name = ['Plant_',num2str(n_pl+1)];
		
	else
		name = 'Plant_1';
	end
	settin.Plants.(name) = handles.System.sola.Default_Plant;
	add_data{row_act,1} = name;
	settin.Selectable{end+1,1} = settin.Selectable{end,1};
	settin.Selectable{end-1,2} = name;
	settin.Plants.(name) = ...
		Configuration_PV_Parameters(handles,'Parameters',settin.Plants.(name));
	settin.Plants.(name).Number = 1;
	typ = handles.System.sola.Typs{settin.Plants.(name).Typ,1};
	long_na = [typ(1:4),' - ',...
		num2str(settin.Plants.(name).Power_Installed),' kWp - ',...
		num2str(settin.Plants.(name).Orientation),'° - ',...
		num2str(settin.Plants.(name).Inclination),'°'];
	settin.Selectable{end-1,1} = long_na;
	handles.Current_Settings.Table_Network.ColumnFormat{4} = settin.Selectable(:,1)';
	handles.Current_Settings.Table_Network.Data{row_act,4} = long_na;
elseif sel == 1
	% keine Anlage mehr ausgewählt, Anlagenanzahl reduzieren:
	name_old = add_data{row_act,2};
	long_na = settin.Selectable{sel,1};
	if ~isempty(name_old)
		% Fall andere Anlagen zuvor angewählt war, deren Anzahl verringern:
		settin.Plants.(name_old).Number = settin.Plants.(name_old).Number - 1;
	end
	add_data{row_act,1} = [];
	handles.Current_Settings.Table_Network.Data{row_act,4} = long_na;
else
	name = settin.Selectable{sel,2};
	long_na = settin.Selectable{sel,1};
	name_old = add_data{row_act,2};
	if ~isempty(name_old)
		% Fall andere Anlagen zuvor angewählt war, deren Anzahl verringern:
		settin.Plants.(name_old).Number = settin.Plants.(name_old).Number - 1;
	end
	% ausgewählte Anlage setzen:
	settin.Plants.(name).Number = settin.Plants.(name).Number + 1;
	add_data{row_act,1} = name;
	handles.Current_Settings.Table_Network.Data{row_act,4} = long_na;
end

handles.Current_Settings.Data_Extract.Solar = settin;
handles.Current_Settings.Table_Network.Additional_Data = add_data;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren
guidata(hObject, handles);


% Hints: contents = cellstr(get(hObject,'String')) returns popup_pqnode_pv_typ contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_pqnode_pv_typ

function popup_time_resolution_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik popup_time_resolution (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Time_Resolution = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_cancel_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_cancel (siehe GCBO)
% eventdata	 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Button wieder deaktivieren:
set(handles.push_cancel, 'Enable', 'off');

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_close_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_close (siehe GCBO)
% eventdata	 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

NAT_main_gui_CloseRequestFcn(hObject, eventdata, handles);

function push_data_show_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_data_show (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

try
	% Daten-Explorer-GUI aufrufen:
	handles = Data_Explorer('NAT_main', handles.NAT_main_gui);
catch ME
	error_titl = 'Anzeigen der Daten...';
	error_text={...
		'Anzeige der Daten ist nicht möglich:';...
		'';...
		ME.message};
	helpdlg(error_text, error_titl);
% 	rethrow(ME);
end

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_load_data_get_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_load_data_get (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

set(handles.push_load_data_get, 'Enable', 'off');
set(handles.push_cancel, 'Enable', 'on');
pause(.01);

% Lastdaten einlesen und in Struktur speichern:
if handles.Current_Settings.Simulation.Use_Scenarios
	handles = get_data_szenarios_load_infeed(handles);
	helpdlg('Daten erfolgreich geladen!', 'Laden der Szenariodaten...');
else
	handles.NAT_Data.Simulation = [];
	handles.NAT_Data.Simulation.Active_Scenario = 1;
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

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
set(handles.push_load_data_get, 'Enable', 'on');
set(handles.push_cancel, 'Enable', 'off');

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_network_analysis_perform_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_analysis_perform (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% handles = network_analysis(handles);
handles = post_analyzing_function_1(handles);

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function push_network_calculation_start_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_calculation_start (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

set(handles.push_network_calculation_start, 'Enable', 'off');
set(handles.push_cancel, 'Enable', 'on');
pause(0.01);

if handles.Current_Settings.Simulation.Use_Scenarios
	handles = network_scenario_calculation(handles);
else
	handles = network_calculation(handles);
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
set(handles.push_cancel, 'Enable', 'off');

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_network_load_allocation_reset_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik  push_network_load_allocation_reset (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Tabelle mit Default-Werten befüllen:
[handles.Current_Settings.Table_Network, ...
    handles.Current_Settings.Data_Extract] = network_table_reset(handles);

% Anzahl der jeweiligen Haushalte ermitteln:
if ~isempty(handles.Current_Settings.Table_Network)
	for i=1:size(handles.System.housholds,1)
		handles.Current_Settings.Data_Extract.Households.(handles.System.housholds{i,1}).Number = ...
			sum(strcmp(handles.System.housholds{i,1},handles.Current_Settings.Table_Network.Data(:,3)));
	end
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_network_load_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_load (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Netzvarianten löschen:
handles.Current_Settings.Simulation.Grid_List = {};
handles.Current_Settings.Simulation.Grids_Path = handles.Current_Settings.Files.Main_Path;

% aktuellen Speicherort für Daten auslesen:
file = handles.Current_Settings.Files.Grid;
% Userabfrage nach Speicherort
[file.Name,file.Path] = uigetfile([...
	{'*.sin','*.sin SINCAL-Netzdatei'};...
	{'*.*','Alle Dateien'}],...
	'Laden von Daten...',...
	[file.Path,filesep]);
% Überprüfen, ob ungültiger Speicherort angegeben wurde:
if isequal(file.Name,0) || isequal(file.Path,0)
	% Falls ja, diese Funktion verlassen:
	% Anzeige des Hauptfensters aktualisieren:
	handles = refresh_display_NAT_main_gui (handles);
	% handles-Struktur aktualisieren:
	guidata(hObject, handles);
	return;
end

% Falls nein, Entfernen der Dateierweiterung vom Dateinamen:
[~, file.Name, file.Exte] = fileparts(file.Name);
% leztes Zeichen ("/") im Pfad entfernen:
file.Path = file.Path(1:end-1);
% Änderungen übernehmen:
handles.Current_Settings.Files.Grid = file;

% Netzdaten laden:
handles = network_load (handles);

% Anzeige des Hauptfensters aktualisieren:
handles = refresh_display_NAT_main_gui (handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function push_network_load_random_allocation_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_load_random_allocation (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Zufällige Zuordnung der Haushalte zu den Anschlusspunkten treffen:
handles = load_random_allocation(handles);

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function push_network_open_Callback(hObject, ~, handles) %#ok<INUSL,DEFNU>
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)
if isfield(handles, 'sin');
	try
	handles.sin.open_application_and_file;
	catch ME
		errordlg(...
			{'Fehler beim Öffnen des Netzes:';' ';ME.message},...
			'Öffnen des akutellen Netzes...');
	end
else
	helpdlg('Kein Netz geladen!','Öffnen des akutellen Netzes...');
end

function push_network_select_scenario_folder_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_select_scenario_folder (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Userabfrage nach neuen Datenbankpfad:
Main_Path = uigetdir(handles.Current_Settings.Simulation.Scenarios_Path,...
	'Auswählen Ordners von Szenariendaten:');
if ischar(Main_Path)
	handles.Current_Settings.Simulation.Scenarios_Path = Main_Path;
	try
		load([Main_Path,'Scenario_Settings.mat']);
		handles.Current_Settings.Simulation.Scenarios = Scenario_Settings;
		handles.Current_Settings.Simulation.Scenarios.Data_avaliable = 1;
	catch ME
		disp('Fehler beim Laden der Szenarioeinstellungen:');
		disp(ME.message);
		handles.Current_Settings.Simulation.Scenarios_Path = handles.Current_Settings.Files.Main_Path;
		handles.Current_Settings.Simulation.Scenarios.Data_avaliable = 0;
	end
else
	handles.Current_Settings.Simulation.Scenarios_Path = handles.Current_Settings.Files.Main_Path;
	handles.Current_Settings.Simulation.Scenarios.Data_avaliable = 0;
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function push_network_select_variant_folder_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_select_variant_folder (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Userabfrage nach neuen Datenbankpfad:
Main_Path = uigetdir(handles.Current_Settings.Simulation.Grids_Path,...
	'Auswählen des Hauptordners einer Datenbank:');
if ischar(Main_Path)
	handles.Current_Settings.Simulation.Grids_Path = Main_Path;
	files = dir(Main_Path);
	files = struct2cell(files);
	files = files(1,3:end);
	files = files(cellfun(@(x) strcmp(x(end-3:end),'.sin'), files));
	% save the present .sin-files for later processing of them:
	handles.Current_Settings.Simulation.Grid_List = files;
	% load the first grid (for getting the primary load-topology):
	handles.Current_Settings.Files.Grid.Path = Main_Path;
	handles.Current_Settings.Files.Grid.Name = files{1}(1:end-4);
	handles.Current_Settings.Files.Grid.Exte = files{1}(end-3:end);
	
	% load the network data:
	handles = network_load (handles);
	
else
	handles.Current_Settings.Simulation.Grid_List = {};
	handles.Current_Settings.Simulation.Grids_Path = handles.Current_Settings.Files.Main_Path;
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function push_network_simulation_settings_Callback(hObject, eventdata, handles)
% hObject    handle to push_network_simulation_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

function push_set_path_database_Callback(hObject, ~, handles)  %#ok<DEFNU>
% hObject    Link zur Grafik push_set_path_database (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% alte Datenbankeinstellungen entfernen:
if isfield(handles.Current_Settings.Load_Database,'setti')
	handles.Current_Settings.Load_Database = rmfield(...
		handles.Current_Settings.Load_Database,'setti');
end
if isfield(handles.Current_Settings.Load_Database,'files')
	handles.Current_Settings.Load_Database = rmfield(...
		handles.Current_Settings.Load_Database,'files');
end

% Userabfrage nach neuen Datenbankpfad:
Main_Path = uigetdir(handles.Current_Settings.Load_Database.Path,...
	'Auswählen des Hauptordners einer Datenbank:');
if ischar(Main_Path)
	[pathstr, name] = fileparts(Main_Path);
	% Die Einstellungen übernehmen:
	handles.Current_Settings.Load_Database.Path = pathstr;
	handles.Current_Settings.Load_Database.Name = name;
	% Laden der Datenbankeinstellungen:
	try
		load([pathstr,filesep,name,filesep,name,'.mat']);
		handles.Current_Settings.Load_Database.setti = setti;
		handles.Current_Settings.Load_Database.files = files;
		helpdlg('Datenbank erfolgreich geladen!', 'Laden der Datenbank...');
	catch ME %#ok<NASGU>
		% Falls keine gültige Datenbank geladen werden konnte, Fehlermeldung an User:
		errordlg('Am angegebenen Pfad wurde keine gültige Datenbank gefunden!',...
			'Fehler beim laden der Datenbank...');
		% Anzeige aktualisieren:
		handles = refresh_display(handles);
	end
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_time_series_settings_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_1 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles = Configuration_Time_Series_Parameters('NAT_main', ...
	 handles.NAT_main_gui);
 
% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_season_1_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_1 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Season = logical([1 0 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_season_2_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_2 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Season = logical([0 1 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_season_3_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_3 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Season = logical([0 0 1]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_weekday_1_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_weekday_1 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Weekday = logical([1 0 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_weekday_2_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_weekday_2 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Weekday = logical([0 1 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_weekday_3_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_weekday_3 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Weekday = logical([0 0 1]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function table_data_network_CellSelectionCallback(hObject, eventdata, handles) %#ok<DEFNU>
% --- Wird ausgeführt, wenn die Auswahl von Zellen in table_data_network verändert
%     werden.
% hObject    Link zur Grafik table_data_network (siehe GCBO)
% eventdata  Struktur mit den folgenden Feldern (see UITABLE)
%     Indices: Zeilen- und Spaltenindex der aktuell ausgewählten Zellen
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

if numel(eventdata.Indices) > 0
	handles.Current_Settings.Table_Network.Selected_Row = eventdata.Indices(1);
	
	% das entsprechende Element in SINCAL GUI markieren (falls dieses offen ist):
	handles.sin.gui_select_element(handles.NAT_Data.Grid.(handles.sin.Settings.Grid_name).P_Q_Node.ids(eventdata.Indices(1)));
else
	handles.Current_Settings.Table_Network.Selected_Row = [];
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function table_data_network_CellEditCallback(hObject, eventdata, handles) %#ok<DEFNU>
% --- Wird ausgeführt, wenn die Daten in table_data_network verändert werden
% hObject    Link zur Grafik table_data_network (siehe GCBO)
% eventdata  Struktur mit den folgenden Feldern (see UITABLE)
%     Indices: Zeilen- und Spaltenindex der aktuell geänderten Zellen
%	  PreviousData: Daten der Zellen vor der Änderung
%	  EditData: String(s), durch den Nutzer eingegeben
%	  NewData: EditData oder die daraus konvertierten Daten gemäß den
%	      Spalten-Eigenschaften. Leer, wenn nichts eingegeben wurde...
%	  Error: Error-String, falls die Konversion von EditData zu einen passenden
%	      Format von Data nicht möglich war.
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Wo wurde was geändert?
row_act = eventdata.Indices(1);
col = eventdata.Indices(2);
% Daten aktualisieren:
handles.Current_Settings.Table_Network.Data = ...
	get(handles.table_data_network, 'Data');

% Falls in der dritten Spalte etwas geändert wurde, sind Änderungen bei den
% Solaranlagen vorgenommen worden:
if col == 3
	settin = handles.Current_Settings.Data_Extract.Solar;
	add_data = handles.Current_Settings.Table_Network.Additional_Data;
	
	sel = find(strcmp(handles.Current_Settings.Table_Network.Data{row_act,col}, ...
		settin.Selectable(:,1)));
	
	if sel == size(settin.Selectable,1)
		% letzter Eintrag ausgewählt, also muss eine neue Anlage hinzugefügt werden:
		if isstruct(settin.Plants)
			n_pl = numel(fieldnames(settin.Plants));
			name = ['Plant_',num2str(n_pl+1)];
		else
			name = 'Plant_1';
		end
		settin.Plants.(name) = handles.System.sola.Default_Plant;
		add_data{row_act,1} = name;
		settin.Selectable{end+1,1} = settin.Selectable{end,1};
		settin.Selectable{end-1,2} = name;
		settin.Plants.(name) = ...
			Configuration_PV_Parameters(handles,'Parameters',settin.Plants.(name));
		settin.Plants.(name).Number = 1;
		typ = handles.System.sola.Typs{settin.Plants.(name).Typ,1};
		long_na = [typ(1:4),' - ',...
			num2str(settin.Plants.(name).Power_Installed),' kWp - ',...
			num2str(settin.Plants.(name).Orientation),'° - ',...
			num2str(settin.Plants.(name).Inclination),'°'];
		settin.Selectable{end-1,1} = long_na;
		handles.Current_Settings.Table_Network.ColumnFormat{4} = settin.Selectable(:,1)';
		handles.Current_Settings.Table_Network.Data{row_act,4} = long_na;
	elseif sel == 1
		% keine Anlage mehr ausgewählt, Anlagenanzahl reduzieren:
		name_old = add_data{row_act,2};
		long_na = settin.Selectable{sel,1};
		if ~isempty(name_old)
			% Fall andere Anlagen zuvor angewählt war, deren Anzahl verringern:
			settin.Plants.(name_old).Number = settin.Plants.(name_old).Number - 1;
		end
		add_data{row_act,1} = [];
		handles.Current_Settings.Table_Network.Data{row_act,4} = long_na;
	else
		name = settin.Selectable{sel,2};
		long_na = settin.Selectable{sel,1};
		name_old = add_data{row_act,2};
		if ~isempty(name_old)
			% Fall andere Anlagen zuvor angewählt war, deren Anzahl verringern:
			settin.Plants.(name_old).Number = settin.Plants.(name_old).Number - 1;
		end
		% ausgewählte Anlage setzen:
		settin.Plants.(name).Number = settin.Plants.(name).Number + 1;
		add_data{row_act,1} = name;
		handles.Current_Settings.Table_Network.Data{row_act,4} = long_na;
	end
	
	handles.Current_Settings.Data_Extract.Solar = settin;
	handles.Current_Settings.Table_Network.Additional_Data = add_data;
end

handles.Current_Settings.Table_Network.Selected_Row = row_act;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function menue_network_load_Callback(hObject, eventdata, handles)
% hObject    handle to menue_network_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menue_configuration_save_as_Callback(hObject, eventdata, handles)
% hObject    handle to menue_configuration_save_as (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menue_configuration_save_Callback(hObject, eventdata, handles)
% hObject    handle to menue_configuration_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menue_configuration_load_Callback(hObject, eventdata, handles)
% hObject    handle to menue_configuration_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menue_file_mainpath_set_Callback(hObject, eventdata, handles)
% hObject    handle to menue_file_mainpath_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_pqnode_pv_installed_power_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pqnode_pv_installed_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function push_pqnode_pv_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to push_pqnode_pv_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function popup_pqnode_wi_typ_Callback(hObject, eventdata, handles)
% hObject    handle to popup_pqnode_wi_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_pqnode_wi_installed_power_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pqnode_wi_installed_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function push_pqnode_wi_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to push_pqnode_wi_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_network_number_variants_Callback(hObject, eventdata, handles)
% hObject    handle to edit_network_number_variants (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_simulation_number_scenarios_Callback(hObject, eventdata, handles)
% hObject    handle to edit_simulation_number_scenarios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- create-Funktionen (werden unmittelbar vor Sichtbarmachen des GUIs ausgeführt):
function popup_time_resolution_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_time_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_hh_worstcase_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_hh_worstcase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_pqnode_hh_typ_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_pqnode_hh_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_simulation_number_scenarios_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_simulation_number_scenarios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_pqnode_pv_typ_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_pqnode_pv_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_pqnode_pv_installed_power_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_pqnode_pv_installed_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_pqnode_wi_installed_power_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_pqnode_wi_installed_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_gen_worstcase_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_gen_worstcase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_simulation_number_runs_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_simulation_number_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_pqnode_wi_typ_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_pqnode_wi_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_network_number_variants_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_network_number_variants (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_use_variants.


% Hint: get(hObject,'Value') returns toggle state of check_use_variants
