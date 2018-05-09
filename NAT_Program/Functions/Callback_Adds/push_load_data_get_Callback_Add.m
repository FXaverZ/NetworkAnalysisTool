function push_load_data_get_Callback_Add(hObject, handles)
%PUSH_LOAD_DATA_GET_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

dlg_heading = 'Loading of input data...';
success_str = 'Data succesfully loaded!';

mh = handles.text_message_main_handler;
ch = handles.cancel_button_main_handler;

buttontext = get(handles.push_load_data_get, 'String');
mh.add_line('"',buttontext,'" pushed, loading loaddata into NAT:');
mh.level_up();

ch.set_cancel_button(handles.push_load_data_get);

% Ask User, from which Source the Data should be derived:
if handles.Current_Settings.Data_Extract.MV_input_generation_in_progress
	answer = questdlg({...
		'Resume the started input data generation?',...
		;'';},...
		'Specifying data source',...
		'Yes', 'Abort', 'Yes');
	switch answer
		case 'Yes'
			answer = 'Simulationresults_resume';
		otherwise
			handles.Current_Settings.Data_Extract.MV_input_generation_in_progress = 0;
			mh.add_line('Canceled by user.');
			% Refresh the GUI:
			ch.reset_cancel_button();
			handles = refresh_display_NAT_main_gui(handles);
			refresh_message_text_operation_finished (handles);
			% Update the handles-structure:
			guidata(hObject, handles);
			return;
	end		
elseif handles.Current_Settings.Load_Database.valid && strcmp(handles.Current_Settings.Grid.Type, 'MV')
	answer = questdlg({[...
		'Should the data be loaded from the load- and infeed-database, ',...
		'should it be newly created out of simulation results (MV input out of LV ',...
		'input) or should the orginal input data from a previous simulation be loaded?'...
		];...
		'';...
		'Please specify desired data source:'},...
		'Specifying data source',...
		'Load- and Infeed-Database', 'Simulationresults', 'Orginal Data', 'Simulationresults');
elseif strcmp(handles.Current_Settings.Grid.Type, 'MV')
	answer = questdlg({[...
		'Should the data be newly created out of simulation results (MV input out of LV ',...
		'results) or should the orginal input data from a previous simulation be loaded?'...
		];...
		'';...
		'Please specify desired data source:'},...
		'Specifying data source',...
		'Simulationresults', 'Orginal Data', 'Simulationresults');
elseif handles.Current_Settings.Load_Database.valid
	answer = questdlg({[...
		'Should the data be loaded from the load- and infeed-database, ',...
		'or should the orginal input data from a previous simulation be loaded?'...
		];...
		'';...
		'Please specify desired data source:'},...
		'Specifying data source',...
		'Load- and Infeed-Database', 'Orginal Data', 'Load- and Infeed-Database');
else
	answer = 'Orginal Data';
end
% According to this, use different function for input-data creation:
switch answer
	case 'Load- and Infeed-Database'
		mh.add_line('Source: Load- and Infeed-Database "',...
			handles.Current_Settings.Load_Database.Name,'"');
		handles = get_input_from_database(handles);
		if ~isempty(handles.NAT_Data.Load_Infeed_Data)
			if handles.Current_Settings.Start_Simulation_after_Extraction
				% Refresh the GUI:
				ch.reset_cancel_button();
				handles = refresh_display_NAT_main_gui(handles);
				refresh_message_text_operation_finished (handles);
				% Update the handles-structure:
				guidata(hObject, handles);
				% start calculation:
				push_network_calculation_start_Callback_Add (hObject, handles);
				return;
			else
				mh.add_line(success_str);
				helpdlg(success_str, dlg_heading);
			end
		else
			% Refresh the GUI:
			ch.reset_cancel_button();
			handles = refresh_display_NAT_main_gui(handles);
			refresh_message_text_operation_finished (handles);
			return;
		end
	case 'Simulationresults'
		mh.add_line('Source: Simulationresults');
		% User has to specify, which results he want's to use...
		file = handles.Current_Settings.Files.Load.Result;
		[file.Name,file.Path] = uigetfile([...
			{'*.mat','*.mat Simulation-Info-File'};...
			{'*.*','All Files'}],...
			'Load simulation results...',...
			[file.Path,filesep]);
		% Check, if there is a invalid file specified:
		if isequal(file.Name,0) || isequal(file.Path,0)
			% Refresh the GUI:
			ch.reset_cancel_button();
			handles = refresh_display_NAT_main_gui(handles);
			refresh_message_text_operation_finished (handles);
			% update the handles-structure:
			guidata(hObject, handles);
			% leave the function:
			return;
		elseif ~isequal(file.Path,0)
			% If there's a valid path, save this for later (programm
			% will look here first...) :
			handles.Current_Settings.Files.Load.Result.Path = file.Path;
			% Update the handles-structure:
			guidata(hObject, handles);
		end
		% a valid file was selected, get the needed information:
		[~, file.Name, file.Exte] = fileparts(file.Name);
		% remove last character in path ("/"):
		file.Path = file.Path(1:end-1);
		try
			% Load the settings of the simulation ('Current_Settings'):
			load([file.Path,filesep,file.Name,file.Exte]);
			% Save the needed settings for Results-Processing:
			handles.Result_Settings = [];
			handles.Result_Settings.Data_Extract = Current_Settings.Data_Extract;
			handles.Result_Settings.Simulation = Current_Settings.Simulation;
			handles.Result_Settings.Grid = Current_Settings.Grid;
			
			% get the result filenames, first search for all files in the current location along with
			% the scenario description
			files = dir(file.Path);
			files = struct2cell(files);
			files = files(1,3:end);
			% reset the files-list:
			handles.Result_Settings.Result_Files = {};
			% get the prefix of the restultfilenames of the current settings file (form:
			% 'Res_yyyy_mm_dd-HH.MM.SS - Scearnrioname.mat'):
			simprefix = regexp(file.Name,' - ','split');
			simprefix = simprefix{1};
			% get the names of the main scenario files:
			if Current_Settings.Simulation.Use_Scenarios
				handles.Current_Settings.Simulation.Use_Scenarios = 1;
				for i=1:Current_Settings.Simulation.Scenarios.Number
					filename = [simprefix,' - ',...
						Current_Settings.Simulation.Scenarios.(['Sc_',num2str(i)]).Filename,...
						'.mat'];
					if ~isempty(find(strcmp(files, filename), 1))
						handles.Result_Settings.Result_Files{end+1} = filename;
					end
				end
			else
				errorstr = 'Single scenario simulation currently not supported!';
				mh.add_error(errorstr);
				errordlg(errorstr);
				% Refresh the GUI:
				ch.reset_cancel_button();
				handles = refresh_display_NAT_main_gui(handles);
				refresh_message_text_operation_finished (handles);
				return;
			end
			clear('Current_Settings');
		catch ME
			mh.add_error(ME.message);
			errordlg({'Error while loading the results:';'';ME.message});
			% If there's a valid path, save this for later (programm
			% will look here first...) :
			handles.Current_Settings.Files.Load.Result.Path = file.Path;
			% Refresh the GUI:
			ch.reset_cancel_button();
			handles = refresh_display_NAT_main_gui(handles);
			refresh_message_text_operation_finished (handles);
			% Update the handles-structure:
			guidata(hObject, handles);
			return;
		end
		handles.Current_Settings.Files.Load.Result = file;
		[handles, error] = get_input_from_results(handles);
		if ~error
			if handles.Current_Settings.Data_Extract.MV_input_generation_in_progress
				warnstr = ['Gridlist successfully loaded, please specify grid allocation ',...
					'and resume input data generation via button "Load Sceanriodata"!'];
				mh.add_warning(warnstr)
				warndlg(warnstr,dlg_heading);
			else
				if handles.Current_Settings.Start_Simulation_after_Extraction
					% Refresh the GUI:
					ch.reset_cancel_button();
					handles = refresh_display_NAT_main_gui(handles);
					refresh_message_text_operation_finished (handles);
					% Update the handles-structure:
					guidata(hObject, handles);
					% start calculation:
					push_network_calculation_start_Callback_Add (hObject, handles);
					return;
				else
					mh.add_line(success_str);
					helpdlg(success_str, dlg_heading);
				end
			end
		end
	case 'Simulationresults_resume'
		mh.add_line('Source: Simulationresults (resumed)');
		[handles, error] = get_input_from_results(handles);
		if ~error
			if handles.Current_Settings.Data_Extract.MV_input_generation_in_progress
				warnstr = ['Gridlist successfully loaded, please specify grid allocation ',...
					'and resume input data generation via button "Resume loading..."!'];
				mh.add_warning(warnstr)
				warndlg(warnstr,dlg_heading);
			else
				if handles.Current_Settings.Start_Simulation_after_Extraction
					% Refresh the GUI:
					handles = refresh_display_NAT_main_gui(handles);
					% Update the handles-structure:
					guidata(hObject, handles);
					% start calculation:
					push_network_calculation_start_Callback_Add (hObject, handles);
					return;
				else
					mh.add_line(success_str);
					helpdlg(success_str, dlg_heading);
				end
			end
		end
	case 'Orginal Data'
		mh.add_line('Source: Orginal Data');
		errorstr = 'Currently not supported!';
		errordlg(errorstr);
		mh.add_error(errorstr);
		%TODO: Extraction of Input-Data out of Simulation Resluts...
	otherwise
		% Do nothing...
		mh.add_line('Canceled by user.');
end

% set(handles.push_cancel, 'Enable', 'off');
% set(handles.push_load_data_get, 'Enable', 'on');

% Refresh the GUI:
ch.reset_cancel_button();
handles = refresh_display_NAT_main_gui(handles);
refresh_message_text_operation_finished (handles);

% Update the handles-structure:
guidata(hObject, handles);

