function push_network_calculation_start_Callback_Add (hObject, handles)
% hObject    Link zur Grafik push_network_calculation_start (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

mh = handles.text_message_main_handler;
ch = handles.cancel_button_main_handler;
wb = handles.waitbar_main_handler;

buttontext = get(handles.push_network_calculation_start, 'String');
mh.reset_display_text();
mh.add_line('"',buttontext,'" pushed, start with calculations:');
mh.level_up();

ch.set_cancel_button(handles.push_network_calculation_start);
wb.reset();

reload_Inputdata = false;
titlestr = 'Automatic Grid Simulation';
% Check if multiple Load-Input-Files can be found:
todo_scenarios = dir(fileparts(handles.Current_Settings.Simulation.Scenarios_Path));
todo_scenarios = struct2cell(todo_scenarios);
todo_scenarios = todo_scenarios(1,3:end);

if numel(todo_scenarios) > 1
	answer = questdlg({...
		'Multiple input files were found in the origin location of the current scenario data...';...
		'';...
		'Do you want to simulate more of them in a row?'},titlestr,'Yes','No','Yes');
	switch answer
		case 'No'
			reload_Inputdata = false;
			todo_scenarios = {'Current'};
		case 'Yes'
			reload_Inputdata = true;
			mh.add_line('Multiple inputfiles will be simulated...');
	end
	
	if reload_Inputdata
		[todo_Selection,todo_ok] = listdlg(...
			'ListString',todo_scenarios,...
			'Name','Selection of Inpudatafolders...',...
			'PromptString',{'Selection of the Inpudatafolders to be simulated';...
			' (Multiple selections possible):'},...
			'CancelString','Cancel',...
			'ListSize', [320, 300]);
		mh.add_listselection(todo_scenarios, todo_Selection);
		todo_scenarios = todo_scenarios(todo_Selection);
		if ~todo_ok
			helpdlg('Normal simulation with the current scneario data will be performed.',...
				titlestr);
			reload_Inputdata = false;
	end
end

for i = 1:numel(todo_scenarios)
	% check, if simulation makes sense:
	if ~(handles.Current_Settings.Simulation.Voltage_Violation_Analysis || ...
			handles.Current_Settings.Simulation.Branch_Violation_Analysis || ...
			handles.Current_Settings.Simulation.Power_Loss_Analysis)
		errorstr = 'No active analysis function! Abort simulation...';
		mh.add_error(errorstr);
		errordlg(errorstr);
	else
		if reload_Inputdata
			if i > 1
				mh.reset_display_text();
				mh.add_line('Automatically procced with next inputdataset.');
				mh.level_up();
				mh.add_line('Processing set ',i,' of ',numel(todo_scenarios),'...');
			end
			mh.add_line('Loading of sceanrio data "',todo_scenarios{i},'" into NAT...');
			mh.level_up();
			% try to load data:
			handles.Current_Settings.Simulation.Scenarios_Path = ...
				[fileparts(handles.Current_Settings.Simulation.Scenarios_Path),filesep,todo_scenarios{i}];
			try
				Scenarios_Selection = handles.Current_Settings.Simulation.Scenarios_Selection;
				handles = load_input_last_settings(handles);
				handles.Current_Settings.Simulation.Scenarios_Selection = Scenarios_Selection;
				mh.level_down();
			catch ME
				mh.add_line('Error during loading of the current loaddata:');
				mh.add_line(ME.message);
				mh.level_down();
				continue;
			end
		end
		if handles.Current_Settings.Simulation.Use_Scenarios
			handles = network_scenario_calculation(handles);
		else
			handles = network_calculation_grid(handles);
		end
	end
	
	% Refresh the GUI:
	if ~ch.was_cancel_pushed()
		wb.stop();
	else
		wb.stop_cancel();
	end
	ch.reset_cancel_button();
	handles = refresh_display_NAT_main_gui(handles);
	refresh_message_text_operation_finished (handles);
	
	% update handles structure:
	guidata(hObject, handles);
end
end

