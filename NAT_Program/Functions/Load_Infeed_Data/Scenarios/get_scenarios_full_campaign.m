function handles = get_scenarios(handles)
%GET_SCENARIOS Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.1
% Erstellt von:            Franz Zeilinger - 26.04.2013
% Letzte ƒnderung durch:   Franz Zeilinger - 25.11.2013

Simulation = handles.Current_Settings.Simulation;
scen_count = 0;

% Similar Values for all Scenarios:
Solar.Power_sgl_dev = 10;       % Standardabweichung der Anlagenleistung [% vom Mittelwert]
Solar.mean_Orientation = 0;     % mittlere Ausrichtung der Anlagen [∞] (0∞ = S¸d; -90∞ = Ost)
Solar.dev_Orientation = 5;      % Standardabweichung der Ausrichtung [∞]
Solar.mean_Inclination = 30;    % mittlere Neigung der Anlagen [∞] (0∞ = Waagrecht; 90∞ = Senkrecht)
Solar.dev_Inclination = 5;      % Standardabweichung der Neigung [∞]
Solar.Performance_Ratio = 0.62; % mittlere Betriebsbedingungen der Photovoltaikanlage [-]
Solar.dev_Performance_Ratio = 5;% Standardabweichung der Betriebsbedingungen [% vom Mittelwert]
Solar.Efficiency = 0.12;        % mittlerer Wirkungsgrad Zelle + WR [-]
Solar.dev_Efficiency = 5;       % Standardabweichung des Wirkungsgrad [% vom Mittelwert]

%====================================================================================
%                       S z e n a r i e n d e f i n i t i o n :
%------------------------------------------------------------------------------------
%                                     Base Scanrios
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Base Scenario - Normal Load, No Infeed, 0% Elektromobility, '...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Filename, under which the data for this scenario will be saved:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_Base_scenario_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [0, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 0;            % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos an Anschlussknoten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Base Scenario - Normal Load, No Infeed, 0% Elektromobility, '...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Filename, under which the data for this scenario will be saved:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_Base_scenario_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [0, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 0;            % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos an Anschlussknoten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Base Scenario - Normal Load, No Infeed, 0% Elektromobility, '...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Filename, under which the data for this scenario will be saved:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_Base_scenario_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [0, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 0;            % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos an Anschlussknoten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Base Scenario - Normal Load, No Infeed, 0% Elektromobility, '...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Filename, under which the data for this scenario will be saved:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_Base_scenario_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [0, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 0;            % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos an Anschlussknoten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------

%------------------------------------------------------------------------------------
%                                     Low load high infeed
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Low load, high infeed - 0-25% E-HH, 24% PV-Infeed w. 10 kWp, 0% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];

Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename =[...
	num2str(scen_count,'%02.0f'),'_Low_load_High_infeed_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [24, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 10000;         % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Low load, high infeed - 0-25% E-HH, 24% PV-Infeed w. 10 kWp, 0% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];

Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename =[...
	num2str(scen_count,'%02.0f'),'_Low_load_High_infeed_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [24, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 10000;         % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Low load, high infeed - 0-25% E-HH, 24% PV-Infeed w. 10 kWp, 0% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];

Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename =[...
	num2str(scen_count,'%02.0f'),'_Low_load_High_infeed_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [24, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 10000;         % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Low load, high infeed - 0-25% E-HH, 24% PV-Infeed w. 10 kWp, 0% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];

Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename =[...
	num2str(scen_count,'%02.0f'),'_Low_load_High_infeed_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [24, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 10000;         % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------

%------------------------------------------------------------------------------------
%                                 High load, medium infeed
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['High load, medium infeed, high e-mobility - 50-75% E-HH, 33.6% PV-Infeed w. 4.5 kWp, 33.6% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_High_load_Medium_infeed_High_e_mobility_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [33.6, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 4500;          % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_075';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 33.6;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['High load, medium infeed, high e-mobility - 50-75% E-HH, 33.6% PV-Infeed w. 4.5 kWp, 33.6% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_High_load_Medium_infeed_High_e_mobility_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [33.6, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 4500;          % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_075';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 33.6;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['High load, medium infeed, high e-mobility - 50-75% E-HH, 33.6% PV-Infeed w. 4.5 kWp, 33.6% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_High_load_Medium_infeed_High_e_mobility_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [33.6, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 4500;          % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_075';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 33.6;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['High load, medium infeed, high e-mobility - 50-75% E-HH, 33.6% PV-Infeed w. 4.5 kWp, 33.6% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_High_load_Medium_infeed_High_e_mobility_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [33.6, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 4500;          % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_075';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 33.6;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;

%------------------------------------------------------------------------------------
%                                     Low load, higher infeed
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Low load, higher infeed - 0-25% E-HH, 24% PV-Infeed w. 20 kWp, 0% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];

Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename =[...
	num2str(scen_count,'%02.0f'),'_Low_load_Higher_infeed_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [24, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 20000;         % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Low load, higher infeed - 0-25% E-HH, 24% PV-Infeed w. 10 kWp, 0% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];

Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename =[...
	num2str(scen_count,'%02.0f'),'_Low_load_Higher_infeed_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [24, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 20000;         % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Low load, higher infeed - 0-25% E-HH, 24% PV-Infeed w. 20 kWp, 0% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];

Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename =[...
	num2str(scen_count,'%02.0f'),'_Low_load_Higher_infeed_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [24, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 20000;         % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Low load, higher infeed - 0-25% E-HH, 24% PV-Infeed w. 20 kWp, 0% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];

Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename =[...
	num2str(scen_count,'%02.0f'),'_Low_load_Higher_infeed_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [24, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 20000;         % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------

%------------------------------------------------------------------------------------
%                                 Higher load, medium infeed
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Higher load, medium infeed, high e-mobility - 75-100% E-HH, 33.6% PV-Infeed w. 4.5 kWp, 75% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_Higher_load_Medium_infeed_High_e_mobility_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [33.6, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 4500;          % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_100';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 75;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Winter';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Higher load, medium infeed, high e-mobility - 75-100% E-HH, 33.6% PV-Infeed w. 4.5 kWp, 75% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_Higher_load_Medium_infeed_High_e_mobility_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [33.6, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 4500;          % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_100';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 75;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Workda';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Higher load, medium infeed, high e-mobility - 75-100% E-HH, 33.6% PV-Infeed w. 4.5 kWp, 75% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_Higher_load_Medium_infeed_High_e_mobility_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [33.6, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 4500;          % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_100';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 75;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;
%------------------------------------------------------------------------------------
scen_count = scen_count + 1;
% create a default-scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]) = handles.System.default_scenario;
% Now adapt the default scenario:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season = 'Summer';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday = 'Sunday';
% Bezeichnung des Szenarios:
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Description = ...
	['Higher load, medium infeed, high e-mobility - 75-100% E-HH, 33.6% PV-Infeed w. 4.5 kWp, 75% Elektromobility, ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,', ',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Filename = [...
	num2str(scen_count,'%02.0f'),'_Higher_load_Medium_infeed_High_e_mobility_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Season,'_',...
	Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Time.Weekday];
% Erzeugungsanlagen verteilen (gem‰ﬂ Parametern):
Solar.Number = [33.6, 0];        % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
Solar.Power_sgl = 4500;          % mittlere Leistung der Anlagen [Wp]

Solar.WC_Selection = 'none_';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Solar = Solar; 

Households.WC_Selection = 'E_100';
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).Households = Households;

El_Mobility.Number = 75;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.(['Sc_',num2str(scen_count)]).El_Mobility = El_Mobility;

%====================================================================================

% Anzahl an akutell verf¸gbaren Szenarios:
Simulation.Scenarios.Number = scen_count;
Simulation.Scenarios.Names = {};
for i=1:Simulation.Scenarios.Number
	Simulation.Scenarios.Names{end+1} = Simulation.Scenarios.(['Sc_',num2str(i)]).Filename;
end
% Szenariendaten verf¸gbar?
Simulation.Scenarios.Data_avaliable = 0;

% mark all scenarios as active for simulation:
Simulation.Scenarios_Selection = [];

handles.Current_Settings.Simulation = Simulation;
end

