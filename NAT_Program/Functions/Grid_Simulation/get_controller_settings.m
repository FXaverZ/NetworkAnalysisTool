function handles = get_controller_settings(handles)
%GET_CONTROLLER_SETTINGS    returns current settings of charge controller
%   GET_CONTROLLER_SETTINGS returns the current settings of the charge
%   controller back into the HANDLES structure of the NAT. Edit this
%   function to alter the active controller settings.

% Settings of the charge controller
Controller = handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller;

% how many e-mobiles are equiped with this controller [in %]? Only applied
% during random allocation within NAT:
Controller.Equipment_Share =  50;  
% percentage of loading limit of the observed branch, which should be kept
% by the controller: 
Controller.Limit_Factor    = 0.5;
 % percentage of maximum power, which can be shifted to times without
 % branch violation:
Controller.Shifting_Factor = 0.1;

handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller = Controller;

end

