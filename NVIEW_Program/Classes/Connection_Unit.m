classdef Connection_Unit < handle
	%CONNECTION_UNIT    Klasse anschlussfähiger Objekte eines Netzes (Last, Erz. ...)
	%    Detaillierte Beschreibung fehlt!
	%
	%    P R O P E R T I E S:
	%    
	%	 'Connection_Point'
	%        handle auf den Anschlusspunkt, an dem diese Objekt angeschlossen ist.
	%	 'P_Q_Act_idx'
	%        Zeilenindex des Leistungsarrays des Anschluss-Objekts, dass dieses
	%        Objekt bearbeiten darf/soll. 
	
	% Erstellt von:            Franz Zeilinger - 14.01.2013
	% Letzte Änderung durch:   Franz Zeilinger - 18.01.2013
	properties
		Connection_Point = [];
	%        handle auf den Anschlusspunkt, an dem diese Objekt angeschlossen ist.
		P_Q_Act_idx = 1;
	%        Zeilenindex des Leistungsarrays des Anschluss-Objekts, dass dieses
	%        Objekt bearbeiten darf/soll. 
	end
	
	methods
		
		function obj = Connection_Unit(cn_point)
			%CONNECTION_UNIT    Konstruktor der Klasse CONNECTION_UNIT
			obj.Connection_Point = cn_point;
			obj.P_Q_Act_idx = size(obj.Connection_Point.P_Q_Act,1) + 1;
			obj.Connection_Point.P_Q_Act(obj.P_Q_Act_idx,:) = zeros(1,6);
			obj.Connection_Point.Num_Units_Connected = ...
				obj.Connection_Point.Num_Units_Connected + 1;
		end
		
	end
end

