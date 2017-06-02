%---------------+--------------------------------------------+-----------------------
%               | ERSTE GEHVERSUCHE ANALYSETOOL FÜR NS-NETZE |
%               +--------------------------------------------+
%
%    Einbindung von Smart-Grid_Controllern in SINCAL-Simulation und automatisierte
%    Berechnung dieser. Ziel dieses Programm ist das erste rudimentäre Testen dieser
%    Funktionalität und das bereitstellen einer ersten Test- und Implementierungs-
%    umgebung. 
%------------------------------------------------------------------------------------

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 30.10.2012
% Letzte Änderung durch:   Franz Zeilinger - 14.11.2012

%====================================================================================
% Einstellmöglichkeiten:
%====================================================================================

% Daten (Pfad des .sin-Files und Name) des zu betrachtetenden Netzes:
Grid.path = 'D:\Projekte\Analysetool für NS-Netze\4_Netzanalysetool\Netze';
Grid.name = 'Test_NS_50_Knoten_o_PV';

% Name der Lastdaten, die herangezogen werden sollen:
Options.Load_Data.name = 'Last+PV_SMARTY_Siedlung_5mi_Sommer_Werktag_3';
Options.Load_Data.path = 'D:\Projekte\Analysetool für NS-Netze\4_Netzanalysetool\EDLEM_Daten';

% Welche Art von Lastdaten sollen verwendet werden?
%    'mean'   = Mittelwerte
%    'sample' = Samplewerte
%    'max'    = Maximalwerte
%    'min'    = Minimalwerte
Options.Load_Data.kind = 'max';

% Definieren der Simulations-Parameter:
Parameters = {...
	'Calculation_method', 'LF_USYM',...  % Unsymmetrischer Lastfluss
	'Batch_mode',          4,...         % Laden aus reeller in virt. Datenbank, Speichern in virtuelle Datenbank
	'Database_typ',       'DB_EL',...    % Datenbanktyp "elektrisches Netz"
	'Language',           'DE',...       % Ausgabe der Meldungen in Deutsch
	'Grid_name',           Grid.name,... % s.o.
	'Grid_path',           Grid.path     % s.o.
	};
%====================================================================================

%------------------------------------------------------------------------------------
% Verschiedene vorbereitende Tätigkeiten:
%------------------------------------------------------------------------------------

% Pfad zu den Hilfsfunktionen dem MATLAB-Suchpfad hinzufügen:
addpath([pwd,filesep,'Functions']);

% Erzeugen der SINCAL-Instanz:
sin = SINCAL(Parameters{:});
% öffnen der Datenbank:
sin.open_database;

% Auslesen der aktuellen Tabelle mit Lasten (Load):
sin.table_data_load('Load');
% Auslesen der aktuellen Tabelle mit den Elementdaten (für den Namen der einzelnen
% Elemente) sowie der Anschluss(Terminal)- und Knoten(Node)-Daten:
sin.table_data_load('Element');
sin.table_data_load('Terminal');
sin.table_data_load('Node');

% Namen aller Lasten auslesen:
Grid.Load.names = sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Load',4),...
	strcmp(sin.Tables.Element(1,:),'Name')...
	);
Grid.Load.names = strtrim(Grid.Load.names);

% Die IDs aller Lasten auslesen:
Grid.Load.ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Load',4),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));

% Die Knoten-IDs der Lasten auslesen:
Grid.Load.node_ids = zeros(size(Grid.Load.ids));
col_1 = strcmp(sin.Tables.Terminal(1,:),'Element_ID');
col_2 = strcmp(sin.Tables.Terminal(1,:),'Node_ID');
for i = 1:numel(Grid.Load.ids)
	idx = find(cell2mat(sin.Tables.Terminal(...
		2:end,col_1)...
		)==Grid.Load.ids(i));
	Grid.Load.node_ids (i) = sin.Tables.Terminal{idx+1,col_2};
end

% Namen sortieren (aufsteigend):
[Grid.Load.names, IX] = sort(Grid.Load.names);
Grid.Load.ids = Grid.Load.ids(IX);
Grid.Load.node_ids = Grid.Load.node_ids(IX);

% laden der EDLEM-Lastdaten:
load([Options.Load_Data.path,filesep,Options.Load_Data.name,'.mat']);

% Zuordnung der Profile zu den Lasten treffen (Versuch, die einzelnen
% Haushaltsklassen über die Stränge zu verteilen:
for i=1:numel(Grid.Load.ids)
	Grid.Load.profile_nr(i) =  mod((i-1)*4,numel(Grid.Load.ids));
end
Grid.Load.profile_nr(Grid.Load.profile_nr==0) = numel(Grid.Load.ids);

% Welche Daten werden herangezogen (nur die ersten 20 Werte einlesen!)?
switch lower(Options.Load_Data.kind)
	case 'max'
		Grid.Load.Data = data_hh_max(61:80,:);
	case 'min'
		Grid.Load.Data = data_hh_min(61:80,:);
	case 'sample'
		Grid.Load.Data = data_hh_sample(61:80,:);
	case 'mean'
% 		data_hh_mean(1:20,:) = 0; %for debugging
		Grid.Load.Data = data_hh_mean(61:80,:);
end
% Die Daten an SINCAL anpassen (Leistungen in MW):
Grid.Load.Data = Grid.Load.Data/1e6;
% Wieviele Zeitpunkte werden berechnet?
Options.timepoints = size(Grid.Load.Data,1);

%------------------------------------------------------------------------------------
% Controller in Netz einfügen:
%------------------------------------------------------------------------------------

%Indizes der Lasten, die mit Spannungsregler ausgestattet werden sollen:
idx = [9, 13, 23]; 
% Leeres Array mit Controllern erzeugen:
SG_Componentes.Controller = U_Control.empty(0,numel(idx));
% Spannungsregler an Lastanschlüsse "anschließen":
for i=1:numel(idx)
	SG_Componentes.Controller(i) = U_Control(sin, Grid.Load.node_ids(idx(i)));
	SG_Componentes.Controller(i).Load_ID = Grid.Load.ids(idx(i));
	SG_Componentes.Controller(i).Load_IDX = idx(i);
end

%------------------------------------------------------------------------------------
% Eigentliche Simulation des Netzes mit den Controllern:
%------------------------------------------------------------------------------------

% Lastfluss einmal rechnen, um Tabellen zu befüllen:
sin.start_calculation;
% Ergebnisse laden (um eine Beispieltabelle zu haben):
sin.table_data_load('ULFNodeResult');

% Die Ergebnis Arrays vorbereiten:
%    Spannungen ohne Regler:
Grid.Load.node_voltage = zeros(size(Grid.Load.ids,1),3,Options.timepoints);
%    Spannungen mit Regler:
Grid.Load.node_voltage_reg = Grid.Load.node_voltage;
% Bezeichnungen und Indizes der Spannungen ermitteln:
col_1 = strcmp(sin.Tables.ULFNodeResult(1,:),'Node_ID');
col_2 = [...
	find(strcmp(sin.Tables.ULFNodeResult(1,:),'U1'),1),...
	find(strcmp(sin.Tables.ULFNodeResult(1,:),'U2'),1),...
	find(strcmp(sin.Tables.ULFNodeResult(1,:),'U3'),1),...
	];

tic; %Zeitmessung start
for k=1:Options.timepoints
	% ------------------------------------
	% Zunächst Fall ohne Regelung rechnen:
	% ------------------------------------
	
	% Dazu die Original-Lastdaten einstellen:
	for i=1:numel(Grid.Load.ids)
		% Welche Last soll verändert werden?
		idx_load = Grid.Load.ids(i);
		% Das betreffende Lastobjekt laden:
		LoadObj = sin.Simulation.GetObj('LOAD', idx_load);
		% Die Lastgangdaten eintragen:
		LoadObj.set('Item','P1',Grid.Load.Data(k,Grid.Load.profile_nr(i)+0));
		LoadObj.set('Item','Q1',Grid.Load.Data(k,Grid.Load.profile_nr(i)+1));
		LoadObj.set('Item','P2',Grid.Load.Data(k,Grid.Load.profile_nr(i)+2));
		LoadObj.set('Item','Q2',Grid.Load.Data(k,Grid.Load.profile_nr(i)+3));
		LoadObj.set('Item','P3',Grid.Load.Data(k,Grid.Load.profile_nr(i)+4));
		LoadObj.set('Item','Q3',Grid.Load.Data(k,Grid.Load.profile_nr(i)+5));
	end
	
	% Lastfluss rechnen:
	sin.start_calculation;

	% alle Last-Knoten-Spannungen auslesen:
	sin.table_data_load('ULFNodeResult');
	for i = 1:numel(Grid.Load.node_ids)
		idx = find(cell2mat(sin.Tables.ULFNodeResult(2:end,col_1)) == ...
			Grid.Load.node_ids(i));
		Grid.Load.node_voltage(i,:,k) = [sin.Tables.ULFNodeResult{idx+1,col_2}];
	end
	
	% ------------------------------------
	% Nun mit Regelung
	% ------------------------------------
	
	% Vorbereitungen, ev. Einstellungen der Regeler vom letzten Mal wieder laden und
	% die Lasten anpassen:
	for i=1:numel(SG_Componentes.Controller)
		% auslesen des Lastindexes (nicht von SINCAL sondern von hier!) --> noch
		% nicht ganz sauber!
		LoadID = SG_Componentes.Controller(i).Load_IDX;
		% Leistungsarrays erstellen:
		P_L = Grid.Load.Data(k,Grid.Load.profile_nr(LoadID)+(0:2:5)); %[ P1, P2, P3]
		Q_L = Grid.Load.Data(k,Grid.Load.profile_nr(LoadID)+(1:2:5)); %[ Q1, Q2, Q3]
		% Leistungen der Lasten anpassen:
		SG_Componentes.Controller(i).adjust_power(P_L, Q_L)
	end
	
	% einen Lastfluss rechnen:
	sin.start_calculation;
	
	% Die aktuellen Spannungen ermitteln...
	for i=1:numel(SG_Componentes.Controller)
		SG_Componentes.Controller(i).get_voltages_node;
	end
	% ... und diese speichern. Die Regelung ist "eingeschwungen", wenn die Differenz
	% der Spannungen an den geregelten Knoten des aktuellen Rechenschrittes (VOLTAGE)
	% und des vorhergehenden (VOLTAGE_OLD) einen gewissen Schwellwert unterschreitet
	voltage_old = reshape(cell2mat({SG_Componentes.Controller.Voltages}),[],3);
	
	% Regelung durchführen (iterativ):
	run = 1;       % Laufbedingung für while-Schleife (wird dort überprüft)
	while_idx = 1; % Sicherheits-Zähler, falls Endlos-Schleife produziert!
	while run == 1 && while_idx <= 10000 
		
		% jeder Controller führt eine Änderung der Lastdaten druch, je nach Situation
		% an seinem Knoten:
		for i=1:numel(SG_Componentes.Controller)
			% Regelungsberechnungen durchführen (ermitteln von delta_P und delta_Q):
			SG_Componentes.Controller(i).regulate;
			% auslesen des Lastindexes (nicht von SINCAL sondern von hier!) --> noch
			% nicht ganz sauber!
			LoadID = SG_Componentes.Controller(i).Load_IDX;
			% Leistungsarrays erstellen:
			P_L = Grid.Load.Data(k,Grid.Load.profile_nr(LoadID)+(0:2:5)); 
			Q_L = Grid.Load.Data(k,Grid.Load.profile_nr(LoadID)+(1:2:5)); 
			% Leistungen der Lasten anpassen:
			SG_Componentes.Controller(i).adjust_power(P_L, Q_L)
		end

		% Lastfluss rechnen:
		sin.start_calculation;
		
		% Die aktuellen Spannungen ermitteln
		for i=1:numel(SG_Componentes.Controller)
			SG_Componentes.Controller(i).get_voltages_node;
		end
		voltage = reshape(cell2mat({SG_Componentes.Controller.Voltages}),[],3);
		
		% Unterschreitet die Änderung einen gewissen Schwellwert? (z.B. < 0,1% der
		% Nennspannung?)
		if max(max(abs(voltage - voltage_old)))*sqrt(3)/400 < 0.000005
			% Falls ja: Regler sind "eingeschwungen", --> while-Schleife kann
			% verlassen werden:
			run = 0;
			
			% Das Endergebnis sicher, also alle Knoten-Spannungen auslesen:
			sin.table_data_load('ULFNodeResult');
			for i = 1:numel(Grid.Load.node_ids)
				idx = find(cell2mat(sin.Tables.ULFNodeResult(2:end,col_1)) == ...
					Grid.Load.node_ids(i));
				Grid.Load.node_voltage_reg(i,:,k) = [sin.Tables.ULFNodeResult{idx+1,col_2}];
			end
			% Information, wieviele Durchgänge notwendig waren:
			disp(['    ',num2str(while_idx),' Regler-Durchläufe benötigt']);
		else
			% Falls nein: nächster Schritt, aktuelle Spannungen für nächsten Schritt
			% speichern:
			voltage_old = voltage;
		end
		% Sicherheitszähler erhöhen:
		while_idx = while_idx + 1;
	end
	
	% Statusinfo zum Gesamtfortschritt an User:
	t = toc;
	progress = k/Options.timepoints;
	time_elapsed = t/progress - t;
	disp(['Lastfluss Nr. ',num2str(k),' von ',...
		num2str(Options.timepoints),' abgeschlossen. Laufzeit: ',...
		sec2str(t),...
		'. Verbleibende Zeit: ',...
		sec2str(time_elapsed)]);
end

% ------------------------------------
% Ausgabe des Ergebnisses:
% ------------------------------------

% Spannungen an den Konten, die geregelt wurden:
figure;
plot([squeeze(Grid.Load.node_voltage(9,:,:))',squeeze(Grid.Load.node_voltage_reg(9,:,:))']);
figure;
plot([squeeze(Grid.Load.node_voltage(13,:,:))',squeeze(Grid.Load.node_voltage_reg(13,:,:))']);
figure;
plot([squeeze(Grid.Load.node_voltage(23,:,:))',squeeze(Grid.Load.node_voltage_reg(23,:,:))']);
