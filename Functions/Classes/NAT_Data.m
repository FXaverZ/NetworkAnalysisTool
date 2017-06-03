classdef NAT_Data < handle
	%NAT_MAIN_CLASS Summary of this class goes here
	%   Detailed explanation goes here
	
	% Erstellt von:            Franz Zeilinger - 10.04.2013
	% Letzte Änderung durch:   Franz Zeilinger - 12.04.2013
	
	properties
		Grid
		Result
		Load_Infeed_Data
		Simulation
	%        different Simulation Setting
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

