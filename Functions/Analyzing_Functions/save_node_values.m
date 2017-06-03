function handles = save_node_values(handles)

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

% Update voltages after load flow calculation
d.Grid.(cg).All_Node.Points.update_voltage_node_LF_USYM;
% Reshape them into a structured array
node_voltages = vertcat(d.Grid.(cg).All_Node.Points.Voltage);
% Write results
d.Result.(cg).Node_Voltages(cd,ct,:,:) = node_voltages;


end
