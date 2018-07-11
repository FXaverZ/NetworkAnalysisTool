function NAT_main_OpeningFcn_Impl(hObject, handles, varargin)

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
	MESSAGE_text_handler(...
	handles.static_text_NAT_status ,...
	'OutputFile'     ,[handles.Current_Settings.Files.Save.Log.Path,filesep,Logname],...
	'OutputToConsole', true);
handles.cancel_button_main_handler = ...
	CANCEL_button_handler(handles.push_cancel);
handles.waitbar_main_handler = ...
	WAITBAR_handler(handles.waitbar_white, handles.waitbar_color,handles.waitbar_text);
handles.waitbar_main_handler.reset();

mh = handles.text_message_main_handler;
mh.divider('=-');
mh.add_line('   NAT (Network Analysis Tool) Version ',handles.System.version);
mh.divider('-=');

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

mh.add_line('Starting up NAT...');
mh.level_up();

% Versuch, die Einstellungen des letzen Durchlaufs zu laden:
try
	mh.add_line('Try to load last configuration...');
	file = handles.Current_Settings.Files.Last_Conf;
	load('-mat', [file.Path,filesep,file.Name,file.Exte]);
	handles.Current_Settings = Current_Settings;
	handles.System = System;
	mh.add_line('... Configuration loaded!');
	if handles.Current_Settings.Load_Database.valid
		mh.add_line('Try to connect to DLE database...');
		mh.level_up();
		pathstr = handles.Current_Settings.Load_Database.Path;
		name = handles.Current_Settings.Load_Database.Name;
		try
			mh.add_line('Connecting "',...
				handles.Current_Settings.Load_Database.Name,'" from "',...
				handles.Current_Settings.Load_Database.Path,'"');
			load([pathstr,filesep,name,filesep,name,'.mat']);
			handles.Current_Settings.Load_Database.setti = setti;
			handles.Current_Settings.Load_Database.files = files;
			handles.Current_Settings.Load_Database.valid = 1;
			mh.level_down();
			mh.add_line('... DLE database successfully connected!');
		catch ME %#ok<NASGU>
			% Falls keine gültige Datenbank geladen werden konnte, Fehlermeldung an User:
			mh.add_error('At the given path was no vaild DLE database found!');
			handles.Current_Settings.Load_Database.valid = 0;
			mh.level_down();
		end
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
			mh.add_error(ME.message);
			mh.level_down();
		end
	catch ME
		mh.add_error(ME.message);
		mh.level_down();
	end
catch ME
	mh.add_error(ME.message);
	mh.level_down();
end
mh.level_down();

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

mh.level_down();
mh.add_line('... NAT succesfully started!');
refresh_message_text_operation_finished (handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

