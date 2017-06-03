function handles = post_analyzing_function_1(handles)
%POST_ANALYZING_FUNCTION_1    dummy of a post analyzing function
%    This function postprcesses the gathered data of the
%    analyzing_function_1 after all simulations were made.

% Getting access to the data-object
d = handles.NAT_Data;
% this object represents a connection to the stored data within the NAT

array = d.Result.Grid.Test_NS_50_Knoten_o_PV;

% e.g. all results at time-count 5 are:
t_5 = squeeze(array(:,5,:,:));
% 1st dim: the single input data sets
% 2nd dim: all the load nodes:
loadnodes_names = {d.Grid.P_Q_Node.Points.Node_Name};
% 3rd dim: the three phases, but in ohter result arrays are here stored
% different values and functions.

% this function iterates over all simulation results and calculates the
% final outcomes and displays / saves them...
end

