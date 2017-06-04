function handles = get_default_values_NVIEW(handles)
%GET_DEFAULT_VALUES_NVIEW   loads the default values for all setting for the NVIEW

% Default system and location settings 
[handles.System.Graphics.Screensize,handles.System.Graphics.Colormap] = set_graphical_values('color10');
handles.System.Graphics.FontSize = set_fontsize_values('default');
handles.System.Graphics.Renderer = 'OpenGL'; %'OpenGL','zbuffer'-if errors occur or 'painter'-MATLAB default
% Result information file data
handles.NVIEW_Control.Result_Information_File.Path = handles.System.Main_Path;
handles.NVIEW_Control.Result_Information_File.Name = [];
handles.NVIEW_Control.Result_Information_File.Exte = '.mat';

% Directory for processed result files (export data to)
if ~isdir([handles.System.Main_Path,filesep,'NVIEW results'])
	mkdir([handles.System.Main_Path,filesep,'NVIEW results']);
end
handles.System.Export_Path = ...
    [handles.System.Main_Path,filesep,'NVIEW results'];

% Processed result information file data
handles.NVIEW_Control.NVIEW_Result_Information_File.Path = handles.System.Export_Path;
handles.NVIEW_Control.NVIEW_Result_Information_File.Name = [];
handles.NVIEW_Control.NVIEW_Result_Information_File.Exte = '.mat';

% Add table ID
handles.System.Graphics.Table = 'Empty';

end

