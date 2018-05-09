% NAT_MAIN    Netzanalyse- und Simulationstool, Hauptprogramm 

% Version:                 7.1
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 09.05.2018

% Last Modified by GUIDE v2.5 25-Apr-2018 15:02:53

function varargout = NAT_main(varargin)
% NAT_MAIN    Netzanalyse- und Simulationstool, Hauptprogramm

% Beginn Initializationscode - NICHT EDITIEREN!
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NAT_main_OpeningFcn, ...
                   'gui_OutputFcn',  @NAT_main_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
% Ende Initializationscode - NICHT EDITIEREN!
end

function NAT_main_OpeningFcn(hObject, ~, handles, varargin)
% Funktion wird vor Sichtbarwerden des Hauptfensters ausgeführt:
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)
% varargin   Übergabevariablen an NAT (see VARARGIN)

% Wo ist "NAT_main.m" zu finden?
[~, Source_File] = fileattrib('NAT_main.m');
% Ordner, in dem "NAT_main.m" sich befindet, enthält Programm:
if ischar(Source_File)
	fprintf([Source_File,' - Current Directory auf Datei setzen, in der sich ',...
		'''NAT_main.m'' befindet!\n']);
	% Fenster schließen:
	delete(handles.NAT_main_gui);
	return;
end
Path = fileparts(Source_File.Name);

% Subfolder in Search-Path aufnehmen (damit alle Funktionen gefunden werden
% können)
addpath(genpath(Path));
handles.Current_Settings.Files.Main_Path = Path;

% Restliche OpeningFcn
NAT_main_OpeningFcn_Impl(hObject, handles, varargin);

function NAT_main_gui_CloseRequestFcn(hObject, ~, handles)
NAT_main_gui_CloseRequestFcn_Impl(hObject, handles);

function varargout = NAT_main_OutputFcn(hObject, eventdata, handles) %#ok<STOUT,INUSD>

function check_analysis_branch_data_save_Callback(hObject, ~, handles) %#ok<DEFNU>
check_analysis_Callback_Add (hObject, handles, 'branch_data_save');

function check_analysis_branch_violation_Callback(hObject, ~, handles) %#ok<DEFNU>
check_analysis_Callback_Add (hObject, handles, 'branch_violation');

function check_analysis_power_loss_Callback(hObject, ~, handles) %#ok<DEFNU>
check_analysis_Callback_Add (hObject, handles, 'power_loss');

function check_analysis_power_loss_data_save_Callback(hObject, ~, handles) %#ok<DEFNU>
check_analysis_Callback_Add (hObject, handles, 'power_loss_data_save');

function check_analysis_voltage_data_save_Callback(hObject, ~, handles) %#ok<DEFNU>
check_analysis_Callback_Add (hObject, handles, 'voltage_data_save');

function check_analysis_voltage_violation_Callback(hObject, ~, handles) %#ok<DEFNU>
check_analysis_Callback_Add (hObject, handles, 'voltage_violation');

function check_controller_emob_charge_active_all_Callback(hObject, eventdata, handles) %#ok<DEFNU>
check_controller_emob_charge_active_all_Callback_Add(hObject, eventdata, handles);

function check_controller_emob_charge_active_Callback(hObject, ~, handles) %#ok<DEFNU>
check_controller_emob_charge_active_Callback_Add(hObject, handles);

function check_extract_05_quantile_value_Callback(hObject, ~, handles) %#ok<DEFNU>
check_extract_value_Callback_Add (hObject, handles, '05_quantile_value')

function check_extract_95_quantile_value_Callback(hObject, ~, handles) %#ok<DEFNU>
check_extract_value_Callback_Add (hObject, handles, '95_quantile_value')

function check_extract_max_value_Callback(hObject, ~, handles) %#ok<DEFNU>
check_extract_value_Callback_Add (hObject, handles, 'max_value')

function check_extract_mean_value_Callback(hObject, ~, handles) %#ok<DEFNU>
check_extract_value_Callback_Add (hObject, handles, 'mean_value')

function check_extract_min_value_Callback(hObject, ~, handles) %#ok<DEFNU>
check_extract_value_Callback_Add (hObject, handles, 'min_value')

function check_extract_sample_value_Callback(hObject, ~, handles) %#ok<DEFNU>
check_extract_value_Callback_Add (hObject, handles, 'sample_value')

function check_get_time_series_Callback(hObject, ~, handles) %#ok<DEFNU>
check_use_scenarios_Callback_Add (hObject, handles);

function check_pqnode_active_Callback(hObject, ~, handles) %#ok<DEFNU>
check_pqnode_active_Callback_Add (hObject, handles);

function check_pqnode_emob_present_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to check_pqnode_emob_present (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the handles-structure:
guidata(hObject, handles);

function check_pqnode_hh_selection_all_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to check_pqnode_hh_selection_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Current_Settings.Data_Extract.Households.Selection_active_all = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function check_pqnode_pv_present_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to check_pqnode_pv_present (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the handles-structure:
guidata(hObject, handles);

function check_simulation_start_after_data_extraction_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to check_simulation_start_after_data_extraction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_simulation_start_after_data_extraction
handles.Current_Settings.Start_Simulation_after_Extraction = get(hObject,'Value');

% Refresh the GUI:
handles = refresh_display_NAT_main_gui(handles);

% Update the handles-structure:
guidata(hObject, handles);

function check_use_scenarios_Callback(hObject, ~, handles) %#ok<DEFNU>
check_use_scenarios_Callback_Add (hObject, handles)

function check_use_variants_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik check_use_scenarios (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Simulation.Use_Grid_Variants = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function edit_network_number_variants_Callback(hObject, eventdata, handles)
% hObject    handle to edit_network_number_variants (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_pqnode_hh_number_Callback(hObject, eventdata, handles) %#ok<DEFNU>
edit_pqnode_hh_number_Callback_Add(hObject, eventdata, handles);

function edit_simulation_number_runs_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik edit_simulation_number_runs (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

Number_Runs = ...
	str2double(get(hObject,'String'));
if isnan(Number_Runs)
	errordlg('Invalid data format! Please give a natural number of simulations runs ...',...
		'Editing simulations runs ...');
else
	Number_Runs = round(Number_Runs);
	% adopt Number of Simruns (also in data extraction settings):
	handles.Current_Settings.Simulation.Number_Runs = Number_Runs;
	handles.Current_Settings.Data_Extract.Number_Data_Sets = Number_Runs;
end
% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function menue_data_load_Callback(hObject, ~, handles) %#ok<DEFNU>
menue_data_load_Callback_Add (hObject, handles);

function menue_data_save_Callback(hObject, ~, handles) %#ok<DEFNU>
 menue_data_save_Callback_Add (hObject, handles);

function menue_file_close_Callback(hObject, eventdata, handles) %#ok<DEFNU>
NAT_main_gui_CloseRequestFcn(hObject, eventdata, handles);

function popup_gen_worstcase_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik popup_hh_worstcase (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Worstcase_Generation = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren
guidata(hObject, handles);

function popup_hh_worstcase_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik popup_hh_worstcase (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Worstcase_Housholds = get(hObject,'Value');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren
guidata(hObject, handles);

function popup_pqnode_hh_typ_Callback(hObject, ~, handles) %#ok<DEFNU>
popup_pqnode_hh_typ_Callback_Add (hObject, handles);

function popup_pqnode_pv_typ_Callback(hObject, ~, handles) %#ok<DEFNU>
popup_pqnode_pv_typ_Callback_Add (hObject, handles);

function popup_time_resolution_Callback(hObject, ~, handles) %#ok<DEFNU>
popup_time_resolution_Callback_Add (hObject, handles);

function push_cancel_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_cancel (siehe GCBO)
% eventdata	 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

if handles.cancel_button_main_handler.was_cancel_pushed()
	handles.cancel_button_main_handler.reset_cancel_button();
end

handles.cancel_button_main_handler.cancel_button_pushed();
% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function push_close_Callback(hObject, eventdata, handles) %#ok<DEFNU>
NAT_main_gui_CloseRequestFcn(hObject, eventdata, handles);

function push_controller_emob_charge_settings_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to push_controller_emob_charge_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

open get_controller_settings.m

function push_input_data_loadsimulation_load_direct_Callback(hObject, eventdata, handles)
% hObject    handle to push_input_data_loadsimulation_load_direct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
push_input_data_loadsimulation_load_direct_Callback_Add(hObject, eventdata, handles);

function push_input_data_merge_Callback(hObject, ~, handles) %#ok<DEFNU>
push_input_data_merge_Callback_Add (hObject, handles)

function push_load_data_get_Callback(hObject, ~, handles) %#ok<DEFNU>
push_load_data_get_Callback_Add(hObject, handles);

function push_network_analysis_perform_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik push_network_analysis_perform (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

% d = handles.NAT_Data;
if  handles.Current_Settings.Simulation.Voltage_Violation_Analysis
	handles = post_voltage_violation_report(handles);
	handles = grid_voltages_comparison(handles,1:3,'all');
end
if handles.Current_Settings.Simulation.Branch_Violation_Analysis
	handles = post_branch_violation_report(handles);
	handles = grid_branches_comparison(handles,1:3,'all');
end
if handles.Current_Settings.Simulation.Power_Loss_Analysis
    handles = post_active_power_loss_report(handles);
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

function push_network_calculation_start_Callback(hObject, ~, handles) %#ok<DEFNU>
push_network_calculation_start_Callback_Add (hObject, handles);

function push_network_load_allocation_reset_Callback(hObject, ~, handles) %#ok<DEFNU>
push_network_load_allocation_reset_Callback_Add(hObject, handles)

function push_network_load_Callback(hObject, ~, handles) %#ok<DEFNU>
push_network_load_Callback_Add (hObject, handles);

function push_network_load_random_allocation_Callback(hObject, ~, handles) %#ok<DEFNU>
 push_network_load_random_allocation_Callback_Add (hObject, handles)

function push_network_open_Callback(hObject, ~, handles) %#ok<INUSL,DEFNU>
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

if isfield(handles, 'sin');
	try
	handles.sin.open_application_and_file;
	catch ME
		errordlg(...
			{'Fehler beim Öffnen des Netzes:';' ';ME.message},...
			'Öffnen des akutellen Netzes...');
	end
else
	helpdlg('Kein Netz geladen!','Öffnen des akutellen Netzes...');
end

function push_network_scenario_show_settings_Callback(hObject, ~, handles) %#ok<DEFNU>
push_network_scenario_show_settings_Callback_Add(hObject, handles);

function push_network_select_scenario_Callback(hObject, ~, handles) %#ok<DEFNU>
push_network_select_scenario_Callback_Add(hObject, handles);

function push_network_select_scenario_folder_Callback(hObject, ~, handles) %#ok<DEFNU>
push_network_select_scenario_folder_Callback_Add (hObject, handles);

function push_network_select_variant_folder_Callback(hObject, ~, handles) %#ok<DEFNU>
push_network_select_variant_folder_Callback_Add (hObject, handles);

function push_network_simulation_settings_Callback(hObject, eventdata, handles)
% hObject    handle to push_network_simulation_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

function push_network_table_import_export_Callback(hObject, eventdata, handles) %#ok<DEFNU>
push_network_table_import_export_Callback_Add(hObject, eventdata, handles)

function push_pqnode_hh_selection_Callback(hObject, eventdata, handles) %#ok<DEFNU>
push_pqnode_hh_selection_Callback_Add(hObject, eventdata, handles);

function push_pqnode_pv_parameters_Callback(hObject, eventdata, handles) %#ok<DEFNU>
push_pqnode_pv_parameters_Callback_Add (hObject, eventdata, handles);

function push_pqnode_wi_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to push_pqnode_wi_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function push_results_merge_Callback(hObject, ~, handles) %#ok<DEFNU>
push_results_merge_Callback_Add (hObject, handles)

function push_set_path_database_Callback(hObject, ~, handles)  %#ok<DEFNU>
push_set_path_database_Callback_Add (hObject, handles);

function push_time_series_settings_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_1 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles = Configuration_Time_Series_Parameters('NAT_main', ...
	 handles.NAT_main_gui);
 
% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_network_type_lv_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to radio_network_type_lv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value')
	handles.Current_Settings.Grid.Type = 'LV';
end

% update main GUI:
handles = refresh_display_NAT_main_gui(handles);
% update handles structure:
guidata(hObject, handles);

function radio_network_type_mv_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to radio_network_type_mv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value')
	handles.Current_Settings.Grid.Type = 'MV';
end

% update main GUI:
handles = refresh_display_NAT_main_gui(handles);
% update handles structure:
guidata(hObject, handles);

function radio_season_1_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_1 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Season = logical([1 0 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_season_2_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_2 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Season = logical([0 1 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_season_3_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_season_3 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Season = logical([0 0 1]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_simulate_05q_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to radio_simulate_05q_value (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

handles.Current_Settings.Simulation.use_Sample_Value = 0;
handles.Current_Settings.Simulation.use_Mean_Value = 0;
handles.Current_Settings.Simulation.use_Max_Value = 0;
handles.Current_Settings.Simulation.use_Min_Value = 0;
handles.Current_Settings.Simulation.use_05_Quantile_Value = 1;
handles.Current_Settings.Simulation.use_95_Quantile_Value = 0;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_simulate_95q_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to radio_simulate_95q_value (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

handles.Current_Settings.Simulation.use_Sample_Value = 0;
handles.Current_Settings.Simulation.use_Mean_Value = 0;
handles.Current_Settings.Simulation.use_Max_Value = 0;
handles.Current_Settings.Simulation.use_Min_Value = 0;
handles.Current_Settings.Simulation.use_05_Quantile_Value = 0;
handles.Current_Settings.Simulation.use_95_Quantile_Value = 1;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_simulate_max_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to radio_simulate_max_value (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

handles.Current_Settings.Simulation.use_Sample_Value = 0;
handles.Current_Settings.Simulation.use_Mean_Value = 0;
handles.Current_Settings.Simulation.use_Max_Value = 1;
handles.Current_Settings.Simulation.use_Min_Value = 0;
handles.Current_Settings.Simulation.use_05_Quantile_Value = 0;
handles.Current_Settings.Simulation.use_95_Quantile_Value = 0;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_simulate_mean_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to radio_simulate_mean_value (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

handles.Current_Settings.Simulation.use_Sample_Value = 0;
handles.Current_Settings.Simulation.use_Mean_Value = 1;
handles.Current_Settings.Simulation.use_Max_Value = 0;
handles.Current_Settings.Simulation.use_Min_Value = 0;
handles.Current_Settings.Simulation.use_05_Quantile_Value = 0;
handles.Current_Settings.Simulation.use_95_Quantile_Value = 0;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_simulate_min_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to radio_simulate_min_value (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

handles.Current_Settings.Simulation.use_Sample_Value = 0;
handles.Current_Settings.Simulation.use_Mean_Value = 0;
handles.Current_Settings.Simulation.use_Max_Value = 0;
handles.Current_Settings.Simulation.use_Min_Value = 1;
handles.Current_Settings.Simulation.use_05_Quantile_Value = 0;
handles.Current_Settings.Simulation.use_95_Quantile_Value = 0;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_simulate_sample_value_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to radio_simulate_sample_value (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

handles.Current_Settings.Simulation.use_Sample_Value = 1;
handles.Current_Settings.Simulation.use_Mean_Value = 0;
handles.Current_Settings.Simulation.use_Max_Value = 0;
handles.Current_Settings.Simulation.use_Min_Value = 0;
handles.Current_Settings.Simulation.use_05_Quantile_Value = 0;
handles.Current_Settings.Simulation.use_95_Quantile_Value = 0;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_weekday_1_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_weekday_1 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Weekday = logical([1 0 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_weekday_2_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_weekday_2 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Weekday = logical([0 1 0]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function radio_weekday_3_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    Link zur Grafik radio_weekday_3 (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Data_Extract.Weekday = logical([0 0 1]');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);

function table_data_network_CellSelectionCallback(hObject, eventdata, handles) %#ok<DEFNU>
table_data_network_CellSelectionCallback_Add (hObject, eventdata, handles);

function table_data_network_CellEditCallback(hObject, eventdata, handles) %#ok<DEFNU>
table_data_network_CellEditCallback_Add (hObject, eventdata, handles);

function menue_network_load_Callback(hObject, eventdata, handles)
% hObject    handle to menue_network_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menue_configuration_save_as_Callback(hObject, eventdata, handles)
% hObject    handle to menue_configuration_save_as (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menue_configuration_save_Callback(hObject, eventdata, handles)
% hObject    handle to menue_configuration_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menue_configuration_load_Callback(hObject, eventdata, handles)
% hObject    handle to menue_configuration_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menue_file_mainpath_set_Callback(hObject, eventdata, handles)
% hObject    handle to menue_file_mainpath_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_pqnode_pv_installed_power_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pqnode_pv_installed_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function popup_pqnode_wi_typ_Callback(hObject, eventdata, handles)
% hObject    handle to popup_pqnode_wi_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_pqnode_wi_installed_power_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pqnode_wi_installed_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_simulation_number_scenarios_Callback(hObject, eventdata, handles)
% hObject    handle to edit_simulation_number_scenarios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- create-Funktionen (werden unmittelbar vor Sichtbarmachen des GUIs ausgeführt):
function popup_time_resolution_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_time_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_hh_worstcase_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_hh_worstcase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_pqnode_hh_typ_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_pqnode_hh_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_simulation_number_scenarios_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_simulation_number_scenarios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_pqnode_pv_typ_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_pqnode_pv_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_pqnode_pv_installed_power_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_pqnode_pv_installed_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_pqnode_wi_installed_power_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_pqnode_wi_installed_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_gen_worstcase_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_gen_worstcase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_simulation_number_runs_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_simulation_number_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popup_pqnode_wi_typ_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to popup_pqnode_wi_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_network_number_variants_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_network_number_variants (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_pqnode_hh_number_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edit_pqnode_hh_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
