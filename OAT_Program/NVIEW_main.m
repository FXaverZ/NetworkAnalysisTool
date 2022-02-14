% RESULT PROCESSING TOOL  (NAT VIEW)  Netzanalyse- und Simulationstool result
% processing tool program

% Version:                 1.1
% Erstellt von:            Matej Rejc       - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger  - 12.02.2022

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

Path = fileparts(Source_File.Name);
handles.System.Main_Path = Path;
% Add path to program
addpath(genpath(Path));
% Add path to common functions
addpath(genpath([fileparts(Path),filesep,'NAT_Common']));


% Set default settings >> default settings are defined in "get_default_values_NVIEW"
handles.NVIEW_Control = [];
handles = get_default_values_NVIEW(handles);

% Refresh display NVIEW main GUI
handles = refresh_display_NVIEW_main_gui(handles);

% Update content panel title
set(handles.panel_result_details,'Title','OAT Content Panel');
% SIEMENS-Logo set to nview_axes_logo:
logo=imread('Figures\Siemens_Logo.jpg','jpg');   % Einlesen der Grafik
% logo=imread('Figures\institutslogo.jpg','jpg');
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

 % --- Executes when user attempts to close NVIEW_main_gui.
function NVIEW_main_gui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to NVIEW_main_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
close(check_active_figures);
delete(hObject);
% --------------------------------------------------------------------

function menu_home_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_home_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 user_response = questdlg('Close NAT result viewer?',...
                          'Close NVIEW','Yes','No','No');
 switch user_response
     case 'No'
         % Do not close
     case 'Yes'
         check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
         close(check_active_figures);
         delete(handles.NVIEW_main_gui);
 end 
 
 function menu_home_export_oat_results_Callback(hObject, ~, handles)
% hObject    handle to menu_home_export_oat_results (see GCBO)
% ~          reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_NVIEW_data(hObject,handles)

function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 msgbox(sprintf(['Result viewer for Netzanalysetool NAT\n',...
                 'Franz Zeilinger, TU Wien / SIEMENS, 2014 - 2022\n',...
                 'Matej Rejc, UL FE / SIEMENS, 2014\n']),...
                 'NAT result processing toolbox','help');

 % --------------------------------------------------------------------
function menu_debug_mode_Callback(hObject, eventdata, handles)
% hObject    handle to menu_debug_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dbstop in NVIEW_main at 210;
fprintf(1,'Debugging mode enabled\n');
fprintf(1,''); % Stop at this line

% idx = find(strcmp(handles.NVIEW_Results.josefstadt_soll_schematisch_20140210.branch_name,'T_JOS'));
% ILim = handles.NVIEW_Results.josefstadt_soll_schematisch_20140210.branch(idx,7);
% dim_res = size(handles.NVIEW_Results.josefstadt_soll_schematisch_20140210.branch_values);
% 
% % Values saved in W, VAr, VA and A: [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie]
% % (4 values per phase and phase-ground)
% vals = squeeze(handles.NVIEW_Results.josefstadt_soll_schematisch_20140210.branch_values(1,:,:,idx,[4 8 12 16]));
% vals_avg = squeeze(sum(vals)/size(vals,1));
% figure;
% plot (vals_avg)

r = load([handles.NVIEW_Control.Result_Files_Paths{1},filesep,handles.NVIEW_Control.Result_Files{1},'.mat']);
d1 = r.Load_Infeed_Data.Set_1.LV_Grid_Input.Data_Mean(:,[1 3 5]+66);
d2 = r.Load_Infeed_Data.Set_2.LV_Grid_Input.Data_Mean(:,[1 3 5]+66);
figure;plot(d1);
figure;plot(d2);
idx_tr = strcmp('T_7272P',handles.NVIEW_Results.josefstadt_ist_schem_red_20140314.branch_name);
vals = squeeze(handles.NVIEW_Results.josefstadt_ist_schem_red_20140314.branch_values(1,:,:,idx_tr,:));
s1 = squeeze(vals(1,:,[1 5 9]+2));
s2 = squeeze(vals(2,:,[1 5 9]+2));
figure;plot(s1);
figure;plot(s2);
idx_tr = strcmp('T_9317P',handles.NVIEW_Results.josefstadt_ist_schem_red_20140314.branch_name);
vals = squeeze(handles.NVIEW_Results.josefstadt_ist_schem_red_20140314.branch_values(1,:,:,idx_tr,:));
s1 = squeeze(vals(1,:,[1 5 9]+2));
s2 = squeeze(vals(2,:,[1 5 9]+2));
figure;plot(s1);
figure;plot(s2);
idx_tr = strcmp('T_7393P',handles.NVIEW_Results.josefstadt_ist_schem_red_20140314.branch_name);
vals = squeeze(handles.NVIEW_Results.josefstadt_ist_schem_red_20140314.branch_values(1,:,:,idx_tr,:));
s1 = squeeze(vals(1,:,[1 5 9]+2));
s2 = squeeze(vals(2,:,[1 5 9]+2));
figure;plot(s1);
figure;plot(s2);
% -----------------------------------
dbclear in NVIEW_main at 210;
guidata(hObject, handles);
 
% --------------------------------------------------------------------
function menu_view_simulation_options_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view_simulation_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% View simulation options
handles = update_NVIEW_control_panel_simulation_options(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_view_scen_information_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view_scen_information (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% View scenario information
handles = update_NVIEW_control_panel_simulation_description(handles,'scenario');
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_view_grid_information_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view_grid_information (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% View grid information
handles = update_NVIEW_control_panel_simulation_description(handles,'grid');
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_view_analysis_settings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view_analysis_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_home_Callback(hObject, eventdata, handles)
% hObject    handle to menu_home (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_settings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_load_analysis_main_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_analysis_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_voltage_analysis_main_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_analysis_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_current_analysis_main_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_analysis_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_electric_losses_analysis_main_Callback(hObject, eventdata, handles)
% hObject    handle to menu_electric_losses_analysis_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_export_analysis_to_xls_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export_analysis_to_xls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Write to Excel
handles = write_to_excel(handles);
guidata(hObject, handles);

function menu_help_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menu_home_import_nat_results_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to menu_home_import_nat_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = get_default_values_NVIEW(handles);
handles = refresh_display_NVIEW_main_gui (handles);

handles = import_nat_results(handles,'UserInput',true);

guidata(hObject, handles);
 
 function menu_home_import_oat_results_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to menu_home_import_oat_results (see GCBO)
% ~          reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load_NVIEW_data(hObject,handles)

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
function pushtool_Color16_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_Color16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.System.Graphics.Screensize,handles.System.Graphics.Colormap] = set_graphical_values('color16');
handles = recolor_nview_figures(handles);
guidata(hObject, handles);

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

function pushtool_Resize_ClickedCallback(hObject, ~, handles) %#ok<DEFNU>
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

function pushtool_SaveFig_ClickedCallback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to pushtool_SaveFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_NVIEW_control_panel(handles, 'Saving figures, please wait...\n', 'clear');

check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);

file_format_1 = 'emf'; % Enhanced meta file
file_format_2 = 'png'; % "Thumbnail" for quick checking of contents of figures...


for i = 1 : numel(check_active_figures)
    Figure_Name = [strrep(handles.NVIEW_Control.Result_Information_File.Name,' - Settings','_'),...
                   get(check_active_figures(i),'name')];
    % Shorten names
    Figure_Name = strrep(Figure_Name, 'percentage', 'perc');
    Figure_Name = strrep(Figure_Name, 'affected','aff');
    Figure_Name = strrep(Figure_Name, 'voltage','volt');
    Figure_Name = strrep(Figure_Name, 'violations','viol');
	Figure_Name = strrep(Figure_Name, 'violation','viol');
	Figure_Name = strrep(Figure_Name, 'currents','curr');
	Figure_Name = strrep(Figure_Name, 'current','curr');
	Figure_Name = strrep(Figure_Name, 'Current','Curr');
	Figure_Name = strrep(Figure_Name, 'histogram','hist');
	Figure_Name = strrep(Figure_Name, ' ', '_');
	
    Figure_Name_1 = [Figure_Name,'.',file_format_1];
	Figure_Name_2 = [Figure_Name,'.',file_format_2];
    
    % Add filepath to file name
    Figure_Name = [handles.System.Export_Path,filesep,Figure_Name_1];    
    saveas(check_active_figures(i),Figure_Name,file_format_1)
	Figure_Name = [handles.System.Export_Path,filesep,Figure_Name_2]; 
	saveas(check_active_figures(i),Figure_Name,file_format_2)
end
handles = refresh_display_NVIEW_main_gui(handles);
helpdlg('The plot(s) were succesfully saved!','Save plots...');
guidata(hObject, handles);

function pushtool_SaveFigData_ClickedCallback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to pushtool_SaveFigData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = get_figure_data(handles);
handles = refresh_display_NVIEW_main_gui(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_OpenExcel_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_OpenExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);

path = handles.System.Export_Path;
file = [strrep(handles.NVIEW_Control.Result_Information_File.Name,' - information','_'),'NVIEW'];
file = [path,filesep,file,'.xls'];
if exist(file,'file') == 2
    winopen(file);
else
    write_to_excel(handles);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function pushtool_SelectGrid_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_SelectGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Selected_List = listbox_selection(handles,'Select grid variants');

if ~isempty(Selected_List) && listbox_ctc_sg(Selected_List,handles.NVIEW_Analysis_Selection.Variants)
    % Set all to zero, followed by setting the selected grid variants to one
    handles.NVIEW_Analysis_Selection.Variants = zeros(size(handles.NVIEW_Analysis_Selection.Variants));
    handles.NVIEW_Analysis_Selection.Variants(Selected_List) = 1;    

    handles = update_NVIEW_control_panel_analysis_selection(handles,[]);   
    handles = clear_table_results(handles);     
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_SelectScenario_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_SelectScenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Selected_List = listbox_selection(handles,'Select scenarios');

if ~isempty(Selected_List) && listbox_ctc_sg(Selected_List,handles.NVIEW_Analysis_Selection.Scenarios)
    % Set all to zero, followed by setting the selected scenarios to one
    handles.NVIEW_Analysis_Selection.Scenarios = zeros(size(handles.NVIEW_Analysis_Selection.Scenarios));
    handles.NVIEW_Analysis_Selection.Scenarios(Selected_List) = 1;
    
    handles = update_NVIEW_control_panel_analysis_selection(handles,[]);   
    handles = clear_table_results(handles);     
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_SelectTimePeriod_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_SelectTimePeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Select timeperiod for analysis
[Selected_Timestamp_Id, Selected_Timestamps, Selected_Hours] = timeperiod_user_selection(handles);

if ~isempty(Selected_Hours) && ~strcmp(Selected_Timestamp_Id,handles.NVIEW_Analysis_Selection.SelectedTime_Id)
    handles.NVIEW_Analysis_Selection.Hours = Selected_Hours;
    handles.NVIEW_Analysis_Selection.Timepoints = Selected_Timestamps;
    handles.NVIEW_Analysis_Selection.SelectedTime_Id = Selected_Timestamp_Id;
    
    handles = update_NVIEW_control_panel_analysis_selection(handles,[]);   
    handles = clear_table_results(handles); 
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function pushtool_SetVoltageLimits_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_SetVoltageLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Umin,Umax] = edit_text_selection_voltage_limits(handles);

if ~isempty(Umin) && ~isempty(Umax) && (handles.NVIEW_Analysis_Selection.Umin ~= Umin  || handles.NVIEW_Analysis_Selection.Umax ~= Umax)
    handles.NVIEW_Analysis_Selection.Umin = Umin;
    handles.NVIEW_Analysis_Selection.Umax = Umax;
    handles = update_NVIEW_control_panel_analysis_selection(handles,[]);
    handles = clear_table_results(handles); 
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_SetCurrentLimits_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_SetCurrentLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Ilim = edit_text_selection_current_limits(handles);
if ~isempty(Ilim)
    handles.NVIEW_Analysis_Selection.Ilim = Ilim;
    handles = update_NVIEW_control_panel_analysis_selection(handles,[]);
    handles = clear_table_results(handles); 
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_setNodes_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_setNodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Selected_List = listbox_selection_topology(handles,'Select nodes');

if listbox_topology_ctc_bn(Selected_List,handles.NVIEW_Analysis_Selection.SelectedNodes)
    % Set all to zero, followed by setting the selected elements to one
    Field_List = handles.NVIEW_Control.Simulation_Description.Variants;
    
    for i = 1 : handles.NVIEW_Control.Simulation_Options.Number_of_Variants
        handles.NVIEW_Analysis_Selection.SelectedNodes.(Field_List{i}) = zeros(size(handles.NVIEW_Analysis_Selection.SelectedNodes.(Field_List{i})));
        
        handles.NVIEW_Analysis_Selection.SelectedNodes.(Field_List{i})(Selected_List.(Field_List{i})) = 1;
    end
        
    handles = update_NVIEW_control_panel_analysis_selection(handles,[]);   
    handles = clear_table_results(handles);     
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function pushtool_setBranches_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtool_setBranches (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Selected_List = listbox_selection_topology(handles,'Select branches');

if listbox_topology_ctc_bn(Selected_List,handles.NVIEW_Analysis_Selection.SelectedBranches)
    % Set all to zero, followed by setting the selected elements to one
    Field_List = handles.NVIEW_Control.Simulation_Description.Variants;
    
    for i = 1 : handles.NVIEW_Control.Simulation_Options.Number_of_Variants
        handles.NVIEW_Analysis_Selection.SelectedBranches.(Field_List{i}) = zeros(size(handles.NVIEW_Analysis_Selection.SelectedBranches.(Field_List{i})));
        
        handles.NVIEW_Analysis_Selection.SelectedBranches.(Field_List{i})(Selected_List.(Field_List{i})) = 1;
    end
        
    handles = update_NVIEW_control_panel_analysis_selection(handles,[]);   
    handles = clear_table_results(handles);     
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_voltage_analysis_all_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_analysis_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_analysis(handles,0);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_show_voltage_analysis_table_Callback(hObject, eventdata, handles)
% hObject    handle to menu_show_voltage_analysis_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_analysis(handles,-1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_voltage_violation_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_violation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_analysis(handles,1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_nodes_violated_Callback(hObject, eventdata, handles)
% hObject    handle to menu_nodes_violated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_analysis(handles,2);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_voltage_histograms_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_histograms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_analysis(handles,3);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_voltage_deviations_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_deviations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_analysis(handles,4);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_load_analysis_all_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_analysis_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_load_analysis(handles,1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_show_load_table_Callback(hObject, eventdata, handles)
% hObject    handle to menu_show_load_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_load_analysis(handles,0);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_load_time_graph_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_time_graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_load_time_graph(handles,1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_load_time_graph_average_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_time_graph_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_load_time_graph(handles,2);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_voltage_violation_time_graph_grid_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_violation_time_graph_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_violation_time_graph(handles,1);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_voltage_violation_time_graph_scenario_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_violation_time_graph_scenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_violation_time_graph(handles,2);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_voltage_violation_sum_time_graph_grid_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_violation_sum_time_graph_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_violation_time_graph(handles,3);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_voltage_violation_sum_time_graph_scenario_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_violation_sum_time_graph_scenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_violation_time_graph(handles,4);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_current_analysis_all_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_analysis_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_analysis(handles,0);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_show_current_analysis_table_Callback(hObject, eventdata, handles)
% hObject    handle to menu_show_current_analysis_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_analysis(handles,-1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_current_violation_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_violation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_analysis(handles,1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_branches_violated_Callback(hObject, eventdata, handles)
% hObject    handle to menu_branches_violated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_analysis(handles,2);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_current_histograms_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_histograms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_analysis(handles,3);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_branch_loading_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_branch_loading_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
handles = call_current_analysis(handles,4);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_current_violation_time_graph_grid_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_violation_time_graph_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_violation_time_graph(handles,1);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_current_violation_time_graph_scenario_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_violation_time_graph_scenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_violation_time_graph(handles,2);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_current_violation_sum_time_graph_grid_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_violation_sum_time_graph_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_violation_time_graph(handles,3);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_current_violation_sum_time_graph_scenario_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_violation_sum_time_graph_scenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_violation_time_graph(handles,4);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_branch_loading_time_graph_grid_Callback(hObject, eventdata, handles)
% hObject    handle to menu_branch_loading_time_graph_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_violation_time_graph(handles,5);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_branch_loading_time_graph_scenario_Callback(hObject, eventdata, handles)
% hObject    handle to menu_branch_loading_time_graph_scenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_violation_time_graph(handles,6);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_branch_loading_time_graph_scenario_total_Callback(hObject, eventdata, handles)
% hObject    handle to menu_branch_loading_time_graph_scenario_total (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
% Changelog FZ 1.3 Start
handles = call_current_violation_time_graph(handles,8);
% Changelog FZ 1.3 End
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_branch_loading_time_graph_grid_total_Callback(hObject, eventdata, handles)
% hObject    handle to menu_branch_loading_time_graph_grid_total (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
% Changelog FZ 1.3 Start
handles = call_current_violation_time_graph(handles,7);
% Changelog FZ 1.3 End
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_electric_losses_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_electric_losses_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
handles = call_electric_losses_analysis(handles,0);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_electric_losses_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to menu_electric_losses_histogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
handles = call_electric_losses_analysis(handles,2);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_show_electric_losses_analysis_table_Callback(hObject, eventdata, handles)
% hObject    handle to menu_show_electric_losses_analysis_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
handles = call_electric_losses_analysis(handles,-1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_electric_losses_time_graph_grid_Callback(hObject, eventdata, handles)
% hObject    handle to menu_electric_losses_time_graph_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
handles = call_electric_losses_time_graph(handles,1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_electric_losses_time_graph_scenario_Callback(hObject, eventdata, handles)
% hObject    handle to menu_electric_losses_time_graph_scenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
handles = call_electric_losses_time_graph(handles,2);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_electric_losses_sum_time_graph_grid_Callback(hObject, eventdata, handles)
% hObject    handle to menu_electric_losses_sum_time_graph_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
handles = call_electric_losses_time_graph(handles,3);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_electric_losses_sum_time_graph_scenario_Callback(hObject, eventdata, handles)
% hObject    handle to menu_electric_losses_sum_time_graph_scenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
handles = call_electric_losses_time_graph(handles,4);
guidata(hObject, handles);

function show_list_nodes_violated_Callback(hObject, eventdata, handles)
% hObject    handle to show_list_nodes_violated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
handles = call_list_nodes_violated(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function show_list_branches_violated_Callback(hObject, eventdata, handles)
% hObject    handle to show_list_branches_violated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_list_branches_violated(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_voltage_show_mean_grids_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to menu_voltage_show_mean_grids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% process data if neccesary:
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_time_graph(handles,2);
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_voltage_show_mean_scenarios_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to menu_voltage_show_mean_scenarios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% process data if neccesary:
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_time_graph(handles,4);
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_voltage_show_mean_total_grids_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to menu_voltage_show_mean_total_grids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% process data if neccesary:
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_time_graph(handles,1);
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_voltage_show_mean_total_scenarios_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to menu_voltage_show_mean_total_scenarios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% process data if neccesary:
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_voltage_time_graph(handles,3);
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_voltage_show_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voltage_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_voltage_show_grids_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to menu_voltage_show_grids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% process data if neccesary:
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction calls
handles = call_voltage_time_graph(handles,1);
handles = call_voltage_time_graph(handles,6);
handles = call_voltage_time_graph(handles,10);
handles = call_voltage_time_graph(handles,2);
handles = call_voltage_time_graph(handles,7);
handles = call_voltage_time_graph(handles,11);
handles = call_voltage_violation_time_graph(handles,1);
handles = call_voltage_violation_time_graph(handles,3);
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_voltage_show_all_scen_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to menu_voltage_show_all_scen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% process data if neccesary:
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction calls
handles = call_voltage_time_graph(handles,3);
handles = call_voltage_time_graph(handles,8);
handles = call_voltage_time_graph(handles,12);
handles = call_voltage_time_graph(handles,4);
handles = call_voltage_time_graph(handles,9);
handles = call_voltage_time_graph(handles,13);
handles = call_voltage_violation_time_graph(handles,2);
handles = call_voltage_violation_time_graph(handles,4);
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_current_show_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_current_show_grids_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_show_grids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% process data if neccesary:
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_violation_time_graph(handles,1);
handles = call_current_violation_time_graph(handles,3);
handles = call_current_violation_time_graph(handles,5);
handles = call_current_violation_time_graph(handles,7);
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_current_show_all_scen_Callback(hObject, eventdata, handles)
% hObject    handle to menu_current_show_all_scen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% process data if neccesary:
handles = process_nat_results_as(handles); % Process results
% Update handles structure
guidata(hObject, handles);
% Analysis subfunction call
handles = call_current_violation_time_graph(handles,2);
handles = call_current_violation_time_graph(handles,4);
handles = call_current_violation_time_graph(handles,6);
handles = call_current_violation_time_graph(handles,8);
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_home_merge_nat_results_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to menu_home_merge_nat_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
merge_nat_results(hObject, handles)
