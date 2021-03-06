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
	% Letzte �nderung durch:   Franz Zeilinger - 18.01.2013
	
	properties
		
		Controlled_Unit = [];
	%        handle auf das Objekt der angeschlossenen Einheit, welche von diesem
	%        SG-Regler beeinflusst wird.
		Values_Last_Step = [];
	%        Werte des letzen Regelschrittes, hier sind je nach Klasse
	%        unterschiedlichste Daten enthalten

	end
	
	methods
		
		function obj = SG_Controller (cn_point, varargin)
			%SG_CONTROLLER    Konstruktor der Klasse SG_CONTROLLER
			
			% Zun�chst ein Anschlussobjekt erzeugen: 
			obj = obj@Connection_Unit(cn_point, 1);
			% Regelerfolg des Anschlusspunktes ist nicht erf�llt:
			obj.Connection_Point.controller_finished = false;
			% Weitere Parameter abarbeiten:
			obj.update_settings(varargin{:})
		end
		
		function update_settings(obj, varargin)
			%UPDATE_SETTINGS    Erg�nzt Parametereinstellungen der Klasse
			%    genaue Beschreibung fehlt!
			
			% wurden Parameter �bergeben?
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
				% Fehler, weil Parameter nicht in Zweiergruppe �bergeben wurde:
				exception = MException(...
					'SG_CONTROLLER:UpdateSettings:WrongNumberArgs', ...
					['Wrong number of inputarguments. Input looks like ',...
					'(''Parameter_Name'', Value)']);
				throw(exception);
			end
		end
		
		function update_parameter(obj, varargin)
			%UPDATE_PARAMETER    aktualisiert die Parameter des Objekts
			obj.update_settings(varargin{:})
		end
		
	end
	
	% Definition der Funktionen, die in den jeweiligen Sub-Klassen definiert werden
	% m�ssen:
	methods (Abstract)
		
		regulate(obj, varargin)
		%REGULATE    f�hrt eine Berechnung zur Regelung f�r aktuellen Schritt durch
		
		success = check_success(obj, varargin)
		%CHECK_SUCCESS    �berpr�gen, ob Regler bereits eingeschwungen
		
		reset_controller(obj, varargin)
		%RESET_CONTROLLER    Regler wieder auf Ausgangswerte setzen
		
	end
	
	methods (Abstract, Hidden)
		
		update_obj_parameter(obj, parameter_name, input)
		%UPDATE_OBJ_PARAMETER    pr�ft und �bernimmt Parameter f�r dieses Objekt
		
	end
	
end

