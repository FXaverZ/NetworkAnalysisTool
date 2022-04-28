function push_network_select_scenario_folder_Callback_Add (hObject, handles)
%PUSH_NETWORK_SELECT_SCENARIO_FOLDER_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.0
% Created by:              Franz Zeilinger - 01.01.2015
% Last change by:          Franz Zeilinger - 23.05.2018

mh = handles.text_message_main_handler;
buttontext = get(hObject, 'String');
mh.add_line('"',buttontext,'" pushed, loading of sceanrio data into NAT.');
mh.level_up();

% Keep the Current Settings:
curr_set = handles.Current_Settings;

% Ask user for path of scenario data:
% if handles.Current_Settings.Simulation.Use_Scenarios
	Main_Path = uigetdir(handles.Current_Settings.Simulation.Scenarios_Path,...
		'Selcet folder with scenario input data...');
% else
% 	Main_Path = uigetdir(handles.Current_Settings.Files.Auto_Load_Feed_Data.Path,...
% 		'Selcet folder with load and infeed input data...');
% end
if ischar(Main_Path)
	if handles.Current_Settings.Simulation.Use_Scenarios
		% Quick check, if valid information can be found:
		files = dir(Main_Path);
		files = struct2cell(files);
		files = files(1,3:end);
		idx = find(strcmp(files,'Scenario_Settings.mat'),1);
		
		% If not, tell user and abort function:
		if isempty(idx)
			errorstr='No valid scenario input data found at the given location!';
			errordlg({errorstr,'',...
				['Hint: A file ''Scenario_Settings.mat'' should be present in the selcted ',...
				'folder...']},...
				'Selcet folder with scenario input data...');
			mh.add_error(errorstr);
			return;
		end
		
		% try to load data:
		handles.Current_Settings.Simulation.Scenarios_Path = Main_Path;
		handles.Current_Settings.Simulation.Use_Scenarios = 1;
		handles.Current_Settings.Simulation.Scenarios_Selection = [];
		try
			handles = load_input_last_settings(handles);
			error = 0;
		catch ME
			error = 1;
			mh.add_line('Error during loading of the current loaddata:');
			mh.add_line(ME.message);
		end
	else
		load([Main_Path,filesep,'act_Load_Feed_Data.mat'])
		handles.NAT_Data.Load_Infeed_Data = Load_Infeed_Data;
		clear Load_Infeed_Data;
		load([Main_Path,filesep,'Data_Settings.mat']);
		handles.Current_Settings.Data_Extract = Data_Extract;
		file = handles.Current_Settings.Files.Auto_Load_Feed_Data;
		file.Path = Main_Path;
		handles.Current_Settings.Files.Auto_Load_Feed_Data = file;
		error = 0;
	end
else
	mh.add_line('Canceled by user.');
	error = 1;
end
if error
	% if no valid scenario-data is available, skip, restore current settings and restet
	% scenario-data information:
	handles.Current_Settings = curr_set;
else
	str = 'Data successfully loaded!';
	helpdlg(str);
	mh.add_line(str);
end

% Refresh the GUI:
handles = refresh_display_NAT_main_gui(handles);
refresh_message_text_operation_finished (handles);

% update handles structure:
guidata(hObject, handles);
end

