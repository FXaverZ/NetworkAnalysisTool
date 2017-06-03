function handles = load_random_allocation(handles)
%LOAD_RANDOM_ALLOCATION Summary of this function goes here
%   Detailed explanation goes here

% Version:                 2.2
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 15.05.2013

% Access to the data object:
d = handles.NAT_Data;
% Check, if an Scenario was selected, otherwise use the default settings,
% which are defined here (compare to function "get_scenarios"):
if ~isfield(d.Simulation, 'Active_Scenario')
	% no active Scenario, use default settings:
	% Bezeichnung des Szenarios:
	Scenario.Description = ...
		'Default settings for random allocation';
	Scenario.Filename = '01_Default_Settings';
	% Erzeugungsanlagen verteilen (gemäß Parametern):
	Solar.Number = [50, 0];         % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
	% Solar.Power_tot = 20;         % gesamte Leistung aller Anlagen [Wp]
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
	
	Households.WC_Selection = 'none_';
	Scenario.Households = Households;
	
	El_Mobility.Number = 50;         % Prozent-Anteil an Elektroautos in den Haushalten
	Scenario.El_Mobility = El_Mobility;
	
	d.Simulation.Active_Scenario = Scenario;
	% remember the case, that the default values were used!
	used_default = 1;
else
	used_default = 0;
end

% Clear the main Table:
[handles.Current_Settings.Table_Network, handles.Current_Settings.Data_Extract] = ...
	network_table_reset(handles);
Table_Data = handles.Current_Settings.Table_Network.Data;

% -----------------------------------------------------------------------------------
% Zufällige Zuordnung der Haushalte zu den Anschlusspunkten treffen:
% -----------------------------------------------------------------------------------
% Die Verteilung der Haushalte umrechnen, um diese für die Zufallsauswahl
% aufzubereiten:
hh_distribution = cell2mat(handles.System.housholds(:,3));
hh_distribution = 100*hh_distribution/sum(hh_distribution);
for i = 2:numel(hh_distribution)
	hh_distribution(i) = hh_distribution(i-1) + hh_distribution(i);
end

for i=1:size(Table_Data,1)
	fortu = ceil(rand()*100);
	if fortu == 100
		idx = size(handles.System.housholds,1);
	else
		idx = find(hh_distribution >= fortu, 1);
	end
	Table_Data{i,2} = handles.System.housholds{idx,1};
end

% Anzahl der jeweiligen Haushalte ermitteln:
for i=1:size(handles.System.housholds,1)
	handles.Current_Settings.Data_Extract.Households.(handles.System.housholds{i,1}).Number = ...
		sum(strcmp(handles.System.housholds{i,1},Table_Data(:,2)));
end

% set the current worst case.
handles.Current_Settings.Data_Extract.Worstcase_Housholds = ...
	find(strcmp(...
	handles.System.wc_households(:,2),...
	d.Simulation.Active_Scenario.Households.WC_Selection),1);

% -----------------------------------------------------------------------------------
% Solaranlagen anordnen:
% -----------------------------------------------------------------------------------
sola_settin = handles.Current_Settings.Data_Extract.Solar;
add_data = handles.Current_Settings.Table_Network.Additional_Data;
% Get the current scenarion settings:
Solar = d.Simulation.Active_Scenario.Solar;

% Wirkliche Anzahl der Anlagen ermitteln:
Solar.Number = round(size(Table_Data,1)*Solar.Number/100);

% Index-Array erstellen, aus denen die Anschlusspunkte ausgewählt werden:
row_idxes = 1:size(Table_Data,1);

% die Fix installierten Anlagen erzeugen:
for i=1:Solar.Number(1)
	% Namen ermitteln, den die neue Anlage erhält:
	if isstruct(sola_settin.Plants)
		n_pl = numel(fieldnames(sola_settin.Plants));
		name = ['Plant_',num2str(n_pl+1)];
	else
		name = 'Plant_1';
	end
	% Default-Anlage hinzufügen:
	sola_settin.Plants.(name) = handles.System.sola.Default_Plant;
	% Zufällig Punkt auswählen, an den Anlage angeschlossen wird:
	idx = ceil(rand*numel(row_idxes));
	row_act = row_idxes(idx);
	row_idxes(idx)=[];
	add_data{row_act,1} = name;
	
	% Parameter der Anlage bestimmen:
	sola_settin.Plants.(name).Power_Installed = vary_parameter(Solar.Power_sgl, Solar.Power_sgl_dev);
	sola_settin.Plants.(name).Size_Collector = ...
		sola_settin.Plants.(name).Rel_Size_Collector * sola_settin.Plants.(name).Power_Installed;
	sola_settin.Plants.(name).Orientation = ...
		vary_parameter(Solar.mean_Orientation, Solar.dev_Orientation, 'Time');
	sola_settin.Plants.(name).Inclination = ...
		vary_parameter(Solar.mean_Inclination, Solar.dev_Inclination, 'Time');
	sola_settin.Plants.(name).Number = 1;
	sola_settin.Plants.(name).Efficiency = vary_parameter(Solar.Efficiency, Solar.dev_Efficiency);
	sola_settin.Plants.(name).Performance_Ratio = vary_parameter(Solar.Performance_Ratio, Solar.dev_Performance_Ratio);
	
	% Anlage der Auswahl hinzufügen:
	sola_settin.Selectable{end+1,1} = sola_settin.Selectable{end,1};
	sola_settin.Selectable{end-1,2} = name;
	
	typ = handles.System.sola.Typs{sola_settin.Plants.(name).Typ,1};
	long_na = [typ(1:4),' - ',...
		num2str(sola_settin.Plants.(name).Power_Installed),' kWp - ',...
		num2str(sola_settin.Plants.(name).Orientation),'° - ',...
		num2str(sola_settin.Plants.(name).Inclination),'°'];
	sola_settin.Selectable{end-1,1} = long_na;
	
	Table_Data{row_act,3} = long_na;
end
handles.Current_Settings.Data_Extract.Solar = sola_settin;

% set the current worst case.
handles.Current_Settings.Data_Extract.Worstcase_Generation = ...
	find(strcmp(...
	handles.System.wc_households(:,2),...
	d.Simulation.Active_Scenario.Solar.WC_Selection),1);

% -----------------------------------------------------------------------------------
% Elektrofahrzeugen einfügen:
% -----------------------------------------------------------------------------------
El_Mobility = d.Simulation.Active_Scenario.El_Mobility;
El_Mobility.Number = round(size(Table_Data,1)*El_Mobility.Number/100);

% Index-Array erstellen, aus denen die Anschlusspunkte ausgewählt werden:
row_idxes = 1:size(Table_Data,1);
for i=1:El_Mobility.Number(1)
	% Zufällig Punkt auswählen, an den Anlage angeschlossen wird:
	idx = ceil(rand*numel(row_idxes));
	row_act = row_idxes(idx);
	row_idxes(idx)=[];
	Table_Data{row_act,4} = Table_Data{row_act,4} + 1;
end

% ermitteln, wieviele Elektrofahrzeuge gesamt im Netz enthalten sind:
handles.Current_Settings.Data_Extract.El_Mobility.Number = ...
	sum(cell2mat(Table_Data(:,4)));

handles.Current_Settings.Table_Network.ColumnFormat{3} = sola_settin.Selectable(:,1)';
handles.Current_Settings.Table_Network.Additional_Data = add_data;
handles.Current_Settings.Table_Network.Data = Table_Data;

if used_default
	% If default values were used, erase the created field, that it will
	% not occur further:
	d.Simulation = rmfield(d.Simulation, 'Active_Scenario');
end
end

