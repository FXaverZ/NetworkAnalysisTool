classdef P_of_U_Control < SG_Controller
	%P_OF_U_CONTROL    Klasse der simplen Spannungsregler mit P=f(U)-Injektion
	%    Detailierte Beschreibung fehlt!
	%
	%    K O N S T R U K T O R:
	%
	%    OBJ = P_OF_U_CONTROL (CN_POINT, VARARGIN) erzeugt eine Instanz der Klasse
	%    P_OF_U_CONTROL. Dazu wird der Konstruktor der Super-Klasse SG_CONTROLLER
	%    verwendet. 
	%    CN_POINT ist ein handle auf ein Anschlusspunktobjekt der Klasse
	%    CONNECTION_POINT, an dem der Controller angeschlossen ist. Die restlichen
	%    Parameter werden in VARARGIN als Parametername-Wert(e)-Paare �bergeben
	%    (siehe Abschnitt PARAMETER in dieser Hilfe).
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
	%
	%    Parameter werden als Parametername-Wert(e)-Paare �bergeben beim erstellen
	%    der Klasse bzw. aktualisieren der Parameter:
	%        OBJ = OBJ_CONSTRUCTOR(..., 'Parameter_Name', VALUE)    bzw.
	%        OBJ.UPDATE_PARAMETER('Parameter_Name', VALUE, ...)
	%    VALUE kann eine beliebiger Datentyp sein!
	%
	%	 'Termination_Threshold'
	%        [%]
	%        prozentuelle Angabe von einem Sollwert, unter dem der akutelle
	%        relative Ist-Wert der geregelten Gr��e fallen muss, damit das
	%        aktuelle Regelergebnis als ausreichend betrachtet wird (der Regler
	%        "eingeschwungen" ist).
	%	 'Setpoint'
	%        [-]
	%        Einzustellender Sollwert
	%	 'dPmax_dStep'
	%        [W/Rechenschritt]
	%        maximal m�gliche Leistungs�nderung pro Rechenschritt dieses
	%        Controllers.
	%	 'P_max'
	%        [MW]
	%        maximal m�gliche Gesamt-Leistungs�nderung (Lasterh�hung) dieses
	%        Controllers.
	%	 'P_min'
	%        [MW]
	%        maximal m�gliche Gesamt-Leistungs�nderung (Einspeisung) dieses
	%        Controllers.
	%	 'dP_min'
	%        [MW]
	%        minimale Leistungs�nderung des Controllers. Ver�ndert sich die Leistung
	%        nur mehr unterhalb dieses Grenzwertes, ist der Regler eingeschwungen.
	%	 'dV_dP'
	%        [W/V]
	%        maximal m�gliche Leistungs�nderung pro Rechenschritt dieses
	%        Controllers.	
	
	% Erstellt von:            Franz Zeilinger - 12.11.2012
	% Letzte �nderung durch:   Franz Zeilinger - 28.01.2013
	
	properties
		
	%    P A R A M E T E R :
		Termination_Threshold = 0;
	%        [%]
	%        prozentuelle Angabe von einem Sollwert, unter dem der akutelle
	%        relative Ist-Wert der geregelten Gr��e fallen muss, damit das
	%        aktuelle Regelergebnis als ausreichend betrachtet wird (der Regler
	%        "eingeschwungen" ist).
		Setpoint = 1;
	%        [-]
	%        Einzustellender Sollwert
		dPmax_dStep = Inf;
	%        [MW/Rechenschritt]
	%        maximal m�gliche Leistungs�nderung pro Rechenschritt dieses
	%        Controllers.
		P_max = Inf;
	%        [MW]
	%        maximal m�gliche Gesamt-Leistungs�nderung (Lasterh�hung) dieses
	%        Controllers.
		P_min =-Inf;
	%        [MW]
	%        maximal m�gliche Gesamt-Leistungs�nderung (Einspeisung) dieses
	%        Controllers.
		dP_min =Inf;
	%        [MW]
	%        minimale Leistungs�nderung des Controllers. Ver�ndert sich die Leistung
	%        nur mehr unterhalb dieses Grenzwertes, ist der Regler eingeschwungen.
		dP_dV = 1;
	%        [MW/V]
	%        maximal m�gliche Leistungs�nderung pro Rechenschritt dieses
	%        Controllers.		
	end
	
	methods
		function obj = P_of_U_Control (varargin)
			%P_OF_U_CONTROL    Konstruktor der Klasse P_OF_U_CONTROL
			%    N�heres siehe Hilfe der Klasse P_OF_U_CONTROL
			
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
			%REGULATE    f�hrt eine Berechnung zur Regelung f�r akt. Schritt durch
						
			for i=1:numel(obj)
				% �berpr�fen, ob Regelung bereits abgeschlossen ist:
				if obj(i).check_success
					continue;
				end

				% wenn nicht, bisherige Leistungs�nderungen auslesen:
				dP_tot = obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,1:2:6);
				
				% zus�tzliche erforderliche Leistungs�nderung ermitteln (aufgrund der
				% Abweichung der aktuellen Spannung von Sollwert):
				d_P = obj(i).dP_dV .* (obj(i).Connection_Point.Voltage - obj(i).Setpoint);
				% Anpassen an maximale �nderung:
				d_P(d_P > obj(i).dPmax_dStep) = obj(i).dPmax_dStep;
				% Gesamte Leistung ermitteln:
				dP_tot = dP_tot + d_P;
				% Anpassen an Begrenzungen:
				dP_tot(dP_tot > obj(i).P_max) = obj(i).P_max;
				dP_tot(dP_tot < obj(i).P_min) = obj(i).P_min;
				% Neue Leistungswerte in P_Q_Array des Anschlusspunktes schreiben:
				obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,1:2:6) = dP_tot;
				% Markieren, dass sich die Werte ge�ndert haben:
				obj(i).Connection_Point.powers_changed = true;
			end
		end
		
		function success = check_success(obj)
			%CHECK_SUCCESS    �berpr�fen, ob Regler eingeschwungen
			%    Diese Funktion �berpr�ft mit Hilfe der aktuellen und vergangenen
			%    Werte, ob der Regler keine �nderugnen mehr vornimmt und teilt dies
			%    einerseits dem aufrufenden Objekt mit sowie dem Verkn�pfungspunkt.
			%    Weiters speichert diese Funktion die aktuellen Werte f�r den
			%    n�chsten Schritt.
			
			success = false;
			
			% Falls noch keine Werte vom vorhergehenden Rechenschritt vorhanden sind,
			% kann keine �berpr�fung stattfinden:
			if isempty(obj.Values_Last_Step)
				obj.Connection_Point.controller_finished = false;
				
				% Werte des aktuellen Schrittes f�r n�chsten Durchlauf speichern:
				obj.Values_Last_Step = ...
					obj.Connection_Point.P_Q_Act(obj.P_Q_Act_idx,:);
				return;
			end
			
			% Finden nur mehr kleine Leistungs�nderungen statt?
			diff = obj.Values_Last_Step - ...
				obj.Connection_Point.P_Q_Act(obj.P_Q_Act_idx,:);
			if all(abs(diff(1:2:6)) < obj.dP_min)
				% Wenn ja --> keine �nderungen mehr m�glich (z.B. weil Regler in
				% Leistungsbegrenzung)
				success = true;
				obj.Connection_Point.controller_finished = ...
					obj.Connection_Point.controller_finished & true;
				
				% Werte des aktuellen Schrittes f�r n�chsten Durchlauf speichern:
				obj.Values_Last_Step = ...
					obj.Connection_Point.P_Q_Act(obj.P_Q_Act_idx,:);
				return;
			end
			
			% Wurde Spannungssollwert bereits erreicht?
			diff = obj.Setpoint - obj.Connection_Point.Voltage;
			if all(abs(diff) < obj.Setpoint*obj.Termination_Threshold/100)
				% Wenn ja --> Soll ist gleich Ist, fertig!
				success = true;
				obj.Connection_Point.controller_finished = ...
					obj.Connection_Point.controller_finished & true;
				
				% Werte des aktuellen Schrittes f�r n�chsten Durchlauf speichern:
				obj.Values_Last_Step = ...
					obj.Connection_Point.P_Q_Act(obj.P_Q_Act_idx,:);
				return;
			end
			
			obj.Connection_Point.controller_finished = false;
			
			% Werte des aktuellen Schrittes f�r n�chsten Durchlauf speichern:
			obj.Values_Last_Step = ...
				obj.Connection_Point.P_Q_Act(obj.P_Q_Act_idx,:);
			
		end
		
		function d_P = get_act_dp (obj)
			%GET_ACT_DP    ermittelt aktuelle Leistungs�nderung dieser Komponente:
			
			d_P = zeros(numel(obj),6);
			for i=1:numel(obj)
				d_P(i,:)=obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:);
			end
		end
	end
	
	methods (Hidden)
		
		function update_obj_parameter(obj, parameter_name, input)
			%UPDATE_PARAMETER    Parameter �berpr�fen und aktualisieren
			%    OBJ.UPDATE_OPJ_PARAMETER(PARAMETER_NAME, INPUT) setzt den Wert des
			%    Parameters, der durch den Namen PARAMETER_NAME gegeben ist, auf
			%    INPUT. Dabei wird ein simpler Plausibilit�tscheck durchgef�hrt.
			
			% �bergebene Parameter �bernehmen, zuvor kontrollieren, ob diese g�ltig
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

