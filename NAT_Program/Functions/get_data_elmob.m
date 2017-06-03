function get_data_elmob (handles, varargin)
%GET_DATA_ELMOB Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.0 - Für Verwendung im NAT
% Erstellt von:            Franz Zeilinger - 24.04.2013
% Letzte Änderung durch:   

system = handles.System;                             % Systemvariablen
settin = handles.Current_Settings.Data_Extract;      % aktuelle Einstellungen
db_fil = handles.Current_Settings.Load_Database;     % Datenbankstruktur
d = handles.NAT_Data;                                % Zugriff auf das Datenobjekt

% Ergebnis-Arrays initialisieren:
El_Mobility.Data_Sample = [];
El_Mobility.Data_Mean = [];
El_Mobility.Data_Min = [];
El_Mobility.Data_Max = [];
El_Mobility.Data_05P_Quantil = [];
El_Mobility.Data_95P_Quantil = [];
El_Mobility.Number = settin.El_Mobility.Number;

if nargin ==2
	% als Zweites Argument wurde ein aktueller Index übergeben für eine
	% Generierung von mehreren Datensätzen...
	idx_act = varargin{1};
else
	idx_act = [];
end

% Falls keine Elektrofahrzeuge betrachtet werden sollen, leere Arrays
% zurückgeben:
if settin.El_Mobility.Number == 0
	if isempty(idx_act)
		% Es wird nur ein Datensatz generiert, diese Direkt in die
		% Load-Infeed-Struktur einfügen:
		d.Load_Infeed_Data.Set_1.El_Mobility = El_Mobility;
		if ~isfield(d.Load_Infeed_Data.Set_1, 'Table_Network')
			d.Load_Infeed_Data.Set_1.Table_Network = handles.Current_Settings.Table_Network;
		end
	else
		d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).El_Mobility = El_Mobility;
		if ~isfield(d.Load_Infeed_Data.(['Set_',num2str(idx_act)]), 'Table_Network')
			d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Table_Network = handles.Current_Settings.Table_Network;
		end
	end
	% Funktion beenden:
	return;
end

% zeitliche Auflösung ermitteln:
time_res = system.time_resolutions{settin.Time_Resolution,2};

% Daten laden (Variable "data_charge")
load([db_fil.Path,filesep,db_fil.Name,filesep,'Chargin_Profiles.mat']);
num_data_sets = size(data_charge,2);
% Phasenaufteilung festlegen:
phase_idx = zeros(1,settin.El_Mobility.Number);
for i=1:settin.El_Mobility.Number
	phase_idx(i) = vary_parameter([1; 3; 5],ones(3,1)*100/3, 'List');
end

pool = 1:num_data_sets;   % Liste mit Indizes der möglichen Datensätze
idx = zeros(settin.El_Mobility.Number,1); % Liste mit Indizes der ausgewählten 
                                          % Datensätzen (mit 0 intialisieren)
for i = 1:settin.El_Mobility.Number
	% Erzeugen einer Zufallszahl im Bereich [1, Anz._verf._Datensätze]
	fortu = round(rand()*(numel(pool)-1))+1;
	idx(i) = pool(fortu); % diesen Index in Indexliste aufnehmen
	% gezogenen Datensatz aus der Auswahlmöglickeit entfernen (damit er
	% nicht mehr gezogen werden kann):
	pool(fortu) = [];
end

% Daten auslesen und aufbereiten (Ausgangsdaten in kW!):
data_phase = zeros(size(data_charge,1),settin.El_Mobility.Number*6);
idx_dp = (0:6:settin.El_Mobility.Number*6-1) + phase_idx;
data_phase(:,idx_dp) = data_charge(:,idx)*1000;
% Dann je nach postprocessing Anforderungen diese durchführen: 
if settin.get_Sample_Value
	data_sample = data_phase(1:time_res:end,:);
	% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
	El_Mobility.Data_Sample = [El_Mobility.Data_Sample,...
		data_sample];
end
if settin.get_Mean_Value || ...
		settin.get_Min_Value || ...
		settin.get_Max_Value || ...
		settin.get_05_Quantile_Value || ...
		settin.get_95_Quantile_Value
	% Das ursprüngliche Datenarray so umformen, dass ein 3D Array mit allen
	% Werten eines Zeitraumes in der ersten Dimension entsteht. Diese wird
	% dann durch die nachfolgenden Funktionen (mean, min, max) sofort in die
	% entsprechenden Werte umgerechnet. Mit squeeze muss dann nur mehr die
	% Singleton-Dimension entfernt werden...
	data_mean = reshape(data_phase,...
		time_res,[],size(data_phase,2));
	% eingelesenen Daten wieder löschen (Speicher freigeben!)
	clear data_phase;
end
if settin.get_Min_Value
	data_min = squeeze(min(data_mean));
	% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
	El_Mobility.Data_Min = [El_Mobility.Data_Min,...
		data_min];
	% eingelesenen Daten wieder löschen (Speicher freigeben!)
	clear data_min;
end
if settin.get_Max_Value
	data_max = squeeze(max(data_mean));
	% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
	El_Mobility.Data_Max = [El_Mobility.Data_Max,...
		data_max];
	% eingelesenen Daten wieder löschen (Speicher freigeben!)
	clear data_max;
end
if settin.get_05_Quantile_Value
	data_05q = squeeze(quantile(data_mean,0.05));
	% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
	El_Mobility.Data_05P_Quantil = [...
		El_Mobility.Data_05P_Quantil,...
		data_05q];
	% eingelesenen Daten wieder löschen (Speicher freigeben!)
	clear data_05q;
end
if settin.get_95_Quantile_Value
	data_95q = squeeze(quantile(data_mean,0.95));
	% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
	El_Mobility.Data_95P_Quantil = [...
		El_Mobility.Data_95P_Quantil,...
		data_95q];
	% eingelesenen Daten wieder löschen (Speicher freigeben!)
	clear data_95q;
end
if settin.get_Mean_Value
	data_mean = squeeze(mean(data_mean));
	% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
	El_Mobility.Data_Mean = [El_Mobility.Data_Mean,...
		data_mean];
	% eingelesenen Daten wieder löschen (Speicher freigeben!)
	clear data_mean
end

% Ergebnis zurückschreiben:
if isempty(idx_act)
	% Es wird nur ein Datensatz generiert:
	d.Load_Infeed_Data.Set_1.El_Mobility = El_Mobility;
	if ~isfield(d.Load_Infeed_Data.Set_1, 'Table_Network')
		d.Load_Infeed_Data.Set_1.Table_Network = handles.Current_Settings.Table_Network;
	end
else
	d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).El_Mobility = El_Mobility;
	if ~isfield(d.Load_Infeed_Data.(['Set_',num2str(idx_act)]), 'Table_Network')
		d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Table_Network = handles.Current_Settings.Table_Network;
	end
end

