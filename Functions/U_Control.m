classdef U_Control < SG_Controller
	%U_CONTROL     Klasse der simplen Spannungsregler mit P-&Q-Injektion
	%    Detailierte Beschreibung fehlt!
	%
	%    E I G E N S C H A F T E N :
	%
	%	 'Connection_Point'
	%        handle auf den Anschlusspunkt, an dem diese Objekt angeschlossen ist.
	%	 'P_Q_Act_idx'
	%        Zeilenindex des Leistungsarrays des Anschluss-Objekts, dass dieses
	%        Objekt bearbeiten darf/soll.
	%	 'Controlled_Unit'
	%        handle auf das Objekt der angeschlossenen Einheit, welche von diesem
	%        SG-Regler beeinflusst wird.
	%	 'Values_Last_Step'
	%        Werte des letzen Regelschrittes
	%
	%    P A R A M E T E R :
	%    Parameter werden als Parametername-Wert(e)-Paare übergeben beim erstellen
	%    der Klasse bzw. aktualisieren der Parameter:
	%        OBJ = OBJ_CONSTRUCTOR(..., 'Parameter_Name', VALUE)    bzw.
	%        OBJ.UPDATE_PARAMETER('Parameter_Name', VALUE, ...)
	%    VALUE kann eine beliebiger Datentyp sein!
	%
	%	 'Termination_Threshold'
	%        [%]
	%        prozentuelle Angabe von einem Sollwert, unter dem der akutelle
	%        relative Ist-Wert der geregelten Größe fallen muss, damit das
	%        aktuelle Regelergebnis als ausreichend betrachtet wird (der Regler
	%        "eingeschwungen" ist).
	%	 'Setpoint'
	%        [-]
	%        Einzustellender Sollwert
	%	 'dPmax_dStep'
	%        [W/Rechenschritt]
	%        maximal mögliche Leistungsänderung pro Rechenschritt dieses
	%        Controllers.
	%	 'P_max'
	%        [MW]
	%        maximal mögliche Gesamt-Leistungsänderung (Lasterhöhung) dieses
	%        Controllers.
	%	 'P_min'
	%        [MW]
	%        maximal mögliche Gesamt-Leistungsänderung (Einspeisung) dieses
	%        Controllers.
	%	 'dP_min'
	%        [MW]
	%        minimale Leistungsänderung des Controllers. Verändert sich die Leistung
	%        nur mehr unterhalb dieses Grenzwertes, ist der Regler eingeschwungen.
	%	 'dV_dP'
	%        [W/V]
	%        maximal mögliche Leistungsänderung pro Rechenschritt dieses
	%        Controllers.	
	
	% Erstellt von:            Franz Zeilinger - 12.11.2012
	% Letzte Änderung durch:   Franz Zeilinger - 18.01.2013
	
	properties
		%    E I G E N S C H A F T E N :
% 		Q_controll_finished = false;
		
		%    P A R A M E T E R :
		Termination_Threshold = 0;
	%        [%]
	%        prozentuelle Angabe von einem Sollwert, unter dem der akutelle
	%        relative Ist-Wert der geregelten Größe fallen muss, damit das
	%        aktuelle Regelergebnis als ausreichend betrachtet wird (der Regler
	%        "eingeschwungen" ist).
		Setpoint = 1;
	%        [-]
	%        Einzustellender Sollwert
		dPmax_dStep = Inf;
	%        [MW/Rechenschritt]
	%        maximal mögliche Leistungsänderung pro Rechenschritt dieses
	%        Controllers.
		P_max = Inf;
	%        [MW]
	%        maximal mögliche Gesamt-Leistungsänderung (Lasterhöhung) dieses
	%        Controllers.
		P_min =-Inf;
	%        [MW]
	%        maximal mögliche Gesamt-Leistungsänderung (Einspeisung) dieses
	%        Controllers.
		dP_min =Inf;
	%        [MW]
	%        minimale Leistungsänderung des Controllers. Verändert sich die Leistung
	%        nur mehr unterhalb dieses Grenzwertes, ist der Regler eingeschwungen.
		dP_dV = 1;
	%        [MW/V]
	%        maximal mögliche Leistungsänderung pro Rechenschritt dieses
	%        Controllers.		
	end
	
	methods
		function obj = U_Control (varargin)
			obj = obj@SG_Controller(varargin{:});
		end
		
		function reset_controller(obj)
			%RESET_CONTROLLER    Regler wieder auf Ausgangswerte setzen.
			for i=1:numel(obj)
				obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:) = zeros(1,6);
				obj(i).Connection_Point.powers_changed = true;
				obj(i).Values_Last_Step = [];
			end
		end
		
		function regulate(obj)
			for i=1:numel(obj)
				% überprüfen, ob Regelung bereits abgeschlossen:
				obj(i).check_success;
				
				% Werte des letzten Schrittes speichern:
				obj(i).Values_Last_Step = ...
					obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:);
				% bisherige Leistungsänderung auslesen:
				dP_tot = obj(i).Values_Last_Step(1:2:6);
				
				% zusätzliche erforderliche Leistungsänderung ermitteln (aufgrund der
				% Abweichung der aktuellen Spannung von Sollwert):
				d_P = obj(i).dP_dV .* (obj(i).Connection_Point.Voltage - obj(i).Setpoint);
				% Anpassen an maximale Änderung:
				d_P(d_P > obj(i).dPmax_dStep) = obj(i).dPmax_dStep;
				% Gesamte Leistung ermitteln:
				dP_tot = dP_tot + d_P;
				% Anpassen an Begrenzungen:
				dP_tot(dP_tot > obj(i).P_max) = obj(i).P_max;
				dP_tot(dP_tot < obj(i).P_min) = obj(i).P_min;
				% Neue Leistungswerte in P_Q_Array des Anschlusspunktes schreiben:
				obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,1:2:6) = dP_tot;
				% Markieren, dass sich die Werte geändert haben:
				obj(i).Connection_Point.powers_changed = true;
			end
		end
		
		function success = check_success(obj)
			%SUCCESS    Überprüfen, ob Regler eingeschwungen
			
			success = false;
			% Falls noch keine Werte vom vorhergehenden Rechenschritt vorhanden sind,
			% kann keine Überprüfung stattfinden:
			if isempty(obj.Values_Last_Step)
				obj.Connection_Point.controller_finished = false;
				return;
			end,
			
			% Überprüfen, ob Regelung bereits erfolgreich war...
			% Finden nur mehr kleine Leistungsänderungen statt?
			diff = obj.Values_Last_Step - ...
				obj.Connection_Point.P_Q_Act(obj.P_Q_Act_idx,:);
			if all(abs(diff(1:2:6)) < obj.dP_min)
				% Wenn ja --> keine Änderungen mehr möglich (z.B. weil Regler in
				% Leistungsbegrenzung)
				success = true;
				obj.Connection_Point.controller_finished = ...
					obj.Connection_Point.controller_finished & true;
				return;
			end
			
			% Wurde Spannungssollwert bereits erreicht?
			diff = obj.Setpoint - obj.Connection_Point.Voltage;
			if all(abs(diff) < obj.Setpoint*obj.Termination_Threshold/100)
				% Wenn ja --> Soll ist gleich Ist, fertig!
				success = true;
				obj.Connection_Point.controller_finished = ...
					obj.Connection_Point.controller_finished & true;
				return;
			end
			obj.Connection_Point.controller_finished = false;
			
		end
		
		function d_P = get_act_dp (obj)
			%GET_ACT_DP    ermittelt aktuelle Leistungsänderung dieser Komponente:
			
			d_P = zeros(numel(obj),6);
			for i=1:numel(obj)
				d_P(i,:)=obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:);
			end
		end
	end
	
	methods (Hidden)
		
		function update_obj_parameter(obj, parameter_name, input)
			%UPDATE_PARAMETER    Parameter überprüfen und aktualisieren
			%    OBJ.UPDATE_OPJ_PARAMETER(PARAMETER_NAME, INPUT) setzt den Wert des
			%    Parameters, der durch den Namen PARAMETER_NAME gegeben ist, auf
			%    INPUT. Dabei wird ein simpler Plausibilitätscheck durchgeführt.
			
			% Übergebene Parameter übernehmen, zuvor kontrollieren, ob diese gültig
			% sind:
			switch parameter_name
% 				case 'String_input'
% 					% Muss ein String sein
% 					if ischar(input)
% 						obj.(parameter_name) = input;
% 					else
% 						exception = MException(...
% 							'U_CONTROL:UpdateParameter:WrongInput', ...
% 							['Value for ''',parameter_name,...
% 							''' has to be a string!']);
% 						throw(exception);
% 					end
				case 'Setpoint'
					% Muss eine Zahl sein
					if isnumeric (input)
						obj.(parameter_name) = input;
					else
						exception = MException(...
							'U_CONTROL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be numeric!']);
						throw(exception);
					end
				case 'Termination_Threshold'
					% Muss eine Zahl sein
					if isnumeric (input)
						obj.(parameter_name) = input;
					else
						exception = MException(...
							'U_CONTROL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be numeric!']);
						throw(exception);
					end
				case 'dPmax_dStep'
					% Muss eine Zahl sein
					if isnumeric (input)
						obj.(parameter_name) = input;
					else
						exception = MException(...
							'U_CONTROL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be numeric!']);
						throw(exception);
					end
				case 'dP_dV'
					% Muss eine Zahl sein
					if isnumeric (input)
						obj.(parameter_name) = input;
					else
						exception = MException(...
							'U_CONTROL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be numeric!']);
						throw(exception);
					end
				case 'P_max'
					% Muss eine Zahl sein
					if isnumeric (input)
						obj.(parameter_name) = input;
					else
						exception = MException(...
							'U_CONTROL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be numeric!']);
						throw(exception);
					end
				case 'P_min'
					% Muss eine Zahl sein
					if isnumeric (input)
						obj.(parameter_name) = input;
					else
						exception = MException(...
							'U_CONTROL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be numeric!']);
						throw(exception);
					end
				case 'dP_min'
					% Muss eine Zahl sein
					if isnumeric (input)
						obj.(parameter_name) = input;
					else
						exception = MException(...
							'U_CONTROL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be numeric!']);
						throw(exception);
					end
				otherwise
					exception = MException(...
						'U_CONTROL:UpdateParameter:UnknownParameter', ...
						['Parameter ''',parameter_name,''' is unknown!']);
					throw(exception);
			end
		end
	end
end

