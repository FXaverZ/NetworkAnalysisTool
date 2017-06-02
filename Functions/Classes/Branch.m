classdef Branch < handle
    %BRANCH    Klasse der Zweigelemente (z.B. Leitungen)
	%    Detaillierte Beschreibung fehlt!
	
	% Version:                 1.0
	% Erstellt von:            Franz Zeilinger - 14.03.2013
	% Letzte Änderung durch:   
    
    properties
        Branch_ID
	%        ID des Kanten-Objektes
        Branch_Obj
	%        Berechnungsobjekt "Line" des Kanten-Objektes		
        Branch_Name	
	%        Name des Kanten-Objektes
        Node_1_ID
        Node_1_Obj
        Node_1_Name
        Node_2_ID
        Node_2_Obj
        Node_2_Name
        Current = zeros(1,4);
    end
    
    methods
        function obj = Branch(sin_ext, branch_id_ext)
            obj.Branch_ID = branch_id_ext;
            obj.Branch_Obj = sin_ext.Simulation.GetObj('Line', obj.Branch_ID);
            obj.Branch_Name = obj.Branch_Obj.get('Item','TOPO.Name');
            obj.Node_1_ID = obj.Branch_Obj.get('Item','TOPO.Node1.DBID');
            obj.Node_2_ID = obj.Branch_Obj.get('Item','TOPO.Node2.DBID');
            obj.Node_1_Obj = sin_ext.Simulation.GetObj('NODE', obj.Node_1_ID);
			obj.Node_1_Name = obj.Node_1_Obj.get('Item','TOPO.Name');
            obj.Node_2_Obj = sin_ext.Simulation.GetObj('NODE', obj.Node_2_ID);
			obj.Node_2_Name = obj.Node_2_Obj.get('Item','TOPO.Name');
        end
        
        function current = update_current_branch_LF_USYM (obj)
			%GET_VOLTAGES_NODE    aktualisieren der Stromwerte des Anschlusses 1
			%    genaue Beschreibung fehlt!
			for i = 1:numel(obj)
				current = zeros(1,3);
				LFBranchResultLoad = obj(i).Branch_Obj.Result('ULFBranchResult', 1);
                if ~isempty(LFBranchResultLoad)
                    current(1,1) = LFBranchResultLoad.get('Item','I1');
                    current(1,2) = LFBranchResultLoad.get('Item','I2');
                    current(1,3) = LFBranchResultLoad.get('Item','I3');
                    current(1,4) = LFBranchResultLoad.get('Item','Ie');
                    current = current*1000; % Umrechnen von kA in A
                    obj(i).Current = current;
                else
                    % Fehlerbehandlung?!?
                end
			end
		end
        
    end
    
end

