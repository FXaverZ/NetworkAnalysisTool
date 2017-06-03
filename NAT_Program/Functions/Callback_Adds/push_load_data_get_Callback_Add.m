function push_load_data_get_Callback_Add(hObject, handles)
%PUSH_LOAD_DATA_GET_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

set(handles.push_load_data_get, 'Enable', 'off');
set(handles.push_cancel, 'Enable', 'on');
pause(.01);
% Ask User, from which Source the Data should be derived:
answer = questdlg({['Sollen Daten aus der Datenbank geladen, auf ',...
	'Simulationsergebnisse bei der Erstellung zurückgegriffen, ',...
	'oder die orginalen Input Daten einer Simulation geladen werden?'];
	'';...
	'Bitte gewünschte Datenquelle angeben:'},...
	'Spezifizierung Datenquelle',...
	'Lastdatenbank', 'Simulationsergebnisse', 'Orginaldaten', 'Simulationsergebnisse');
% According to this, use differen function for input-data creation:
switch answer
	case 'Lastdatenbank'
		handles = get_input_from_database(handles);
		helpdlg('Daten erfolgreich geladen!', 'Laden der Input-Daten...');
	case 'Simulationsergebnisse'
		% User has to specify, which results he want's to use...
		file = handles.Current_Settings.Files.Load.Result;
		[file.Name,file.Path] = uigetfile([...
			{'*.mat','*.mat Simulation-Info-File'};...
			{'*.*','Alle Dateien'}],...
			'Laden von Simulationsergebnissen...',...
			[file.Path,filesep]);
		% Check, if there is a valid file specified:
		if isequal(file.Name,0) || isequal(file.Path,0)
			% Refresh the GUI:
			handles = refresh_display_NAT_main_gui(handles);
			set(handles.push_cancel, 'Enable', 'off');
			set(handles.push_load_data_get, 'Enable', 'on');
			% Update the handles-structure:
			guidata(hObject, handles);
			if ~isequal(file.Path,0)
				% If there's a valid path, save this for later (programm
				% will look here first...) :
				handles.Current_Settings.Files.Load.Result.Path = file.Path;
				% Update the handles-structure:
				guidata(hObject, handles);
			end
			% leave the function:
			return;
		end
		% Falls nein, Entfernen der Dateierweiterung vom Dateinamen:
		[~, file.Name, file.Exte] = fileparts(file.Name);
		% leztes Zeichen ("/") im Pfad entfernen:
		file.Path = file.Path(1:end-1);
		try
			inp_info = load([file.Path,filesep,file.Name,file.Exte]);
			Result = [];
			Result.Result_Filepath = file.Path;
			Result.Result_Filenames = inp_info.result_filename;
			Result.Simulation_Options = inp_info.simulation_options;
			Result.Scenarios = inp_info.scenarios;
            Result.Grid_Variants = inp_info.variants;
            Result.Datasets = inp_info.datasets;
            Result.Timepoints = inp_info.simulation_options.Timepoints;            
            Result.Result_Files = Load_Result_File(Result);
		catch ME
			errordlg({'Fehler beim Laden der Ergebnisse:';'';ME.message});
			% If there's a valid path, save this for later (programm
			% will look here first...) :
			handles.Current_Settings.Files.Load.Result.Path = file.Path;
			% Refresh the GUI:
			handles = refresh_display_NAT_main_gui(handles);
			set(handles.push_cancel, 'Enable', 'off');
			set(handles.push_load_data_get, 'Enable', 'on');
			% Update the handles-structure:
			guidata(hObject, handles);
			return;
		end
		handles.Result_Settings = Result;
		handles.Current_Settings.Files.Load.Result = file;
		handles = get_input_from_results(handles);
		helpdlg('Daten erfolgreich geladen!', 'Laden der Input-Daten...');
	case 'Orginaldaten'
		% User has to specify, which results he want's to use...
		file = handles.Current_Settings.Files.Load.Result;
		[file.Name,file.Path] = uigetfile([...
			{'*.mat','*.mat Simulation-Info-File'};...
			{'*.*','Alle Dateien'}],...
			'Laden von ursprünglichen Simulationsdaten...',...
			[file.Path,filesep]);
		% Check, if there is a valid file specified:
		if isequal(file.Name,0) || isequal(file.Path,0)
			% Refresh the GUI:
			handles = refresh_display_NAT_main_gui(handles);
			set(handles.push_cancel, 'Enable', 'off');
			set(handles.push_load_data_get, 'Enable', 'on');
			% Update the handles-structure:
			guidata(hObject, handles);
			if ~isequal(file.Path,0)
				% If there's a valid path, save this for later (programm
				% will look here first...) :
				handles.Current_Settings.Files.Load.Result.Path = file.Path;
				% Update the handles-structure:
				guidata(hObject, handles);
			end
			% leave the function:
			return;
		end
		% Falls nein, Entfernen der Dateierweiterung vom Dateinamen:
		[~, file.Name, file.Exte] = fileparts(file.Name);
		% leztes Zeichen ("/") im Pfad entfernen:
		file.Path = file.Path(1:end-1);
		% try to load the information file of the Results:
		try
			inp_info = load([file.Path,filesep,file.Name,file.Exte]);
			Result = [];
			Result.Result_Filepath = file.Path;
			Result.Result_Filenames = inp_info.result_filename;
			Result.Simulation_Options = inp_info.simulation_options;
			Result.Scenarios = inp_info.scenarios;
            Result.Grid_Variants = inp_info.variants;
            Result.Datasets = inp_info.datasets;
            Result.Timepoints = inp_info.simulation_options.Timepoints;            
            Result.Result_Files = Load_Result_File(Result);
		catch ME
			errordlg({'Fehler beim Laden der originalen Input Daten:';'';ME.message});
			% If there's a valid path, save this for later (programm
			% will look here first...) :
			handles.Current_Settings.Files.Load.Result.Path = file.Path;
			% Refresh the GUI:
			handles = refresh_display_NAT_main_gui(handles);
			set(handles.push_cancel, 'Enable', 'off');
			set(handles.push_load_data_get, 'Enable', 'on');
			% Update the handles-structure:
			guidata(hObject, handles);
			return;
		end
		handles.Result_Settings = Result;
		handles.Current_Settings.Files.Load.Result = file;
		handles = load_input_from_results(handles);
		helpdlg('Daten erfolgreich geladen!', 'Laden der Input-Daten...');
	otherwise
		% Do nothing...
end

% Refresh the GUI:
handles = refresh_display_NAT_main_gui(handles);
set(handles.push_cancel, 'Enable', 'off');
set(handles.push_load_data_get, 'Enable', 'on');

% Update the handles-structure:
guidata(hObject, handles);

