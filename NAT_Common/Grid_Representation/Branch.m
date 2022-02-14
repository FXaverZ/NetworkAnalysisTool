classdef Branch < handle
    %BRANCH    Klasse der Zweigelemente (z.B. Leitungen)
	%    Detaillierte Beschreibung fehlt!
	
	% Version:                 2.0
	% Erstellt von:            Franz Zeilinger - 14.03.2013
	% Letzte Änderung durch:   Franz Zeilinger - 12.02.2022
    
    properties
        Branch_ID
	%        ID des Kanten-Objektes
        Branch_Obj
	%        Berechnungsobjekt "Line" des Kanten-Objektes		
        Branch_Name	
	%        Name des Kanten-Objektes
        Branch_Type
    %        Type of branch element (Line, 2W TR) 
        Branch_Type_ID
    %        Branch_Type_ID = 1 (Lines), = 2 (2W TR)
        Node_1_ID
        Node_1_Obj
        Node_1_Name
        Node_2_ID
        Node_2_Obj
        Node_2_Name

        Rated_Voltage1_phase_phase
    %        Rated_Voltage1_phase_phase is defined for the "from" node        
        Rated_Voltage1_phase_earth
    %             [U_L1-E U_L2-E U_L3-E] in Volts
    %        Rated_Voltage1_phase_earth is defined for the "from" node        
        Rated_Voltage2_phase_phase
    %        Rated_Voltage2_phase_phase is defined for the "to" node            
        Rated_Voltage2_phase_earth
    %        [U_L1-E U_L2-E U_L3-E] in Volts
    %        Rated_Voltage2_phase_earth is defined for the "to" node
        Voltage_Level_ID
    %        Voltage level ID of element from the "from" node 
        Current_Limits 
    %        Current limits (thermal) defined by base rating, first, second,
    %        third additional thermal limit. Given in the form of a 1x4 array [base,
    %        first,second, third] thermal limit in A        
        App_Power_Limits
    %        Apparent power limits        
        Number_of_Branch_Violation_limits
    %        Number of branch limits (0 or 1)   
        Current = zeros(1,4); 
    %        Currents (from node to element) [L1 L2 L3 LE?]  
	    Current_to = zeros(1,8);
    %        Currents (from node to element) [I1 I2 I3 Ie phiI1 phiI2 phiI3 cos_phie] 
        Active_Power = zeros(1,4); 
    %        Active Power (from node to element) [L1 L2 L3 LE?]    
        Reactive_Power = zeros(1,4); 
    %        Reactive Power (from node to element) [L1 L2 L3 LE?]  
        Apparent_Power = zeros(1,4);
    %        Apperant power (from node to element) [L1 L2 L3 LE?]  
        Active_Power_to = zeros(1,4); 
    %        Active Power (from element to node) [L1 L2 L3 LE?]    
        Reactive_Power_to = zeros(1,4); 
    %        Reactive Power (from element to node) [L1 L2 L3 LE?]  
        Apparent_Power_to = zeros(1,4);
    %        Apperant power (from element to node) [L1 L2 L3 LE?]          
    end
    % Note: Current, Active_Power, Reactive_Power and Apparent_Power
    % are all defined FROM node TO element
        
    methods
        function obj = Branch(sin_ext, branch_id_ext)
            obj.Branch_ID = branch_id_ext;
            if ~isempty(sin_ext.Simulation.GetObj('Line', obj.Branch_ID))
                % Branch method used for lines!
                obj.Branch_Obj = sin_ext.Simulation.GetObj('Line', obj.Branch_ID);
                obj.Branch_Name = obj.Branch_Obj.get('Item','TOPO.Name');
                obj.Branch_Type = obj.Branch_Obj.get('Item','TOPO.ObjTyp'); % Added
                obj.Node_1_ID = obj.Branch_Obj.get('Item','TOPO.Node1.DBID');
                obj.Node_2_ID = obj.Branch_Obj.get('Item','TOPO.Node2.DBID');
                obj.Node_1_Obj = sin_ext.Simulation.GetObj('NODE', obj.Node_1_ID);
                obj.Node_1_Name = obj.Node_1_Obj.get('Item','TOPO.Name');
                obj.Node_2_Obj = sin_ext.Simulation.GetObj('NODE', obj.Node_2_ID);
                obj.Node_2_Name = obj.Node_2_Obj.get('Item','TOPO.Name');
                
                obj.Branch_Type_ID = 1;
                % Lines have an internal branch type ID of 1!
                
                % Define voltage level of observed line object. Voltages are
                % needed for the calculation of apparent power limits
                % Voltage level defined from the "from" node
                all_nodes_in_table = sin_ext.Tables.Node(:,strcmp(sin_ext.Tables.Node(1,:),'Name'));
                all_nodes_in_table = strtrim(all_nodes_in_table);
                
                
                VoltLevel1 = ...
                    cell2mat(sin_ext.Tables.Node(strcmp(all_nodes_in_table,...
                    obj.Node_1_Name),...
                    strcmp(sin_ext.Tables.Node(1,:),'VoltLevel_ID')));
                % Voltage index for network levels
                volt_idx = ...
                    cell2mat(sin_ext.Tables.VoltageLevel(2:end,...
                    strcmp(sin_ext.Tables.VoltageLevel(1,:),'VoltLevel_ID')));
                % Voltage levels for network levels
                volt_val = ...
                    cell2mat(sin_ext.Tables.VoltageLevel(2:end,...
                    strcmp(sin_ext.Tables.VoltageLevel(1,:),'Un')...
                    ));
                % -- changelog v1.1b ##### (start) // 20130425
                % Define voltage level ID of element from the "from" node
                obj.Voltage_Level_ID = VoltLevel1;
                % -- changelog v1.1b ##### (end) // 20130425
                
                % Define rated voltage phase-phase and phase-earth for lines
                obj.Rated_Voltage1_phase_phase = volt_val(volt_idx==VoltLevel1)*1000;
                obj.Rated_Voltage1_phase_earth = repmat(obj.Rated_Voltage1_phase_phase / sqrt(3),1,3);
                
                % Both the to and from ends of the line have the same rated
                % voltage!
                obj.Rated_Voltage2_phase_phase = obj.Rated_Voltage1_phase_phase;
                obj.Rated_Voltage2_phase_earth = obj.Rated_Voltage1_phase_earth;
                
            elseif ~isempty(sin_ext.Simulation.GetObj('TwoWindingTransformer', obj.Branch_ID))
                % Branch method used for two winding transformers
                obj.Branch_Obj = sin_ext.Simulation.GetObj('TwoWindingTransformer', obj.Branch_ID);
                obj.Branch_Name = obj.Branch_Obj.get('Item','TOPO.Name');
                obj.Branch_Type = obj.Branch_Obj.get('Item','TOPO.ObjTyp'); % Added
                obj.Node_1_ID = obj.Branch_Obj.get('Item','TOPO.Node1.DBID');
                obj.Node_2_ID = obj.Branch_Obj.get('Item','TOPO.Node2.DBID');
                obj.Node_1_Obj = sin_ext.Simulation.GetObj('NODE', obj.Node_1_ID);
                obj.Node_1_Name = obj.Node_1_Obj.get('Item','TOPO.Name');
                obj.Node_2_Obj = sin_ext.Simulation.GetObj('NODE', obj.Node_2_ID);
                obj.Node_2_Name = obj.Node_2_Obj.get('Item','TOPO.Name');
                
                obj.Branch_Type_ID = 2;
                % 2w transformers have an internal branch type ID of 2!
                
                % To define voltage level ID we require the following code
                % Voltage level defined from the "from" node
                all_nodes_in_table = sin_ext.Tables.Node(:,strcmp(sin_ext.Tables.Node(1,:),'Name'));
                all_nodes_in_table = strtrim(all_nodes_in_table);
                
                VoltLevel1 = ...
                    cell2mat(sin_ext.Tables.Node(strcmp(all_nodes_in_table,...
                    obj.Node_1_Name),...
                    strcmp(sin_ext.Tables.Node(1,:),'VoltLevel_ID')));
                
                % Define voltage level ID of element from the "from" node
                obj.Voltage_Level_ID = VoltLevel1;
                
                % Rated voltages for primary and secondary transformer side
                % are given in kV, therefore we use *1000 to convert to
                % Volts
                obj.Rated_Voltage1_phase_phase = obj.Branch_Obj.get('Item','Un1')*1000;
                obj.Rated_Voltage2_phase_phase = obj.Branch_Obj.get('Item','Un2')*1000;
                
                obj.Rated_Voltage1_phase_earth = repmat(obj.Rated_Voltage1_phase_phase / sqrt(3),1,3);
                obj.Rated_Voltage2_phase_earth = repmat(obj.Rated_Voltage2_phase_phase / sqrt(3),1,3);
                
            end
        end
        
        function current_limits = define_branch_limits (obj)
            %DEFINE_BRANCH_LIMITS
            % app_power_limits and current_limits defined as 4 element array
            % [Ith  Ith1  Ith2  Ith3] and [Smax Smax1 Smax2 Smax3]
            % Function checks if current limits are defined in SINCAL model
            % and writes them in a 1x4 element array
            
            % If object is a line, 4 thermal limits are defined:
            % the base, the first, second and third thermal limit.
            % They are given in kA values
            % Thermal limits defined in kA, used *1000 to convert to A
            
            
            for i = 1:numel(obj)
                if strcmp(obj(i).Branch_Type,'Line') == 1
                    
                    % The first part of this function reads the current limit
                    % values for lines. The second part of the function reads
                    % the apparent power limit values for two winding
                    % transformers.
                    
                    % In the first part of the function, current values are
                    % read and additionally converted to apparent power limits
                    
                    % In the second part of the function, app. power values are
                    % read and additionally converted to current limits
                    
                    % The user can use one or the other (or just one, if we
                    % define it later)
                    
                    current_limits=zeros(1,4);
                    % Base current rating - if no base current rating is
                    % defined an error is given
                    if obj(i).Branch_Obj.get('Item','Ith') ~= 0
                        current_limits(1) = obj(i).Branch_Obj.get('Item','Ith')*1000;
                        current_limit_ids(1) = 1;
                    else
                        current_limits(1) = 9999999;
                    end
                    % First, second and third current ratings are checked
                    % If different current limits are not defined, we equal
                    % all to the base thermal limit
                    if obj(i).Branch_Obj.get('Item','Ith1') == 0
                        current_limits(2) = NaN;
                    else
                        current_limits(2) = obj(i).Branch_Obj.get('Item','Ith1')*1000;
                    end
                    if obj(i).Branch_Obj.get('Item','Ith2') == 0
                        current_limits(3) = NaN;
                    else
                        current_limits(3) = obj(i).Branch_Obj.get('Item','Ith2')*1000;
                    end
                    if obj(i).Branch_Obj.get('Item','Ith3') == 0
                        current_limits(4) = NaN;
                    else
                        current_limits(4) = obj(i).Branch_Obj.get('Item','Ith3')*1000;
                    end
                    % Conversion from single-phase currents to apparent power limits for three-phase system!
                    app_power_limits = 3*current_limits *...
                        obj(i).Rated_Voltage1_phase_phase/sqrt(3); % L123
                    % Current limit in A, Rated voltage PH-PH in V
                    
                elseif strcmp(obj(i).Branch_Type,'TwoWindingTransformer') == 1
                    % Thermal limits for transformers are defined in MVA. Therefore the program uses
                    % *1e6 to convert to VA. We define the current limit by dividing the value with
                    % sqrt(3)*Ur1, thus the current limit is defined for the "from" side
                    
                    app_power_limits=zeros(1,4);
                    if obj(i).Branch_Obj.get('Item','Smax') ~= 0 % Base rating
                        app_power_limits(1) = obj(i).Branch_Obj.get('Item','Smax')*1e6;
                        app_power_limits_ids(1) = 1;
                    else
                        app_power_limits(1) = 999e6;
                    end
                    
                    if obj(i).Branch_Obj.get('Item','Smax1') ~= 0 % First rating
                        app_power_limits(2) = obj(i).Branch_Obj.get('Item','Smax1')*1e6;
                    else
                        app_power_limits(2) = NaN;
                    end
                    
                    if obj(i).Branch_Obj.get('Item','Smax2') ~= 0 % Second rating
                        app_power_limits(3) = obj(i).Branch_Obj.get('Item','Smax2')*1e6;
                    else
                        app_power_limits(3) = NaN;
                    end
                    
                    if obj(i).Branch_Obj.get('Item','Smax3') ~= 0 % Third rating
                        app_power_limits(4) = obj(i).Branch_Obj.get('Item','Smax3')*1e6;
                    else
                        app_power_limits(4) = NaN;
                    end
                    
                    % Conversion from app. power to current on "from" side
                    current_limits = app_power_limits / (sqrt(3) * obj(i).Rated_Voltage1_phase_phase);
                    % Current limits are given in A for single phase
                    % App power limits are given in VA for all three phases L123
                    
                end % if object is line or transformer
                
                % Determine if only one branch limit is set across branches
                if sum(isnan(current_limits)) == 3
                    % 'If 3 NaNs exist only the base value limit is
                    % defined
                    obj(i).Number_of_Branch_Violation_limits = 0;
                    % Only one limit is defined
                else
                    obj(i).Number_of_Branch_Violation_limits = 1;
                    % More than one thermal limit is defined
                end
                obj(i).Current_Limits = current_limits; % Current limits defined for SINGLE PHASE!!
                obj(i).App_Power_Limits = app_power_limits; % Apparent power limits defined for THREE PHASE!
                
            end % for i = 1 : numel(obj)
        end % end of function current_limits
        
        function current = update_current_branch_LF_USYM (obj)
            %update_current_branch_LF_USYM
            for i = 1:numel(obj)
                current = zeros(1,8);
                LFBranchResultLoad = obj(i).Branch_Obj.Result('ULFBranchResult', 2);
                if ~isempty(LFBranchResultLoad)
                    current(1,1) = LFBranchResultLoad.get('Item','I1');
                    current(1,2) = LFBranchResultLoad.get('Item','I2');
                    current(1,3) = LFBranchResultLoad.get('Item','I3');
                    current(1,4) = LFBranchResultLoad.get('Item','Ie');
                    current(1,5) = LFBranchResultLoad.get('Item','phiI1');
                    current(1,6) = LFBranchResultLoad.get('Item','phiI2');
                    current(1,7) = LFBranchResultLoad.get('Item','phiI3');
                    current(1,8) = LFBranchResultLoad.get('Item','cos_phie');
                    current(:,1:4) = current(:,1:4)*1000; % Umrechnen von kA in A
                    obj(i).Current = current;
                else
                    % Fehlerbehandlung?!?
                end
            end
        end
        
        function current = update_current_branch_LF_USYM_to (obj)
            %update_current_branch_LF_USYM
            for i = 1:numel(obj)
                current = zeros(1,8);
                LFBranchResultLoad = obj(i).Branch_Obj.Result('ULFBranchResult', 1);
                if ~isempty(LFBranchResultLoad)
                    current(1,1) = LFBranchResultLoad.get('Item','I1');
                    current(1,2) = LFBranchResultLoad.get('Item','I2');
                    current(1,3) = LFBranchResultLoad.get('Item','I3');
                    current(1,4) = LFBranchResultLoad.get('Item','Ie');
                    current(1,5) = LFBranchResultLoad.get('Item','phiI1');
                    current(1,6) = LFBranchResultLoad.get('Item','phiI2');
                    current(1,7) = LFBranchResultLoad.get('Item','phiI3');
                    current(1,8) = LFBranchResultLoad.get('Item','cos_phie');
                    current(:,1:4) = current(:,1:4)*1000; % Umrechnen von kA in A
                    obj(i).Current_to = current;
                else
                    % Fehlerbehandlung?!?
                end
            end
        end
        
        function power = update_power_branch_LF_USYM (obj)
            %update_power_branch_LF_USYM  - load flow values are read
            %for elements - from node to element
            for i = 1:numel(obj)
                active_power = zeros(1,4);
                reactive_power = zeros(1,4);
                apparent_power = zeros(1,4);
                power = [active_power, reactive_power, apparent_power];
                
                LFBranchResultLoad = obj(i).Branch_Obj.Result('ULFBranchResult', 1);
                if ~isempty(LFBranchResultLoad)
                    
                    active_power(1,1) = LFBranchResultLoad.get('Item','P1');
                    active_power(1,2) = LFBranchResultLoad.get('Item','P2');
                    active_power(1,3) = LFBranchResultLoad.get('Item','P3');
                    active_power(1,4) = LFBranchResultLoad.get('Item','Pl');
                    active_power = active_power*1e6; % Umrechnen von MW in W
                    
                    reactive_power(1,1) = LFBranchResultLoad.get('Item','Q1');
                    reactive_power(1,2) = LFBranchResultLoad.get('Item','Q2');
                    reactive_power(1,3) = LFBranchResultLoad.get('Item','Q3');
                    reactive_power(1,4) = LFBranchResultLoad.get('Item','Ql');
                    reactive_power = reactive_power*1e6; % Umrechnen von MVAr in VAr
                    
                    apparent_power(1,1) = LFBranchResultLoad.get('Item','S1');
                    apparent_power(1,2) = LFBranchResultLoad.get('Item','S2');
                    apparent_power(1,3) = LFBranchResultLoad.get('Item','S3');
                    apparent_power(1,4) = LFBranchResultLoad.get('Item','Sl');
                    apparent_power = apparent_power*1e6;% Umrechnen von MVA in VA
                    
                    % Assign values to object
                    obj(i).Active_Power = active_power;
                    obj(i).Reactive_Power = reactive_power;
                    obj(i).Apparent_Power = apparent_power;
                    power = [active_power, reactive_power, apparent_power];
                    
                else
                    % Fehlerbehandlung?!?
                end
            end
        end % end of function update_power_branch
        
        function power = update_power_branch_LF_USYM_to(obj)
            %update_power_branch_LF_USYM_to  - load flow values are read
            %for elements - TO node FROM element
            % ** 'To' values are useful for power loss analysis
            for i = 1:numel(obj)
                active_power_to = zeros(1,4);
                reactive_power_to = zeros(1,4);
                apparent_power_to = zeros(1,4);
                power = [active_power_to, reactive_power_to, apparent_power_to];
                
                LFBranchResultLoad = obj(i).Branch_Obj.Result('ULFBranchResult', 2);
                if ~isempty(LFBranchResultLoad)
                    
                    active_power_to(1,1) = LFBranchResultLoad.get('Item','P1');
                    active_power_to(1,2) = LFBranchResultLoad.get('Item','P2');
                    active_power_to(1,3) = LFBranchResultLoad.get('Item','P3');
                    active_power_to(1,4) = LFBranchResultLoad.get('Item','Pl');
                    active_power_to = active_power_to*1e6; % Umrechnen von MW in W
                    
                    reactive_power_to(1,1) = LFBranchResultLoad.get('Item','Q1');
                    reactive_power_to(1,2) = LFBranchResultLoad.get('Item','Q2');
                    reactive_power_to(1,3) = LFBranchResultLoad.get('Item','Q3');
                    reactive_power_to(1,4) = LFBranchResultLoad.get('Item','Ql');
                    reactive_power_to = reactive_power_to*1e6; % Umrechnen von MVAr in VAr
                    
                    apparent_power_to(1,1) = LFBranchResultLoad.get('Item','S1');
                    apparent_power_to(1,2) = LFBranchResultLoad.get('Item','S2');
                    apparent_power_to(1,3) = LFBranchResultLoad.get('Item','S3');
                    apparent_power_to(1,4) = LFBranchResultLoad.get('Item','Sl');
                    apparent_power_to = apparent_power_to*1e6;% Umrechnen von MVA in VA
                    
                    % Assign values to object
                    obj(i).Active_Power_to = active_power_to;
                    obj(i).Reactive_Power_to = reactive_power_to;
                    obj(i).Apparent_Power_to = apparent_power_to;
                    power = [active_power_to, reactive_power_to, apparent_power_to];
                else
                    % Fehlerbehandlung?!?
                end
            end
        end
        
        function remove_COM_objects (obj)
            % removing all COM-Object out of this class. This has to be
            % done just before instances of this class are saved. Because
            % the COM-Connection will be mostly lost, when this data is
            % reloaded, warnings would appear. By a previous deletion of
            % the COM-Objects, this can be avoided.
            for i = 1:numel(obj)
                obj(i).Branch_Obj = [];
                obj(i).Node_1_Obj = [];
                obj(i).Node_2_Obj = [];
            end
        end % End of remove_COM_objects
        
    end % End of Methods
end % End of classdef
