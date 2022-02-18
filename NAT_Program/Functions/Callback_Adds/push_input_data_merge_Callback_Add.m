function push_input_data_merge_Callback_Add (hObject, handles)
% --- Executes on button press in push_input_data_merge.
% hObject    handle to push_input_data_merge (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% String for all dialogs out of this function:
title_str = 'Merging of input data...';

button = questdlg({['ATTENTION: Only data with same setting of the extraction ',...
	'(Resolution, Sampling, ...) can be merged!'];'';['E.g. is this function of use to merge ',...
	'the input data of different Scenarios.'];'';'Proceed?'},title_str,...
	'Yes','No','Yes');

if strcmp(button,'No')
	return;
end

% Ask user for path of the folder containing the inputdatafolders to be merged:
Main_Path = uigetdir(handles.Current_Settings.Files.Grid.Path,...
	'Selcet folder containing the inputdatafolders to be merged...');
if ~ischar(Main_Path)
	disp('Error during merging inputdata:');
	disp('    No valid path!');
	errordlg('No valid path!', title_str);
	return;
end

% Quick check, if valid information can be found, get all folders at the given
% location:
folders = dir(Main_Path);
folders = struct2cell(folders);
folders = folders(1,3:end);
valid_data = 0;
valid_folders = {};
% Search in all of this folders, if a file 'Scenario_Settings.mat' is existing
for i=1:numel(folders)
	files = dir([Main_Path,filesep,folders{i}]);
	files = struct2cell(files);
	files = files(1,3:end);
	idx = find(strcmp(files,'Scenario_Settings.mat'),1);
	if ~isempty(idx)
		% If the 'Scenario_Settings.mat' file is existing, count the valid_data
		% folders and remember their name:
		valid_data = valid_data + 1;
		valid_folders{end+1} = folders{i}; %#ok<AGROW>
	end
end

if valid_data == 0
	errordlg('No valid data present for merging!', title_str);
	return;
elseif valid_data < 2
	errordlg({'Not enough input data present to be merged!';...
		'(Only one set of Input Data found.)'}, title_str);
	return;
end

% User dialogs to select the desired files to be merged:
[File_Sel,File_ok] = listdlg(...
	'ListString',valid_folders,...
	'Name','Selection of the inputdata to be merged',...
	'PromptString',{'Selection of the input data of following folder';...
	' (Multiple Selection possible):'},...
	'CancelString','Cancel',...
	'ListSize', [150, 150]);
if ~File_ok
	errordlg('No data selected for merging!', title_str);
	return;
end

% Check, if a Subfolder for input-data within the current grid-folder is avaliable:
if isempty(handles.Current_Settings.Simulation.Grid_List)
	path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_nat'];
else
	path = handles.Current_Settings.Simulation.Grids_Path;
end
if ~isdir([path,filesep,'Load_Infeed_Data_f_Scenarios'])
	mkdir([path,filesep,'Load_Infeed_Data_f_Scenarios']);
end

% Create a Subfolder for the extracted data, containing the extraction-moment:
Date_Extraktion = now();
handles.Current_Settings.Simulation.Scenarios_Path = [...
	path,filesep,'Load_Infeed_Data_f_Scenarios',filesep,...
	datestr(Date_Extraktion,'yyyy_mm_dd-HH.MM.SS'),'_merged',...
	];
mkdir(handles.Current_Settings.Simulation.Scenarios_Path);

% Merge the data:
Scenarios_Settings = [];
for i=1:numel(File_Sel)
	cur_path = [Main_Path,filesep,folders{File_Sel(i)}];
	setti = load([cur_path,filesep,'Scenario_Settings.mat']);
	if i==1
		Scenarios_Settings = setti.Scenarios_Settings;
		Data_Extract = setti.Data_Extract;
		Data_Extract.Date_Extraktion = Date_Extraktion;
		% copy the Data:
		for j=1:Scenarios_Settings.Number
			copyfile([cur_path,filesep,Scenarios_Settings.Names{j},'.mat'],...
				[handles.Current_Settings.Simulation.Scenarios_Path,filesep,Scenarios_Settings.Names{j},'.mat']);
		end
	else
		% Quick check, if data is compatible:
		if setti.Data_Extract.Number_Data_Sets ~= Data_Extract.Number_Data_Sets
			errordlg({'Different Number of Datasets!','Data can''t be merged'},...
				title_str);
			return;
		end
		if 	setti.Data_Extract.Timepoints_per_dataset ~= Data_Extract.Timepoints_per_dataset
			errordlg({'Different Number of Timepoints!','Data can''t be merged'},...
				title_str);
			return;
		end
		if (setti.Data_Extract.get_05_Quantile_Value ~= Data_Extract.get_05_Quantile_Value) ||...
				(setti.Data_Extract.get_95_Quantile_Value ~= Data_Extract.get_95_Quantile_Value) ||...
				(setti.Data_Extract.get_Max_Value ~= Data_Extract.get_Max_Value) ||...
				(setti.Data_Extract.get_Mean_Value ~= Data_Extract.get_Mean_Value) ||...
				(setti.Data_Extract.get_Min_Value ~= Data_Extract.get_Min_Value) ||...
				(setti.Data_Extract.get_Sample_Value ~= Data_Extract.get_Sample_Value)
			errordlg({'Different settings of data handling (Min, Max, Mean, ...)!',...
				'Data can''t be merged'}, title_str);
			return;
		end
		% If Data is compatible, proceed:
		for j=1:setti.Scenarios_Settings.Number
			Scenarios_Settings.(['Sc_',num2str(Scenarios_Settings.Number+j)])=...
				setti.Scenarios_Settings.(['Sc_',num2str(j)]);
			% are there equal names?
			if isempty(find(strcmp(Scenarios_Settings.Names,setti.Scenarios_Settings.Names{j}), 1))
				% if not, add the scenario name to names field:
				Scenarios_Settings.Names{end+1} = setti.Scenarios_Settings.Names{j};
			else
				% if the name allready exixts, generate a new (unique) one:
				count = 1;
				name = setti.Scenarios_Settings.Names{j};
				while ~isempty(find(strcmp(Scenarios_Settings.Names,name), 1))
					name = [setti.Scenarios_Settings.Names{j},'_',num2str(count)];
					count = count + 1;
				end
				Scenarios_Settings.Names{Scenarios_Settings.Number+j} = name;
				Scenarios_Settings.(['Sc_',num2str(Scenarios_Settings.Number+j)]).Filename = name;
			end
			% copy the Data:
			copyfile([cur_path,filesep,setti.Scenarios_Settings.Names{j},'.mat'],...
				[handles.Current_Settings.Simulation.Scenarios_Path,filesep,...
				Scenarios_Settings.Names{Scenarios_Settings.Number+j},'.mat']);
		end
		Scenarios_Settings.Number = Scenarios_Settings.Number + setti.Scenarios_Settings.Number;
	end
end

% Save also the settings:
save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,...
	'Scenario_Settings.mat'],'Scenarios_Settings', 'Data_Extract');

% Reset a possible Scenario selection:
handles.Current_Settings.Simulation.Scenarios_Selection =[];

if handles.Current_Settings.Start_Simulation_after_Extraction
	handles.Current_Settings.Simulation.Scenarios = Scenarios_Settings;
	handles.Current_Settings.Data_Extract = Data_Extract;
	% Refresh the GUI:
	handles = refresh_display_NAT_main_gui(handles);
	% Update the handles-structure:
	guidata(hObject, handles);
	% start calculation:
	push_network_calculation_start_Callback_Add (hObject, handles);
	return;
else
	% Inform the user:
	helpdlg('Data successfully merged!', title_str);
end

% update GUI:
handles = refresh_display_NAT_main_gui(handles);

% update handles structure:
guidata(hObject, handles);
end

