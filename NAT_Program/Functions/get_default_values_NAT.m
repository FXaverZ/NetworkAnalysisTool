function handles = get_default_values_NAT(handles)
%GET_DEFAULT_VALUES_NAT   loads the default values for all setting for the NAT
%   Detailed explanation goes here

% Version:                 7.0
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte �nderung durch:   Franz Zeilinger - 23.01.2019

%------------------------------------------------------------------------------------
% System-Werte - sollten sich w�hrend der Systemlaufzeit nicht �ndern!
%------------------------------------------------------------------------------------

% Current version of the NAT
System.version = '4.3';

% possible logos
System.logos = {
    'TU Wien', 'institutslogo.jpg';
    'Siemens', 'siemenslogo.jpg';
    };

System.logo_selector = 'TU Wien';

% maximum number of a whole dataset, if this number is exceeded, partial
% files are created: 
System.number_max_datasets = 500;

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
% 	'home_1',  'Haus - 1 Bewohner'             , 11;...
% 	'home_2',  'Haus - 2 Bewohner'             , 14;...
% 	'home_3',  'Haus - 3 Bewohner'             ,  9;...
% 	'hom_4p',  'Haus - 4 und mehr Bewohner'    , 15;...
% 	'flat_1',  'Wohnung - 1 Bewohner'          , 23;...
% 	'flat_2',  'Wohnung - 2 Bewohner'          , 15;...
% 	'flat_3',  'Wohnung - 3 Bewohner'          ,  7;...
% 	'fla_4p',  'Wohnung - 4 und mehr Bewohner' ,  7;...
 	'various', 'Mehrere Haushalte am Anschlusspunkt', 0;... % this line has to be always present!
	};
	
System.lv_grids = {...
	'lv_def', 'No LV-Grid data';...
	};
 
% m�gliche Zeitaufl�sungen:
System.time_resolutions = {...
	'sec - Seconds',      1;...
	'min - Minutes',      60;...
	'2.5m - 2.5 Minutes', 150;...
	'3mi - 3 Minutes',    180;... 
	'5mi - 5 Minutes',    300;...
	'10m - 10 Minutes',   600;...
	'quh - 15 Minutes',   900;...
	};

% Definition der verschiedenen "Worst Cases":
System.wc_households = {...
	'Random selection out of all households',                                   'none_';...
	'Highest energyconsumption',                                                'E_max';...
	'Lowest energyconsumption',                                                 'E_min';...
	'Highest powerconsumption',                                                 'P_max';...
	'Random selection out of households with 0.0-0.25 share energyconsumption', 'E_025';...
	'Random selection out of households with 0.25-0.5 share energyconsumption', 'E_050';...
	'Random selection out of households with 0.5-0.75 share energyconsumption', 'E_075';...
	'Random selection out of households with 0.75-1.0 share energyconsumption', 'E_100';...
	'DEBUG',                                                                    'debug';...
	};
System.wc_generation = {...
	'No special WC selected',   'none_';...
	'Highest Energyinfeed',     'E_max';...
	'Lowest Energyinfeed',      'E_min';...
% 	'H�chste Leistung';...
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

% Default Werte (alle Anlagen aus, Standardwerte) f�r PV-Anlagen:
Default_Plant.Typ = 1;                  % Typ der Anlage (siehe 
%                                             HANDLES.SYSTEM.SOLA.TYPS)
Default_Plant.Number = 0;               % Anzahl Anlagen           [-]
Default_Plant.Power_Installed = 0;      % Installierte Leistung    [W]
Default_Plant.Orientation = 0;          % Ausrichtung              [�]
Default_Plant.Inclination = 30;         % Neigung                  [�]
Default_Plant.Efficiency = 0.12;        % Wirkungsgrad Zelle + WR  [-]
Default_Plant.Performance_Ratio = 0.62; % Betriebsbedingungen der Photovoltaikanlage [-]
Default_Plant.Rel_Size_Collector = 6.5*1e-3; % Rel. Kollektorfl�che     [m�/Wp]
Default_Plant.Size_Collector = ...      % Kollektorfl�che          [m�]
	Default_Plant.Power_Installed * Default_Plant.Rel_Size_Collector;
Default_Plant.Sigma_delay_time = 15;    % zeitl. Standardabweichung[s] 
Default_Plant.Phase_Allocation_Mode = 'auto';  % Modus zur Phasenzuordnung der Anlage [-]
                                               % siehe handles.System.Phase_Modes_Generation
Default_Plant.Max_Power_4_Single_Phase = 4.601;% Max. Leistung f�r einphasigen Anschluss [kW]
System.sola.Default_Plant = Default_Plant;
clear('Default_Plant');

% Name der verf�gbaren Windkraft-Anlagen auslesen:
System.wind.Typs = get_wind_turbine_parameters('typs');
System.wind.Selectable = System.sola.Selectable;
% Defaultwerte f�r Windkraftanlagen:
Default_Plant.Typ =             1;      % Anlagen-Typ, 1 = "keine Anlage"
Default_Plant.Number =          0;      % Anzahl der Anlagen               [-]
Default_Plant.Power_Installed = 0;      % Nennleistung der Anlage          [W]
Default_Plant.Rho =         1.225;      % Luftdichte                       [kg/m�]
Default_Plant.v_nominal =      11;      % Windgeschwindigkeit bei der Nennleistung
%                                             verf�gbar ist                [m/s]
Default_Plant.Efficiency =   0.98;      % Wirkungsgrad des Wechselrichters [-]
Default_Plant.v_start =       0.8;      % Anlaufwindgeschwindigkeit        [m/s]
Default_Plant.v_cut_off =      15;      % Abschaltwindgeschwindigkeit      [m/s]
Default_Plant.Size_Rotor =    2.5;      % Rotordurchmesser                 [m]
Default_Plant.Typ_Rotor =  'n.d.';      % Art des Rotors
Default_Plant.Inertia =      20.0;      % Tr�gheit des Windrads            [s]
Default_Plant.c_p =            [];      % Tabelle mit Leistungsbeiwerten bei
%                                             bestimmten Windgeschwindigkeiten (kommt 
%                                             aus Anlagenparameterdatei
%                                             "get_wind_turbine_parameters").
Default_Plant.Sigma_delay_time = 15;    % zeitl. Standardabweichung        [s] 
Default_Plant.Phase_Allocation_Mode = 'auto';  % Modus zur Phasenzuordnung der Anlage [-]
                                               % siehe handles.System.Phase_Modes_Generation
Default_Plant.Max_Power_4_Single_Phase = 4601; % Max. Leistung f�r einphasigen Anschluss [W]
System.wind.Default_Plant = Default_Plant;

% Define a default scenario:
Scenario.Description = ...
	'Default settings for random allocation';
Scenario.Filename = '01_Default_Settings';
Scenario.Data_is_divided = 0;   % indicates, if file-parts are present (=1) or not (=0)
Scenario.Data_number_parts = 1; % number of file-parts for the scenariodata (only valid, 
                                %    when Scenario.Data_is_divided = 1)
Scenario.Data_content = [];     % Array with number of datasets within the specified file part

Time.Season = [];               % current sesason of the sceanrio (possible ones: see handles.System.seasons{1,:})
Time.Weekday = [];              % current weekday of the sceanrio (possible ones: see handles.System.weekdays{1,:})
Scenario.Time = Time;           % settings in the time domain of the scenario

Solar.Number = [50, 0];         % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 10000;         % mittlere Leistung der Anlagen [Wp]
Solar.Power_sgl_dev = 30;       % Standardabweichung der Anlagenleistung [% vom Mittelwert]
Solar.mean_Orientation = 0;     % mittlere Ausrichtung der Anlagen [�] (0� = S�d; -90� = Ost)
Solar.dev_Orientation = 10;      % Standardabweichung der Ausrichtung [�]
Solar.mean_Inclination = 30;    % mittlere Neigung der Anlagen [�] (0� = Waagrecht; 90� = Senkrecht)
Solar.dev_Inclination = 10;      % Standardabweichung der Neigung [�]
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
System.table_settings.lv.ColumnName = {...
	'Names',...
	'Active',...
	'Housh.type',...
	'Hh. Number',...
	'PV-Plant',...
	'El. Mob.'};
% 'Names' = Name of the PQ-Node (Connection Point)
% 'Active' = is this node active (if not, no load change is performed during simulation)
System.table_settings.lv.ColumnFormat = {...
	'char', ...
	'logical', ...
	System.housholds(:,1)', ...
	'numeric',...
    System.sola.Selectable(:,1)',...
    'numeric'};
System.table_settings.lv.ColumnEditable = [false, true, true, true, true];
% Content of the additional data array
System.table_settings.lv.Additional_Data_Content = {...
	'PV_Plant_Name',...
	'Wind_Plant_Name',...
	'HHs_Selection',...
	'HHs_Pool',...
	};
System.table_settings.lv.ColumnWidth = 'auto';

% Settings for MV-Grids
System.table_settings.mv.ColumnName = {...
	'Names', ...
	'Active',...
	'LV-Grid',...
	'PV?',...
	'El. Mob?',...
	'EMob Ctr.',...
	};
System.table_settings.mv.ColumnFormat = {...
	'char', ...
	'logical', ...
	System.lv_grids(:,2)', ...
    'logical',...
    'logical',...
	'logical',...
	};
System.table_settings.mv.ColumnEditable = [false, true, true, false, false, true];
System.table_settings.mv.ColumnWidth = {'auto', 40, 150, 60, 60, 60};

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

% Speicherpfad f�r Daten
if ~isfolder([Files.Main_Path,filesep,'Results'])
	mkdir([Files.Main_Path,filesep,'Results']);
end
Files.Save.Result.Path = [Files.Main_Path,filesep,'Results'];
Files.Save.Result.Name = 'Data';
Files.Save.Result.Exte = '.mat';

Files.Save.Log.Path = [Files.Main_Path,filesep,'Log'];
Files.Save.Log.Name = 'NAT_Main_Log';
Files.Save.Log.Exte = '.log';

Files.Load.Result.Path = [Files.Main_Path,filesep,'Results'];
Files.Load.Result.Name = 'Res_XXX - information';
Files.Load.Result.Exte = '.mat';

% Name der automaisch gespeicherten Lastdaten (Pfad ist immer der Ordner des
% jeweiligen Netzes): 
Files.Auto_Load_Feed_Data.Name = 'act_Load_Feed_Data';
Files.Auto_Load_Feed_Data.Data_Settings = 'Data_Settings';
Files.Auto_Load_Feed_Data.Exte = '.mat';
Files.Auto_Load_Feed_Data.Path = Files.Main_Path;

Current_Settings.Files = Files;

% Defaultwerte der Datenbehandlungseinstellungen (Auslesen & Speichern):
data_settings.Time_Resolution = 150;        % zeitliche Aufl�sung 2.5min
 % Number of Timepoints per dataset (is depending on
 % handles.Current_Settings.Data_Extract.Time_Resolution and time series
 % settings):
data_settings.Timepoints_per_dataset = round(24*60*60/data_settings.Time_Resolution);

data_settings.get_Sample_Value = 0;   % Sample-Werte ermitteln bzw. speichern.
data_settings.get_Mean_Value = 1;     % Mittelwerte ermitteln bzw. speichern.
data_settings.get_Min_Value = 1;      % Minimalwerte ermitteln bzw. speichern.
data_settings.get_Max_Value = 1;      % Maximalwerte ermitteln bzw. speichern.
data_settings.get_95_Quantile_Value = 0; % Ermitteln des 95%-Quantils
data_settings.get_05_Quantile_Value = 0; % Ermitteln des 5%-Quantils
% Einstellungen f�r Datenauslesen:
Data_Extract = data_settings;
% Soll eine Zeitreihe erstellt werden?
Data_Extract.get_Time_Series = 0;
% Einstellungen der Zeitreihe
Time_Series.Date_Start = '27.04.2012'; % Startdatum der Zeitreihe
Time_Series.Duration = 7;              % Dauer der Zeitreihe in Tagen
Data_Extract.Time_Series = Time_Series;
% Jahreszeiten setzen:
Data_Extract.Season =  logical([1 0 0]');
Data_Extract.Weekday = logical([1 0 0]');
% Anzahl der Haushalte Null setzen:
% for i=1:size(System.housholds,1)
% 	Current_Settings.Data_Extract.Households.(System.housholds{i,1}).Number = 0;
% end
Data_Extract.Households.Number = handles.System.housholds(1:end-1,1);
[Data_Extract.Households.Number{:,end+1}] = deal(0);
% Anzahl Elektrofahrzeuge Null setzen:
Data_Extract.El_Mobility.Number = 0;
% Aktueller Worstcase f�r Haushalte. M�glichkeiten siehe
% HANDLES.SYSTEM.WC_HOUSEHOLDS.
Data_Extract.Worstcase_Housholds = 1; % Default = 'Kein'
Data_Extract.Worstcase_Generation = 1;
% Erzeugungsanlagen:
Data_Extract.Solar.Selectable = System.sola.Selectable;
Data_Extract.Wind.Selectable = System.wind.Selectable;
Data_Extract.LV_Grids_List = {};
Data_Extract.LV_Grids_Number = [];
Data_Extract.MV_input_generation_in_progress = 0;
Data_Extract.Households.Selection_active_all = 0;

Current_Settings.Data_Extract = Data_Extract;

Current_Settings.Grid.Type = 'LV';

% Standard-Dateipfade, Pfad zur Datenbank:
Current_Settings.Load_Database.Path = Current_Settings.Files.Main_Path;
Current_Settings.Load_Database.Name = 'DLE_Datenbank';
Current_Settings.Load_Database.valid = 0;

% Einstellungstabelle f�r das Netz (wird in GUI angezeigt)
Current_Settings.Table_Network = [];

% Definieren der Simulations-Parameter:
Simulation.Parameters = {...
	'Calculation_method', 'LF_USYM',...   % Unsymmetrischer Lastfluss (RST)
	'Batch_mode',          4,...          % Laden aus reeller in virt. Datenbank, Speichern in virtuelle Datenbank
	'Database_typ',       'DB_EL',...     % Datenbanktyp "elektrisches Netz"
	'Language',           'US',...        % Ausgabe der Meldungen in Deutsch
	'Database_Connector', 'ACCESS12',...  % Verwendeter Datenbankconnector (Hier: MS Access, .mdb)
	};
Simulation.No_GUI_output = 0;
% Anzahl der durchzuf�hrenden Einzelsimulationen (wieviele unterschiedliche
% Input-Datens�tze sollen aus der Datenbank geladen werden?)
Simulation.Number_Runs = 10;
% Welche verschiedenen Netze sollen simuliert werden. ACHTUNG: diese
% sollten in ihrer Grundstruktur gleich sein: d.h. z.B. gleiche Anzahl an
% Last- und Einspeisepunkten, da diese mit den Eingangsdaten �bereinstimmen
% m�ssen!
Simulation.Grid_List = {};
% Should the tool take into account different variants of the grid?
Simulation.Use_Grid_Variants = 0;
% Root path to the folder, in which the single Networks of the grid variants are stored...
Simulation.Grids_Path = Files.Main_Path;
% Should the tool calculate different scenarios (if avaliable)?
Simulation.Use_Scenarios = 1;
Simulation.Scenarios_Path = Files.Main_Path;
Simulation.Scenarios_Selection = [];
% Datatyps to be used:
Simulation.use_Sample_Value = 0;
Simulation.use_Mean_Value = 1;
Simulation.use_Max_Value = 0;
Simulation.use_Min_Value = 0;
Simulation.use_05_Quantile_Value = 0;
Simulation.use_95_Quantile_Value = 0;

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

% Settings of possible charging controllers:
Controller.Active = 0;            % are the controllers active?
Controller.Equipment_Share = 0;   % how many e-mobiles are equiped with this controller [in %]?
Controller.Limit_Factor = 0.5;    % percentage of loading limit of the observed branch, which should be kept by the controller
Controller.Shifting_Factor = 0.1; % percentage of maximum power, which can be shifted to times without branch violation
Simulation.Controller.El_Mobility.Charge_Controller = Controller;

Current_Settings.Simulation = Simulation;

% should the grid simulation be started after the data extraction is finished (1 = Yes, 0 = No)?
Current_Settings.Start_Simulation_after_Extraction = 0;

% Anzahl der unterschiedlichen Input-Datens�tze (entspricht
% handles.Current_Settings.Simulation.Number_Runs zum Extraktionszeitpunkt):
Current_Settings.Data_Extract.Number_Data_Sets = Simulation.Number_Runs;

handles.Current_Settings = Current_Settings;
end

