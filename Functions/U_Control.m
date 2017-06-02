classdef U_Control < SG_Controller
	%U_CONTROL     Klasse der simplen Spannungsregler mit P-&Q-Injektion
	%    Detailierte Beschreibung fehlt!
	
	% Erstellt von:            Franz Zeilinger - 12.11.2012
	% Letzte Änderung durch:   Franz Zeilinger - 14.11.2012
	
	properties
		Load_ID = [];        % ID der Last, die diesen Spannungsregler angeschlossen 
		%                          hat.
		Load_IDX = [];       % ACHTUNG: noch nicht ganz sauber: hier wird nur der 
		%                          Index der Last in den Datenarrays
		%                          zwischengespeichert, ist aber keine Eigenschaft,
		%                          die in dieser Klasse etwas verloren hätte!
		Load_Obj = [];       % Berechnungsobjekt der Last, an die dieser 
		%                          Spannungsregler angeschlossen ist.
		delta_P = [0, 0, 0]; % aktuelle Änderung der Wirkleistung durch 
		%                          Spannungsregler: [P1, P2, P3]
		delta_Q = [0, 0, 0]; % aktuelle Änderung der Blindleistung durch 
		%                          Spannungsregler: [Q1, Q2, Q3]
	end
	
	methods
		function obj = U_Control (varargin)
			obj = obj@SG_Controller(varargin{:});
		end
		
		function set.Load_ID(obj, value)
			%SET.LOAD_ID    SET-Funktion für Aktualisierung von LOAD_ID
			%    U_CONTROL.LOAD_ID = VALUE setzt das Property LOAD_ID auf den Wert
			%    VALUE und lädt (sofern noch nicht passiert) das
			%    COM-Berechnungsobjekt der Last LOAD_ID, um dieses einfach zur
			%    Verfügung zu stellen, um z.B. die Leistungen ändern zu können.
			obj.Load_ID = value;
			if isempty(obj.Load_Obj)  %#ok<*MCSUP>
				obj.Load_Obj = obj.Sincal.Simulation.GetObj('LOAD', obj.Load_ID);
			end
		end
		
		function regulate(obj)
			%REGULATE    Regelungsberechnungen ausführen
			
			% Regelungsberechnungen:
			for i = 1:3
				%Spannungen auslesen:
				u = obj.Voltages(i);
				% normieren der Spannung:
% 				u = u*sqrt(3)/400;
% 				if u > 1.001 || u < 0.999
% 					obj.delta_Q(i) = obj.delta_Q(i) + 0.05 * (u-1);
% 				else
% 					obj.delta_Q(i) = 0;
% 				end
% 				if u > 1.01 || u < 0.99
				if 20/1e6 * (u-400/sqrt(3)) > 50/1e6
					obj.delta_P(i) = obj.delta_P(i)+ 50/1e6;
				else
					obj.delta_P(i) = obj.delta_P(i) + 20/1e6 * (u-400/sqrt(3));
				end
% 				else
% 					obj.delta_P(i) = 0;
% 				end
			end
		end
		
		function reset_controller(obj)
			%RESET_CONTROLLER    Regler wieder auf Ausgangswerte setzen.
			obj.delta_Q = [0, 0, 0];
			obj.delta_P = [0, 0, 0];
		end
		
		function adjust_power(obj, p_load, q_load)
			%ADJUST_POWER    aktualisieren der Leistungsaufnahme

			obj.Load_Obj.set('Item','P1',p_load(1) + obj.delta_P(1));
			obj.Load_Obj.set('Item','P2',p_load(2) + obj.delta_P(2));
			obj.Load_Obj.set('Item','P3',p_load(3) + obj.delta_P(3));
			
			obj.Load_Obj.set('Item','Q1',q_load(1) + obj.delta_Q(1));
			obj.Load_Obj.set('Item','Q2',q_load(2) + obj.delta_Q(2));
			obj.Load_Obj.set('Item','Q3',q_load(3) + obj.delta_Q(3));
		end
	end
	
end

