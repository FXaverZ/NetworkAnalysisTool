function handles = get_scenarios(handles)
%GET_SCENARIOS Summary of this function goes here
%   Detailed explanation goes here

Simulation = handles.Current_Settings.Simulation;

%====================================================================================
%                       S z e n a r i e n d e f i n i t i o n :
%------------------------------------------------------------------------------------
%                                     Szenario 1
%------------------------------------------------------------------------------------
Simulation.Scenarios.Sc_1.Description = 'Base Scenario - No Infeed, 0% Elektormobility, Normal Load';
Simulation.Scenarios.Sc_1.Filename = '01_Base_Scenario';
% Erzeugungsanlagen verteilen (gemäß Parametern):
Solar.Number = [0, 0];          % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_tot = 20;         % gesamte Leistung aller Anlagen [kWp]
Solar.Power_sgl = 5;            % mittlere Leistung der Anlagen [kWp]
Solar.Power_sgl_dev = 10;       % Standardabweichung der Anlagenleistung [% vom Mittelwert]
Solar.mean_Orientation = 0;     % mittlere Ausrichtung der Anlagen [°] (0° = Süd; -90° = Ost)
Solar.dev_Orientation = 5;      % Standardabweichung der Ausrichtung [°]
Solar.mean_Inclination = 30;    % mittlere Neigung der Anlagen [°] (0° = Waagrecht; 90° = Senkrecht)
Solar.dev_Inclination = 5;      % Standardabweichung der Neigung [°]
Solar.WC_Selection = 'none_';
Simulation.Scenarios.Sc_1.Solar = Solar; 

Households.WC_Selection = 'none_';
Simulation.Scenarios.Sc_1.Households = Households;

El_Mobility.Number = 0;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.Sc_1.El_Mobility = El_Mobility;

%------------------------------------------------------------------------------------
%                                     Szenario 2
%------------------------------------------------------------------------------------
% Bezeichnung des Szenarios:
Simulation.Scenarios.Sc_2.Description = 'Scenario 1 - High Infeed, 30% Elektormobility, Low Load (0-25)%';
Simulation.Scenarios.Sc_2.Filename = '02_Scenario_1';
% Erzeugungsanlagen verteilen (gemäß Parametern):
Solar.Number = [75, 0];         % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_tot = 20;         % gesamte Leistung aller Anlagen [kWp]
Solar.Power_sgl = 10;           % mittlere Leistung der Anlagen [kWp]
Solar.Power_sgl_dev = 10;       % Standardabweichung der Anlagenleistung [% vom Mittelwert]
Solar.mean_Orientation = 0;     % mittlere Ausrichtung der Anlagen [°] (0° = Süd; -90° = Ost)
Solar.dev_Orientation = 5;      % Standardabweichung der Ausrichtung [°]
Solar.mean_Inclination = 30;    % mittlere Neigung der Anlagen [°] (0° = Waagrecht; 90° = Senkrecht)
Solar.dev_Inclination = 5;      % Standardabweichung der Neigung [°]
Solar.WC_Selection = 'none_';
Simulation.Scenarios.Sc_2.Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.Sc_2.Households = Households;

El_Mobility.Number = 30;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.Sc_2.El_Mobility = El_Mobility;

%------------------------------------------------------------------------------------
%                                     Szenario 3
%------------------------------------------------------------------------------------
Simulation.Scenarios.Sc_3.Description = 'Scenario 2 - Medium Infeed, 75% Elektormobility, High Load (75-100)%';
Simulation.Scenarios.Sc_3.Filename = '03_Scenario_2';
% Erzeugungsanlagen verteilen (gemäß Parametern):
Solar.Number = [25, 0];         % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_tot = 20;         % gesamte Leistung aller Anlagen [kWp]
Solar.Power_sgl = 5;            % mittlere Leistung der Anlagen [kWp]
Solar.Power_sgl_dev = 10;       % Standardabweichung der Anlagenleistung [% vom Mittelwert]
Solar.mean_Orientation = 0;     % mittlere Ausrichtung der Anlagen [°] (0° = Süd; -90° = Ost)
Solar.dev_Orientation = 5;      % Standardabweichung der Ausrichtung [°]
Solar.mean_Inclination = 30;    % mittlere Neigung der Anlagen [°] (0° = Waagrecht; 90° = Senkrecht)
Solar.dev_Inclination = 5;      % Standardabweichung der Neigung [°]
Solar.WC_Selection = 'none_';
Simulation.Scenarios.Sc_2.Solar = Solar; 

Households.WC_Selection = 'E_100';
Simulation.Scenarios.Sc_3.Households = Households;

El_Mobility.Number = 75;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.Sc_3.El_Mobility = El_Mobility;

%------------------------------------------------------------------------------------
%                                     Szenario 4
%------------------------------------------------------------------------------------
Simulation.Scenarios.Sc_4.Description = 'Scenario 2 - High Infeed, 25% Elektormobility, Low Load (0-25)%';
Simulation.Scenarios.Sc_4.Filename = '03_Scenario_2';
% Erzeugungsanlagen verteilen (gemäß Parametern):
Solar.Number = [25, 0];         % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_tot = 20;         % gesamte Leistung aller Anlagen [kWp]
Solar.Power_sgl = 10;            % mittlere Leistung der Anlagen [kWp]
Solar.Power_sgl_dev = 10;       % Standardabweichung der Anlagenleistung [% vom Mittelwert]
Solar.mean_Orientation = 0;     % mittlere Ausrichtung der Anlagen [°] (0° = Süd; -90° = Ost)
Solar.dev_Orientation = 5;      % Standardabweichung der Ausrichtung [°]
Solar.mean_Inclination = 30;    % mittlere Neigung der Anlagen [°] (0° = Waagrecht; 90° = Senkrecht)
Solar.dev_Inclination = 5;      % Standardabweichung der Neigung [°]
Solar.WC_Selection = 'none_';
Simulation.Scenarios.Sc_2.Solar = Solar; 

Households.WC_Selection = 'E_025';
Simulation.Scenarios.Sc_4.Households = Households;

El_Mobility.Number = 25;         % Prozent-Anteil an Elektroautos in den Haushalten
Simulation.Scenarios.Sc_4.El_Mobility = El_Mobility;
%====================================================================================

% Anzahl an akutell verfügbaren Szenarios:
Simulation.Scenarios.Number = numel(fields(Simulation.Scenarios));
Simulation.Scenarios.Names = {};
for i=1:Simulation.Scenarios.Number
	Simulation.Scenarios.Names{end+1} = Simulation.Scenarios.(['Sc_',num2str(i)]).Filename;
end
% Szenariendaten verfügbar?
Simulation.Scenarios.Data_avaliable = 0;

handles.Current_Settings.Simulation = Simulation;
end

