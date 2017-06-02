classdef Unit_Time_Dependent < Connection_Unit
	%UNIT_TIME_DEPENDENT    Klasse zeitabh. Anschlussobjekte (z.B. Last m. Lastgang) 
	%    Detaillierte Beschreibung fehlt!
	%
	%    P R O P E R T I E S:
	%    
	%	 'Connection_Point'
	%        handle auf den Anschlusspunkt, an dem diese Objekt angeschlossen ist.
	%	 'P_Q_Act_idx = 1'
	%        Zeilenindex des Leistungsarrays des Anschluss-Objekts, dass dieses
	%        Objekt bearbeiten darf/soll. 
	%	 'P_Q_t'
	%        Array mit den 	Zeitreihen der Leistungen des Anschlussobjektes. 
	%        Daten werde im im VZPS angegeben: --> P > 0: entpr. Leistungsaufnahme
	%        (Last).
	%        Aufbau des Arrays: [m,6], m ... Anzal der Einzelzeitschritte
	%            [P_L1, Q_L1, P_L2, Q_L2, P_L3, Q_L3])
	%        Für den Zeitpunkt t kann die Leistungsaufnahme zu diesem Zeitpunkt mit
	%        OBJ.P_Q_T(t,:) ausgelesesn werden (t. Zeile der Matrix).
	
	% Erstellt von:            Franz Zeilinger - 14.01.2013
	% Letzte Änderung durch:   Franz Zeilinger - 16.01.2013
	
	properties
		P_Q_t = [];
	%        Array mit den 	Zeitreihen der Leistungen des Anschlussobjektes. 
	%        Daten werde im im VZPS angegeben: --> P > 0: entpr. Leistungsaufnahme
	%        (Last).
	%        Aufbau des Arrays: [m,6], m ... Anzal der Einzelzeitschritte
	%            [P_L1, Q_L1, P_L2, Q_L2, P_L3, Q_L3])
	%        Für den Zeitpunkt t kann die Leistungsaufnahme zu diesem Zeitpunkt mit
	%        OBJ.P_Q_T(t,:) ausgelesesn werden (t. Zeile der Matrix).
	end
	
	methods
		function obj = Unit_Time_Dependent(cn_point, P_Q_t)
			obj = obj@Connection_Unit(cn_point);
			obj.P_Q_t = P_Q_t;
		end
		
		function obj = update_power(obj, t)
			
			for i=1:numel(obj)
				obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:) = ...
					obj(i).P_Q_t(t,:);
				obj(i).Connection_Point.powers_changed = true;
			end
			
% 			con_poi = [obj.Connection_Point];
% 			p_act = vertcat(con_poi.P_Q_Act);
% 			p_act_idx = vertcat(obj.P_Q_Act_idx);
% 			sizes = vertcat(con_poi.Num_Units_Connected);
% 			idx_insert = p_act_idx(2:end) +  sizes(1:end-1);
% 			
% 			pq_t = [obj.P_Q_t];
% 			pq_t = pq_t(t,:);
% 			pq_t = reshape(pq_t,6,[])';
% 			
% 			% 			[con_poi.P_Q_Act] = deal(p_act{:});
% 			[con_poi.P_Q_Act] = p_act_idx{:};
% 			
% 			sizes = vertcat(p_act.Num_Units_Connected);
% 			p_act = vertcat(p_act.P_Q_Act);
% 			
% 			obj.Connection_Point.P_Q_Act(obj.P_Q_Act_idx,:) = ...
% 				obj.Connection_Point.P_Q_Act(obj.P_Q_Act_idx,:) + obj.P_Q_t(t,:);
		end
		
	end
	
end

