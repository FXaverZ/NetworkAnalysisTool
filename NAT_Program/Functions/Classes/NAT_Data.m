classdef NAT_Data < handle
	%NAT_MAIN_CLASS Summary of this class goes here
	%   Detailed explanation goes here
	
	% Version:                 1.2
	% Erstellt von:            Franz Zeilinger - 10.04.2013
	% Letzte Änderung durch:   Matej Rejc      - 24.04.2013
	
	properties
	% Grid Properties and grid related Objects
		Grid
	% Structure with result data
		Result
	% Structure with the input data (loads and infeed)
		Load_Infeed_Data
	% Structure with data, which is neccesary during the running simulation:
		Simulation
	% Structure for saving debug information:
		Debug
	%        different simulation settings
	end
	
	methods
        function remove_COM_objects (obj)
            % removing all COM-Object out of this class. This has to be
            % done just before instances of this class are saved. Because
            % the COM-Connection will be mostly lost, when this data is
            % reloaded, warnings would appear. By a previous deletion of
            % the COM-Objects, this can be avoided.
            grids = fields(obj.Grid);
            for i=1:numel(grids)
                cg = grids{i};
                obj.Grid.(cg).P_Q_Node.Points.remove_COM_objects;
                obj.Grid.(cg).All_Node.Points.remove_COM_objects;
                obj.Grid.(cg).Branches.Lines.remove_COM_objects;
                obj.Grid.(cg).Branches.Transf.remove_COM_objects;
            end
        end
        
	end
	
end

