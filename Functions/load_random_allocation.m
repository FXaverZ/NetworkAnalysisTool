function handles = load_random_allocation(handles)
%LOAD_RANDOM_ALLOCATION Summary of this function goes here
%   Detailed explanation goes here

% Version:                 2.0
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 24.04.2013

% Access to the data object:
d = handles.NAT_Data;

% Clear the main Table:
[handles.Current_Settings.Table_Network, handles.Current_Settings.Data_Extract] = ...
	network_table_reset(handles);

% Zufällige Zuordnung der Haushalte zu den Anschlusspunkten treffen:
Table_Data = handles.Current_Settings.Table_Network.Data;
hh_typ_number = size(handles.System.housholds,1);
sola_settin = handles.Current_Settings.Data_Extract.Solar;
add_data = handles.Current_Settings.Table_Network.Additional_Data;

for i=1:size(Table_Data,1)
	idx = ceil(rand()*hh_typ_number);
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

% Elektrofahrzeuge einfügen:
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

end

