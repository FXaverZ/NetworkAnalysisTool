function handles = get_default_values(handles)
%GET_DEFAULT_VALUES Summary of this function goes here
%   Detailed explanation goes here

%------------------------------------------------------------------------------------
% System-Werte - sollten sich während der Systemlaufzeit nicht ändern!
%------------------------------------------------------------------------------------
System.Version = '1.0';

% Standardbezeichnungen:
System.seasons =   {... % Typen der Jahreszeiten
	'Summer', 'Sommer';... 
	'Transi', 'Übergang';...
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

% mögliche Zeitauflösungen:
System.time_resolutions = {...
	'sec - Sekunden',     1;...
	'min - Minuten',     60;...
	'5mi - 5 Minuten',  300;...
	'quh - 15 Minuten', 900;...
	};

% Definition der verschiedenen "Worst Cases":
System.wc_households = {...
	'Kein';...
	'Höchster Energieverbrauch';...
	'Niedrigster Energieverbrauch';...
	'Höchste Leistungsaufnahme';...
	};

handles.System = System; 

%------------------------------------------------------------------------------------
% Default-Einstellungen herstellen sowie Einstellungsstruktur generieren: 
%------------------------------------------------------------------------------------
Current_Settings = handles.Current_Settings;

% Anzahl der Haushalte Null setzen:
for i=1:size(System.housholds,1)
	Current_Settings.Households.(System.housholds{i,1}).Number = 0;
end

% automatisch erzeugte Konfigurationsdatei (merken der letzten Einstellungen):
Current_Settings.Last_Conf.Path = Current_Settings.Main_Path;
Current_Settings.Last_Conf.Name = 'Einstellungen';
Current_Settings.Last_Conf.Exte = '.cfg';

% Daten (Pfad des .sin-Files und Name) des zu betrachtetenden Netzes:
Current_Settings.Grid.Path = Current_Settings.Main_Path;
Current_Settings.Grid.Name = [];
Current_Settings.Grid.Exte = '.sin';

% Speicherpfad für Daten
if ~isdir([Current_Settings.Main_Path,filesep,'Ergebnisse'])
	mkdir([Current_Settings.Main_Path,filesep,'Ergebnisse']);
end
Current_Settings.Save.Result.Path = [Current_Settings.Main_Path,filesep,'Ergebnisse'];
Current_Settings.Save.Result.Name = 'Daten';
Current_Settings.Save.Result.Exte = '.mat';

% Name der automaisch gespeicherten Lastdaten (Pfad ist immer der Ordner des
% jeweiligen Netzes): 
Current_Settings.Auto_Load_Feed_Data.Name = 'act_Load_Feed_Data';
Current_Settings.Auto_Load_Feed_Data.Exte = '.mat';

% Definieren der Simulations-Parameter:
Current_Settings.Simulation.Parameters = {...
	'Calculation_method', 'LF_USYM',...  % Unsymmetrischer Lastfluss
	'Batch_mode',          4,...         % Laden aus reeller in virt. Datenbank, Speichern in virtuelle Datenbank
	'Database_typ',       'DB_EL',...    % Datenbanktyp "elektrisches Netz"
	'Language',           'DE',...       % Ausgabe der Meldungen in Deutsch 
	};

% Defaultwerte der Datenbehandlungseinstellungen (Auslesen & Speichern):
data_settings.Time_Resolution = 1;    % zeitliche Auflösung
data_settings.get_Sample_Value = 1;   % Sample-Werte ermitteln bzw. speichern.
data_settings.get_Mean_Value = 0;     % Mittelwerte ermitteln bzw. speichern.
data_settings.get_Min_Value = 0;      % Minimalwerte ermitteln bzw. speichern.
data_settings.get_Max_Value = 0;      % Maximalwerte ermitteln bzw. speichern.
data_settings.get_95_Quantile_Value = 0; % Ermitteln des 95%-Quantils
data_settings.get_05_Quantile_Value = 0; % Ermitteln des 5%-Quantils
% Einstellungen für Datenauslesen:
Current_Settings.Data_Extract = data_settings;
% Soll eine Zeitreihe erstellt werden?
Current_Settings.Data_Extract.get_Time_Series = 0;
% Einstellungen der Zeitreihe
Time_Series.Date_Start = '27.04.2012'; % Startdatum der Zeitreihe
Time_Series.Duration = 7;              % Dauer der Zeitreihe in Tagen
Current_Settings.Data_Extract.Time_Series = Time_Series;

% Jahreszeiten setzen:
Current_Settings.Season =  logical([1 0 0]');
Current_Settings.Weekday = logical([1 0 0]');

% Standard-Dateipfade, Pfad zur Datenbank:
Current_Settings.Load_Database.Path = Current_Settings.Main_Path;
Current_Settings.Load_Database.Name = 'DLE_Datenbank';

% Einstellungstabelle für das Netz (wird in GUI angezeigt)
Current_Settings.Table_Network = [];

% Aktueller Worstcase für Haushalte. Möglichkeiten siehe
% HANDLES.SYSTEM.WC_HOUSEHOLDS.
Current_Settings.Worstcase_Housholds = 1; % Default = 'Kein'

handles.Current_Settings = Current_Settings;

end

