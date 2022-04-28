function handles = save_simulation_data(handles)
%SAVE_SIMULATON_DATA Summary of this function goes here
%   Detailed explanation goes here

handles.NAT_Data.remove_COM_objects;
mh = handles.text_message_main_handler;

Result = handles.NAT_Data.Result; %#ok<*NASGU>
Grid = handles.NAT_Data.Grid;
Load_Infeed_Data = handles.NAT_Data.Load_Infeed_Data;
Debug = handles.NAT_Data.Debug;

file = handles.Current_Settings.Files.Save.Result;
% save([file.Path,filesep,file.Name,file.Exte],'Result', 'Grid',...
% 	'Load_Infeed_Data','Debug','-v7.3');
mh.add_line('Saving Resultsfile "',file.Name,file.Exte,'" in "',file.Path,'"');
save([file.Path,filesep,file.Name,file.Exte],'Result', 'Grid',...
	'Load_Infeed_Data','-v7.3');

% % Append info to log file what scenario was calculated
% if handles.Current_Settings.Simulation.Use_Scenarios
%     write_scenario_log(handles,'append');
% end

end

