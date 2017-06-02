function handles = load_random_allocation(handles)
%LOAD_RANDOM_ALLOCATION Summary of this function goes here
%   Detailed explanation goes here

% Zufällige Zuordnung der Haushalte zu den Anschlusspunkten treffen:
Table_Data = handles.Current_Settings.Table_Network.Data;
hh_typ_number = size(handles.System.housholds,1);
settin = handles.Current_Settings.Data_Extract.Solar;
add_data = handles.Current_Settings.Table_Network.Additional_Data;

for i=1:size(Table_Data,1)
	idx = ceil(rand()*hh_typ_number);
	Table_Data{i,3} = handles.System.housholds{idx,1};
end

% Erzeugungsanlagen verteilen (gemäß Parametern):
Solar.Number = [75, 0];         % Anteil der Anlagen an Gesamtanzahl an Anschlussknoten [% Fix, % Tracker]
% Solar.Power_tot = 20;         % gesamte Leistung aller Anlagen [kWp]
Solar.Power_sgl = 10;            % mittlere Leistung der Anlagen [kWp]
Solar.Power_sgl_dev = 10;       % Standardabweichung der Anlagenleistung [% vom Mittelwert]
Solar.mean_Orientation = 0;     % mittlere Ausrichtung der Anlagen [°] (0° = Süd; -90° = Ost)
Solar.dev_Orientation = 5;      % Standardabweichung der Ausrichtung [°]
Solar.mean_Inclination = 30;    % mittlere Neigung der Anlagen [°] (0° = Waagrecht; 90° = Senkrecht)
Solar.dev_Inclination = 5;      % Standardabweichung der Neigung [°]

% Frühere Anlagen entfernen:
settin.Plants = [];
add_data = cell(size(add_data));
if size(settin.Selectable,1) > 2
	settin.Selectable(2:end-1,:) = [];
end
Table_Data(:,4) = deal(handles.System.sola.Selectable(1,1));
Table_Data(:,5) = deal(handles.System.wind.Selectable(1,1));

% Wirkliche Anzahl der Anlagen ermitteln:
Solar.Number = round(size(Table_Data,1)*Solar.Number/100);

% Index-Array erstellen, aus denen die Anschlusspunkte ausgewählt werden:
row_idxes = 1:size(Table_Data,1);

% die Fix installierten Anlagen erzeugen:
for i=1:Solar.Number(1)
	% Namen ermitteln, den die neue Anlage erhält:
	if isstruct(settin.Plants)
		n_pl = numel(fieldnames(settin.Plants));
		name = ['Plant_',num2str(n_pl+1)];
	else
		name = 'Plant_1';
	end
	% Default-Anlage hinzufügen:
	settin.Plants.(name) = handles.System.sola.Default_Plant;
	% Zufällig Punkt auswählen, an den Anlage angeschlossen wird:
	idx = ceil(rand*numel(row_idxes));
	row_act = row_idxes(idx);
	row_idxes(idx)=[];
	add_data{row_act,1} = name;
	
	% Parameter der Anlage bestimmen:
	settin.Plants.(name).Power_Installed = vary_parameter(Solar.Power_sgl, Solar.Power_sgl_dev);
	settin.Plants.(name).Size_Collector = ...
		settin.Plants.(name).Rel_Size_Collector * settin.Plants.(name).Power_Installed;
	settin.Plants.(name).Orientation = ...
		vary_parameter(Solar.mean_Orientation, Solar.dev_Orientation, 'Time');
	settin.Plants.(name).Inclination = ...
		vary_parameter(Solar.mean_Inclination, Solar.dev_Inclination, 'Time');
	settin.Plants.(name).Number = 1;
	
	% Anlage der Auswahl hinzufügen:
	settin.Selectable{end+1,1} = settin.Selectable{end,1};
	settin.Selectable{end-1,2} = name;
	
	typ = handles.System.sola.Typs{settin.Plants.(name).Typ,1};
	long_na = [typ(1:4),' - ',...
		num2str(settin.Plants.(name).Power_Installed),' kWp - ',...
		num2str(settin.Plants.(name).Orientation),'° - ',...
		num2str(settin.Plants.(name).Inclination),'°'];
	settin.Selectable{end-1,1} = long_na;
	
	Table_Data{row_act,4} = long_na;
end

handles.Current_Settings.Table_Network.ColumnFormat{4} = settin.Selectable(:,1)';
handles.Current_Settings.Data_Extract.Solar = settin;
handles.Current_Settings.Table_Network.Additional_Data = add_data;
handles.Current_Settings.Table_Network.Data = Table_Data;

% Anzahl der jeweiligen Haushalte ermitteln:
for i=1:size(handles.System.housholds,1)
	handles.Current_Settings.Data_Extract.Households.(handles.System.housholds{i,1}).Number = ...
		sum(strcmp(handles.System.housholds{i,1},handles.Current_Settings.Table_Network.Data(:,3)));
end
end

