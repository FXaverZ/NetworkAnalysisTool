function handles = network_calculation(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 05.02.2013
% Letzte Änderung durch:   Franz Zeilinger - 27.02.2013

Grid = handles.Grid;
Table_Data = handles.Current_Settings.Table_Network.Data;
Result = handles.Result;
Current_Settings = handles.Current_Settings;

%------------------------------------------------------------------------------------
% Übernehmen der akutell geladen Daten:
%------------------------------------------------------------------------------------
if Current_Settings.Data_Extract.get_Max_Value
	Grid.Load.Data = Result.Households.Data_Max;
	Grid.Sola.Data = Result.Solar.Data_Max;
end
if Current_Settings.Data_Extract.get_Min_Value
	Grid.Load.Data = Result.Households.Data_Min;
	Grid.Sola.Data = Result.Solar.Data_Min;
end
if Current_Settings.Data_Extract.get_Sample_Value
	Grid.Load.Data = Result.Households.Data_Sample;
	Grid.Sola.Data = Result.Solar.Data_Sample;
end
if Current_Settings.Data_Extract.get_Mean_Value
	Grid.Load.Data = Result.Households.Data_Mean;
	Grid.Sola.Data = Result.Solar.Data_Mean;
end

% Die Daten an SINCAL anpassen (Leistungen in MW und pos. bei Verbrauch):
Grid.Load.Data = Grid.Load.Data/1e6;
Grid.Sola.Data = Grid.Sola.Data/-1e6; %Einspeiser negativ!
% Wieviele Zeitpunkte werden berechnet?
Current_Settings.Simulation.Timepoints = size(Grid.Load.Data,1);

%------------------------------------------------------------------------------------
% Lasten ins Netz einfügen:
%------------------------------------------------------------------------------------
Grid.Load.Loads = Unit_Time_Dependent.empty(0,numel(Grid.P_Q_Node.ids));
hhs = Current_Settings.Data_Extract.Households;
for i=1:numel(Grid.P_Q_Node.ids)
	% Welcher Haushaltstyp soll angeschlossen werden?
	hh_typ = Table_Data{i,3};
	idx = find(strcmp(hh_typ,Result.Households.Content));
	idx = idx(hhs.(hh_typ).Number)-1;
	hhs.(hh_typ).Number = hhs.(hh_typ).Number - 1;
	% Last-Instanz erzeugen:
	obj = Unit_Time_Dependent(...
		Grid.P_Q_Node.Points(i),...                   % Anschlusspunkt-Objekt
		Grid.Load.Data(:,(idx*6)+1:(idx*6)+6));       % Lastgang des Last
% 	disp([Grid.P_Q_Node.Points(i).P_Q_Name,' --> ',hh_typ]);
	Grid.Load.Loads(i) = obj;
end

%------------------------------------------------------------------------------------
% Erzeuger einfügen
%------------------------------------------------------------------------------------
add_data = Current_Settings.Table_Network.Additional_Data;
num_unit = size(Grid.Sola.Data,2)/6;
Grid.Sola.Gen_Units = Unit_Time_Dependent.empty(0,num_unit);
plants = Current_Settings.Data_Extract.Solar.Plants;
gen_count = 1;
for i=1:numel(Grid.P_Q_Node.ids)
	gen_unit_name = add_data{i,1};
	if isempty(gen_unit_name)
		continue;
	end
	idx = find(strcmp(gen_unit_name,Result.Solar.Content));
	idx = idx(plants.(gen_unit_name).Number) - 1;
	plants.(gen_unit_name).Number = plants.(gen_unit_name).Number - 1;
	% Last-Instanz erzeugen:
	obj = Unit_Time_Dependent(...
		Grid.P_Q_Node.Points(i),...                   % Anschlusspunkt-Objekt
		Grid.Sola.Data(:,(idx*6)+1:(idx*6)+6));       % Lastgang des Last
	Grid.Sola.Gen_Units(gen_count) = obj;
	gen_count = gen_count + 1;
end

% ------------------------------------
% Zunächst Fall ohne Regelung rechnen:
% ------------------------------------

fprintf('\nStarte Netz-Simulation...\n');
Result.Grid.Load.node_voltage = zeros(...
	size(Grid.P_Q_Node.Points,2),3,Current_Settings.Simulation.Timepoints);
Result.Grid.Lines.currents = zeros(...
    numel(Grid.Branches.Lines),4,Current_Settings.Simulation.Timepoints);
tic; %Zeitmessung start
for k=1:Current_Settings.Simulation.Timepoints
	
	% Last- und Einspeisedaten aktualisieren:
	Grid.Load.Loads.update_power(k);
	Grid.Sola.Gen_Units.update_power(k);
	
	% der Berechnung die neuen Leistungswerte übermitteln:
	Grid.P_Q_Node.Points.update_power;
	
	% Lastfluss rechnen:
	handles.sin.start_calculation;
	
	% alle Last-Knoten-Spannungen auslesen:
	Grid.P_Q_Node.Points.update_voltage_node_LF_USYM;
	Result.Grid.Load.node_voltage(:,:,k) = vertcat(Grid.P_Q_Node.Points.Voltage);
    Grid.Branches.Lines.update_current_branch_LF_USYM;
    Result.Grid.Lines.currents(:,:,k) = vertcat(Grid.Branches.Lines.Current);
	
	% Statusinfo zum Gesamtfortschritt an User:
	t = toc;
	progress = k/Current_Settings.Simulation.Timepoints;
	time_elapsed = t/progress - t;
	fprintf(['\t\t\tLastfluss Nr. ',num2str(k),' von ',...
		num2str(Current_Settings.Simulation.Timepoints),' abgeschlossen. Laufzeit: ',...
		sec2str(t),...
		'. Verbleibende Zeit: ',...
		sec2str(time_elapsed),'\n']);
end
t = toc;
fprintf('\t\t--> erledigt!\n');
fprintf(['\tBerechnungen beendet nach ',sec2str(t)]);

handles.Current_Settings = Current_Settings;
handles.Grid = Grid;
handles.Result = Result;

handles = adopt_data_for_display(handles);

end

