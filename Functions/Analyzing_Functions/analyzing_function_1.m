function handles = analyzing_function_1(handles)
%ANALYZING_FUNCTION_1    dummy of an analyzing function
%    This function represents the body of an anlayzing function for
%    "on-line" analyzing simulation results within the NAT.
%
%    This function has to know:
%      -  the current timepoint, which is simulated (e.g. time of day)
%      -  the used "set" of input values
%      -  the simulated grid variant
%      -  how the grid is organized within MATLAB (Grid representation in
%         MATLAB) in order to allow a mapping of the results. The Mapping
%         is done automatically, if the objects of the MATLAB Grid
%         representation (Structure "Grid") are used (see examples below) 

% Getting access to the data-object
d = handles.NAT_Data;
% this object represents a connection to the stored data within the NAT

% current time point (integer from 1 to number of timepoints to be
% simulated):
ct = d.Simulation.Current_timepoint;
% current simulated grid (grid name as string):
cg = d.Simulation.Grid_act;
% current active dataset (also as integers?):
cd = d.Simulation.Input_Data_act;

% example: update the voltages of all load-nodes using the objects of the
% grid representation in MATLAB:
d.Grid.P_Q_Node.Points.update_voltage_node_LF_USYM;
% get the voltages of all load-nodes:
load_node_voltages = vertcat(d.Grid.P_Q_Node.Points.Voltage);

% also the Tables of the SINCAL-Object are accessable to write own
% functions:
handles.sin.Tables.Element;
% as well as all other object of the SINCAL-automatization.


% The Results are stored in the structure "Grid" within the "Result"-Structure:
d.Result.Grid.Grid_act = [];
% I would propose an array like this
d.Result.Grid.(cg)(cd,ct,:,:) = load_node_voltages;% = "payload"
% The payload is also as a 2D-Array, where the rows are mapped to the
% elements, which are investigated (e.g. branches), the columns are the data of
% interest (e.g. rating of overcurrent).
end

