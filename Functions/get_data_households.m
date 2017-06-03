function get_data_households (handles, varargin)
%GET_DATA_HOUSEHOLDS    extrahiert die Daten der Haushalte 

% Version:                 2.1 - Für Verwendung im NAT
% Erstellt von:            Franz Zeilinger - 14.02.2012
% Letzte Änderung durch:   Franz Zeilinger - 19.04.2013

system = handles.System;                             % Systemvariablen
settin = handles.Current_Settings.Data_Extract;      % aktuelle Einstellungen
db_fil = handles.Current_Settings.Load_Database;     % Datenbankstruktur

% Ergebnis-Arrays initialisieren:
Households.Data_Sample = [];
Households.Data_Mean = [];
Households.Data_Min = [];
Households.Data_Max = [];
Households.Data_05P_Quantil = [];
Households.Data_95P_Quantil = [];
Households.Content = {};

if nargin ==2
	% als Zweites Argument wurde ein aktueller Index übergeben für eine
	% Generierung von mehreren Datensätzen...
	idx_act = varargin{1};
else
	idx_act = [];
end

max_num_data_set = db_fil.setti.max_num_data_set; % Anzahl an Datensätzen in einer
                                                  % Teildatei
sep = db_fil.files.sep;    % Trenner im Dateinamen (' - ')

% die aktuellen Zeitdaten (Jahreszeit, Wochentag) auslesen:
season = system.seasons{settin.Season,1};
weekda = system.weekdays{settin.Weekday,1};
% zeitliche Auflösung ermitteln:
time_res = system.time_resolutions{settin.Time_Resolution,2};

% die einzelnen Haushaltsklassen durchgehen:
for i=1:size(system.housholds,1)
	% Anzahl der Haushalte gemäß Einstellungen auslesen:
	number_hh = settin.Households.(system.housholds{i,1}).Number;
	if number_hh < 1
		% Falls für diesen Haushalt keine Daten extrahiert werden sollen 
		% (Anzahl = 0), überspringen:
		continue;
	end
	% Inhaltsarray mit den Haushaltsbezeichnungen befüllen:
	Households.Content(end+1:end+number_hh)=deal(system.housholds(i,1));
	% Info Datei laden:
	path = [db_fil.Path,filesep,db_fil.Name,filesep,season,filesep,weekda];
	name = ['Load',sep,season,sep,weekda,sep,system.housholds{i,1},sep,'Info'];
	% Daten laden (Variable "data_info")
	load([path,filesep,name,'.mat']);
	% wieviele Datensätze gibt es insgesamt?
	num_data_sets = size(data_info,2)/6;
	
	% Je nach Einstellung Datensätze auswählen:
	switch system.wc_households{settin.Worstcase_Housholds,2}
		case 'none_' % Einstellung: Zufällige Auswahl
			% eine Indexliste erstellen, mit zufällig ausgewählten Datensätzen:
			pool = 1:num_data_sets;   % Liste mit Indizes der möglichen Datensätze
			idx = zeros(number_hh,1); % Liste mit Indizes der ausgewählten Datensätze
			                          % (mit 0 intialisieren)
			for j = 1:number_hh
				% Erzeugen einer Zufallszahl im Bereich [1, Anz._verf._Datensätze]
				fortu = round(rand()*(numel(pool)-1))+1;
				idx(j) = pool(fortu); % diesen Index in Indexliste aufnehmen
				% gezogenen Datensatz aus der Auswahlmöglickeit entfernen (damit er
				% nicht mehr gezogen werden kann):
				pool(fortu) = [];
			end
		case 'E_max' % Worst Case: Höchster Energieverbrauch
			% aus den Phasenenergieaufnahmen die Gesamtenergieaufnahme ermitteln
			% (Summe aus L1, L2 und L3):
			data_e = sum([...
				data_info(3,1:6:end);...
				data_info(3,3:6:end);...
				data_info(3,5:6:end)],1); %#ok<COLND>
			% die Energiebeträge sortieren, die Indexliste I übernehmen:
			[~, I] = sort(data_e,'descend');
			% die geforderten Inidizes mit dem höchsten Energieverbrauch übernehmen
			% (sind die ersten "number_hh"-Inzies der Sortierliste I):
			idx = I(1:number_hh)';
		case 'E_min' % Worst Case: Niedrigster Energieverbrauch
			% Gleicher Ablauf wie bei "Höchster Energieverbrauch", nur umgekehrte
			% Sortierung:
			data_e = sum([...
				data_info(3,1:6:end);...
				data_info(3,3:6:end);...
				data_info(3,5:6:end)],1); %#ok<COLND>
			[~, I] = sort(data_e); 
			idx = I(1:number_hh)';
		case 'P_max' % Worst Case: Höchste Leistungsaufnahme
			% Summen-Leistungsaufnahme aus max. Phasenleistungsaufnahme ermitteln:
			data_max = sum([...
				data_info(1,1:6:end);...
				data_info(1,3:6:end);...
				data_info(1,5:6:end)],1); %#ok<COLND>
			[~, I] = sort(data_max,'descend');
			% die geforderten Inidizes mit dem höchsten Energieverbrauch übernehmen:
			idx = I(1:number_hh)';
		case 'E_025' %0.0-0.25 Anteil Energieverbrauch (1. Viertel)
			% aus den Phasenenergieaufnahmen die Gesamtenergieaufnahme ermitteln
			% (Summe aus L1, L2 und L3):
			data_e = sum([...
				data_info(3,1:6:end);...
				data_info(3,3:6:end);...
				data_info(3,5:6:end)],1); %#ok<COLND>
			% die Energiebeträge sortieren, die Indexliste I übernehmen:
			[~, I] = sort(data_e);
			num_hh_cont = numel(I);
			idx = round(num_hh_cont/4);
			pool = 1:idx;   % Liste mit Indizes der möglichen Datensätze
			pool = I(pool);
			idx = zeros(number_hh,1); % Liste mit Indizes der ausgewählten Datensätze
			                          % (mit 0 intialisieren)
			for j = 1:number_hh
				% Erzeugen einer Zufallszahl im Bereich [1, Anz._verf._Datensätze]
				fortu = round(rand()*(numel(pool)-1))+1;
				idx(j) = pool(fortu); % diesen Index in Indexliste aufnehmen
				% gezogenen Datensatz aus der Auswahlmöglickeit entfernen (damit er
				% nicht mehr gezogen werden kann):
				pool(fortu) = [];
			end
		case 'E_050' %0.25-0.5 Anteil Energieverbrauch (1. Viertel)
			% aus den Phasenenergieaufnahmen die Gesamtenergieaufnahme ermitteln
			% (Summe aus L1, L2 und L3):
			data_e = sum([...
				data_info(3,1:6:end);...
				data_info(3,3:6:end);...
				data_info(3,5:6:end)],1); %#ok<COLND>
			% die Energiebeträge sortieren, die Indexliste I übernehmen:
			[~, I] = sort(data_e);
			num_hh_cont = numel(I);
			idx_start = round(num_hh_cont/4)+1;
			idx_end = round(num_hh_cont/2);
			pool = idx_start:idx_end;   % Liste mit Indizes der möglichen Datensätze
			pool = I(pool);
			idx = zeros(number_hh,1); % Liste mit Indizes der ausgewählten Datensätze
			                          % (mit 0 intialisieren)
			for j = 1:number_hh
				% Erzeugen einer Zufallszahl im Bereich [1, Anz._verf._Datensätze]
				fortu = round(rand()*(numel(pool)-1))+1;
				idx(j) = pool(fortu); % diesen Index in Indexliste aufnehmen
				% gezogenen Datensatz aus der Auswahlmöglickeit entfernen (damit er
				% nicht mehr gezogen werden kann):
				pool(fortu) = [];
			end
		case 'E_075' %0.5-0.75 Anteil Energieverbrauch (1. Viertel)
			% aus den Phasenenergieaufnahmen die Gesamtenergieaufnahme ermitteln
			% (Summe aus L1, L2 und L3):
			data_e = sum([...
				data_info(3,1:6:end);...
				data_info(3,3:6:end);...
				data_info(3,5:6:end)],1); %#ok<COLND>
			% die Energiebeträge sortieren, die Indexliste I übernehmen:
			[~, I] = sort(data_e);
			num_hh_cont = numel(I);
			idx_start = round(num_hh_cont/2)+1;
			idx_end = round(num_hh_cont*0.75);
			pool = idx_start:idx_end;   % Liste mit Indizes der möglichen Datensätze
			pool = I(pool);
			idx = zeros(number_hh,1); % Liste mit Indizes der ausgewählten Datensätze
			                          % (mit 0 intialisieren)
			for j = 1:number_hh
				% Erzeugen einer Zufallszahl im Bereich [1, Anz._verf._Datensätze]
				fortu = round(rand()*(numel(pool)-1))+1;
				idx(j) = pool(fortu); % diesen Index in Indexliste aufnehmen
				% gezogenen Datensatz aus der Auswahlmöglickeit entfernen (damit er
				% nicht mehr gezogen werden kann):
				pool(fortu) = [];
			end
		case 'E_100' %0.75-1.0 Anteil Energieverbrauch (1. Viertel)
			% aus den Phasenenergieaufnahmen die Gesamtenergieaufnahme ermitteln
			% (Summe aus L1, L2 und L3):
			data_e = sum([...
				data_info(3,1:6:end);...
				data_info(3,3:6:end);...
				data_info(3,5:6:end)],1); %#ok<COLND>
			% die Energiebeträge sortieren, die Indexliste I übernehmen:
			[~, I] = sort(data_e);
			num_hh_cont = numel(I);
			idx_start = round(num_hh_cont*0.75)+1;
			idx_end = num_hh_cont;
			pool = idx_start:idx_end;   % Liste mit Indizes der möglichen Datensätze
			pool = I(pool);
			idx = zeros(number_hh,1); % Liste mit Indizes der ausgewählten Datensätze
			                          % (mit 0 intialisieren)
			for j = 1:number_hh
				% Erzeugen einer Zufallszahl im Bereich [1, Anz._verf._Datensätze]
				fortu = round(rand()*(numel(pool)-1))+1;
				idx(j) = pool(fortu); % diesen Index in Indexliste aufnehmen
				% gezogenen Datensatz aus der Auswahlmöglickeit entfernen (damit er
				% nicht mehr gezogen werden kann):
				pool(fortu) = [];
			end
		otherwise
			disp('Unbekannter Auswahlmodus!');
			return;
	end
	% die ermittelten Indizes sortieren (für effektiveres Abarbeiten):
	idx = sort(idx);
	% nun die einzelnen Datensätze aus den jeweiligen Teildateien laden:
	for j=1:ceil(num_data_sets/max_num_data_set)
		% jene Indizes ermitteln, die in aktueller Teil-Datei enthalten sind
		idx_part = idx(idx > (j-1)*max_num_data_set & idx <= j*max_num_data_set);
		if isempty(idx_part)
			% sind keine Daten in dieser Datei, die ausgelesen werden müssen, diese
			% überspringen:
			continue;
		end
		% die Indizes der Datenspalten erstellen: jeder Datensatz besteht aus 6
		% Spalten (3x Wirk-, 3x Blindleistung):
		idx_part_real = repmat((idx_part-1)*6,[1,6])+repmat(1:6,[size(idx_part,1),1]);
		idx_part_real = sort(reshape(idx_part_real,1,[]));
		% Indexzahl korrigieren (der Index der geladenen Daten geht nur von
		% 1:max_num_datasets):
		idx_part_real = idx_part_real - (j-1)*6*max_num_data_set;
		% Name der aktuellen Teil-Datei:
		name = ['Load',sep,season,sep,weekda,sep,system.housholds{i,1},sep,...
			num2str(j,'%03.0f')];
		% Daten laden (Variable "data_phase")
		load([path,filesep,name,'.mat']);
		% je nach Einstellungen, die relevanten Daten auslesen:
		if settin.get_Sample_Value
			data_sample = data_phase(1:time_res:end,idx_part_real);
			% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
			Households.Data_Sample = [Households.Data_Sample,...
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
			data_phase = data_phase(1:end-1,idx_part_real);
			data_mean = reshape(data_phase,...
				time_res,[],size(data_phase,2));
			% eingelesenen Daten wieder löschen (Speicher freigeben!)
			clear data_phase;
		end
		if settin.get_Min_Value
			data_min = squeeze(min(data_mean));
			% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
			Households.Data_Min = [Households.Data_Min,...
				data_min];
			% eingelesenen Daten wieder löschen (Speicher freigeben!)
			clear data_min;
		end
		if settin.get_Max_Value
			data_max = squeeze(max(data_mean));
			% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
			Households.Data_Max = [Households.Data_Max,...
				data_max];
			% eingelesenen Daten wieder löschen (Speicher freigeben!)
			clear data_max;
		end
		if settin.get_05_Quantile_Value
			data_05q = squeeze(quantile(data_mean,0.05));
			% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
			Households.Data_05P_Quantil = [...
				Households.Data_05P_Quantil,...
				data_05q];
			% eingelesenen Daten wieder löschen (Speicher freigeben!)
			clear data_05q;
		end
		if settin.get_95_Quantile_Value
			data_95q = squeeze(quantile(data_mean,0.95));
			% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
			Households.Data_95P_Quantil = [...
				Households.Data_95P_Quantil,...
				data_95q];
			% eingelesenen Daten wieder löschen (Speicher freigeben!)
			clear data_95q;
		end
		if settin.get_Mean_Value
			data_mean = squeeze(mean(data_mean));
			% die ausgelesenen Daten zum bisherigen Ergebnis hinzufügen:
			Households.Data_Mean = [Households.Data_Mean,...
				data_mean];
			% eingelesenen Daten wieder löschen (Speicher freigeben!)
			clear data_mean
		end
	end
end

% also store the number of different households (the allocation) for later
% use:
Households.Number = handles.Current_Settings.Data_Extract.Households;

% Zugriff auf das Datenobjekt:
d = handles.NAT_Data;

% Ergebnis zurückschreiben:
if isempty(idx_act)
	% Es wird nur ein Datensatz generiert:
	d.Load_Infeed_Data.Set_1.Households = Households;
	d.Load_Infeed_Data.Set_1.Table_Network = handles.Current_Settings.Table_Network;
else
	d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Households = Households;
	d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Table_Network = handles.Current_Settings.Table_Network;
end

