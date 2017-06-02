function handles = save_simulation_data(handles)
%SAVE_SIMULATON_DATA Summary of this function goes here
%   Detailed explanation goes here

Result = handles.NAT_Data.Result;

% Dateieinstellungen aktualisieren:
Result.Current_Settings.Files = handles.Current_Settings.Files;

file = Result.Current_Settings.Files.Save.Result;
save([file.Path,filesep,file.Name,file.Exte],'Result');

end

