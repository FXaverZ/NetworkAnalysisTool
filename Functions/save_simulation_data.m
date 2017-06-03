function handles = save_simulation_data(handles)
%SAVE_SIMULATON_DATA Summary of this function goes here
%   Detailed explanation goes here

handles.NAT_Data.remove_COM_objects;

Result = handles.NAT_Data.Result;
Grid = handles.NAT_Data.Grid;
Load_Infeed_Data = handles.NAT_Data.Load_Infeed_Data;
Debug = handles.NAT_Data.Debug;


file = handles.Current_Settings.Files.Save.Result;
save([file.Path,filesep,file.Name,file.Exte],'Result', 'Grid',...
	'Load_Infeed_Data', 'Debug');

% -- changelog v1.1b ##### (start) // 20130430
% Append info to log file what scenario was calculated
if handles.Current_Settings.Simulation.Use_Scenarios
    write_scenario_log(handles,'append');
    % -- changelog v1.1b ##### (end) // 20130430
end

end

