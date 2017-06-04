function handles = get_scenarios(handles)
%GET_SCENARIOS Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.1
% Erstellt von:            Franz Zeilinger - 26.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 25.11.2013

Simulation = handles.Current_Settings.Simulation;
scen_count = 0;

% Similar Values for all Scenarios:
Solar.Power_sgl_dev = 10;       % Standardabweichung der Anlagenleistung [% vom Mittelwert]
Solar.mean_Orientation = 0;     % mittlere Ausrichtung der Anlagen [°] (0° = Süd; -90° = Ost)
Solar.dev_Orientation = 5;      % Standardabweichung der Ausrichtung [°]
Solar.mean_Inclination = 30;    % mittlere Neigung der Anlagen [°] (0° = Waagrecht; 90° = Senkrecht)
Solar.dev_Inclination = 5;      % Standardabweichung der Neigung [°]
Solar.Performance_Ratio = 0.62; % mittlere Betriebsbedingungen der Photovoltaikanlage [-]
Solar.dev_Performance_Ratio = 5;% Standardabweichung der Betriebsbedingungen [% vom Mittelwert]
Solar.Efficiency = 0.12;        % mittlerer Wirkungsgrad Zelle + WR [-]
Solar.dev_Efficiency = 5;       % Standardabweichung des Wirkungsgrad [% vom Mittelwert]

%====================================================================================
%                       S z e n a r i e n d e f i n i t i o n :
%------------------------------------------------------------------------------------
%  Testen der Input-Daten (Basis Last-Scenario mit unterschiedlichen Jahreszeiten und
%  Wochentagen...
%------------------------------------------------------------------------------------
%                                    Base-Scenario
%------------------------------------------------------------------------------------
b_scen = handles.System.default_scenario;
% Bezeichnung des Szenarios:
b_scen.Description = ...
	'Base Scenario - Normal Load, No Infeed, 0% Elektromobility';
% Filename, under which the data for this scenario will be saved:
b_scen.Filename = 'Base_scenario';
% Erzeugungsanlagen verteilen (gemäß Parametern):
b_scen.Solar = Solar;
b_scen.Solar.Number = [0, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
b_scen.Solar.Power_sgl = 0;            % mittlere Leistung der Anlagen [Wp]
b_scen.Solar.WC_Selection = 'none_';

b_scen.Households.WC_Selection = 'none_';

b_scen.El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos an Anschlussknoten
%------------------------------------------------------------------------------------
%                                     Scenariendefinition:
%------------------------------------------------------------------------------------

scen_count = scen_count + 1;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = b_scen;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = [...
	b_scen.Description,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_',b_scen.Filename,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];

scen_count = scen_count + 1;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = b_scen;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = [...
	b_scen.Description,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_',b_scen.Filename,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];

scen_count = scen_count + 1;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = b_scen;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Transi';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = [...
	b_scen.Description,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_',b_scen.Filename,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];

scen_count = scen_count + 1;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = b_scen;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Transi';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = [...
	b_scen.Description,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_',b_scen.Filename,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];

scen_count = scen_count + 1;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = b_scen;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = [...
	b_scen.Description,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_',b_scen.Filename,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];

scen_count = scen_count + 1;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = b_scen;
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = [...
	b_scen.Description,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_',b_scen.Filename,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday,...
	];

% %====================================================================================
% %                       S z e n a r i e n d e f i n i t i o n :
% %------------------------------------------------------------------------------------
% %                                     Szenario 1
% %------------------------------------------------------------------------------------
% scen_count = scen_count + 1;
% % create a default-scenario:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% % Now adapt the default scenario:
% % Bezeichnung des Szenarios:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
% 	'Base Scenario - Normal Load, No Infeed, 0% Elektromobility';
% % Filename, under which the data for this scenario will be saved:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = '01_Base_scenario';
% % Erzeugungsanlagen verteilen (gemäß Parametern):
% Solar.Number = [0, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_sgl = 0;            % mittlere Leistung der Anlagen [Wp]
% 
% Solar.WC_Selection = 'none_';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 
% 
% Households.WC_Selection = 'none_';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;
% 
% El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos an Anschlussknoten
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
% %------------------------------------------------------------------------------------
% %                                     Szenario 2
% %------------------------------------------------------------------------------------
% scen_count = scen_count + 1;
% % create a default-scenario:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% % Now adapt the default scenario:
% % Bezeichnung des Szenarios:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
% 	'Low load, high infeed - 0-25% E-HH, 24% PV-Infeed w. 20 kWp, 0% Elektromobility';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = '02_Low_load_High_infeed';
% % Erzeugungsanlagen verteilen (gemäß Parametern):
% Solar.Number = [24, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_sgl = 20000;         % mittlere Leistung der Anlagen [Wp]
% 
% Solar.WC_Selection = 'none_';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 
% 
% Households.WC_Selection = 'E_025';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;
% 
% El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
% %------------------------------------------------------------------------------------
% %                                     Szenario 3
% %------------------------------------------------------------------------------------
% scen_count = scen_count + 1;
% % create a default-scenario:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% % Now adapt the default scenario:
% % Bezeichnung des Szenarios:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
% 	'High load, medium infeed, high e-mobility - 75-100% E-HH, 33.6% PV-Infeed w. 4.5 kWp, 75% Elektromobility';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = '03_High_load_Medium_infeed_High_e_mobility';
% % Erzeugungsanlagen verteilen (gemäß Parametern):
% Solar.Number = [33.6, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_sgl = 4500;          % mittlere Leistung der Anlagen [Wp]
% 
% Solar.WC_Selection = 'none_';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 
% 
% Households.WC_Selection = 'E_100';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;
% 
% El_Mobility.Number = 75;         % Prozent-Anteil an Elektroautos in den Haushalten
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
% %------------------------------------------------------------------------------------
% %                                     Szenario 4
% %------------------------------------------------------------------------------------
% scen_count = scen_count + 1;
% % create a default-scenario:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% % Now adapt the default scenario:
% % Bezeichnung des Szenarios:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
% 	'High load, High infeed, High e-mobility - 75-100% E-HH, 24% PV-Infeed w. 20 kWp, 75% Elektromobility';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = '04_High_load_High_infeed_High_e_mobility';
% % Erzeugungsanlagen verteilen (gemäß Parametern):
% Solar.Number = [24, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_sgl = 20000;       % mittlere Leistung der Anlagen [Wp]
% 
% Solar.WC_Selection = 'none_';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 
% 
% Households.WC_Selection = 'E_100';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;
% 
% El_Mobility.Number = 75;         % Prozent-Anteil an Elektroautos in den Haushalten
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
% %------------------------------------------------------------------------------------
% %                                     Szenario 5
% %------------------------------------------------------------------------------------
% scen_count = scen_count + 1;
% % create a default-scenario:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% % Now adapt the default scenario:
% % Bezeichnung des Szenarios:
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
% 	'Normal load, medium infeed (whole roofs), medium e-mobility - Normal Load, 67.2% PV-Infeed w. 4.5 kWp, 30% Elektromobility';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = '05_Normal_load_Medium_infeed_whole_roofs_Medium_e_mobility';
% % Erzeugungsanlagen verteilen (gemäß Parametern):
% Solar.Number = [67.2, 0];     % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_sgl = 4500;       % mittlere Leistung der Anlagen [Wp]
% 
% Solar.WC_Selection = 'none_';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 
% 
% Households.WC_Selection = 'none_';
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;
% 
% El_Mobility.Number = 30;         % Prozent-Anteil an Elektroautos in den Haushalten
% Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
% %====================================================================================

% Anzahl an akutell verfügbaren Szenarios:
Simulation.Scenarios.Number = scen_count;
Simulation.Scenarios.Names = {};
for i=1:Simulation.Scenarios.Number
	Simulation.Scenarios.Names{end+1} = Simulation.Scenarios.(['Sc_',num2str(i)]).Filename;
end
% Szenariendaten verfügbar?
Simulation.Scenarios.Data_avaliable = 0;

% mark all scenarios as active for simulation:
Simulation.Scenarios_Selection = ones(1,Simulation.Scenarios.Number);

handles.Current_Settings.Simulation = Simulation;
end

