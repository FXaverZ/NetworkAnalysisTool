function load_NVIEW_data(hObject,handles)
%LOAD_NVIEW_DATA Summary of this function goes here
%   Detailed explanation goes here

% Select OAT result file
file = handles.NVIEW_Control.OAT_Data_File;
% Open UI window and select result information file
[file.Name,file.Path] = uigetfile([...
	{'*.mat','*.mat OAT data file'};...
	{'*.*','All files'}],...
	'Load OAT data file...',...
	[file.Path,filesep]);
% Check whether an invalid location has been specified:
if isequal(file.Name,0) || isequal(file.Path,0)  
    % If file is invalid, exit this function and update display of main window    
    % Update detail result panel with error information, not yet implemented
    % Update handles structure
	guidata(hObject, handles);
	return;
end

% Selected file and location are valid.
[~, file.Name, file.Exte] = fileparts(file.Name);
% Remove backslash from folder name
file.Path = file.Path(1:end-1);

% load the OAT data of the file...
handles = update_NVIEW_control_panel(handles, 'Loading OAT Data...\n', 'clear');
try
    handles = update_NVIEW_control_panel(handles, '- Loading "Analysis Selection"...', 'append');
    load([file.Path,filesep,file.Name,file.Exte],'NVIEW_Analysis_Selection');
    if exist('NVIEW_Analysis_Selection', 'var')
        handles.NVIEW_Analysis_Selection = NVIEW_Analysis_Selection;
        clear NVIEW_Analysis_Selection
    end
    handles = update_NVIEW_control_panel(handles, ' done.\n', 'append');
    
    handles = update_NVIEW_control_panel(handles, '- Loading "Control"...', 'append');
    load([file.Path,filesep,file.Name,file.Exte],'NVIEW_Control');
    if exist('NVIEW_Control', 'var')
        handles.NVIEW_Control = NVIEW_Control;
        clear NVIEW_Control
    end
    handles = update_NVIEW_control_panel(handles, ' done.\n', 'append');
    
    handles = update_NVIEW_control_panel(handles, '- Loading "Processed"...', 'append');
    load([file.Path,filesep,file.Name,file.Exte],'NVIEW_Processed');
    if exist('NVIEW_Processed', 'var')
        handles.NVIEW_Processed = NVIEW_Processed;
        clear NVIEW_Processed
    end
    handles = update_NVIEW_control_panel(handles, ' done.\n', 'append');
    
    handles = update_NVIEW_control_panel(handles, '- Loading "Results"...', 'append');
    load([file.Path,filesep,file.Name,file.Exte],'NVIEW_Results');
    if exist('NVIEW_Results', 'var')
        handles.NVIEW_Results = NVIEW_Results;
        clear NVIEW_Results
    end
    handles = update_NVIEW_control_panel(handles, ' done.\n', 'append');
catch
    errordlg({'Could not load file';['"',file.Name,file.Exte,'"'];'Aborting...'},'Import OAT Data...');
    handles = refresh_display_NVIEW_main_gui(handles);
    guidata(hObject, handles);
    return;
end

% Update NVIEW settings result information
handles.NVIEW_Control.OAT_Data_File = file;

handles = refresh_display_NVIEW_main_gui(handles);

guidata(hObject, handles);
end

