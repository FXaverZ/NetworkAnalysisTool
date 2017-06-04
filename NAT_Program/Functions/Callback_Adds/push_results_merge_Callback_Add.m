function push_results_merge_Callback_Add (hObject, handles)
% --- Executes on button press in push_results_merge.
% hObject    handle to push_results_merge (see GCBO)
% ~          reserved - evendata not needed
% handles    structure with handles and user data (see GUIDATA)

% String for all dialogs out of this function:
title_str = 'Merging of result data...';

button = questdlg({['ATTENTION: Only results with same setting of the extraction and simulation ',...
	'(Resolution, Sampling, Functions...) can be merged!'];'';['E.g. is this function of use to merge ',...
	'the results of different Scenarios.'];'';'Proceed?'},title_str,...
	'Yes','No','Yes');

if strcmp(button,'No')
	return;
end

% Ask user for path of the folder containing the resultfolder to be merged:
Main_Path = uigetdir(handles.Current_Settings.Files.Grid.Path,...
	'Selcet folder containing the results to be merged...');
if ~ischar(Main_Path)
	disp('Error during merging results:');
	disp('    No valid path!');
	errordlg('No valid path!', title_str);
	return;
end

% Quick check, if valid information can be found, get all files at the given location:
files = dir(Main_Path);
files = struct2cell(files);
files = files(1,3:end);

valid_data = 0;
valid_results = {};
for i=1:numel(files)
	% get the prefix of the restultfilenames (form:
	%    'Res_yyyy_mm_dd-HH.MM.SS - Settings.mat') and check, if valid data is
	%    present (the Settings are there). If so remember this prefixes...
	simprefix = regexp(files{i},' - ','split');
	simprefix = simprefix{1};
	if ~isempty(find(strcmp(files,[simprefix,' - Settings.mat']),1))
		% Check, if this data is allready known:
		if isempty(find(strcmp(valid_results,simprefix),1))
			% Remember the data:
			valid_data = valid_data + 1;
			valid_results{end+1} = simprefix; %#ok<AGROW>
		end
	end
end

if valid_data == 0
	errordlg('No valid data present for merging!', title_str);
	return;
elseif valid_data < 2
	errordlg({'Not enough results present to be merged!';...
		'(Only one set of result data found.)'}, title_str);
	return;
end

% User dialogs to select the desired files to be merged:
[File_Sel,File_ok] = listdlg(...
	'ListString',valid_results,...
	'Name','Selection of the results to be merged',...
	'PromptString',{'Selection of the results to be merged';...
	' (Multiple selection possible):'},...
	'CancelString','Cancel',...
	'ListSize', [200, 150]);
if ~File_ok
	errordlg('No data selected for merging!', title_str);
	return;
end

% save the date of merging:
simdate = now;
simdatestr = datestr(now,'yyyy_mm_dd-HH.MM.SS');

% investegate the settings and decide what to do
for i=1:numel(File_Sel)
	% Load the settings of the current results-file ('Current_Settings')
	load([Main_Path,filesep,valid_results{File_Sel(i)},' - Settings.mat']);
	sim = Current_Settings.Simulation; %#ok<NODEF>
	dat = Current_Settings.Data_Extract;
	fgr = Current_Settings.Files.Grid;
	% which grids are present in the current data:
	if ~isempty(sim.Grid_List)
		grds = sim.Grid_List;
	else
		grds = {};
		grds{1} = fgr.Name;
	end
	if i==1
		% save the important settings of the first dataset (to be extended by the other
		% ones...
		Simulation = sim;
		Data_Extract = dat;
		Files_Grid = fgr;
		% create a information cell array with grids simulated within the scenarions
		for j=1:Simulation.Scenarios.Number
			for k=1:numel(grds)
				grd_lst{k,j,1} = grds{k}; %#ok<AGROW>
				grd_lst{k,j,2} = valid_results{File_Sel(i)}; %#ok<AGROW>
			end
		end
	else
		% Quick check, if data is compatible:
		if dat.Number_Data_Sets ~= Data_Extract.Number_Data_Sets
			errordlg({'Different Number of Datasets!','Data can''t be merged'},...
				title_str);
			return;
		end
		if 	dat.Timepoints_per_dataset ~= Data_Extract.Timepoints_per_dataset
			errordlg({'Different Number of Timepoints!','Data can''t be merged'},...
				title_str);
			return;
		end
		if (dat.get_05_Quantile_Value ~= Data_Extract.get_05_Quantile_Value) ||...
				(dat.get_95_Quantile_Value ~= Data_Extract.get_95_Quantile_Value) ||...
				(dat.get_Max_Value ~= Data_Extract.get_Max_Value) ||...
				(dat.get_Mean_Value ~= Data_Extract.get_Mean_Value) ||...
				(dat.get_Min_Value ~= Data_Extract.get_Min_Value) ||...
				(dat.get_Sample_Value ~= Data_Extract.get_Sample_Value)
			errordlg({'Different settings of data handling (Min, Max, Mean, ...)!',...
				'Data can''t be merged'}, title_str);
			return;
		end
		if (sim.Voltage_Violation_Analysis ~= Simulation.Voltage_Violation_Analysis) ||...
				(sim.Branch_Violation_Analysis ~= Simulation.Branch_Violation_Analysis) ||...
				(sim.Power_Loss_Analysis ~= Simulation.Power_Loss_Analysis)
			errordlg({'Different settings of analyzing functions (Voltage Violaton, ...)!',...
				'Data can''t be merged'}, title_str);
		end
		% merge the scenarios and check, if same scenarios are present
		for j=1:sim.Scenarios.Number
			% are there equal names?
			idx = find(strcmp(Simulation.Scenarios.Names,sim.Scenarios.Names{j}),1);
			if ~isempty(idx)
				% if equal scenarionames check, if different grids were simulated
				for k=1:numel(grds)
					if ~isempty(find(strcmp(grd_lst(:,idx,1),grds{k}),1))
						% Error, this kind of Results can't be mergerd!
						errordlg({['Same scenarioname with same gridname detected!',...
							' Data can''t be merged!'];'';...
							['Scenario name: ',Simulation.Scenarios.Names{idx}];...
							['Grid name: ',grds{k}];...
							['Resultfile: ',valid_results{File_Sel(i)}]},title_str);
						return;
					else
						% Same Scenario but different grids simulated, add the grid to the
						% List
						if isempty(grd_lst{end,idx,1})
							grd_lst{end,idx,1} = grds{k}; %#ok<AGROW>
						else
							grd_lst{end+1,idx,1} = grds{k}; %#ok<AGROW>
						end
						grd_lst{end,idx,2} = valid_results{File_Sel(i)}; %#ok<AGROW>
					end
				end
			else
				% New scenario, add it:
				Simulation.Scenarios.Number = Simulation.Scenarios.Number + 1;
				Simulation.Scenarios.(['Sc_',num2str(Simulation.Scenarios.Number)])=...
					sim.Scenarios.(['Sc_',num2str(j)]);
				% add the scenario name to names field:
				Simulation.Scenarios.Names{end+1} = sim.Scenarios.Names{j};
				% extend the information cell array with grids simulated within the
				% scenarions:
				for k=1:numel(grds)
					if k==1
						grd_lst{k,end+1,1} = grds{k}; %#ok<AGROW>
						grd_lst{k,end  ,2} = valid_results{File_Sel(i)}; %#ok<AGROW>
					else
						grd_lst{k,end,1}= grds{k}; %#ok<AGROW>
						grd_lst{k,end,2} = valid_results{File_Sel(i)}; %#ok<AGROW>
					end
				end
			end
		end
	end
end

% Sort the scnearios according to their names:

Grid_Allocation = cell(size(grd_lst));
scen_old = Simulation.Scenarios;
scen_new.Number = scen_old.Number;
[scen_new.Names,IX] = sort(scen_old.Names);
for i=1:scen_new.Number
	scen_new.(['Sc_',num2str(i)]) = scen_old.(['Sc_',num2str(IX(i))]);
	Grid_Allocation(:,i,:) = grd_lst(:,IX(i),:);
end
scen_new.Data_avaliable = 1;
Simulation.Scenarios = scen_new;

if Simulation.Scenarios.Number > 1
	% Ask user, which scenarios should be merged:
	% User dialogs to select the desired files to be merged:
	[Scen_Sel,Scen_ok] = listdlg(...
		'ListString',Simulation.Scenarios.Names,...
		'Name','Selection of the scenarios to be merged',...
		'PromptString',{'Selection of the scenarios, which should be present';...
		' in the merged results';'(Multiple selection possible):'},...
		'CancelString','Cancel',...
		'ListSize', [250, 150]);
	if ~Scen_ok
		errordlg('No data selected for merging!', title_str);
		return;
	end
	% adapt the Scenario-Settings according to the selection:
	scen_old = Simulation.Scenarios;
	scen_new.Number = numel(Scen_Sel);
	scen_new.Names = cell(1,scen_new.Number);
	for i=1:scen_new.Number
		scen_new.Names{i} = scen_old.Names{Scen_Sel(i)};
		scen_new.(['Sc_',num2str(i)]) = scen_old.(['Sc_',num2str(Scen_Sel(i))]);
	end
	scen_new.Data_avaliable = 1;
	Simulation.Scenarios = scen_new;
	% adapt the grid list:
	Grid_Allocation = Grid_Allocation(:,Scen_Sel,:);
end

% Check, if in all scenarios are now the same grids present (the ones whiche are not
% present in every scenario file are later removed):
% first, get all unique grid names, for this the empty entries have to be converted into a
% string (for the function unique):
grd_lst = Grid_Allocation;
[grd_lst{cellfun('isempty',grd_lst)}] = deal(' ');
grds = unique(grd_lst(:,:,1));
grds(strcmp(grds,' ')) = [];
% undo the adding of the empty strings:
[grd_lst{strcmp(grd_lst,' ')}]= deal([]);
% check the occurences of these grids in the single scenarios:
for i=1:numel(grds)
	if sum(sum(strcmp(grd_lst(:,:,1),grds{i}))) ~= Simulation.Scenarios.Number
		% the grid is not in every scenario, so remove it:
		[row,col] = ind2sub(size(grd_lst(:,:,1)),find(strcmp(grd_lst(:,:,1),grds{i})));
		[grd_lst{row,col,:}]= deal([]);
	end
end
grd_lst(cellfun('isempty',grd_lst)) = [];
grd_lst = reshape(grd_lst,[],Simulation.Scenarios.Number,2);
% final list with the unique grids:
Grid_List = unique(grd_lst(:,:,1))';
if isempty(Grid_List)
	errordlg({['No matching grid simulation found in all scenario data!',...
		' Data can''t be merged!'];'';...
		'At least one grid should be simulated in every scenario'},title_str);
	return;
end

if numel(grds) > 1
	% Ask user, which grid simulation he want's to merge:
	[Grid_Sel,Grid_ok] = listdlg(...
		'ListString',Grid_List,...
		'Name','Selection of the grids to be merged',...
		'PromptString',{'Selection of the grids, which should be present';...
		' in the merged results';'(Multiple selection possible):'},...
		'CancelString','Cancel',...
		'ListSize', [250, 150]);
	if ~Grid_ok
		errordlg('No data selected for merging!', title_str);
		return;
	end
	Grid_List = Grid_List(Grid_Sel);
end

% Save also the grid selection in the settings structures:
if numel(Grid_List) > 1
	Simulation.Grid_List = Grid_List;
	Simulation.Use_Grid_Variants = 1;
else
	Simulation.Grid_List = {};
	Simulation.Use_Grid_Variants = 0;
end
Files_Grid.Name = Grid_List{1};

% adapt the Grid_Allocation:
grd_lst = Grid_Allocation;
Grid_Allocation = cell(size(grd_lst));
for i=1:numel(Grid_List)
	[row,col] = ind2sub(size(grd_lst(:,:,1)),find(strcmp(grd_lst(:,:,1),Grid_List{i})));
	[Grid_Allocation{row,col,:}]=deal(grd_lst{row,col,:});
end
Grid_Allocation(cellfun('isempty',Grid_Allocation)) = [];
Grid_Allocation = reshape(Grid_Allocation,[],Simulation.Scenarios.Number,2);

% now merge the Data:
for i=1:Simulation.Scenarios.Number
	% get the files, which should be merged:
	files_to_load = squeeze(Grid_Allocation(:,i,2));
	% remove empty or double entries:
	files_to_load(cellfun('isempty',files_to_load)) = [];
	files_to_load = unique(files_to_load);
	% merge the data:
	for j=1:numel(files_to_load)
		res = load([Main_Path,filesep,files_to_load{j},' - ',Simulation.Scenarios.(['Sc_',num2str(i)]).Filename,'.mat']);
		for k=1:numel(Grid_List)
			% read in current gridname (without fileending)
			if ~isempty(strfind(Grid_List{k},'.sin'))
				cur_grd = Grid_List{k}(1:end-4);
			else
				cur_grd = Grid_List{k};
			end
			if isfield(res.Result,cur_grd)
				Result.(cur_grd) = res.Result.(cur_grd); %#ok<STRNU>
				Load_Infeed_Data.(cur_grd) = res.Load_Infeed_Data; %#ok<STRNU>
				Grid.(cur_grd) = res.Grid.(cur_grd); %#ok<STRNU>
				if isfield(res, 'Debug');
					Debug.(cur_grd) = res.Debug.(cur_grd); %#ok<STRNU>
				end
			end
		end
	end
	% Save the new merged Scenario-File
	save([Main_Path,filesep,...
		'Res_',simdatestr,' - ',Simulation.Scenarios.(['Sc_',num2str(i)]).Filename,'.mat'],...
		'Result', 'Grid', 'Load_Infeed_Data','-v7.3');
end

% Update the Current_Settings with the settings for the merged data:
Current_Settings.Simulation = Simulation;
Current_Settings.Data_Extract = Data_Extract;
Current_Settings.Files.Grid = Files_Grid;
Current_Settings.Files.Save.Result.Simdate = simdate;

% Save the Current_Settings
save([Main_Path,filesep,'Res_',simdatestr,' - Settings.mat'],'Current_Settings','-v7.3');

% Inform the user:
helpdlg('Data successfully merged!', title_str);

% update GUI:
handles = refresh_display_NAT_main_gui(handles);

% update handles structure:
guidata(hObject, handles);
end

