function handles = loaddata_get(handles)
%LOADDATA_GET Summary of this function goes here
%   Detailed explanation goes here

% akutelle Daten auslesen:

set(handles.push_load_data_get, 'Enable', 'off');
pause(.01);

Table_Data = handles.Current_Settings.Table_Network.Data;

% Anzahl der jeweiligen Haushalte ermitteln:
for i=1:size(handles.System.housholds,1)
	handles.Current_Settings.Households.(handles.System.housholds{i,1}).Number = ...
		sum(strcmp(handles.System.housholds{i,1},Table_Data(:,3)));
end

fprintf('\tAuslesen der Lastdaten...\n');
% Je nach Zeitreiheneinstellungen verfahren:
if handles.Current_Settings.Data_Extract.get_Time_Series
	% Auslesen einer Zeitreihe, d.h. mehrere Datensätz kombinieren
	% Wieviele Tage müssen ausgelesen werden?
	num_days = handles.Current_Settings.Data_Extract.Time_Series.Duration;
	num_days = ceil(num_days);
	date = handles.Current_Settings.Data_Extract.Time_Series.Date_Start;
	date = datenum(date, 'dd.mm.yyyy');
	for i = 1:num_days
		% aktuelle Jahreszeit und Tagestyp bestimmen:
		date = date + i - 1;
		wkd = weekday(date);
		switch wkd
			case 1 % Sonntag
				handles.Current_Settings.Weekday = logical([0 0 1]');
			case 2 % Montag
				handles.Current_Settings.Weekday = logical([1 0 0]');
			case 3 % Dienstag
				handles.Current_Settings.Weekday = logical([1 0 0]');
			case 4 % Mittwoch
				handles.Current_Settings.Weekday = logical([1 0 0]');
			case 5 % Donnerstag
				handles.Current_Settings.Weekday = logical([1 0 0]');
			case 6 % Freitag
				handles.Current_Settings.Weekday = logical([1 0 0]');
			case 7 % Samstag
				handles.Current_Settings.Weekday = logical([0 1 0]');
		end
		% Daten auslesen + hinzufügen zu bisherigen Daten:
		handles = get_data_households(handles);
% 		handles = get_data_solar(handles);
% 		handles = get_data_wind(handles);
	end
else
	% Auslesen eines Tages:
	handles = get_data_households(handles);
% 	handles = get_data_solar(handles);
% 	handles = get_data_wind(handles);
end

% Die Daten + zugehörige Einstellungen in aktuelles Netzverzeichnis speichern:
Load_Feed_Data = handles.Result.Households; %#ok<NASGU>
Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
Table_Network = handles.Current_Settings.Table_Network; %#ok<NASGU>
% Speicherort = aktulles Netzfile
grid = handles.Current_Settings.Grid;
file = handles.Current_Settings.Auto_Load_Feed_Data;
file.Path = [grid.Path,filesep,grid.Name,'_files'];

save([file.Path,filesep,file.Name,file.Exte],...
	'Load_Feed_Data', 'Data_Extract', 'Table_Network');
fprintf('\t\t--> erledigt!\n');

set(handles.push_load_data_get, 'Enable', 'on');

end

