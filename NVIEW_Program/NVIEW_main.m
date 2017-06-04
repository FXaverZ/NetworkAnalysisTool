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
% Read config.ini settings
handles = get_config_settings(handles);

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
if isfield(handles,'NVIEW_Appended_Results')
    handles = rmfield(handles,'NVIEW_Appended_Results');
end
% Clear table if existing
if isfield(handles,'table_results')
    set(handles.table_results,'Visible','off');
    set(handles.table_results,'Data',[])
    set(handles.table_results,'ColumnName',[],'RowName',[])
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

% Load result information database
handles = load_result_information(handles);
% Convert unprocessed NAT results to NVIEW results
% Update GUI display with new values
handles = refresh_display_NVIEW_main_gui (handles);
% Update handles structure

% select user response and act accordingly
user_response = questdlg([sprintf(['The program must convert NAT results to NVIEW format for result analysis.\n\n',...
                                   'Do you want to save the converted NVIEW Result File for later use?'])],...
                                   'NVIEW Result Processing and Conversion',...
                                   'Save NVIEW Result File',...
                                   'Don''t Save NVIEW Result File',...
                                   'Cancel','Save NVIEW Result File');

switch user_response
    case 'Save NVIEW Result File'
        % Save file
        handles = update_NVIEW_control_panel_busy(handles);        
        [handles,NVIEW_Results,NVIEW_Control] = convert_nat_results_to_nview(handles); 
        handles.NVIEW_Results = NVIEW_Results;
        % Set default scenarios/variants/timestamp values
        handles = set_default_analysis_selection(handles);
        % Refresh display
        handles = refresh_display_NVIEW_main_gui (handles);
        % Save processed results
        file = []; file = NVIEW_Control.NVIEW_Result_Information_File;
        save([file.Path,filesep,file.Name,file.Exte],'NVIEW_Results', 'NVIEW_Control');
    case 'Don''t Save NVIEW Result File'
        % Do not save as NVIEW file
        handles = update_NVIEW_control_panel_busy(handles);
        [~,NVIEW_Results,NVIEW_Control] = convert_nat_results_to_nview(handles);
        handles.NVIEW_Results = NVIEW_Results;
        % Set default scenarios/variants/timestamp values
        handles = set_default_analysis_selection(handles);
        % Refresh display
        handles = refresh_display_NVIEW_main_gui (handles);
    case 'Cancel'
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
if isfield(handles,'NVIEW_Appended_Results')
    handles = rmfield(handles,'NVIEW_Appended_Results');
end
% Clear table if existing
if isfield(handles,'table_results')
    set(handles.table_results,'Visible','off');
    set(handles.table_results,'Data',[])
    set(handles.table_results,'ColumnName',[],'RowName',[])
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
load([file.Path,filesep,file.Name,file.Exte]);
% Update imported NVIEW_Result_Information_File data!
NVIEW_Control.NVIEW_Result_Information_File = file;

% Update NVIEW control and results
handles.NVIEW_Results = [];
handles.NVIEW_Control = [];
handles.NVIEW_Control = NVIEW_Control;
handles.NVIEW_Results = NVIEW_Results;
clear NVIEW_Control NVIEW_Results

cond_missing_nat_files = 0;
% Check if NVIEW file has accurate paths and NAT file locations
for i = 1: size(handles.NVIEW_Control.Result_Files,1)
    if ischar(handles.NVIEW_Control.Result_Files_Paths{i,1})
        if exist([handles.NVIEW_Control.Result_Files_Paths{i,1},filesep,handles.NVIEW_Control.Result_Files{i,1},'.mat'],'file') ~=2
            % Path or file does not exist in NVIEW result file, must recreate result file !
            cond_missing_nat_files = 1;
        end
    else
        for j = 1 : numel(handles.NVIEW_Control.Result_Files_Paths{i,1})
            if exist([handles.NVIEW_Control.Result_Files_Paths{i,1}{1,j},filesep,handles.NVIEW_Control.Result_Files{i,1}{1,j},'.mat'],'file') ~=2
                % Path or file does not exist in NVIEW result file, must recreate result file !
                cond_missing_nat_files = 1;
                break;
            end
        end
    end
end

if cond_missing_nat_files == 1
    % Remove idents
    handles.NVIEW_Control.Result_Files_Paths = [];
    handles.NVIEW_Control.Result_Files = [];
    
    helpdlg_condition = 0;
    while helpdlg_condition == 0;
        user_response = questdlg(sprintf([...
            'Can''t find NAT result files defined in the selected NVIEW processed result file!\n\n',...
            'If TIME DOMAIN result files are available, time period selection is possible. If time domain result files are not available, time period selection will be disabled.\n']),...
            'Can''t find NAT result files!',...
            'Ok','Ok');
        switch user_response
            case 'Ok'
                helpdlg_condition = 1;
        end
    end
    clear user_response helpdlg_condition
end

% Set default scenarios/variants/timestamp values
handles = set_default_analysis_selection(handles);

% Update GUI display with new values
handles = refresh_display_NVIEW_main_gui(handles);
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
handles = call_load_analysis(handles,1);
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

handles = call_voltage_analysis(handles,-1);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_show_load_table_Callback(hObject, eventdata, handles)
% hObject    handle to menu_show_load_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Analysis subfunction call
handles = call_load_analysis(handles,0);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_export_analysis_to_xls_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export_analysis_to_xls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = write_to_excel(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_merge_nat_results_Callback(hObject, eventdata, handles)
% hObject    handle to menu_merge_nat_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = merge_simulation_runs(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_SelectGrid_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_SelectGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Selected_List = listbox_selection(handles,'Select grid variants');

if ~isempty(Selected_List)
    % Set all to zero, followed by setting the selected grid variants to one
    handles.NVIEW_Analysis_Selection.Variants = zeros(size(handles.NVIEW_Analysis_Selection.Variants));
    handles.NVIEW_Analysis_Selection.Variants(Selected_List) = 1;    
    handles = update_NVIEW_control_panel_display_options(handles);
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_SelectScenario_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_SelectScenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Selected_List = listbox_selection(handles,'Select scenarios');

if ~isempty(Selected_List)
    % Set all to zero, followed by setting the selected scenarios to one
    handles.NVIEW_Analysis_Selection.Scenarios = zeros(size(handles.NVIEW_Analysis_Selection.Scenarios));
    handles.NVIEW_Analysis_Selection.Scenarios(Selected_List) = 1;
    handles = update_NVIEW_control_panel_display_options(handles);
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_SelectTimePeriod_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_SelectTimePeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% -------------------------------------------------------------------------
% First time warning!
if handles.System.Settings.First_Run_Select_Time_Period == 1    
    helpdlg_condition = 0;
    while helpdlg_condition == 0;
        user_response = questdlg(sprintf([...
            'WARNING: For time-period domain result analysis NAT results must be available!\r\n\n',...
            'For faster time-domain analysis, enable time-domain result file saving.']),...
            'Select time-period for analysis',...
            'Ok','Don''t show this message again',...
            'Ok');
        switch user_response
            case 'Ok'
                handles.System.Settings.First_Run_Select_Time_Period = 0;
                helpdlg_condition = 1;
            case 'Don''t show this message again'
                handles.System.Settings.First_Run_Select_Time_Period = 0;
                set_config_settings(handles);
                helpdlg_condition = 1;                
        end
    end
    clear user_response helpdlg_condition    
end
% -------------------------------------------------------------------------

if ~isfield(handles.NVIEW_Analysis_Selection,'Appended_External_Results')
    handles.NVIEW_Analysis_Selection.Appended_External_Results = 0;
end

cond_missing_nat_files = 0;
if numel(handles.NVIEW_Control.Result_Files) == 0
    cond_missing_nat_files = 1;
end

% -------------------------------------------------------------------------
if cond_missing_nat_files == 0 
    % NAT results found, select timeperiod
    handles = select_timeperiod(handles);
else
    if handles.NVIEW_Analysis_Selection.Appended_External_Results == 0
        % Missing NAT Result files
        helpdlg_condition = 0;
        while helpdlg_condition == 0;
            
            user_response = questdlg(sprintf([...
                'Can''t find NAT result files defined in the selected NVIEW processed result file!\n\n',...
                'If TIME DOMAIN result files are available, time period selection is possible. \n\nPush ''Select time domain result file path'' to append time domain results.\n']),...
                'Can''t find NAT result files!',...
                'Cancel time domain analysis','Select time domain result file path','Cancel time domain analysis');
            switch user_response
                case 'Cancel time domain analysis'
                    helpdlg_condition = 1;
                case 'Select time domain result file path'
                    handles = find_external_time_domain_results(handles);
                    helpdlg_condition = 1;
            end
        end
        clear user_response helpdlg_condition
    end
end

if handles.NVIEW_Analysis_Selection.Appended_External_Results == 1        
     set(handles.static_text_result_details, 'String', ...
         sprintf(handles.NVIEW_Analysis_Selection.Appended_External_Results_Text));
    
    % Select timeperiod for analysis
    [Selected_Timestamp_Id, Selected_Timestamps, Selected_Hours] = timeperiod_user_selection(handles);
    
    if ~isempty(Selected_Hours)
        if ~strcmp(Selected_Timestamp_Id,handles.NVIEW_Analysis_Selection.DefaultTime_Id)
            
            if isfield(handles.NVIEW_Appended_Results,['TD_',Selected_Timestamp_Id])
                handles.NVIEW_Analysis_Selection.Hours = [];
                handles.NVIEW_Analysis_Selection.Timepoints = [];
                handles.NVIEW_Analysis_Selection.SelectedTime_Id = [];
                
                handles.NVIEW_Analysis_Selection.Hours = Selected_Hours;
                handles.NVIEW_Analysis_Selection.Timepoints = Selected_Timestamps;
                handles.NVIEW_Analysis_Selection.SelectedTime_Id = Selected_Timestamp_Id;
                
                handles = update_NVIEW_control_panel_display_options(handles);
                handles = clear_table_results(handles);
            else
                text_output = ['Time domain results for the selected time period do not exist!'];
                set(handles.static_text_result_details, 'String', ...
                    sprintf(text_output));
            end
        end
    end
end

guidata(hObject, handles);
 
% --------------------------------------------------------------------
function menu_settings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_save_time_domain_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_time_domain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_time_domain = get(hObject,'Label');
if strcmp(save_time_domain,'Disable time-domain files saving')
    handles.System.Settings.Save_Time_Domain = 0;
    set(hObject,'Label','Enable time-domain files saving');
    % Write to config.ini
    set_config_settings(handles);    
else
    set(hObject,'Label','Disable time-domain files saving');
    handles.System.Settings.Save_Time_Domain = 1;
    % Write to config.ini
    set_config_settings(handles);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_debug_mode_Callback(hObject, eventdata, handles)
% hObject    handle to menu_debug_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dbstop in NVIEW_main at 788;
fprintf(1,'Debugging mode enabled\n');
fprintf(1,''); % Stop at this line
% -----------------------------------
dbclear in NVIEW_main at 788;
guidata(hObject, handles);
