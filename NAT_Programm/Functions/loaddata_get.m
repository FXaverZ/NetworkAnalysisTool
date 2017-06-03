function handles = loaddata_get(handles)
%LOADDATA_GET Summary of this function goes here
%   Detailed explanation goes here

% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 12.04.2013

% bisherige Daten löschen:
handles.NAT_Data.Load_Infeed_Data = [];

if handles.Current_Settings.Simulation.Number_Runs == 1
	% Ein einzelner Datensatz soll ausgelesen werden...
	fprintf('\tAuslesen der Lastdaten (für Einzeldurchlauf)...\n');
else
	fprintf('\tAuslesen der Lastdaten...\n');
end

% es müssen mehrere Datensätze ausgelesen werden...
% Anzahl an zu auszulesenden Datensätzen:
num_set = handles.Current_Settings.Simulation.Number_Runs;
% Diese erstellen:
tic; %Zeitmessung start
for i = 1:num_set
	% Zufällige Zuordnung treffen:
	handles = load_random_allocation(handles);
	% Daten auslesen und dem Input-Datensatz hinzufügen:
	get_data_households(handles, i);
	get_data_solar(handles, i);
	get_data_elmob(handles, i);
	
	% Infos to the console:
	fprintf(['\t\tSatz ',num2str(i),' von ',num2str(num_set),' erledigt... ']);
	t = toc;
	progress = i/num_set;
	time_elapsed = t/progress - t;
	fprintf([' Laufzeit: ', sec2str(t),'. gesch. verbleibende Zeit: ',...
		sec2str(time_elapsed),'\n']);
end
fprintf('\t\t--> erledigt!\n');
end

