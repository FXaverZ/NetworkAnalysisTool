classdef SG_Controller < handle
	%SG_CONTROLLER    Klasse der Smart-Grid-Controller
	%   Detaillierte Beschreibung fehlt!
	
	% Erstellt von:            Franz Zeilinger - 30.10.2012
	% Letzte Änderung durch:   Franz Zeilinger - 14.11.2012
	
	properties
		Node_ID = [];            % ID des Knotens, an der diese Instanz des 
			%                          Controllers angeschlossen ist.
		Voltages = [];           % aktuelle Spannungswerte. Werden durch 
		%                              SG_CONTROLLER.GET_VOLTAGES_NODE aktualisiert
		%                              mit den Spannungswerten des Knotens NODE_ID
	end
	
	properties (Hidden)
		Sincal = [];             % Handle auf SINCAL-Simulation (Instanz der Klasse
		%                              SINCAL).
		Node_Obj = [];           % COM-Berechnungsobjekt des Knotens, an dem die
		%                              Instanz des Controllers angeschlossen ist!
	end
	
	methods
		function obj = SG_Controller (sin_ext, node_ext)
			%SG_CONTROLLER    Konstruktor der Klasse SG_CONTROLLER
			%    OBJ = SG_CONTROLLER (SIN_EXT, NODE_EXT) erzeugt eine Instanz der
			%    Klasse SG_CONTROLLER. Dazu wird ein Handel auf eine Instanz der
			%    Simulationssteuerungsklasse SINCAL (SIN_EXT) benötigt sowie die ID
			%    des Knotens, an den die Instanz des Controllers angeschlossen werden
			%    soll.
			
			obj.Sincal = sin_ext;
			obj.Node_ID = node_ext;
			obj.Node_Obj = obj.Sincal.Simulation.GetObj('NODE', obj.Node_ID);
		end
		
		function voltages = get_voltages_node (obj)	
			%GET_VOLTAGES_NODE    aktualisieren der Spannungswerte
			%    genaue Beschreibung fehlt!
			
			switch obj.Sincal.Settings.Calculation_method
				case 'LF_NR'
					LFNodeResultLoad = obj.Node_Obj.Result('LFNodeResult', 0);
					voltages = LFNodeResultLoad.get('Item','U_Un');
					obj.Voltages = voltages;
				case 'LF_USYM'
					voltages = zeros(1,3);
					LFNodeResultLoad = obj.Node_Obj.Result('ULFNodeResult', 0);
					voltages(1,1) = LFNodeResultLoad.get('Item','U1');
					voltages(1,2) = LFNodeResultLoad.get('Item','U2');
					voltages(1,3) = LFNodeResultLoad.get('Item','U3');
					voltages = voltages*1000;
					obj.Voltages = voltages;
				otherwise
					exception = MException(...
						'SG_Controller:UnknownCalculationMethod',...
						['The specified calculation method ''',...
						obj.Sincal.Settings.Calculation_method,...
						''' is not supported!']);
					throw(exception);
			end
		end
	end
	
end

