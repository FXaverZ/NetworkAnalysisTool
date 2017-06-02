classdef Connection_Point < handle
	%CONNECTION_POINT    Klasse von Netzanschlusspunkten für anschlussfähige Objekte
	%    Detaillierte Beschreibung fehlt!
	
	% Erstellt von:            Franz Zeilinger - 14.01.2013
	% Letzte Änderung durch:   Franz Zeilinger - 16.01.2013
	
	properties
		P_Q_ID = [];
	%        ID des Objektes, über das die Leistungen aus dem Netz bezogen bzw.
	%        eingespeist werden. 
		P_Q_Obj = [];
	%        Berechnungsobjekt "Last", repräsentiert hier den Leistungsknoten (über P
	%        & Q wird bestimmt, wieviel Leistung an diesem Punkt dem Netz entnommen
	%        bzw. wie viel eingespeist wird). 
		P_Q_Name = [];
	%        Name des Lastanschlusspunktes in SINCAL
		Node_ID = [];
	%        ID des Knotens, an der diese Instanz des Controllers angeschlossen ist.
		Node_Obj = [];           
	%        Berechnungsobjekt des aktuellen Knotens.
		Node_Name = [];
	%        Name des Knotens des Lastanschlusspunktes in SINCAL.
		P_Q_Act = zeros(0,6);
	%        aktuelle Leistung im VZPS --> P > 0: entpr. Leistungsaufnahme (Last):
	%        Aufbau des Arrays [m,6], m = OBJ.NUM_UNITS_CONNECTED:
	%            [P_L1, Q_L1, P_L2, Q_L2, P_L3, Q_L3])
		Num_Units_Connected = 0;
	%        Anzahl an angeschlossenen Einheiten an diesem Knotenpunkt.
		Voltage = zeros(1,3);
	%        aktuelle Spannungswerte. Werden durch OBJ.GET_VOLTAGES_NODE
	%        aktualisiert mit den Spannungswerten des Knotens OBJ.NODE_ID. 
		powers_changed = false;
	%        Wahrheitswert, der angibt, ob eine Änderung der Leistungsdaten an diesem
	%        Knoten erfolgt ist (TRUE) bzw. aktuellen Lastdaten P_Q_ACT bereits im
	%        Berechnungsobjekt "Last" P_Q_OBJ eingetragen sind (FALSE).
		controller_finished = true;
	%        Wahrheitswert, der angibt, ob alle die an diesem Knotenpunkt
	%        angeschlossenen SG-Regler mit ihrer Regelaufgabe fertig sind 
	%            TRUE = alle Regler fertig --> Simulationspunkt fertig berechnet; 
	%            FALSE = Regler sind noch aktiv und haben noch keinen "stationären"
	%            Endwert erreicht!
	
	end
	
	methods
		function obj = Connection_Point(sin_ext, p_q_id_ext)
			%SG_CONTROLLER    Konstruktor der Klasse CONNECTION_POINT
			%    OBJ = CONNECTION_POINT (SIN_EXT, P_Q_ID_EXT) erzeugt eine Instanz
			%    der Klasse CONNECTION_POINT. Dazu wird ein Handel auf eine Instanz
			%    der Simulationssteuerungsklasse SINCAL (SIN_EXT) benötigt sowie die
			%    ID des Lastanschlusses, die diesen Verbindungspunkt spezifiziert.
			%    Mit diesen Daten werden sowohl die Berechnungsobjekte für den
			%    Lastanschluss (OBJ.P_Q_OBJ) als des Netzknotens dieses
			%    Lastanschlusspunktes (OBJ.NODE_OBJ) in die Instanz geladen und
			%    stehen damit für den Zugriff auf diese Objekte zur Verfügung.
			
			% ID des Leistungszugriffsobjekts speichern:
			obj.P_Q_ID = p_q_id_ext;
			% Berechnungsobjekt des Leistungszugriffsobjekts speichern:
			obj.P_Q_Obj = sin_ext.Simulation.GetObj('LOAD', obj.P_Q_ID);
			% Anschlusskonten-ID ermitteln:
			obj.Node_ID = obj.P_Q_Obj.get('Item','TOPO.Node1.DBID');
			obj.P_Q_Name = obj.P_Q_Obj.get('Item','TOPO.Name');
			% Das Berechnungsobjekt des Knotens speichern:
			obj.Node_Obj = sin_ext.Simulation.GetObj('NODE', obj.Node_ID);
			obj.Node_Name = obj.Node_Obj.get('Item','TOPO.Name');
		end
		
		function p_q = update_power(obj)
			% Auswahl aller Objekte, für die eine Änderung in der Leistungsaufnahme
			% vorliegt:
			obj_s = obj([obj.powers_changed]);
			% Über diese Elemente iterieren, das Berechnungsobjekt "Last"
			% aktualisieren sowie dies in OBJ.POWERS_CHANGED festhalten:
			for i=1:numel(obj_s)
				p_q = obj_s(i).P_Q_Act;
				p_q = sum(p_q,1);
				obj_s(i).P_Q_Obj.set('Item','P1',p_q(1));
				obj_s(i).P_Q_Obj.set('Item','Q1',p_q(2));
				obj_s(i).P_Q_Obj.set('Item','P2',p_q(3));
				obj_s(i).P_Q_Obj.set('Item','Q2',p_q(4));
				obj_s(i).P_Q_Obj.set('Item','P3',p_q(5));
				obj_s(i).P_Q_Obj.set('Item','Q3',p_q(6));
				obj_s(i).powers_changed = false;
			end
		end
		
		function voltage = update_voltage_node_LF_USYM (obj)
			%GET_VOLTAGES_NODE    aktualisieren der Spannungswerte
			%    genaue Beschreibung fehlt!
			for i = 1:numel(obj)
				voltage = zeros(1,3);
				LFNodeResultLoad = obj(i).Node_Obj.Result('ULFNodeResult', 0);
				voltage(1,1) = LFNodeResultLoad.get('Item','U1');
				voltage(1,2) = LFNodeResultLoad.get('Item','U2');
				voltage(1,3) = LFNodeResultLoad.get('Item','U3');
				voltage = voltage*1000; % Umrechnen von kV in V
				obj(i).Voltage = voltage;
			end
		end
		
		function voltage = update_voltages_node_LF_NR (obj)
			%GET_VOLTAGES_NODE    aktualisieren der Spannungswerte
			%    genaue Beschreibung fehlt!
			for i = 1:numel(obj)
				LFNodeResultLoad = obj(i).Node_Obj.Result('LFNodeResult', 0);
				voltage = LFNodeResultLoad.get('Item','U_Un');
				obj.Voltage = voltage;
			end
		end
	end
end

