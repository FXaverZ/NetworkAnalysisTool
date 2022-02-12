function save_NVIEW_data(hObject,handles)
%SAVE_NVIEW_DATA Summary of this function goes here
%   Detailed explanation goes here

handles = update_NVIEW_control_panel(handles, 'Saving OAT Data, please wait...\n', 'clear');

if ~isfield(handles, 'NVIEW_Results')
    handles = refresh_display_NVIEW_main_gui(handles);
    guidata(hObject, handles);
    return
end

sep = ' - ';
titlestr = 'Saving OAT Data File...';
% Set default location for UI get file to open at (handles >> System)
handles.NVIEW_Control.OAT_Data_File.Path = handles.System.Main_Path;
sourcefile = handles.NVIEW_Control.Result_Information_File;
result_Name = strsplit(sourcefile.Name,sep);
result_Name = result_Name{1};

% Select OAT result file
file = handles.NVIEW_Control.OAT_Data_File;
% Open UI window and select result information file
file.Path = uigetdir(...
    [file.Path,filesep],...
	titlestr);
% Check whether an invalid location has been specified:
if isequal(file.Path,0)  
    % If file is invalid, exit this function and update display of main window    
    % Update detail result panel with error information, not yet implemented
    % Update handles structure
    handles = refresh_display_NVIEW_main_gui(handles);
	guidata(hObject, handles);
	return;
end
handles.NVIEW_Control.OAT_Data_File = file;

filename_add = [sep,'000'];
% make a subfolder
if ~isfolder([file.Path,filesep,result_Name,filename_add])
    mkdir([file.Path,filesep,result_Name,filename_add])
else
    selection = questdlg({...
        'A result exoprt for result id';...
        ['    "',result_Name,'"'];...
        'alread exixts. How should be further progessed?';...
        '';...
        '"Overwrite" = overwrite the existing files';...
        '"Keep" = create a new version with with a suffix " - XXX"';...
        },titlestr,'Overwrite','Keep','Cancel','Keep');
    switch selection
        case 'Overwrite'
            delete([file.Path,filesep,result_Name,filename_add,filesep,'*']);
        case 'Keep'
            new_filename_add_found  = false;
            new_filename_add_number = 1;
            while ~ new_filename_add_found
                filename_add = [sep,num2str(new_filename_add_number,'%03d')];
                if ~isfolder([file.Path,filesep,result_Name,filename_add])
                    mkdir([file.Path,filesep,result_Name,filename_add])
                    new_filename_add_found = true;
                end
                new_filename_add_number = new_filename_add_number + 1;
            end
        case 'Cancel'
            handles = refresh_display_NVIEW_main_gui(handles);
            guidata(hObject, handles);
            return
    end
end
% copy the settings file and the corresponding log-file in the new
% directory for later reference:
copyfile([sourcefile.Path,filesep,sourcefile.Name,sourcefile.Exte],[file.Path,filesep,result_Name,filename_add]);
copyfile([sourcefile.Path,filesep,result_Name,sep,'Log.log'],[file.Path,filesep,result_Name,filename_add]);


[~, infostr] = update_NVIEW_control_panel_simulation_options(handles);
infostr = sprintf([...
    'Content of this data file:\n',...
    '--------------------------\n',...
    strrep(infostr,'%','%%'),...
    '--------------------------\n',...
    ]);
[~, infostr] = update_NVIEW_control_panel_analysis_selection(handles,infostr);
infostr = sprintf([...
    strrep(infostr,'%','%%'),'\n',...
    '--------------------------',...
    ]);
fid = fopen([file.Path,filesep,result_Name,filename_add,filesep,result_Name,sep,'OAT-Data-Info.txt'],'w');
fprintf(fid, strrep(infostr,'%','%%'));
fclose(fid);

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

save([file.Path,filesep,result_Name,filename_add,sep,'OAT-Data','.mat'],variables{:},'-v7.3')

% Inform the user:
str = 'Data successfully saved!';
helpdlg(str, titlestr);

handles = refresh_display_NVIEW_main_gui(handles);

guidata(hObject, handles);
end

