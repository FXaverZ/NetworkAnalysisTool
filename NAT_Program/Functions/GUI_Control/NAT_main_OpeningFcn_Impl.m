function NAT_main_OpeningFcn_Impl(hObject, handles, varargin)
% Funktion wird vor Sichtbarwerden des Hauptfensters ausgeführt:
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)
% varargin   Übergabevariablen an NAT (see VARARGIN)

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
handles = get_default_values_NAT(handles);
% Load the Szenarios:
handles = get_scenarios(handles);
% create NAT_Data object, which is an instance of the NAT_Data-Class:
handles.NAT_Data = NAT_Data();

% Set up of info box message handler
Logname = [datestr(now, 'yyyy-mm-dd_HH-MM-SS'),'_',...
	handles.Current_Settings.Files.Save.Log.Name,...
	handles.Current_Settings.Files.Save.Log.Exte];
if ~isdir(handles.Current_Settings.Files.Save.Log.Path)
	mkdir(handles.Current_Settings.Files.Save.Log.Path)
end
handles.text_message_main_handler = ...
	MESSAGE_text_handler(handles.static_text_NAT_status ,...
	'OutputFile',[handles.Current_Settings.Files.Save.Log.Path,filesep,Logname],...
	'OutputToConsole', true);

handles.text_message_main_handler.divider('=-');
handles.text_message_main_handler.add_line('   NAT (Network Analysis Tool) Version ',handles.System.version);
handles.text_message_main_handler.divider('-=');

% GUI-Elemente mit Inhalten füllen:
% Wochentage und Jahreszeiten anpassen:
seas = handles.System.seasons;
week = handles.System.weekdays;
for i=1:3
	set(handles.(['radio_season_',num2str(i)]),'String',seas{i,2});
	set(handles.(['radio_weekday_',num2str(i)]),'String',week{i,2});
end

% Time resolutions:
set(handles.popup_time_resolution, 'String', handles.System.time_resolutions(:,1));
% Worst-Cases:
set(handles.popup_hh_worstcase, 'String', handles.System.wc_households(:,1));
set(handles.popup_gen_worstcase, 'String', handles.System.wc_generation(:,1));

% Versuch, die Einstellungen des letzen Durchlaufs zu laden:
try
	handles.text_message_main_handler.add_line('Try to load last configuration...');
	handles.text_message_main_handler.level_up();
	file = handles.Current_Settings.Files.Last_Conf;
	load('-mat', [file.Path,filesep,file.Name,file.Exte]);
	handles.Current_Settings = Current_Settings;
	handles.System = System;
	handles.text_message_main_handler.add_line('Configuration loaded!');
	if handles.Current_Settings.Load_Database.valid
		handles.text_message_main_handler.add_line('Trying to connect to DLE database:');
		handles.text_message_main_handler.level_up();
		pathstr = handles.Current_Settings.Load_Database.Path;
		name = handles.Current_Settings.Load_Database.Name;
		try
			handles.text_message_main_handler.add_line('Connecting "',...
				handles.Current_Settings.Load_Database.Name,'" from "',...
				handles.Current_Settings.Load_Database.Path,'"');
			load([pathstr,filesep,name,filesep,name,'.mat']);
			handles.Current_Settings.Load_Database.setti = setti;
			handles.Current_Settings.Load_Database.files = files;
			handles.Current_Settings.Load_Database.valid = 1;
			str = 'DLE database successfully connected!';
			handles.text_message_main_handler.add_line(str);
		catch ME %#ok<NASGU>
			% Falls keine gültige Datenbank geladen werden konnte, Fehlermeldung an User:
			errorstr = 'At the given path was no vaild DLE database found!';
			handles.text_message_main_handler.add_line('Error: ', errorstr);
			handles.Current_Settings.Load_Database.valid = 0;
		end
		handles.text_message_main_handler.level_down();
	end
	try
		% Netzdaten laden:
		handles = network_load (handles);
		% Tabelle mit Default-Werten befüllen:
		[handles.Current_Settings.Table_Network, handles.Current_Settings.Data_Extract] = ...
			network_table_reset(handles);
		try
			% Lastdaten laden:
			handles = load_input_last_settings(handles);
		catch ME
			handles.text_message_main_handler.add_line('Error during loading of the current loaddata:');
			handles.text_message_main_handler.add_line(ME.message);
		end
	catch ME
		handles.text_message_main_handler.add_line('Error during loading of the grid:');
		handles.text_message_main_handler.add_line(ME.message);
	end
catch ME
	handles.text_message_main_handler.add_line('Error during loading of last configuration:');
	handles.text_message_main_handler.add_line(ME.message);
end

% Logo anzeigen:
% if strcmpi(getComputerName, 'eeapc14')
logo=imread('Figures\institutslogo.jpg','jpg');   % Einlesen der Grafik
% else
% 	logo=imread('Figures\siemenslogo.jpg','jpg');     % Einlesen der Grafik
% end
image(logo,'Parent',handles.axes_logo);           % Darstellen des Logos
axis image;                                       % Grafik entzerren
axis off;                                         % Achsenbezeichnung ausschalten

% Anzeige des Hauptfensters aktualisieren:
handles = refresh_display_NAT_main_gui (handles);
refresh_message_text_operation_finished (handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

