% NAT_MAIN    Netzanalyse- und Simulationstool, Hauptprogramm 

% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte �nderung durch:   Franz Zeilinger - 05.02.2013

% Last Modified by GUIDE v2.5 08-Mar-2013 16:03:34

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
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_05_Quantile_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_95_quantile_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_95_quantile_value (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_95_Quantile_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_max_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_max_value (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_Max_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_mean_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_mean_value (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_Mean_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_min_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_min_value (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_Min_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_extract_sample_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_extract_sample_value (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.get_Sample_Value = get(hObject, 'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);

function check_get_time_series_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_output_mean_value (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
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

function menue_data_load_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik menue_data_load (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)



% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function menue_data_save_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik menue_data_save (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles = save_simulation_data(handles);

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function menue_file_close_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_close (siehe GCBO)
% eventdata	 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

NAT_main_gui_CloseRequestFcn(hObject, eventdata, handles);

function NAT_main_gui_CloseRequestFcn(hObject, ~, handles) %#ok<INUSL>
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
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
% Funktion wird vor Sichtbarwerden des Hauptfensters ausgef�hrt: 
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)
% varargin   �bergabevariablen an Access_Tool (see VARARGIN)

% Wo ist "NAT_main.m" zu finden?
[~, Source_File] = fileattrib('NAT_main.m');
% Ordner, in dem "NAT_main.m" sich befindet, enth�lt Programm:
if ischar(Source_File)
	fprintf([Source_File,' - Current Directory auf Datei setzen, in der sich ',...
		'''NAT_main.m'' befindet!\n']);
	% Fenster schlie�en:
	delete(handles.NAT_main_gui);
	return;
end
Path = fileparts(Source_File.Name);

% Subfolder in Search-Path aufnehmen (damit alle Funktionen gefunden werden
% k�nnen)
addpath(genpath(Path));
handles.Current_Settings.Files.Main_Path = Path;

% Default-Einstellungen laden
handles = get_default_values(handles);

% GUI-Elemente mit Inhalten f�llen:
% Wochentage und Jahreszeiten anpassen:
seas = handles.System.seasons;
week = handles.System.weekdays;
for i=1:3
	set(handles.(['radio_season_',num2str(i)]),'String',seas{i,2});
	set(handles.(['radio_weekday_',num2str(i)]),'String',week{i,2});
end
% Worst-Cases:
set(handles.popup_hh_worstcase, 'String', handles.System.wc_households);
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

function popup_hh_worstcase_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik popup_hh_worstcase (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
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

function popup_time_resolution_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik popup_time_resolution (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Time_Resolution = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_cancel_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_cancel (siehe GCBO)
% eventdata	 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Button wieder deaktivieren:
set(handles.push_cancel, 'Enable', 'off');

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_close_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_close (siehe GCBO)
% eventdata	 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

NAT_main_gui_CloseRequestFcn(hObject, eventdata, handles);

function push_data_show_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_data_show (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

try
	% Daten-Explorer-GUI aufrufen:
	handles = Data_Explorer('NAT_main', handles.NAT_main_gui);
catch ME
	error_titl = 'Anzeigen der Daten...';
	error_text={...
		'Anzeige der Daten ist nicht m�glich:';...
		'';...
		ME.message};
	helpdlg(error_text, error_titl);
% 	rethrow(ME);
end

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_load_data_get_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_load_data_get (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)


set(handles.push_load_data_get, 'Enable', 'off');
set(handles.push_cancel, 'Enable', 'on');
pause(.01);

% Lastdaten einlesen und in Struktur speichern:
handles = loaddata_get (handles);

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
set(handles.push_cancel, 'Enable', 'off');

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_network_analysis_perform_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_analysis_perform (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles = network_analysis(handles);

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function push_network_calculation_start_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_calculation_start (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

set(handles.push_network_calculation_start, 'Enable', 'off');
set(handles.push_cancel, 'Enable', 'on');
pause(0.01);

handles = network_calculation(handles);

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
set(handles.push_cancel, 'Enable', 'off');

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_network_load_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_load (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% aktuellen Speicherort f�r Daten auslesen:
file = handles.Current_Settings.Files.Grid;
% Userabfrage nach Speicherort
[file.Name,file.Path] = uigetfile([...
	{'*.sin','*.sin SINCAL-Netzdatei'};...
	{'*.*','Alle Dateien'}],...
	'Laden von Daten...',...
	[file.Path,filesep]);
% �berpr�fen, ob ung�ltiger Speicherort angegeben wurde:
if isequal(file.Name,0) || isequal(file.Path,0)
	% Falls ja, diese Funktion verlassen:
	return;
end

% Falls nein, Entfernen der Dateierweiterung vom Dateinamen:
[~, file.Name, file.Exte] = fileparts(file.Name);
% leztes Zeichen ("/") im Pfad entfernen:
file.Path = file.Path(1:end-1);
% �nderungen �bernehmen:
handles.Current_Settings.Files.Grid = file;

% Netzdaten laden:
handles = network_load (handles);

% Anzeige des Hauptfensters aktualisieren:
handles = refresh_display_NAT_main_gui (handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function push_network_load_random_allocation_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_load_random_allocation (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% Zuf�llige Zuordnung der Haushalte zu den Anschlusspunkten treffen:
Table_Data = handles.Current_Settings.Table_Network.Data;
hh_typ_number = size(handles.System.housholds,1);

for i=1:size(Table_Data,1)
	idx = ceil(rand()*hh_typ_number);
	Table_Data{i,3} = handles.System.housholds{idx,1};
end

handles.Current_Settings.Table_Network.Data = Table_Data;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function push_network_open_Callback(hObject, ~, handles) %#ok<INUSL,DEFNU>
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)
if isfield(handles, 'sin');
	try
	handles.sin.open_application_and_file;
	catch ME
		errordlg(...
			{'Fehler beim �ffnen des Netzes:';' ';ME.message},...
			'�ffnen des akutellen Netzes...');
	end
else
	helpdlg('Kein Netz geladen!','�ffnen des akutellen Netzes...');
end

function push_network_simulation_settings_Callback(hObject, eventdata, handles)
% hObject    handle to push_network_simulation_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

function push_set_path_database_Callback(hObject, ~, handles)  %#ok<DEFNU>
% hObject    Link zur Grafik push_set_path_database (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
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
	'Ausw�hlen des Hauptordners einer Datenbank:');
if ischar(Main_Path)
	[pathstr, name] = fileparts(Main_Path);
	% Die Einstellungen �bernehmen:
	handles.Current_Settings.Load_Database.Path = pathstr;
	handles.Current_Settings.Load_Database.Name = name;
	% Laden der Datenbankeinstellungen:
	try
		load([pathstr,filesep,name,filesep,name,'.mat']);
		handles.Current_Settings.Load_Database.setti = setti;
		handles.Current_Settings.Load_Database.files = files;
		helpdlg('Datenbank erfolgreich geladen!', 'Laden der Datenbank...');
	catch ME %#ok<NASGU>
		% Falls keine g�ltige Datenbank geladen werden konnte, Fehlermeldung an User:
		errordlg('Am angegebenen Pfad wurde keine g�ltige Datenbank gefunden!',...
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
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles = Configuration_Time_Series_Parameters('NAT_main', ...
	 handles.NAT_main_gui);
 
% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_season_1_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_1 (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Season = logical([1 0 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_season_2_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_2 (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Season = logical([0 1 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_season_3_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_3 (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Season = logical([0 0 1]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_weekday_1_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_weekday_1 (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Weekday = logical([1 0 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_weekday_2_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_weekday_2 (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Weekday = logical([0 1 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_weekday_3_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_weekday_3 (siehe GCBO)
% ~			 nicht ben�tigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Weekday = logical([0 0 1]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function table_data_network_CellSelectionCallback(hObject, eventdata, handles) %#ok<DEFNU>
% --- Wird ausgef�hrt, wenn die Auswahl von Zellen in table_data_network ver�ndert
%     werden.
% hObject    Link zur Grafik table_data_network (siehe GCBO)
% eventdata  Struktur mit den folgenden Feldern (see UITABLE)
%     Indices: Zeilen- und Spaltenindex der aktuell ausgew�hlten Zellen
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

if numel(eventdata.Indices) > 0
	handles.Current_Settings.Table_Network.Selected_Row = eventdata.Indices(1);
	
	% das entsprechende Element in SINCAL GUI markieren (falls dieses offen ist):
	handles.sin.gui_select_element(handles.Grid.P_Q_Node.ids(eventdata.Indices(1)));
else
	handles.Current_Settings.Table_Network.Selected_Row = [];
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function table_data_network_CellEditCallback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Wird ausgef�hrt, wenn die Daten in table_data_network ver�ndert werden
% hObject    Link zur Grafik table_data_network (siehe GCBO)
% eventdata  Struktur mit den folgenden Feldern (see UITABLE)
%     Indices: Zeilen- und Spaltenindex der aktuell ge�nderten Zellen
%	  PreviousData: Daten der Zellen vor der �nderung
%	  EditData: String(s), durch den Nutzer eingegeben
%	  NewData: EditData oder die daraus konvertierten Daten gem�� den
%	      Spalten-Eigenschaften. Leer, wenn nichts eingegeben wurde...
%	  Error: Error-String, falls die Konversion von EditData zu einen passenden
%	      Format von Data nicht m�glich war.
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Table_Network.Data = ...
	get(handles.table_data_network, 'Data');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

% --------------------------------------------------------------------
function menue_network_load_Callback(hObject, eventdata, handles)
% hObject    handle to menue_network_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menue_configuration_save_as_Callback(hObject, eventdata, handles)
% hObject    handle to menue_configuration_save_as (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menue_configuration_save_Callback(hObject, eventdata, handles)
% hObject    handle to menue_configuration_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menue_configuration_load_Callback(hObject, eventdata, handles)
% hObject    handle to menue_configuration_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menue_file_mainpath_set_Callback(hObject, eventdata, handles)
% hObject    handle to menue_file_mainpath_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- create-Funktionen (werden unmittelbar vor Sichtbarmachen des GUIs ausgef�hrt):
function popup_time_resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_time_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_hh_worstcase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_hh_worstcase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_pqnode_hh_typ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_pqnode_hh_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



