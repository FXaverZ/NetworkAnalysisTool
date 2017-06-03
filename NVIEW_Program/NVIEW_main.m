% RESULT PROCESSING TOOL  (NAT VIEW)  Netzanalyse- und Simulationstool result
% processing tool program

% Version:                 1.1
% Erstellt von:            Matej Rejc       - 29.01.2013
% Letzte Änderung durch:   Matej Rejc       - 29.04.2013

function varargout = NVIEW_main(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NVIEW_main_OpeningFcn, ...
                   'gui_OutputFcn',  @NVIEW_main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function NVIEW_main_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for NVIEW_main_gui
handles.output = hObject;


% Search for the location of the program
[~, Source_File] = fileattrib('NVIEW_main.m');
if ischar(Source_File)
	fprintf([Source_File,' - Cannot find ', '''NVIEW_main.m'' in the current directory!\n']);
	% Close window
	delete(handles.NVIEW_main_gui);
	return;
end
% Add path to program
Path = fileparts(Source_File.Name);
addpath(genpath(Path));
handles.System.Main_Path = Path;
% Set default settings >> default settings are defined in "get_default_values_NVIEW"
handles = get_default_values_NVIEW(handles);

% Refresh display NVIEW main GUI
handles = refresh_display_NVIEW_main_gui(handles);

% Update content panel title
set(handles.panel_result_details,'Title','NVIEW Content Panel');
% SIEMENS-Logo set to nview_axes_logo:
logo=imread('Figures\siemenslogo.jpg','jpg');   % Einlesen der Grafik
image(logo,'Parent',handles.nview_axes_logo);   % Darstellen des Logos
axis image;                                     % Grafik entzerren
axis off;                                       % Achsenbezeichnung ausschalten
set(handles.table_results,'Visible','off');

% Update handles structure
guidata(hObject, handles);

function varargout = NVIEW_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% Outputs from this function are returned to the command line.
% Get default command line output from handles structure
varargout{1} = handles.output;

function menu_home_Callback(hObject, eventdata, handles)
% hObject    handle to menu_home (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_import_nat_results_Callback(hObject, eventdata, handles)
% Import unprocessed results and view information

% Clear NVIEW Control and Result fields
handles.NVIEW_Control = [];
handles = get_default_values_NVIEW(handles);
handles = refresh_display_NVIEW_main_gui (handles);
% Clear NVIEW_Results if existing
if isfield(handles,'NVIEW_Results')
    handles = rmfield(handles,'NVIEW_Results');
end
        
% Set default location for UI get file to open at (handles >> System)
handles.NVIEW_Control.Result_Information_File.Path = handles.System.Main_Path;

% Select NAT result file
file = handles.NVIEW_Control.Result_Information_File;
% Open UI window and select result information file
[file.Name,file.Path] = uigetfile([...
	{'*.mat','*.mat result information MAT-file'};...
	{'*.*','All files'}],...
	'Load result information data...',...
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
% Update NVIEW settings result information
handles.NVIEW_Control.Result_Information_File = file;
% Match Scenario/Grid details path with result information file
handles.NVIEW_Control.Scen_Grid_Information_File.Path = file.Path;
% Check for scenario/grid detail log file
file = []; file = dir([...
    handles.NVIEW_Control.Result_Information_File.Path,filesep,...
    'Scen_',handles.NVIEW_Control.Result_Information_File.Name(1+size('Res_',2):end - size(' - information',2)+1),'*.txt']);
 
% Alter the file properties to match the txt log file
if ~isempty(file)
    [~, file.Name, ~] = fileparts(file.name);
    handles.NVIEW_Control.Scen_Grid_Information_File.Name = file.Name;
end

% Load result information database
handles = load_result_information(handles);
% Convert unprocessed NAT results to NVIEW results
% Update GUI display with new values
handles = refresh_display_NVIEW_main_gui (handles);
% Update handles structure

user_response = questdlg(sprintf(['NVIEW Result conversion and processing! ',...
                                   '\nContinue conversion to NVIEW Result File?']),...
                                   'NVIEW Result conversion',...
                                   'Yes And Save to NVIEW Result File',...
                                   'Yes But Don''t Save',...
                                   'Cancel NVIEW Conversion','Yes And Save to NVIEW Result File');

% select user response and act accordingly
switch user_response
    case 'Yes And Save to NVIEW Result File'
        % Save file
        handles = update_NVIEW_control_panel_busy(handles);
        
        [handles,NVIEW_Results,NVIEW_Control] = convert_nat_results_to_nview(handles);
        % Save processed results
        file = []; file = NVIEW_Control.NVIEW_Result_Information_File;
        save([file.Path,filesep,file.Name,file.Exte],'NVIEW_Results', 'NVIEW_Control');
        
        handles.NVIEW_Results = NVIEW_Results;
        handles = refresh_display_NVIEW_main_gui (handles);
    case 'Yes But Don''t Save'
        % Do not save as NVIEW file
        handles = update_NVIEW_control_panel_busy(handles);
        [~,NVIEW_Results,NVIEW_Control] = convert_nat_results_to_nview(handles);
        handles.NVIEW_Results = NVIEW_Results;
        handles = refresh_display_NVIEW_main_gui (handles);
    case 'Cancel NVIEW Conversion'
        handles.NVIEW_Control = [];
        handles = get_default_values_NVIEW(handles);
        handles = refresh_display_NVIEW_main_gui (handles);
        % Clear NVIEW_Results if existing
        if isfield(handles,'NVIEW_Results')
            handles = rmfield(handles,'NVIEW_Results');
        end
end
 guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_import_nview_results_Callback(hObject, eventdata, handles)
% hObject    handle to menu_import_nview_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NVIEW_Control = [];
handles = get_default_values_NVIEW(handles);
handles = refresh_display_NVIEW_main_gui (handles);
% Clear NVIEW_Results if existing
if isfield(handles,'NVIEW_Results')
    handles = rmfield(handles,'NVIEW_Results');
end


% Set default location for UI get file to open at (handles >> System)
handles.NVIEW_Control.Result_Information_File.Path = handles.System.Main_Path;

% Select NVIEW result file
file = handles.NVIEW_Control.NVIEW_Result_Information_File;
% Open UI window and select result information file
[file.Name,file.Path] = uigetfile([...
	{'*.mat','*.mat NVIEW result MAT-file'};...
	{'*.*','All files'}],...
	'Load NVIEW result data...',...
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

file.Path = file.Path(1:end-1);

% Load NVIEW result files
load([file.Path,filesep,file.Name]);
% Update imported NVIEW_Result_Information_File data!
NVIEW_Control.NVIEW_Result_Information_File = file;

% Update NVIEW control and results
handles.NVIEW_Control = NVIEW_Control;
handles.NVIEW_Results = NVIEW_Results;
clear NVIEW_Control NVIEW_Results

% Update GUI display with new values
handles = refresh_display_NVIEW_main_gui (handles);
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
 function menu_exit_Callback(hObject, eventdata, handles)
 % hObject    handle to menu_exit (see GCBO)
 % eventdata  reserved - to be defined in a future version of MATLAB
 % handles    structure with handles and user data (see GUIDATA)
 user_response = questdlg('Close NAT result viewer?',...
                          'Close NVIEW','Yes','No','No');
 switch user_response
     case 'No'
         % Do not close
     case 'Yes'
         % Kein speichern der akutellen Einstellungen, nur beenden des Programms:
         check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
         close(check_active_figures);
         delete(handles.NVIEW_main_gui);
 end       
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
 function menu_about_Callback(hObject, eventdata, handles)
 % hObject    handle to menu_about (see GCBO)
 % eventdata  reserved - to be defined in a future version of MATLAB
 % handles    structure with handles and user data (see GUIDATA)
 msgbox(sprintf(['Netzanalyse und Simulationstool result viewer\n',...
                 'Matej Rejc, UL FE, Slovenia, 2013']),...
                 'NVIEW result processing toolbox','help');

% --------------------------------------------------------------------
function menu_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_scen_information_Callback(hObject, eventdata, handles)
% View result file information (name of filename, scenario/grid information)
handles = update_NVIEW_control_panel_simulation_description(handles,'scenario');
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_grid_information_Callback(hObject, eventdata, handles)
% hObject    handle to menu_grid_information (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_NVIEW_control_panel_simulation_description(handles,'grid');
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_view_simulation_options_Callback(hObject, eventdata, handles)
% View simulation options
handles = update_NVIEW_control_panel_simulation_options(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_voltage_analysis_all_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_analysis_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Analysis subfunction call
handles = call_voltage_analysis(handles,0);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_load_analysis_all_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_analysis_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Close existing figures

% Analysis subfunction call
handles = call_load_analysis(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_current_analysis_main_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_analysis_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_voltage_violation_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_violation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Analysis subfunction call
handles = call_voltage_analysis(handles,1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_nodes_violated_Callback(hObject, eventdata, handles)
% hObject    handle to menu_nodes_violated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Analysis subfunction call
handles = call_voltage_analysis(handles,2);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_voltage_histograms_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_histograms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Analysis subfunction call
handles = call_voltage_analysis(handles,3);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_voltage_deviations_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_deviations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Analysis subfunction call
handles = call_voltage_analysis(handles,4);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_losses_analysis_main_Callback(hObject, eventdata, handles)
% hObject    handle to menu_losses_analysis_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_analysis_details_Callback(hObject, eventdata, handles)
% hObject    handle to menu_analysis_details (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_voltage_analysis_main_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_analysis_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function pushtool_Grayscale_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_Grayscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.System.Graphics.Screensize,handles.System.Graphics.Colormap] = set_graphical_values('gray');
handles = recolor_nview_figures(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_Color10_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_Color10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.System.Graphics.Screensize,handles.System.Graphics.Colormap] = set_graphical_values('color10');
handles = recolor_nview_figures(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_Color12_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_Color12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.System.Graphics.Screensize,handles.System.Graphics.Colormap] = set_graphical_values('color12');
handles = recolor_nview_figures(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_CloseFig_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_CloseFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.System.Graphics.FontSize = set_fontsize_values('default');
[handles.System.Graphics.Screensize,handles.System.Graphics.Colormap] = set_graphical_values('color10');

check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
close(check_active_figures);
guidata(hObject, handles);

% --- Executes when user attempts to close NVIEW_main_gui.
function NVIEW_main_gui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to NVIEW_main_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
close(check_active_figures);
delete(hObject);

% --------------------------------------------------------------------
function pushtool_FontSizeUp_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_FontSizeUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.System.Graphics.FontSize = set_fontsize_values(handles.System.Graphics.FontSize+2);
if handles.System.Graphics.FontSize > 24
    handles.System.Graphics.FontSize = 24;
end

check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
for i = 1 :  numel(check_active_figures)
    % Set text and axes text size
    set(findall(check_active_figures(i),'Type','text'),'FontSize',handles.System.Graphics.FontSize);
    set(findall(check_active_figures(i),'Type','axes'),'FontSize',handles.System.Graphics.FontSize);
    
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_FontSizeDown_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_FontSizeDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.System.Graphics.FontSize = set_fontsize_values(handles.System.Graphics.FontSize-2);
% Limit text to 4 fontsize
if handles.System.Graphics.FontSize < 6
    handles.System.Graphics.FontSize = 6;
end

check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
for i = 1 :  numel(check_active_figures)
    % Set text and axes text size
    set(findall(check_active_figures(i),'Type','text'),'FontSize',handles.System.Graphics.FontSize);
    set(findall(check_active_figures(i),'Type','axes'),'FontSize',handles.System.Graphics.FontSize);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function pushtool_OpenExcel_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_OpenExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = handles.System.Export_Path;
file = [strrep(handles.NVIEW_Control.Result_Information_File.Name,' - information','_'),'Summary'];
file = [path,filesep,file,'.xls'];

if exist(file,'file') == 2
    winopen(file);
else
    write_to_excel(handles);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function pushtool_SaveFig_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_SaveFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
file_format = 'emf'; % Enhanced meta file

for i = 1 : numel(check_active_figures)
    Figure_Name = [];
    Figure_Name = [strrep(handles.NVIEW_Control.Result_Information_File.Name,' - information','_'),...
                   get(check_active_figures(i),'name')];
    
    % Shorten names
    Figure_Name = strrep(Figure_Name, 'percentage', 'perc');
    Figure_Name = strrep(Figure_Name, 'affected','aff');
    Figure_Name = strrep(Figure_Name, 'voltage','volt');
    Figure_Name = strrep(Figure_Name, 'violations','viol');
    Figure_Name = strrep(Figure_Name, ' ', '_');               
    Figure_Name = [Figure_Name,'.',file_format];
    % Add filepath to file name
    Figure_Name = [handles.System.Export_Path,filesep,Figure_Name];    
    saveas(check_active_figures(i),Figure_Name,file_format)
end
    
% --------------------------------------------------------------------
function pushtool_Resize_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_Resize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Screensize = change_screensize(handles);
handles.System.Graphics.Screensize = Screensize;
check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);

for i = 1 : numel(check_active_figures)
    set(check_active_figures(i),'Position',Screensize);
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_load_analysis_main_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_analysis_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_show_voltage_analysis_table_Callback(hObject, eventdata, handles)
% hObject    handle to menu_show_voltage_analysis_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Transfer handles substructures to internal structures
d = handles.NVIEW_Results;
s = handles.NVIEW_Control;

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,'Voltage analysis')
    handles = clear_table_results(handles);    
    Table = create_voltage_violation_table(handles,d,s);
    handles = draw_voltage_violation_table(handles,Table);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_show_load_table_Callback(hObject, eventdata, handles)
% hObject    handle to menu_show_load_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Table_Inp = get_data_input_scenarios(handles);

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,'Load/Infeed analysis')    
    handles = clear_table_results(handles);  
    Table = create_load_infeed_table(handles,Table_Inp);
    handles = draw_load_infeed_table(handles,Table);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_export_analysis_to_xls_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export_analysis_to_xls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = write_to_excel(handles);

