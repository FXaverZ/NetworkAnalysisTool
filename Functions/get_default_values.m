function handles = get_default_values(handles)
%GET_DEFAULT_VALUES Summary of this function goes here
%   Detailed explanation goes here

%------------------------------------------------------------------------------------
% System-Werte - sollten sich w�hrend der Systemlaufzeit nicht �ndern!
%------------------------------------------------------------------------------------
System.Version = '1.0';

% Standardbezeichnungen:
System.seasons =   {... % Typen der Jahreszeiten
	'Summer', 'Sommer';... 
	'Transi', '�bergang';...
	'Winter', 'Winter';...
	}; 
System.weekdays =  {... % Typen der Wochentage
	'Workda', 'Werktag';...
	'Saturd', 'Samstag';...
	'Sunday', 'Sonntag';...
	};  
System.housholds = {... % Definition der Haushaltskategorien:
% 	'fami_rt', 'Familie mit Pensionist(en)'    ;...
% 	'sing_vt', 'Single Vollzeit'               ;... 
% 	'coup_vt', 'Paar Vollzeit'                 ;... 
% 	'sing_pt', 'Single Teilzeit'               ;... 
%  	'coup_pt', 'Paar Teilzeit'                 ;... 
% 	'sing_rt', 'Single Pension'                ;... 
% 	'coup_rt', 'Paar Pension'                  ;... 
% 	'fami_2v', 'Familie, 2 Mitglieder Vollzeit';...    
% 	'fami_1v', 'Familie, 1 Mitglied Vollzeit'  ;... 
	'home_1',  'Haus - 1 Bewohner'            ;...
	'home_2',  'Haus - 2 Bewohner'            ;...
	'home_3',  'Haus - 3 Bewohner'            ;...
	'hom_4p',  'Haus - 4 und mehr Bewohner'   ;...
	'flat_1',  'Wohnung - 1 Bewohner'         ;...
	'flat_2',  'Wohnung - 2 Bewohner'         ;...
	'flat_3',  'Wohnung - 3 Bewohner'         ;...
	'fla_4p',  'Wohnung - 4 und mehr Bewohner';...
	};

% m�gliche Zeitaufl�sungen:
System.time_resolutions = {...
	'sec - Sekunden',     1;...
	'min - Minuten',     60;...
	'5mi - 5 Minuten',  300;...
	'quh - 15 Minuten', 900;...
	};

% Definition der verschiedenen "Worst Cases":
System.wc_households = {...
	'Kein';...
	'H�chster Energieverbrauch';...
	'Niedrigster Energieverbrauch';...
	'H�chste Leistungsaufnahme';...
	};

handles.System = System; 

%------------------------------------------------------------------------------------
% Default-Einstellungen herstellen sowie Einstellungsstruktur generieren: 
%------------------------------------------------------------------------------------
Current_Settings = handles.Current_Settings;
Files = Current_Settings.Files;

% automatisch erzeugte Konfigurationsdatei (merken der letzten Einstellungen):
Files.Last_Conf.Path = Files.Main_Path;
Files.Last_Conf.Name = 'Einstellungen';
Files.Last_Conf.Exte = '.cfg';

% Daten (Pfad des .sin-Files und Name) des zu betrachtetenden Netzes:
Files.Grid.Path = Files.Main_Path;
Files.Grid.Name = [];
Files.Grid.Exte = '.sin';

% Speicherpfad f�r Daten
if ~isdir([Files.Main_Path,filesep,'Ergebnisse'])
	mkdir([Files.Main_Path,filesep,'Ergebnisse']);
end
Files.Save.Result.Path = [Files.Main_Path,filesep,'Ergebnisse'];
Files.Save.Result.Name = 'Daten';
Files.Save.Result.Exte = '.mat';

% Name der automaisch gespeicherten Lastdaten (Pfad ist immer der Ordner des
% jeweiligen Netzes): 
Files.Auto_Load_Feed_Data.Name = 'act_Load_Feed_Data';
Files.Auto_Load_Feed_Data.Exte = '.mat';

Current_Settings.Files = Files;

% Definieren der Simulations-Parameter:
Current_Settings.Simulation.Parameters = {...
	'Calculation_method', 'LF_USYM',...  % Unsymmetrischer Lastfluss
	'Batch_mode',          4,...         % Laden aus reeller in virt. Datenbank, Speichern in virtuelle Datenbank
	'Database_typ',       'DB_EL',...    % Datenbanktyp "elektrisches Netz"
	'Language',           'DE',...       % Ausgabe der Meldungen in Deutsch 
	};

% Defaultwerte der Datenbehandlungseinstellungen (Auslesen & Speichern):
data_settings.Time_Resolution = 1;    % zeitliche Aufl�sung
data_settings.get_Sample_Value = 1;   % Sample-Werte ermitteln bzw. speichern.
data_settings.get_Mean_Value = 0;     % Mittelwerte ermitteln bzw. speichern.
data_settings.get_Min_Value = 0;      % Minimalwerte ermitteln bzw. speichern.
data_settings.get_Max_Value = 0;      % Maximalwerte ermitteln bzw. speichern.
data_settings.get_95_Quantile_Value = 0; % Ermitteln des 95%-Quantils
data_settings.get_05_Quantile_Value = 0; % Ermitteln des 5%-Quantils
% Einstellungen f�r Datenauslesen:
Current_Settings.Data_Extract = data_settings;
% Soll eine Zeitreihe erstellt werden?
Current_Settings.Data_Extract.get_Time_Series = 0;
% Einstellungen der Zeitreihe
Time_Series.Date_Start = '27.04.2012'; % Startdatum der Zeitreihe
Time_Series.Duration = 7;              % Dauer der Zeitreihe in Tagen
Current_Settings.Data_Extract.Time_Series = Time_Series;
% Jahreszeiten setzen:
Current_Settings.Data_Extract.Season =  logical([1 0 0]');
Current_Settings.Data_Extract.Weekday = logical([1 0 0]');
% Anzahl der Haushalte Null setzen:
for i=1:size(System.housholds,1)
	Current_Settings.Data_Extract.Households.(System.housholds{i,1}).Number = 0;
end
% Aktueller Worstcase f�r Haushalte. M�glichkeiten siehe
% HANDLES.SYSTEM.WC_HOUSEHOLDS.
Current_Settings.Data_Extract.Worstcase_Housholds = 1; % Default = 'Kein'


% Standard-Dateipfade, Pfad zur Datenbank:
Current_Settings.Load_Database.Path = Current_Settings.Files.Main_Path;
Current_Settings.Load_Database.Name = 'DLE_Datenbank';

% Einstellungstabelle f�r das Netz (wird in GUI angezeigt)
Current_Settings.Table_Network = [];

handles.Current_Settings = Current_Settings;

end
