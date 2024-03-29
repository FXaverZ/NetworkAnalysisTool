function get_data_solar (handles, varargin)
%GET_DATA_SOLAR    extrahiert und simuliert die Einspeise-Daten der Solaranlagen

% Version:                 2.2 - F�r Verwendung im NAT
% Erstellt von:            Franz Zeilinger - 04.07.2012
% Letzte �nderung durch:   Franz Zeilinger - 23.01.2019

system = handles.System;   % Systemvariablen
settin = handles.Current_Settings.Data_Extract; % aktuelle Einstellungen
db_fil = handles.Current_Settings.Load_Database;  % Datenbankstruktur
d = handles.NAT_Data; % Zugriff auf das Datenobjekt

max_num_data_set = db_fil.setti.max_num_data_set*6; % Anzahl an Datens�tzen in einer
%                                                     Teildatei --> da im Fall von
%                                                     Wetterdaten nur eine Spalte pro
%                                                     Zeitreihe (im Gegensatz zu
%                                                     sechs bei den Haushalten)
%                                                     ben�tigt wird, die Anzahl
%                                                     entsprechend erh�hen...
sep = db_fil.files.sep;    % Trenner im Dateinamen (' - ')

% die aktuellen Zeitdaten (Jahreszeit, Wochentag) auslesen:
season = system.seasons{settin.Season,1};

% zeitliche Aufl�sung ermitteln:
time_res = settin.Time_Resolution;
% Ergebnis-Arrays initialisieren:
Solar.Data_Sample = [];
Solar.Data_Mean = [];
Solar.Data_Min = [];
Solar.Data_Max = [];
Solar.Data_05P_Quantil = [];
Solar.Data_95P_Quantil = [];
% store the plants strukture for later use:
Solar.Plants = handles.Current_Settings.Data_Extract.Solar.Plants;

if nargin ==2
	% als Zweites Argument wurde ein aktueller Index �bergeben f�r eine
	% Generierung von mehreren Datens�tzen...
	idx_act = varargin{1};
else
	idx_act = [];
end

% Sind �berhaupt Solaranlagen angelegt?
if isempty(settin.Solar.Plants)
    % --> Nein, es m�ssen daher keine Daten ausgelesen werden:
    % (leeres) Ergebnis zur�ckschreiben:
	if isempty(idx_act)
		% Es wird nur ein Datensatz generiert, diese Direkt in die
		% Load-Infeed-Struktur einf�gen:
		d.Load_Infeed_Data.Set_1.Solar = Solar;
		d.Load_Infeed_Data.Set_1.Solar_Plants = handles.Current_Settings.Data_Extract.Solar;
		if ~isfield(d.Load_Infeed_Data.Set_1, 'Table_Network')
			d.Load_Infeed_Data.Set_1.Table_Network = handles.Current_Settings.Table_Network;
		end
	else
		d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Solar = Solar;
		d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Solar_Plants = handles.Current_Settings.Data_Extract.Solar;
		if ~isfield(d.Load_Infeed_Data.(['Set_',num2str(idx_act)]), 'Table_Network')
			d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Table_Network = handles.Current_Settings.Table_Network;
		end
	end
	% Funktion beenden:
	return;
end

% Gesamtanzahl der zu simulierenden Anlagen ermitteln:
plants = fieldnames(settin.Solar.Plants);
number_plants = 0;
for i=1:numel(plants)
	plant = settin.Solar.Plants.(plants{i});
	number_plants = number_plants + plant.Number;
end

% �berpr�fen, ob �berhaupt PV-Erzeugungsanlagen verarbeitet werden sollen:
if number_plants == 0
	% (leeres) Ergebnis zur�ckschreiben:
	if isempty(idx_act)
		% Es wird nur ein Datensatz generiert, diese direkt in die
		% Load-Infeed-Struktur einf�gen: 
		d.Load_Infeed_Data.Set_1.Solar = Solar;
		d.Load_Infeed_Data.Set_1.Solar_Plants = handles.Current_Settings.Data_Extract.Solar;
		if ~isfield(d.Load_Infeed_Data.Set_1, 'Table_Network')
			d.Load_Infeed_Data.Set_1.Table_Network = handles.Current_Settings.Table_Network;
		end
	else
		d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Solar = Solar;
		d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Solar_Plants = handles.Current_Settings.Data_Extract.Solar;
		if ~isfield(d.Load_Infeed_Data.(['Set_',num2str(idx_act)]), 'Table_Network')
			d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Table_Network = handles.Current_Settings.Table_Network;
		end
	end
	% Funktion beenden:
	return;
end

% Die Info-Datei laden:
path = [db_fil.Path,filesep,db_fil.Name,filesep,season,filesep,'Genera'];
name = ['Gene',sep,season,sep,'Solar',sep,'Cloud_Factor',sep,'Info'];
% Daten laden (Variable "data_info")
load([path,filesep,name,'.mat'],'data_info');
% wieviele Datens�tze gibt es insgesamt?
num_data_sets = size(data_info,2);

% Aus den allgemeinen Strahlungsdaten und den Analgenparametern die aktuellen
% Einstrahlungswerte interpolieren, dazu erst die entsprechenden Daten laden:
name = ['Gene',sep,season,sep,'Solar',sep,'Radiation'];
% Daten laden (Variable 'radiation_data_fix','radiation_data_tra' und 'Content'):
load([path,filesep,name,'.mat'],'radiation_data_fix','radiation_data_tra');

% Aufbau des Arrays f�r geneigte Fl�chen (fix montiert, 'radiation_data_fix'):
% 1. Dimension: Monat innerhalb einer Jahreszeit (je 4 Monate)
% 2. Dimension: Orientierung z.B. [-15�, 0�, 15�] (0� = S�d; -90� = Ost)
% 3. Dimension: Neigung z.B. [15�, 30�, 45�, 60�, 90�] (0�  = waagrecht,
%                                                        90� = senkrecht,
%                                                        trac = Tracker)
% 4. Dimension: Datenart [Zeit, Temperatur, Direkt, Diffus]
% 5. Dimension: Werte in W/m^2
%
% Beim Array f�r die nachgef�hrten Anlagen (Tracker, 'radiation_data_tra') entfallen
% die Dimensionen f�r "Orientierung" und "Neigung"!
%
% Die Struktur "db_fil.setti.content_sola_data" enth�lt die korrekten Bezeichnungen/Werte der einzelnen
% Dimensionen f�r die sp�tere Weiterverarbeitung (f�r Indexsuche bzw.
% Interpolationen). Aufbau siehe: 'create_radiation_array.m'

% je nach Einstellungen die Wetterdaten des aktuellen Tages einlesen:
switch settin.Worstcase_Generation
	case 1 % zuf�llige Auswahl
		% einen beliebigen Monat ausw�hlen:
		month_fix = vary_parameter((1:4)', 25*ones(1,4)', 'List');
		month_tra = month_fix;
		% Zuf�llig einen Wolkendatensatz ausw�hlen:
		pool = 1:num_data_sets; % Liste mit Indizes der m�glichen Datens�tze
		% Erzeugen einer Zufallszahl im Bereich [1, Anz._verf._Datens�tze]
		fortu = round(rand()*(numel(pool)-1))+1;
		idx = pool(fortu); % Dieser Index bezeichnet den ausgew�hlten Datensatz!
	case 2 % h�chste Tagesenergieeinspeisung
		% Monat ausw�hlen mit den h�chsten durchnschnittlichen Einstrahlungswerten
		% bei der direkten Einstrahlung. Exemplarisch wird die geringste Neigung und
		% S�dausrichtung herangezogen:
		idx_orient = db_fil.setti.content_sola_data.orienta == 0; % Index der S�dausrichtung
		idx_inclin = db_fil.setti.content_sola_data.inclina == min(Content.inclina); % Index der geringsten
		% Neigung
		% Anzahl der Datenpunkte jedes Monats ermitteln (d.h. Zeitwert > 0)
		num_datapoi = sum(squeeze(...
			radiation_data_fix(:,idx_orient, idx_inclin,1,:)) > 0,2);  
		% Durchschnittliche Einstrahlung ermitteln:
		e_avg_fix = sum(squeeze(...
			radiation_data_fix(:,idx_orient, idx_inclin,3,:)),2)./num_datapoi;
		e_avg_tra = sum(squeeze(radiation_data_tra(:,3,:)),2)./num_datapoi; 
		% Monat ausw�hlen, in dem die durchschnittliche Einstrahlung Maximal wird:
		month_fix = find(e_avg_fix == max(e_avg_fix),1); % Monat f�r fixe Anlagen
		month_tra = find(e_avg_tra == max(e_avg_tra),1); % Monat f�r Tracker
		
		% Datensatz mit der geringsten durchschnittlichen Bew�lkung finden:
		[~, I] = sort(data_info);
		idx = I(1);
	case 3 % niedrigste Tagesenergieeinspeisung
		% Monat ausw�hlen mit den geringsten durchnschnittlichen Einstrahlungswerten
		% bei der direkten Einstrahlung. Exemplarisch wird die geringste Neigung und
		% S�dausrichtung herangezogen:
		idx_orient = Content.orienta == 0; % Index der S�dausrichtung
		idx_inclin = Content.inclina == min(Content.inclina); % Index der geringsten
		% Neigung
		% Anzahl der Datenpunkte jedes Monats ermitteln (d.h. Zeitwert > 0)
		num_datapoi = sum(squeeze(...
			radiation_data_fix(:,idx_orient, idx_inclin,1,:)) > 0,2); 
		% Durchschnittliche Einstrahlung ermitteln:
		e_avg_fix = sum(squeeze(...
			radiation_data_fix(:,idx_orient, idx_inclin,3,:)),2)./num_datapoi;
		e_avg_tra = sum(squeeze(radiation_data_tra(:,3,:)),2)./num_datapoi; 
		% Monat ausw�hlen, in dem die durchschnittliche Einstrahlung Maximal wird:
		month_fix = find(e_avg_fix == min(e_avg_fix),1); % Monat f�r fixe Anlagen
		month_tra = find(e_avg_tra == min(e_avg_tra),1); % Monat f�r Tracker
		
		% Datensatz mit der h�chsten durchschnittlichen Bew�lkung finden:
		[~, I] = sort(data_info,'descend');
		idx = I(1);
		% 	case 4
end

% nun den ausgew�hlten Datensatz aus der richtigen Teildatei laden:
for j=1:ceil(num_data_sets/max_num_data_set)
	% jene Indizes ermitteln, die in aktueller Teil-Datei enthalten sind
	idx_part = idx(idx > (j-1)*max_num_data_set & idx <= j*max_num_data_set);
	if isempty(idx_part)
		% sind keine Daten in dieser Datei, die ausgelesen werden m�ssen, diese
		% �berspringen:
		continue;
	end
	% Indexzahl korrigieren (der Index der geladenen Daten geht nur von
	% 1:max_num_datasets je Datei):
	idx_part = idx_part - (j-1)*max_num_data_set;
	% Name der aktuellen Teil-Datei:
	name = ['Gene',sep,season,sep,'Solar',sep,'Cloud_Factor',sep,...
		num2str(j,'%03.0f')];
	% Daten laden (Variable 'data_cloud_factor')
	load([path,filesep,name,'.mat'],'data_cloud_factor');
	% die relevanten Daten auslesen:
	data_cloud_factor = data_cloud_factor(:,idx_part);
end
Solar.Content = cell(1,number_plants);
Content_count = 1;

% nun stehen f�r die Anlagen jeweils Einstrahlungsdaten sowie Wolkeneinflussdaten zur
% Verf�gung. Mit diesen Daten sowie den definierten Anlagenparametern werden nun die
% Anlagen simuliert:
for i=1:numel(plants)
	plant = settin.Solar.Plants.(plants{i});
	% Inhaltsverzeichnis der Daten erstellen:
	for j=1:plant.Number
		Solar.Content{1,Content_count} = plants{i};
		Content_count = Content_count + 1;
	end
	switch plant.Typ
		case 1 % Fix installierte Anlage
			data_phase = model_pv_fix(plant, db_fil.setti.content_sola_data, data_cloud_factor,...
				radiation_data_fix, month_fix);
		case 2 % Tracker
			data_phase = model_pv_tra(plant, data_cloud_factor,...
				radiation_data_tra, month_tra);
	end
	% je nach Einstellungen, die relevanten Daten auslesen:
	if settin.get_Sample_Value
		data_sample = data_phase(1:time_res:end,:);
		% die ausgelesenen Daten zum bisherigen Ergebnis hinzuf�gen:
		Solar.Data_Sample = [Solar.Data_Sample,...
			data_sample];
	end
	if settin.get_Mean_Value || ...
			settin.get_Min_Value || ...
			settin.get_Max_Value
		% Das urspr�ngliche Datenarray so umformen, dass ein 3D Array mit allen
		% Werten eines Zeitraumes in der ersten Dimension entsteht. Diese wird
		% dann durch die nachfolgenden Funktionen (mean, min, max) sofort in die
		% entsprechenden Werte umgerechnet. Mit squeeze muss dann nur mehr die
		% Singleton-Dimension entfernt werden...
		data_phase = data_phase(1:end-1,:);
		data_mean = reshape(data_phase,...
			time_res,[],size(data_phase,2));
		% eingelesenen Daten wieder l�schen (Speicher freigeben!)
		clear data_phase;
	end
	if settin.get_Max_Value
		data_max = squeeze(max(data_mean));
		% die ausgelesenen Daten zum bisherigen Ergebnis hinzuf�gen:
		Solar.Data_Max = [Solar.Data_Max,...
			data_max];
		% eingelesenen Daten wieder l�schen (Speicher freigeben!)
		clear data_max;
	end
	if settin.get_Min_Value
		data_min = squeeze(min(data_mean));
		% die ausgelesenen Daten zum bisherigen Ergebnis hinzuf�gen:
		Solar.Data_Min = [Solar.Data_Min,...
			data_min];
		% eingelesenen Daten wieder l�schen (Speicher freigeben!)
		clear data_min;
	end
	if settin.get_05_Quantile_Value
		data_05q = squeeze(quantile(data_mean,0.05));
		% die ausgelesenen Daten zum bisherigen Ergebnis hinzuf�gen:
		Solar.Data_05P_Quantil = [...
			Solar.Data_05P_Quantil,...
			data_05q];
		% eingelesenen Daten wieder l�schen (Speicher freigeben!)
		clear data_05q;
	end
	if settin.get_95_Quantile_Value
		data_95q = squeeze(quantile(data_mean,0.95));
		% die ausgelesenen Daten zum bisherigen Ergebnis hinzuf�gen:
		Solar.Data_95P_Quantil = [...
			Solar.Data_95P_Quantil,...
			data_95q];
		% eingelesenen Daten wieder l�schen (Speicher freigeben!)
		clear data_95q;
	end
	if settin.get_Mean_Value
		data_mean = squeeze(mean(data_mean));
		% die ausgelesenen Daten zum bisherigen Ergebnis hinzuf�gen:
		Solar.Data_Mean = [Solar.Data_Mean,...
			data_mean];
		% eingelesenen Daten wieder l�schen (Speicher freigeben!)
		clear data_mean
	end
end

% Ergebnis zur�ckschreiben:
if isempty(idx_act)
	% Es wird nur ein Datensatz generiert, diese Direkt in die
	% Load-Infeed-Struktur einf�gen:
	d.Load_Infeed_Data.Set_1.Solar = Solar;
	d.Load_Infeed_Data.Set_1.Solar_Plants = handles.Current_Settings.Data_Extract.Solar;
	if ~isfield(d.Load_Infeed_Data.Set_1, 'Table_Network')
		d.Load_Infeed_Data.Set_1.Table_Network = handles.Current_Settings.Table_Network;
	end
else
	d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Solar = Solar;
	d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Solar_Plants = handles.Current_Settings.Data_Extract.Solar;
	if ~isfield(d.Load_Infeed_Data.(['Set_',num2str(idx_act)]), 'Table_Network')
		d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Table_Network = handles.Current_Settings.Table_Network;
	end
end
end

