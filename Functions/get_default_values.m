function handles = get_default_values(handles)
%GET_DEFAULT_VALUES Summary of this function goes here
%   Detailed explanation goes here

% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 12.04.2013

%------------------------------------------------------------------------------------
% System-Werte - sollten sich während der Systemlaufzeit nicht ändern!
%------------------------------------------------------------------------------------
System.Version = '4.0';

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
System.wc_generation = {...
	'Kein';...
	'Höchste Tageseinspeisung';...
	'Niedrigste Tageseinspeisung';...
% 	'Höchste Leistung';...
	};

% Definition der Erzeugungs-Anlagenarten:
System.sola.Typs = {...
	'Fix montiert';...
	'Tracker';...
	};
System.sola.Selectable = {...
	'Keine Anlage ausgewählt'  ,[];...
	'Neue Anlage hinzufügen...',[];...
	};
% Default Werte (alle Anlagen aus, Standardwerte) für PV-Anlagen:
Default_Plant.Typ = 1;                  % Typ der Anlage (siehe 
%                                             HANDLES.SYSTEM.SOLA.TYPS)
Default_Plant.Number = 0;               % Anzahl Anlagen           [-]
Default_Plant.Power_Installed = 0;      % Installierte Leistung    [kW]
Default_Plant.Orientation = 0;          % Ausrichtung              [°]
Default_Plant.Inclination = 30;         % Neigung                  [°]
Default_Plant.Efficiency = 0.17;        % Wirkungsgrad Zelle + WR  [-]
Default_Plant.Rel_Size_Collector = 6.5; % Rel. Kollektorfläche     [m²/kWp]
Default_Plant.Size_Collector = ...      % Kollektorfläche          [m²]
	Default_Plant.Power_Installed * Default_Plant.Rel_Size_Collector;
Default_Plant.Sigma_delay_time = 15;    % zeitl. Standardabweichung[s] 
% Zwei Anlagen werden per Default angeboten:
System.sola.Default_Plant = Default_Plant;
clear('Default_Plant');

% Name der verfügbaren Windkraft-Anlagen auslesen:
System.wind.Typs = get_wind_turbine_parameters('typs');
System.wind.Selectable = System.sola.Selectable;
% Defaultwerte für Windkraftanlagen:
Default_Plant.Typ =             1;      % Anlagen-Typ, 1 = "keine Anlage"
Default_Plant.Number =          0;      % Anzahl der Anlagen               [-]
Default_Plant.Power_Installed = 0;      % Nennleistung der Anlage          [W]
Default_Plant.Rho =         1.225;      % Luftdichte                       [kg/m³]
Default_Plant.v_nominal =      11;      % Windgeschwindigkeit bei der Nennleistung
%                                             verfügbar ist                [m/s]
Default_Plant.Efficiency =   0.98;      % Wirkungsgrad des Wechselrichters [-]
Default_Plant.v_start =       0.8;      % Anlaufwindgeschwindigkeit        [m/s]
Default_Plant.v_cut_off =      15;      % Abschaltwindgeschwindigkeit      [m/s]
Default_Plant.Size_Rotor =    2.5;      % Rotordurchmesser                 [m]
Default_Plant.Typ_Rotor =  'n.d.';      % Art des Rotors
Default_Plant.Inertia =      20.0;      % Trägheit des Windrads            [s]
Default_Plant.c_p =            [];      % Tabelle mit Leistungsbeiwerten bei
%                                             bestimmten Windgeschwindigkeiten (kommt 
%                                             aus Anlagenparameterdatei
%                                             "get_wind_turbine_parameters").
Default_Plant.Sigma_delay_time = 15;    % zeitl. Standardabweichung        [s] 
System.wind.Default_Plant = Default_Plant;

% Systemeinstellungen speichern
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

% Speicherpfad für Daten
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
% Anzahl der durchzuführenden Einzelsimulationen (wieviele unterschiedliche
% Input-Datensätze sollen aus der Datenbank geladen werden?)
Current_Settings.Simulation.Number_Runs = 10;
% Welche verschiedenen Netze sollen simuliert werden. ACHTUNG: diese
% sollten in ihrer Grundstruktur gleich sein: d.h. z.B. gleiche Anzahl an
% Last- und Einspeisepunkten, da diese mit den Eingangsdaten übereinstimmen
% müssen!
Current_Settings.Simulation.Grid_List = {};

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
Current_Settings.Data_Extract.Season =  logical([1 0 0]');
Current_Settings.Data_Extract.Weekday = logical([1 0 0]');
% Anzahl der Haushalte Null setzen:
for i=1:size(System.housholds,1)
	Current_Settings.Data_Extract.Households.(System.housholds{i,1}).Number = 0;
end
% Aktueller Worstcase für Haushalte. Möglichkeiten siehe
% HANDLES.SYSTEM.WC_HOUSEHOLDS.
Current_Settings.Data_Extract.Worstcase_Housholds = 1; % Default = 'Kein'
Current_Settings.Data_Extract.Worstcase_Generation = 1;
% Erzeugungsanlagen:
Current_Settings.Data_Extract.Solar.Selectable = System.sola.Selectable;
Current_Settings.Data_Extract.Wind.Selectable = System.wind.Selectable;


% Standard-Dateipfade, Pfad zur Datenbank:
Current_Settings.Load_Database.Path = Current_Settings.Files.Main_Path;
Current_Settings.Load_Database.Name = 'DLE_Datenbank';

% Einstellungstabelle für das Netz (wird in GUI angezeigt)
Current_Settings.Table_Network = [];

handles.Current_Settings = Current_Settings;

end

