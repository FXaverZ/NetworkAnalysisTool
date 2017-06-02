function handles = loaddata_get(handles)
%LOADDATA_GET Summary of this function goes here
%   Detailed explanation goes here

% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 12.04.2013

% akutelle Daten auslesen:


if handles.Current_Settings.Simulation.Number_Runs == 1
	% Ein einzelner Datensatz soll ausgelesen werden...
	fprintf('\tAuslesen der Lastdaten (für Einzeldurchlauf)...\n');
	
	% Anzahl der jeweiligen Haushalte ermitteln:
	for i=1:size(handles.System.housholds,1)
		handles.Current_Settings.Data_Extract.Households.(handles.System.housholds{i,1}).Number = ...
			sum(strcmp(handles.System.housholds{i,1},handles.Current_Settings.Table_Network.Data(:,3)));
	end
	
	settin = handles.Current_Settings;
	% Zunächst bisherige Daten zurücksetzen:
	handles.NAT_Data.Load_Infeed_Data = [];
	% Je nach Zeitreiheneinstellungen verfahren:
	if settin.Data_Extract.get_Time_Series
		% Auslesen einer Zeitreihe, d.h. mehrere Datensätz kombinieren
		% Wieviele Tage müssen ausgelesen werden?
		num_days = settin.Data_Extract.Time_Series.Duration;
		num_days = ceil(num_days);
		date = settin.Data_Extract.Time_Series.Date_Start;
		date = datenum(date, 'dd.mm.yyyy');
		for i = 1:num_days
			% aktuelle Jahreszeit und Tagestyp bestimmen:
			date = date + i - 1;
			wkd = weekday(date);
			switch wkd
				case 1 % Sonntag
					settin.Weekday = logical([0 0 1]');
				case 2 % Montag
					settin.Weekday = logical([1 0 0]');
				case 3 % Dienstag
					settin.Weekday = logical([1 0 0]');
				case 4 % Mittwoch
					settin.Weekday = logical([1 0 0]');
				case 5 % Donnerstag
					settin.Weekday = logical([1 0 0]');
				case 6 % Freitag
					settin.Weekday = logical([1 0 0]');
				case 7 % Samstag
					settin.Weekday = logical([0 1 0]');
			end
			% Daten auslesen + hinzufügen zu bisherigen Daten:
			get_data_households(handles);
			% 		handles = get_data_solar(handles);
			% 		handles = get_data_wind(handles);
		end
	else
		% Auslesen eines Tages:
		get_data_households(handles);
		get_data_solar(handles);
		% 	handles = get_data_wind(handles);
	end
	
	% Die Daten + zugehörige Einstellungen in aktuelles Netzverzeichnis speichern:
	Load_Infeed_Data = handles.NAT_Data.Load_Infeed_Data; %#ok<NASGU>
	Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
	% Speicherort = aktulles Netzfile
	file = handles.Current_Settings.Files.Auto_Load_Feed_Data;
	file.Path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_files'];
	
	save([file.Path,filesep,file.Name,file.Exte],...
		'Load_Infeed_Data', 'Data_Extract');
	fprintf('\t\t--> erledigt!\n');
else
	% es müssen mehrere Datensätze ausgelesen werden...
	% Anzahl an zu auszulesenden Datensätzen:
	num_set = handles.Current_Settings.Simulation.Number_Runs; 
	% Diese erstellen:
	fprintf('\tAuslesen der Lastdaten...\n');
	tic; %Zeitmessung start
	for i = 1:num_set
		% Zufällige Zuordnung treffen:
		handles = load_random_allocation(handles);
		% Daten auslesen und dem Input-Datensatz hinzufügen:
		get_data_households (handles, i);
		get_data_solar(handles, i);
		fprintf(['\t\tSatz ',num2str(i),' von ',num2str(num_set),' erledigt... ']);
		t = toc;
		progress = i/num_set;
		time_elapsed = t/progress - t;
		fprintf([' Laufzeit: ', sec2str(t),'. gesch. verbleibende Zeit: ',...
			sec2str(time_elapsed),'\n']);
	end
	% Die Daten + zugehörige Einstellungen in aktuelles Netzverzeichnis speichern:
	Load_Infeed_Data = handles.NAT_Data.Load_Infeed_Data; %#ok<NASGU>
	Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
	% Speicherort = aktulles Netzfile
	file = handles.Current_Settings.Files.Auto_Load_Feed_Data;
	file.Path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_files'];
	
	save([file.Path,filesep,file.Name,file.Exte],...
		'Load_Infeed_Data', 'Data_Extract');
	fprintf('\t\t--> erledigt!\n');
end
end

