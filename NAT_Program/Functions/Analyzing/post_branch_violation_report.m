function handles = post_branch_violation_report(handles)
%POST_BRANCH_VIOLATION_REPORT - post analyzing function

% Getting access to the data-object
d = handles.NAT_Data;
% this object represents a connection to the stored data within the NAT

% Check d.Result for (cg) grids
list_of_grids = fields(d.Result);

for cg = 1 : numel(list_of_grids)  % Number of topologies, i.e. models analysed
    
   grid = list_of_grids{cg}; % Observed grid name
   ext_obj = d.Result.(grid); % Results of topologies/datasets/timepoints
   ext_grid = d.Grid.(grid); % Grid information
   
   % Branch limit violation for lines - <Post_Branch_Violation_Analysis>
   d.Result.(grid).Branch_Violation_Summary = ...
	   Post_Branch_Violation_Analysis(ext_obj,ext_grid,grid);
   
   % Display results as text display in command window
   d.Result.(grid).Branch_Violation_Summary.Display_results;
   

end



end


