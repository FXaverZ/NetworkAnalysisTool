function save_NVIEW_data(hObject,handles)
%SAVE_NVIEW_DATA Summary of this function goes here
%   Detailed explanation goes here

% Set default location for UI get file to open at (handles >> System)
handles.NVIEW_Control.OAT_Data_File.Path = handles.System.Main_Path;

% Select OAT result file
file = handles.NVIEW_Control.OAT_Data_File;
% Open UI window and select result information file
file.Path = uigetdir(...
    [file.Path,filesep],...
	'Location for OAT data file...');
% Check whether an invalid location has been specified:
if isequal(file.Path,0)  
    % If file is invalid, exit this function and update display of main window    
    % Update detail result panel with error information, not yet implemented
    % Update handles structure
	guidata(hObject, handles);
	return;
end

handles.NVIEW_Control.OAT_Data_File = file;

handles = process_nat_results_as(handles); % Process results

variables = {};
if isfield(handles, 'NVIEW_Analysis_Selection')
    variables{end+1} = 'NVIEW_Analysis_Selection';
    NVIEW_Analysis_Selection = handles.NVIEW_Analysis_Selection; %#ok<*NASGU>
end
if isfield(handles, 'NVIEW_Control')
    variables{end+1} = 'NVIEW_Control';
    NVIEW_Control = handles.NVIEW_Control;
end
if isfield(handles, 'NVIEW_Processed')
    variables{end+1} = 'NVIEW_Processed';
    NVIEW_Processed = handles.NVIEW_Processed;
end
if isfield(handles, 'NVIEW_Results')
    variables{end+1} = 'NVIEW_Results';
    NVIEW_Results = handles.NVIEW_Results;
end

% load the OAT data of the file...
handles = update_NVIEW_control_panel(handles, 'Saving OAT Data, please wait...\n', 'clear');


simdate = datestr(now,'yyyy-mm-dd_HH-MM-SS');
save([file.Path,filesep,'Res_',simdate,' - OAT-Data'],variables{:},'-v7.3')

% Inform the user:
str = 'Data successfully saved!';
helpdlg(str, 'Saving OAT Data File...');

handles = refresh_display_NVIEW_main_gui(handles);

guidata(hObject, handles);
end

