classdef SG_Controller < Connection_Unit
	%SG_CONTROLLER    Klasse der Smart-Grid-Controller
	%   Detaillierte Beschreibung fehlt!
	%
	%    P R O P E R T I E S:
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
	
	% Erstellt von:            Franz Zeilinger - 30.10.2012
	% Letzte Änderung durch:   Franz Zeilinger - 18.01.2013
	
	properties
		Controlled_Unit = [];
	%        handle auf das Objekt der angeschlossenen Einheit, welche von diesem
	%        SG-Regler beeinflusst wird.
		Values_Last_Step = [];
	%        Werte des letzen Regelschrittes

	end
	
	methods
		
		function obj = SG_Controller (cn_point, ctrld_unit, varargin)
			%SG_CONTROLLER    Konstruktor der Klasse SG_CONTROLLER
			
			% Zunächst ein Anschlussobjekt erzeugen: 
			obj = obj@Connection_Unit(cn_point);
			% Geregelte Einheit zuweisen:
			obj.Controlled_Unit = ctrld_unit;
			% Regelerfolg des Anschlusspunktes ist nicht erfüllt:
			obj.Connection_Point.controller_finished = false;
			% Weiteren Parameter abarbeiten:
			obj.update_settings(varargin{:})
		end
		
		function update_settings(obj, varargin)
			%UPDATE_SETTINGS    Ergänzt Parametereinstellungen der Klasse
			%    genaue Beschreibung fehlt!
			
			% wurden Parameter übergeben?
			if nargin == 1
				return;
			end
			
			% Sind die Argumente Zweiergruppen --> wenn nicht --> Fehler:
			if (mod(nargin-1,2) == 0)
				% Durchlaufen aller Eingangsparameter (in 2er Schritten):
				for i = 1:2:nargin-1
					% Erster Teil: Parametername, ist dieser ein String -->
					% wenn nicht --> Fehler:
					if ischar(varargin{i})
						try
							obj.update_obj_parameter(varargin{i}, varargin{i+1});
						catch ME
							% Falls Fehler passieren, dies melden und weiterreichen:
							exception = MException(...
								'SG_CONTROLLER:UpdateSettings:Error',...
								['When processing the parameter ''',...
								varargin{i},''' a error occured!']);
							exception = addCause (ME, exception);
							throw(exception);
						end
					else
						% Fehler, weil erster Eintrag in Parameterliste kein
						% Text war:,
						exception = MException(...
							'SG_CONTROLLER:UpdateSettings:WrongParameterName',...
							['Wrong inputarguments. Input looks like ',...
							'(''Parameter_Name'', Value)']);
						throw(exception);
					end
				end
			else
				% Fehler, weil Parameter nicht in Zweiergruppe übergeben wurde:
				exception = MException(...
					'SG_CONTROLLER:UpdateSettings:WrongNumberArgs', ...
					['Wrong number of inputarguments. Input looks like ',...
					'(''Parameter_Name'', Value)']);
				throw(exception);
			end
		end
		
		function update_parameter(obj, varargin)
			% aktualisieren der Parameter des Objekts
			obj.update_settings(varargin{:})
		end
		
		function regulate(obj, varargin)
			% Diese Funktion muss in Sub-Klassen definiert werden.
		end
		
		function success = check_success(obj, varargin)
			% Diese Funktion muss in Sub-Klassen definiert werden.
		end
		
		function reset_controller(obj, varargin)
			%RESET_CONTROLLER    Regler wieder auf Ausgangswerte setzen.
			% Diese Funktion muss in Sub-Klassen definiert werden.
		end
		
	end
	
	methods (Hidden)
		
		function update_obj_parameter(obj, parameter_name, input)
			% Diese Funktion muss in Sub-Klassen definiert werden.
		end
		
	end
end

