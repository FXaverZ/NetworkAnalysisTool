%---------------+--------------------------------------------+-----------------------
%               | ERSTE GEHVERSUCHE ANALYSETOOL FÜR NS-NETZE |
%               +--------------------------------------------+
%
%    Einbindung von Smart-Grid_Controllern in SINCAL-Simulation und automatisierte
%    Berechnung dieser. Ziel dieses Programm ist das erste rudimentäre Testen dieser
%    Funktionalität und das bereitstellen einer ersten Test- und Implementierungs-
%    umgebung. 
%------------------------------------------------------------------------------------

% Version:                 2.0
% Erstellt von:            Franz Zeilinger - 30.10.2012
% Letzte Änderung durch:   Franz Zeilinger - 21.01.2013

%------------------------------------------------------------------------------------
% Einstellmöglichkeiten:
%------------------------------------------------------------------------------------

% Daten (Pfad des .sin-Files und Name) des zu betrachtetenden Netzes:
Grid.path = 'D:\Projekte\Analysetool für NS-Netze\4_Netzanalysetool\Netze';
Grid.name = 'Test_NS_50_Knoten_o_PV';

% Name der Lastdaten, die herangezogen werden sollen:
Options.Load_Data.path = 'D:\Projekte\Analysetool für NS-Netze\4_Netzanalysetool\EDLEM_Daten';
Options.Load_Data.name = 'Last+PV_SMARTY_Siedlung_5mi_Sommer_Werktag_3';
Options.Load_Data.idx_Start = 61;
Options.Load_Data.idx_Stop = 80;%90;
% Options.Load_Data.name = 'Rohdaten_SMARTY_Siedlung_sec_Sommer_Werktag_3';
% Options.Load_Data.idx_Start = 17801;
% Options.Load_Data.idx_Stop = 19000;

% Welche Art von Lastdaten sollen verwendet werden?
%    'mean'   = Mittelwerte
%    'sample' = Samplewerte
%    'max'    = Maximalwerte
%    'min'    = Minimalwerte
Options.Load_Data.kind = 'max';

% Einstellungen der Spannungsregler:
Options.SG_Control.Parameters = {...
	'Setpoint',                ones(1,3)*400/sqrt(3),... %[220,220,230],...
	'Termination_Threshold',   0.01,...
	'dPmax_dStep',             500/1e6,...
	'dP_dV',                   200/1e6,...
	'P_max',                   2000/1e6,...
	'P_min',                   -2000/1e6,...
	'dP_min',                  0.1/1e6...
	'dQmax_dStep',             1000/1e6,...
	'dQ_dV',                   200/1e6,...
	'Q_max',                   1000/1e6,...
	'Q_min',                  -1000/1e6,...
	'dQ_min',                  0.1/1e6,...
	};

% Namen der Lasten, an die eine PV-Anlage angeschlossen ist:
Options.Gena_Data.PV_Locations = {...
	'G09';...
	'G12';...
	'G13';...
	'R05';...
	'R07';...
	'R10';...
	};

% % Namen der Lasten, an die ein Spannungsregler angeschlossen werden kann:
Options.SG_Control.P_Q_Points_U_Contr = {
	'G09';...
% 	'G12';...
% 	'G13';...
% 	'R05';...
% 	'R07';...
% 	'R10';...
	};

% Liste mit Namen der Punkte, die ausgegeben werden soll:
Options.Diagramms = {...
	'G09';...
% 	'R10';...
% 	'G12';...
	};

% Definieren der Simulations-Parameter:
Options.Simulation.Parameters = {...
	'Calculation_method', 'LF_USYM',...  % Unsymmetrischer Lastfluss
	'Batch_mode',          4,...         % Laden aus reeller in virt. Datenbank, Speichern in virtuelle Datenbank
	'Database_typ',       'DB_EL',...    % Datenbanktyp "elektrisches Netz"
	'Language',           'DE',...       % Ausgabe der Meldungen in Deutsch
	'Grid_name',           Grid.name,... % s.o.
	'Grid_path',           Grid.path     % s.o.
	};

%------------------------------------------------------------------------------------
% Verschiedene vorbereitende Tätigkeiten:
%------------------------------------------------------------------------------------

diary([pwd,filesep,'Log.txt']);

% Pfad zu den Hilfsfunktionen dem MATLAB-Suchpfad hinzufügen:
addpath([pwd,filesep,'Functions']);

% Erzeugen der SINCAL-Instanz:
sin = SINCAL(Options.Simulation.Parameters{:});
% öffnen der Datenbank:
sin.open_database;

% Auslesen der aktuellen Tabelle mit den Elementdaten
sin.table_data_load('Element');

% Element-IDs aller SINCAL-Lasten auslesen:
Grid.P_Q_Node.ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Load',4),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));

%------------------------------------------------------------------------------------
% Verbindungspunkte anlegen (jede Last im SINCAL-Netz entspricht einem Knoten, an dem
% eine Einheit angeschlossen werden kann a.k.a. Hausanschluss:
%------------------------------------------------------------------------------------
Grid.P_Q_Node.Points = Connection_Point.empty(numel(Grid.P_Q_Node.ids),0);
for i=1:numel(Grid.P_Q_Node.ids)
	Grid.P_Q_Node.Points(i) = Connection_Point(sin, Grid.P_Q_Node.ids(i));
end

%------------------------------------------------------------------------------------
% laden der EDLEM-Lastdaten für die Versuche:
%------------------------------------------------------------------------------------
load([Options.Load_Data.path,filesep,Options.Load_Data.name,'.mat']);
% Welche Daten werden herangezogen (nur 20 interessante Werte einlesen!)?
switch lower(Options.Load_Data.kind)
	case 'max'
		Grid.Load.Data = data_hh_max(...
			Options.Load_Data.idx_Start:Options.Load_Data.idx_Stop,...
			:);
		Grid.Gena.Data = data_pv_max(...
			Options.Load_Data.idx_Start:Options.Load_Data.idx_Stop,...
			:);
	case 'min'
		Grid.Load.Data = data_hh_min(Options.Load_Data.idx_Start:Options.Load_Data.idx_Stop,:);
		Grid.Gena.Data = data_pv_min(Options.Load_Data.idx_Start:Options.Load_Data.idx_Stop,:);
	case 'sample'
		Grid.Load.Data = data_hh_sample(Options.Load_Data.idx_Start:Options.Load_Data.idx_Stop,:);
		Grid.Gena.Data = data_pv_sample(Options.Load_Data.idx_Start:Options.Load_Data.idx_Stop,:);
	case 'mean'
% 		data_hh_mean(61:80,:) = 0; %for debugging
		Grid.Load.Data = data_hh_mean(Options.Load_Data.idx_Start:Options.Load_Data.idx_Stop,:);
		Grid.Gena.Data = data_pv_mean(Options.Load_Data.idx_Start:Options.Load_Data.idx_Stop,:);
end
% Die Daten an SINCAL anpassen (Leistungen in MW und pos. bei Verbrauch):
Grid.Load.Data = Grid.Load.Data/1e6;
Grid.Gena.Data = Grid.Gena.Data/-1e6;
% Wieviele Zeitpunkte werden berechnet?
Options.timepoints = size(Grid.Load.Data,1);

%------------------------------------------------------------------------------------
% Lasten und Einspeiser ins Netz einfügen:
%------------------------------------------------------------------------------------
% Last-Instanzen erzeugen und zu den jeweilingen Anschlusspunkten hinzufügen. Über
% eine Modulo 4 Operation wird versucht, möglichst gleichmäßig über das Netz zu
% verteilen:
Grid.Load.Loads = Unit_Time_Dependent.empty(0,numel(Grid.P_Q_Node.ids));
for i=1:numel(Grid.P_Q_Node.ids)
	idx = mod((i-1)*4,numel(Grid.P_Q_Node.ids));
	% Last-Instanz erzeugen:
	obj = Unit_Time_Dependent(...
		Grid.P_Q_Node.Points(i),...                   % Anschlusspunkt-Objekt
		Grid.Load.Data(:,(idx*6)+1:(idx*6)+6));       % Lastgang des Last
	Grid.Load.Loads(i) = obj;
end

%Position der SINCAL-Lasten, die mit PV-Anlagen ausgestattet werden sollen:
el_ids = find(ismember(...
	{Grid.P_Q_Node.Points.P_Q_Name},...
	Options.Gena_Data.PV_Locations));
Grid.Gena.Generators = Unit_Time_Dependent.empty(0,numel(el_ids));
for i=1:numel(el_ids)
	% Einspeise-Instanz erzeugen:
	obj = Unit_Time_Dependent(...
		Grid.P_Q_Node.Points(el_ids(i)),...           % Anschlusspunkt-Objekt
		Grid.Gena.Data(:,(i-1)*6+1:(i)*6));           % Zeitverlauf Einspeisung
	Grid.Gena.Generators(i) = obj;
end

%------------------------------------------------------------------------------------
% Controller in Netz einfügen:
%------------------------------------------------------------------------------------
%Position der SINCAL-Lasten, die mit Spannungsregler ausgestattet werden sollen:
el_ids = find(ismember(...
	{Grid.P_Q_Node.Points.P_Q_Name},...
	Options.SG_Control.P_Q_Points_U_Contr));
% 	Options.Gena_Data.PV_Locations));
% Leeres Array mit Controllern erzeugen:
SG_Componentes.Controller = PQU_Control.empty(0,numel(el_ids));
% Spannungsregler an Lastanschlüsse "anschließen":
for i=1:numel(el_ids)
	SG_Componentes.Controller(i) = PQU_Control(...
		Grid.P_Q_Node.Points(el_ids(i)),...
		Grid.Load.Loads(el_ids(i)),...
		Options.SG_Control.Parameters{:});
end

%------------------------------------------------------------------------------------
% Eigentliche Simulation des Netzes mit den Controllern:
%------------------------------------------------------------------------------------
% Die Ergebnis Arrays vorbereiten:
%    Spannungen ohne Regler:
Grid.Load.node_voltage = zeros(size(Grid.P_Q_Node.Points,2),3,Options.timepoints);
%    Spannungen mit Regler:
Grid.Load.node_voltage_reg = Grid.Load.node_voltage;
Grid.Load.d_P_Q_reg = zeros(numel(SG_Componentes.Controller),6,Options.timepoints);

% ------------------------------------
% Zunächst Fall ohne Regelung rechnen:
% ------------------------------------
disp('----');
disp('Starte Simulation ohne Regelung...');
tic; %Zeitmessung start
for k=1:Options.timepoints
	
	% Last- und Einspeisedaten aktualisieren:
	Grid.Load.Loads.update_power(k);
	Grid.Gena.Generators.update_power(k);
	
	% der Berechnung die neuen Leistungswerte übermitteln:
	Grid.P_Q_Node.Points.update_power;
	
	% Lastfluss rechnen:
	sin.start_calculation;
	
	% alle Last-Knoten-Spannungen auslesen:
	Grid.P_Q_Node.Points.update_voltage_node_LF_USYM;
	Grid.Load.node_voltage(:,:,k) = vertcat(Grid.P_Q_Node.Points.Voltage);
	
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
t = toc;
disp(['    Berechnungen beendet nach ',sec2str(t)]);

	
% ------------------------------------
% Nun mit Regelung
% ------------------------------------
disp('----');
disp('Starte Simulation mit Regelung...');
tic; %Zeitmessung start
for k=1:Options.timepoints
	
	% Last- und Einspeisedaten aktualisieren:
	Grid.Load.Loads.update_power(k);
	Grid.Gena.Generators.update_power(k);
	
	% der Berechnung die neuen Leistungswerte übermitteln:
	Grid.P_Q_Node.Points.update_power;
	
	% Lastfluss rechnen:
	sin.start_calculation;
	
	% Regelung durchführen (iterativ):
	run = 1;       % Laufbedingung für while-Schleife (wird dort überprüft)
	while_idx = 1; % Sicherheits-Zähler, falls Endlos-Schleife produziert!
	while run == 1 && while_idx <= 1000 
		
		% Spannungswerte aktualisieren:
		Grid.P_Q_Node.Points.update_voltage_node_LF_USYM;
		
		% Anschlusspunkte vorbereiten:
		[Grid.P_Q_Node.Points.controller_finished] = deal(true);
		
		% Regler einen Durchlauf machen lassen:
		SG_Componentes.Controller.regulate;
		
		% Sind alle Regler bereits fertig?
		if all([Grid.P_Q_Node.Points.controller_finished])
			
			% Falls ja: Regler sind "eingeschwungen", --> while-Schleife kann
			% verlassen werden:
			run = 0;
			
			% Das Endergebnis sicher, also alle Knoten-Spannungen auslesen:
			Grid.Load.node_voltage_reg(:,:,k) = vertcat(Grid.P_Q_Node.Points.Voltage);
			% erforderliche Leistungsänderungen auslesen:
			Grid.Load.d_P_Q_reg(:,:,k) = SG_Componentes.Controller.get_act_dp*1e6;
			
			% Information, wieviele Durchgänge notwendig waren:
			disp(['    ',num2str(while_idx),' Regler-Durchläufe benötigt']);
			
			% Die Vergleichswerte wieder zurücksetzen (für nächsten Zeitpunkt):
			[SG_Componentes.Controller.Values_Last_Step] = deal([]);
			
			% Schleife verlassen:
			continue;
		end
		
		% der Berechnung die neuen Leistungswerte übermitteln:
		Grid.P_Q_Node.Points.update_power;
		
		% Lastfluss rechnen:
		sin.start_calculation;	

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
t = toc;
disp(['    Berechnungen beendet nach ',sec2str(t)]);

% ------------------------------------
% Ausgabe des Ergebnisses:
% ------------------------------------

el_ids = find(ismember({Grid.P_Q_Node.Points.P_Q_Name},Options.Diagramms));
sg_ids = [SG_Componentes.Controller.Connection_Point];
sg_ids = find(ismember({sg_ids.P_Q_Name},Options.Diagramms));

for i = 1:numel(Options.Diagramms)
	figure;
	plot([squeeze(Grid.Load.node_voltage(el_ids(i),:,:))',...
		squeeze(Grid.Load.node_voltage_reg(el_ids(i),:,:))']);
	title(['Spannungen am P-Q-Anschlusspunkt ''',...
		Grid.P_Q_Node.Points(el_ids(i)).P_Q_Name,...
		'''']);
	legend({...
		'U_{L1}',...
		'U_{L2}',...
		'U_{L3}',...
		'U_{L1_{reg}}',...
		'U_{L2_{reg}}',...
		'U_{L3_{reg}}',...
		});
	if i <= numel(sg_ids)
		figure;
		plot(squeeze(Grid.Load.d_P_Q_reg(sg_ids(i),:,:))')
		title(['zus. Leistungen aufgrund der Regelung im P-Q-Anschlusspunkt ''',...
			SG_Componentes.Controller(sg_ids(i)).Connection_Point.P_Q_Name,...
			'''']);
		legend({...
			'P_{L1}',...
			'Q_{L1}',...
			'P_{L2}',...
			'Q_{L2}',...
			'P_{L3}',...
			'Q_{L3}',...
			});
	end
end

diary('off');
