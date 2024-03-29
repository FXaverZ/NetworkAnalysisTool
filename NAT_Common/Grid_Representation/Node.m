classdef Node < handle
	%NODE
	%
    %    E I G E N S C H A F T E N :
	%
	%	 'Node_ID'
	%        ID des Knotens, an der diese Instanz des Controllers angeschlossen ist.
	%	 'Node_Obj'
	%        Berechnungsobjekt des aktuellen Knotens.
	%	 'Node_Name'
	%        Name des Knotens des Lastanschlusspunktes in SINCAL.
	%	 'Voltage'
	%        aktuelle Spannungswerte. Werden durch OBJ.GET_VOLTAGES_NODE
	%        aktualisiert mit den Spannungswerten des Knotens OBJ.NODE_ID. 
    %        Wert der Abhängigkeit der Spannungsänderung pro Laständerung an diesem
	%        Knoten. Dabei handelt es sich um eine [6,3] Matrix, da für jede Phase
	%        sowohl für Wirk- als auch Blindleistung die Spannungsänderung auf allen
	%        drei Phasen angegeben wird:
	%                            U_L1         U_L2         U_L3
	%                P_L1    dU_L1_dP_L1  dU_L2_dP_L1  dU_L3_dP_L1
	%                Q_L1    dU_L1_dQ_L1  dU_L2_dQ_L1  dU_L3_dQ_L1
	%                P_L2    dU_L1_dP_L2  dU_L2_dP_L2  dU_L3_dP_L2
	%                Q_L2    ...
	%                P_L3 
	%                Q_L3 	
	
	% Version:                 1.2
	% Erstellt von:            Matej Rejc      - 17.04.2013
	% Letzte Änderung durch:   Matej Rejc      - 24.04.2013
	properties
		
	%        All node ids in network
		Node_ID = [];
	%        ID des Knotens, an der diese Instanz des Controllers angeschlossen ist.
		Node_Obj = [];           
	%        Berechnungsobjekt des aktuellen Knotens.
		Node_Name = [];
	%        Name des Knotens des Lastanschlusspunktes in SINCAL.
        VoltLevel_ID = [];
    %        Voltage level ID of the node    
        Rated_Voltage_phase_phase = [];
    %        Rated voltages phase - earth in V, used for unsym. LF
        Rated_Voltage_phase_earth = [];
    %        Rated voltages phase - phase in V
        Voltage_Limits = [];
    %        Voltage limits in %
        Number_of_Voltage_Violation_limits
    %        Number of voltage limits (1 or 2)
        Voltage = zeros(1,3);
	%        aktuelle Spannungswerte. Werden durch OBJ.GET_VOLTAGES_NODE
	%        aktualisiert mit den Spannungswerten des Knotens OBJ.NODE_ID. 
        
    %        drei Phasen angegeben wird:
	%                            U_L1         U_L2         U_L3
	%                P_L1    dU_L1_dP_L1  dU_L2_dP_L1  dU_L3_dP_L1
	%                Q_L1    dU_L1_dQ_L1  dU_L2_dQ_L1  dU_L3_dQ_L1
	%                P_L2    dU_L1_dP_L2  dU_L2_dP_L2  dU_L3_dP_L2
	%                Q_L2    ...
	%                P_L3 
	%                Q_L3 
	end
	
	methods
		function obj = Node(sin_ext, node_id_ext)
			%NODE    Konstruktor der Klasse NODE
			
            if  ischar(sin_ext) && strcmpi(sin_ext, 'recreation')
                obj.Node_ID                   = node_id_ext.Node_ID;
                obj.Node_Obj                  = node_id_ext.Node_Obj;
                obj.Node_Name                 = node_id_ext.Node_Name;
                obj.VoltLevel_ID              = node_id_ext.VoltLevel_ID;
                obj.Rated_Voltage_phase_phase = node_id_ext.Rated_Voltage_phase_phase;
                obj.Rated_Voltage_phase_earth = node_id_ext.Rated_Voltage_phase_earth;
                obj.Voltage_Limits            = node_id_ext.Voltage_Limits;
                obj.Voltage                   = node_id_ext.Voltage;
                return;
            end
            
			% ID nodes:
            obj.Node_ID = node_id_ext;
			% SINCAL Node object
			obj.Node_Obj = sin_ext.Simulation.GetObj('NODE', obj.Node_ID);
            % All Node Names:
			obj.Node_Name = obj.Node_Obj.get('Item','TOPO.Name');
            
            % Voltage level id of node
            all_nodes_in_table = sin_ext.Tables.Node(:,strcmp(sin_ext.Tables.Node(1,:),'Name'));
            all_nodes_in_table = strtrim(all_nodes_in_table);
            
            obj.VoltLevel_ID = cell2mat(sin_ext.Tables.Node(...
               strcmp(all_nodes_in_table,...
               obj.Node_Name),...
               strcmp(sin_ext.Tables.Node(1,:),'VoltLevel_ID')...
               ));
            
           % all voltage level ids
           volt_idx = ...
               cell2mat(sin_ext.Tables.VoltageLevel(2:end,...  
               strcmp(sin_ext.Tables.VoltageLevel(1,:),'VoltLevel_ID')...
               ));
           % Voltage values of voltage levels in kV
           volt_val = ...
               cell2mat(sin_ext.Tables.VoltageLevel(2:end,...    
               strcmp(sin_ext.Tables.VoltageLevel(1,:),'Un')...
               ));
           
           % Voltage level phase-phase in V (for symm. load flow calculations)
           obj.Rated_Voltage_phase_phase = volt_val(volt_idx==obj.VoltLevel_ID)*1000;
           
           % Voltage level phase-earth in V (for unsymm. load flow calculations)
           obj.Rated_Voltage_phase_earth = repmat(obj.Rated_Voltage_phase_phase / sqrt(3),1,3); 
		   
        end		
        
        function voltage_limits = define_voltage_limits (obj)
			%DEFINE_VOLTAGE_LIMITS    aktualisieren der Spannungswerte
			%    genaue Beschreibung fehlt!
			voltage_limits(1) = 110;   % Default settings 1.1 p.u.
			voltage_limits(2) = 90;    % Default settings 0.9 p.u.
			voltage_limits(3) = 110;   % Default settings 1.1 p.u.
			voltage_limits(4) = 90;    % Default settings 0.9 p.u.
			% voltage_limits defined as 4 element matrix
			% [upper_U_limit  lower_U_limit  upper_U_limit2   lower_U_limit2]
			
			for i = 1:numel(obj)
				% Check if voltage limits are defined in SINCAL model
				% If not, default values are used (110 % and 90 % for upper
				% and lower limits)
				if obj(i).Node_Obj.get('Item','uul') ~= 0
					voltage_limits(1) = obj(i).Node_Obj.get('Item','uul');
				end
				
				if obj(i).Node_Obj.get('Item','ull') ~= 0
					voltage_limits(2) = obj(i).Node_Obj.get('Item','ull');
				end
				
				if obj(i).Node_Obj.get('Item','uul1') ~= 0
					voltage_limits(3) = obj(i).Node_Obj.get('Item','uul1');
				end
				
				if obj(i).Node_Obj.get('Item','ull1') ~= 0
					voltage_limits(4) = obj(i).Node_Obj.get('Item','ull1');
				end
				
				obj(i).Voltage_Limits = voltage_limits;
				% Voltage limits assigned to object
                
                % Determine if only one voltage limit is set across all nodes (more common than two)
                % If all uul = uul2 and ull = ull2 are the same, comparison truth values
                % equal the number of all nodes!
                if size(voltage_limits,1) == sum(voltage_limits(:,1) == voltage_limits(:,3)) && ...
                   size(voltage_limits,1) == sum(voltage_limits(:,2) == voltage_limits(:,4))    
               
                     obj(i).Number_of_Voltage_Violation_limits = 0;
                     % Only one limit is defined ... Number_of_Voltage_Violation_limits = 1;
                else
                     obj(i).Number_of_Voltage_Violation_limits = 1;
                     % Two limits are defined ... Number_of_Voltage_Violation_limits = 1;
                end                     
			end
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
        
        function remove_COM_objects (obj)
            % removing all COM-Object out of this class. This has to be
            % done just before instances of this class are saved. Because
            % the COM-Connection will be mostly lost, when this data is
            % reloaded, warnings would appear. By a previous deletion of
            % the COM-Objects, this can be avoided.
            for i = 1:numel(obj)
                obj(i).Node_Obj = [];
            end
        end
        
    end % Methods
end % Classdef