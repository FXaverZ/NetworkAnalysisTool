function handles = analyzing_function_1(handles, Grid, Result)
%ANALYZING_FUNCTION_1    dummy of an analyzing function
%    This function represents the body of an anlayzing function for
%    "on-line" analyzing simulation results within the NAT.
%
%    This function has to know:
%      -  the current timepoint, which is simulated (e.g. time of day)
%      -  the used "set" of input values
%      -  the simulated grid variant
%      -  how the grid is organized within MATLAB (Grid representation in
%         MATLAB) in order to allow a mapping of the results 

% 

Grid.P_Q_Node.Points.update_voltage_node_LF_USYM;
load_node_voltages = vertcat(Grid.P_Q_Node.Points.Voltage);

end

