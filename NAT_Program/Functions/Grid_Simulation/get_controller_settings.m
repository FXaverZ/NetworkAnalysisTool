function handles = get_controller_settings(handles)
%GET_CONTROLLER_SETTINGS Summary of this function goes here
%   Detailed explanation goes here

% Settings of the charge controller
Controller = handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller;

Controller.Equipment_Share = 50;  % how many e-mobiles are equiped with this controller [in %]? Only applied during random allocation within NAT!
Controller.Limit_Factor = 0.5;      % percentage of loading limit of the observed branch, which should be kept by the controller
Controller.Shifting_Factor = 0.1; % percentage of maximum power, which can be shifted to times without branch violation

handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller = Controller;

end

