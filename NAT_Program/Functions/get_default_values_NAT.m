function handles = get_default_values_NAT(handles)
%GET_DEFAULT_VALUES   loads the default values for all setting for the NAT
%   Detailed explanation goes here

% Version:                 4.3
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 11.11.2013

%------------------------------------------------------------------------------------
% System-Werte - sollten sich während der Systemlaufzeit nicht ändern!
%------------------------------------------------------------------------------------

% Current version of the NAT
System.version = '4.3';

% maximum number of a whole dataset, if this number is exceeded, partial
% files are created: 
System.number_max_datasets = 200;

% reset of RPC-server (SINCAL-connection) after this number of profiles (due to problems
% with a permanently open connection with the RPC-Server. After the this number of
% profiles is simulated, the SINCAL-connection is rebuild...)
System.number_max_profiles_simulated = 50;

% Standardbezeichnungen:
System.seasons =   {... % Typen der Jahreszeiten
	'Summer', 'Summer';... 
	'Transi', 'Transition';...
	'Winter', 'Winter';...
	}; 
System.weekdays =  {... % Typen der Wochentage
	'Workda', 'Workday';...
	'Saturd', 'Saturday';...
	'Sunday', 'Sunday';...
	};  
System.housholds = {... % Definition der Haushaltskategorien:
	'sing_vt', 'Single Vollzeit'               ,  4.91;... 
	'coup_vt', 'Paar Vollzeit'                 ,  6.71;... 
	'sing_pt', 'Single Teilzeit'               ,  0.86;... 
 	'coup_pt', 'Paar Teilzeit'                 ,  0.29;... 
	'sing_rt', 'Single Pension'                ,  7.70;... 
	'coup_rt', 'Paar Pension'                  , 27.45;... 
	'fami_2v', 'Familie, 2 Mitglieder Vollzeit', 10.67;...    
	'fami_1v', 'Familie, 1 Mitglied Vollzeit'  , 21.48;... 
	'fami_rt', 'Familie mit Pensionist(en)'    ,  9.97;...
% 	'home_1',  'Haus - 1 Bewohner'            ;...
% 	'home_2',  'Haus - 2 Bewohner'            ;...
% 	'home_3',  'Haus - 3 Bewohner'            ;...
% 	'hom_4p',  'Haus - 4 und mehr Bewohner'   ;...
% 	'flat_1',  'Wohnung - 1 Bewohner'         ;...
% 	'flat_2',  'Wohnung - 2 Bewohner'         ;...
% 	'flat_3',  'Wohnung - 3 Bewohner'         ;...
% 	'fla_4p',  'Wohnung - 4 und mehr Bewohner';...
	};

% mögliche Zeitauflösungen:
System.time_resolutions = {...
	'sec - Seconds',     1;...
	'min - Minutes',     60;...
	'5mi - 5 Minutes',  300;...
	'10m - 10 Minutes', 600;...
	'quh - 15 Minutes', 900;...
	};

% Definition der verschiedenen "Worst Cases":
System.wc_households = {...
	'None',                             'none_';...
	'Highest Energyconsumption',        'E_max';...
	'Lowest Energyconsumption',         'E_min';...
	'Highest Powerconsumption',         'P_max';...
	'0.0-0.25 Share Energyconsumption', 'E_025';...
	'0.25-0.5 Share Energyconsumption', 'E_050';...
	'0.5-0.75 Share Energyconsumption', 'E_075';...
	'0.75-1.0 Share Energyconsumption', 'E_100';...
	'DEBUG',                            'debug';...
	};
System.wc_generation = {...
	'None';...
	'Highest Energyinfeed';...
	'Lowest Energyinfeed';...
% 	'Höchste Leistung';...
	};

% Definition der Erzeugungs-Anlagenarten:
System.sola.Typs = {...
	'Fix mounted';...
	'Tracker';...
	};
% Default list with allready available solar plants for fast selection
System.sola.Selectable = {...
	'No plant selected'  ,[];...
	'Add new plant...'   ,[];...
	};

% Default Werte (alle Anlagen aus, Standardwerte) für PV-Anlagen:
Default_Plant.Typ = 1;                  % Typ der Anlage (siehe 
%                                             HANDLES.SYSTEM.SOLA.TYPS)
Default_Plant.Number = 0;               % Anzahl Anlagen           [-]
Default_Plant.Power_Installed = 0;      % Installierte Leistung    [W]
Default_Plant.Orientation = 0;          % Ausrichtung              [°]
Default_Plant.Inclination = 30;         % Neigung                  [°]
Default_Plant.Efficiency = 0.12;        % Wirkungsgrad Zelle + WR  [-]
Default_Plant.Performance_Ratio = 0.62; % Betriebsbedingungen der Photovoltaikanlage [-]
Default_Plant.Rel_Size_Collector = 0.01;% Rel. Kollektorfläche     [m²/Wp]
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

% Define a default scenario:
Scenario.Description = ...
	'Default settings for random allocation';
Scenario.Filename = '01_Default_Settings';
Scenario.Data_is_divided = 0;   % indicates, if file-parts are presten (=1) or not (=0)
Scenario.Data_number_parts = 1; % number of file-parts for the scenariodata (only valid, when ...Scenario.Data_is_divided = 1)
Solar.Number = [50, 0];         % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 5000;         % mittlere Leistung der Anlagen [Wp]
Solar.Power_sgl_dev = 10;       % Standardabweichung der Anlagenleistung [% vom Mittelwert]
Solar.mean_Orientation = 0;     % mittlere Ausrichtung der Anlagen [°] (0° = Süd; -90° = Ost)
Solar.dev_Orientation = 5;      % Standardabweichung der Ausrichtung [°]
Solar.mean_Inclination = 30;    % mittlere Neigung der Anlagen [°] (0° = Waagrecht; 90° = Senkrecht)
Solar.dev_Inclination = 5;      % Standardabweichung der Neigung [°]
Solar.Performance_Ratio = 0.62; % mittlere Betriebsbedingungen der Photovoltaikanlage [-]
Solar.dev_Performance_Ratio = 5;% Standardabweichung der Betriebsbedingungen [% vom Mittelwert]
Solar.Efficiency = 0.12;        % mittlerer Wirkungsgrad Zelle + WR [-]
Solar.dev_Efficiency = 5;       % Standardabweichung des Wirkungsgrad [% vom Mittelwert]
Solar.WC_Selection = 'none_';
Scenario.Solar = Solar;
Scenario.Households.WC_Selection = 'none_';   
Scenario.El_Mobility.Number = 50; % Prozent-Anteil an Elektroautos in den Haushalten

System.default_scenario = Scenario;

% Default settings of the tables in the main GUI (for different grid-types)
% Settings for LV-Grids
System.table_settings.lv.ColumnName = {'Names', 'Active', 'Housh.type', 'PV-Plant', 'El. Mob.'};
% 'Names' = Name of the PQ-Node (Connection Point)
% 'Active' = is this node active (if not
System.table_settings.lv.ColumnFormat = {...
	'char', ...
	'logical', ...
	System.housholds(:,1)', ...
    System.sola.Selectable(:,1)',...
    'numeric'};
System.table_settings.lv.ColumnEditable = [false, true, true, true, true];
% Content of the additional data array
System.table_settings.lv.Additional_Data_Content = {'PV_Plant_Name', 'Wind_Plant_Name'};

% Systemeinstellungen speichern
handles.System = System; 

%------------------------------------------------------------------------------------
% Default-Einstellungen herstellen sowie Einstellungsstruktur generieren: 
%------------------------------------------------------------------------------------
Current_Settings = handles.Current_Settings;
Files = Current_Settings.Files;

% automatisch erzeugte Konfigurationsdatei (merken der letzten Einstellungen):
Files.Last_Conf.Path = Files.Main_Path;
Files.Last_Conf.Name = 'Settings';
Files.Last_Conf.Exte = '.cfg';

% Daten (Pfad des .sin-Files und Name) des zu betrachtetenden Netzes:
Files.Grid.Path = Files.Main_Path;
Files.Grid.Name = [];
Files.Grid.Exte = '.sin';

% Speicherpfad für Daten
if ~isdir([Files.Main_Path,filesep,'Results'])
	mkdir([Files.Main_Path,filesep,'Results']);
end
Files.Save.Result.Path = [Files.Main_Path,filesep,'Results'];
Files.Save.Result.Name = 'Data';
Files.Save.Result.Exte = '.mat';

Files.Load.Result.Path = [Files.Main_Path,filesep,'Results'];
Files.Load.Result.Name = 'Res_XXX - information';
Files.Load.Result.Exte = '.mat';

% Name der automaisch gespeicherten Lastdaten (Pfad ist immer der Ordner des
% jeweiligen Netzes): 
Files.Auto_Load_Feed_Data.Name = 'act_Load_Feed_Data';
Files.Auto_Load_Feed_Data.Exte = '.mat';

Current_Settings.Files = Files;

% Defaultwerte der Datenbehandlungseinstellungen (Auslesen & Speichern):
data_settings.Time_Resolution = 1;    % zeitliche Auflösung
data_settings.Timepoints_per_dataset = 1440; % Number of Timepoints per dataset (is 
% depending on handles.Current_Settings.Data_Extract.Time_Resolution and time series 
% settings) 
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
% Anzahl Elektrofahrzeuge Null setzen:
Current_Settings.Data_Extract.El_Mobility.Number = 0;
% Aktueller Worstcase für Haushalte. Möglichkeiten siehe
% HANDLES.SYSTEM.WC_HOUSEHOLDS.
Current_Settings.Data_Extract.Worstcase_Housholds = 1; % Default = 'Kein'
Current_Settings.Data_Extract.Worstcase_Generation = 1;
% Erzeugungsanlagen:
Current_Settings.Data_Extract.Solar.Selectable = System.sola.Selectable;
Current_Settings.Data_Extract.Wind.Selectable = System.wind.Selectable;

Current_Settings.Grid.Type = 'LV';

% Standard-Dateipfade, Pfad zur Datenbank:
Current_Settings.Load_Database.Path = Current_Settings.Files.Main_Path;
Current_Settings.Load_Database.Name = 'DLE_Datenbank';

% Einstellungstabelle für das Netz (wird in GUI angezeigt)
Current_Settings.Table_Network = [];

% Definieren der Simulations-Parameter:
Simulation.Parameters = {...
	'Calculation_method', 'LF_RST',...  % Unsymmetrischer Lastfluss
	'Batch_mode',          4,...         % Laden aus reeller in virt. Datenbank, Speichern in virtuelle Datenbank
	'Database_typ',       'DB_EL',...    % Datenbanktyp "elektrisches Netz"
	'Language',           'DE',...       % Ausgabe der Meldungen in Deutsch 
	};
% Anzahl der durchzuführenden Einzelsimulationen (wieviele unterschiedliche
% Input-Datensätze sollen aus der Datenbank geladen werden?)
Simulation.Number_Runs = 10;
% Welche verschiedenen Netze sollen simuliert werden. ACHTUNG: diese
% sollten in ihrer Grundstruktur gleich sein: d.h. z.B. gleiche Anzahl an
% Last- und Einspeisepunkten, da diese mit den Eingangsdaten übereinstimmen
% müssen!
Simulation.Grid_List = {};
% Should the tool take into account different variants of the grid?
Simulation.Use_Grid_Variants = 0;
% Root path to the folder, in which the single Networks of the grid variants are stored...
Simulation.Grids_Path = Files.Main_Path;
% Should the tool calculate different scenarios (if avaliable)?
Simulation.Use_Scenarios = 0;
Simulation.Scenarios_Path = Files.Main_Path;

Simulation.Voltage_Violation_Analysis = 0; 
% 1 = Voltage violation analysis function is used
% 0 = Voltage violation analysis function is not used
Simulation.Save_Voltage_Results = 0;
% 1 = Save voltage results
% 0 = Do not save voltage results
Simulation.Branch_Violation_Analysis = 0;
% 1 = Branch violation analysis function is used
% 0 = Branch violation analysis function is not used
Simulation.Save_Branch_Results = 0;
% 1 = Save branch results
% 0 = Do not save branch results
Simulation.Power_Loss_Analysis = 0;
% 1 = Power Loss analysis function is used
% 0 = Power Loss analysis function is not used
Simulation.Save_Power_Loss_Results = 0;
% 1 = Power Loss data is saved
% 0 = Power Loss data is not saved
Current_Settings.Simulation = Simulation;

% Anzahl der unterschiedlichen Input-Datensätze (entspricht
% handles.Current_Settings.Simulation.Number_Runs zum Extraktionszeitpunkt):
Current_Settings.Data_Extract.Number_Data_Sets = Simulation.Number_Runs;

handles.Current_Settings = Current_Settings;
end

