classdef Result_Post_Processing < handle
    
	%RESULT_POST_PROCESSING  
    
    %    E I G E N S C H A F T E N :
	%
	%	 'Node_ID'
	%        ID des Knotens, an der diese Instanz des Controllers angeschlossen ist.

    
	properties
		
		%    All node ids in network
		Node_ID = [];
	%        ID des Knotens, an der diese Instanz des Controllers angeschlossen ist.

    end
	
	methods
		function obj = Connection_All_Point(sin_ext, node_id_ext)
			
        end
        		
		function voltage = update_voltage_node_LF_USYM (obj)
			%GET_VOLTAGES_NODE    aktualisieren der Spannungswerte
			%    genaue Beschreibung fehlt!
			for i = 1:numel(obj)
				voltage = zeros(1,3);
				LFNodeResult = obj(i).Node_Obj.Result('ULFNodeResult', 0);
                if ~isempty(LFNodeResult)
                    voltage(1,1) = LFNodeResult.get('Item','U1');
                    voltage(1,2) = LFNodeResult.get('Item','U2');
                    voltage(1,3) = LFNodeResult.get('Item','U3');
                    voltage = voltage*1000; % Umrechnen von kV in V
                    obj(i).Voltage = voltage;
                else
                    % Fehlerbehandlung?!?
                end
			end
		end
		
		function voltage = update_voltages_node_LF_NR (obj)
			%GET_VOLTAGES_NODE    aktualisieren der Spannungswerte
			%    genaue Beschreibung fehlt!
			for i = 1:numel(obj)
				LFNodeResult = obj(i).Node_Obj.Result('LFNodeResult', 0);
				voltage = LFNodeResult.get('Item','U_Un');
				obj.Voltage = voltage;
			end
		end
	end
end
