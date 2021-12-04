function handles = get_default_values_NVIEW(handles)
%GET_DEFAULT_VALUES_NVIEW   loads the default values for all setting for the NVIEW

% Default system and location settings 
[handles.System.Graphics.Screensize,handles.System.Graphics.Colormap] = set_graphical_values('color10');
handles.System.Graphics.FontSize = set_fontsize_values('default');
handles.System.Graphics.Renderer = 'OpenGL'; %'OpenGL','zbuffer'-if errors occur or 'painter'-MATLAB default

% Result information file data
handles.NVIEW_Control = [];
handles.NVIEW_Control.Result_Information_File.Path = handles.System.Main_Path;
handles.NVIEW_Control.Result_Information_File.Name = [];
handles.NVIEW_Control.Result_Information_File.Exte = '.mat';

% Add table ID
handles.System.Graphics.Table = 'Empty';

% Export path for results
handles.System.Export_Path = [handles.System.Main_Path,filesep,'NVIEW results'];
if exist(handles.System.Export_Path,'dir') == 0
    % Pat does not exist
    mkdir(handles.System.Export_Path);
end

