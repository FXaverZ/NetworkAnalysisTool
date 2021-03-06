function data_phase = model_pv_tra(plant, content, data_cloud_factor, ...
	radiation_data, month)
%MODEL_PV_TRA    Modell eines PV-Trackers 
%    DATA_PHASE = MODEL_PV_TRA(PLANT, CONTENT, DATA_CLOUD_FACTOR, RADIATION_DATA,...
%    MONTH) ermittelt aus den �bergebenen Einstrahlungsdaten (RADIATION_DATA
%    mit dem Inhalten definiert in der Struktur CONTENT) und den
%    Bew�lkungsfaktoren DATA_CLOUD_FACTOR f�r den Monat MONTH (1...12) die
%    eingespeiste Leistung DATA_PHASE ([t,6]-Matrix f�r t Zeitpunkte).
%    Die Anlagenparamerter, nach der diese Berechnung durchgef�hrt wird, sind in der
%    Struktur PLANT enthalten.

% Erstellt von:            Franz Zeilinger - 28.06.2012
% Letzte �nderung durch:   Franz Zeilinger - 10.01.2018

% % ---  FOR DEBUG OUTPUTS  ---
% function data_phase = model_pv_tra(plant, content, data_cloud_factor, ...
% 	radiation_data, month, xls)
% % --- --- --- --- --- --- ---

% Daten auslesen, zuerst die Zeit (ist f�r alle Orientierungen und Neigungen gleich,
% daher wird diese nur vom ersten Element ausgelesen):
idx = strcmpi(content.dat_typ,'Time');
time = squeeze(radiation_data(month,idx,:))';
% Strahlungsdaten (nur jene Zeitpunkte, die gr��er Null sind (= nicht vorhandene
% Elemente)):
idx = strcmpi(content.dat_typ,'DirectClearSyk_Irradiance');
data_dir = squeeze(radiation_data(month,idx,time>0))';
idx = strcmpi(content.dat_typ,'Diffuse_Irradiance');
data_dif = squeeze(radiation_data(month,idx,time>0))';
% Temperatur:
% temp = squeeze(Radiation_fixed_Plane(month,2,time>0));
% Vektoren, mit den St�tzstellen der Daten f�r die Interpolation erstellen:
time = time(time > 0); % Zeitpunkte = 0 --> keine Daten sind vorhanden
% neue Zeit mit Sekundenaufl�sung:
time_fine = time(1):1/86400:time(end);
% Interpolieren der Zeitreihen, zuerst direkte Einstrahlung:
rad_dir = interp1(time,data_dir,time_fine,'linear');
% dann die diffuse Strahlung:
rad_dif = interp1(time,data_dif,time_fine,'linear');

% Zeitpunkte vor Sonnenauf- und Untergang hinzuf�gen (Strahlung = 0):
time_add_fine = 0:1/86400:time(1);
time_add_fine = time_add_fine(1:end-1); % letzter Zeitpunkt ist bereits vorhanden.
rad_add_fine = zeros(size(time_add_fine));
rad_dir = [rad_add_fine, rad_dir];
rad_dif = [rad_add_fine, rad_dif];

time_add_fine = time(end):1/86400:(1+1/86400);
time_add_fine = time_add_fine(2:end); % erster Zeitpunkt ist bereits vorhanden.
rad_add_fine = zeros(size(time_add_fine));
rad_dir = [rad_dir, rad_add_fine];
rad_dif = [rad_dif, rad_add_fine];

% % ---  FOR DEBUG OUTPUTS  ---
% rad_dir_d = rad_dir';
% rad_dif_d = rad_dif';
% xls.set_worksheet('rad_dir');
% xls.write_values(rad_dir_d);
% xls.reset_row;
% xls.set_worksheet('rad_dif');
% xls.write_values(rad_dif_d);
% xls.reset_row;
% % --- --- --- --- --- --- ---

% Nun liegen die Strahlungswerte in Sekundenaufl�sung f�r 24h vor interpoliert auf
% die Neigung und Orientierung der betrachteten Solaranlagen. Mit diesen Daten werden
% nun die PV-Anlagen simuliert:
data_phase = zeros(size(rad_dir,2),6*plant.Number);
for i=1:plant.Number
	% Anschluss der Anlage an eine Phase ermitteln:
	[phase_idx, powr_factor] = plant_get_phase_allocation(plant);
	% Die Wolkeneinflussdaten innerhalb einer gewissen Zeitspanne verschieben, weil 
	% nicht alle Anlagen am gleichen Ort installiert sind. Dadurch, dass in den
	% Nachststunden keine Strahlung vorhanden ist, k�nnen die fehlenden Werte einfach
	% mit Null ersetzt werden:
	% Gaussche Verteilung angegebener Standardabweichung:
	delay = round((0.5-rand())*plant.Sigma_delay_time);
	if delay < 0
		data_cloud_factor_dev = data_cloud_factor(abs(delay):end);
		data_cloud_factor_dev(end+1:86401) = 0;
	else
		data_cloud_factor_dev = data_cloud_factor(1:end-delay);
		data_cloud_factor_dev = [zeros(delay,1);data_cloud_factor_dev]; %#ok<AGROW>
	end
	
	% Gesamte Einstrahlung ermitteln (setzt sich aus globaler und giffuser Strahlung
	% zusammen):
	% zuerst direkte Einstrahlung (abgeschw�cht durch Wolkeneinfluss):
	rad_dir = rad_dir .* (1-data_cloud_factor_dev');
	% diffuse Einstrahlung:
	rad_dif = rad_dif .* data_cloud_factor_dev';
	% Gesamte Einstrahlung:
	rad_total = rad_dir + rad_dif;
	
	% Leistungsarrays initialisieren:
	power_active = zeros(size(rad_total,2),3);
	power_reacti = power_active;
	% Leistungseinspeisung berechnen:
	power_active(:,phase_idx) = repmat((rad_total*...
		plant.Power_Installed*plant.Rel_Size_Collector*...
		plant.Efficiency) / powr_factor, powr_factor, 1)';
	% die Daten speichern, [P_L1, Q_L1, P_L2, ...]:
	data_phase(:,(1:2:6)+6*(i-1)) = power_active;
	data_phase(:,(2:2:6)+6*(i-1)) = power_reacti;
end
end

