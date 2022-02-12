function merge_nat_results(hObject, handles)
%MERGE_NAT_RESULTS merges results from NAT
% hObject    handle to menu_home_merge_nat_results (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Create a text message handler
% TODO TODO TODO
% - this should be done during main window creation... Has to be moved,
%   currently only used for the merger function...
Logname = [datestr(now, 'yyyy-mm-dd_HH-MM-SS'),'_',...
	handles.System.Files.Save.Log.Name,...
	handles.System.Files.Save.Log.Exte];
if ~isfolder(handles.System.Files.Save.Log.Path)
	mkdir(handles.System.Files.Save.Log.Path)
end

mh = MESSAGE_text_handler(...
	handles.static_text_result_details ,...
	'OutputFile'     ,[handles.System.Files.Save.Log.Path,filesep,Logname],...
	'OutputToConsole', false);

buttontext = get(hObject, 'Text');
mh.reset_display_text();
mh.add_line('"',buttontext,'" pushed, start with merging of result data:');
mh.level_up();

% String for all dialogs out of this function:
title_str = 'Merging of NAT result data...';

button = questdlg({...
    'ATTENTION:';...
    '';...
    ['Only NAT results with same setting of the extraction and simulation ',...
    '(Resolution, Sampling, Functions...) can be merged!'];...
    '';...
    'E.g. is this function of use to merge the results of different scenarios.';...
    '';...
    'Proceed?'...
    },title_str,...
    'Yes','No','Yes');

if strcmp(button,'No')
    mh.add_line('Canceled by user.');
    refresh_message_text_operation_finished (handles);
    return;
end

% Ask user for path of the folder containing the resultfolder to be merged:
Main_Path = uigetdir(handles.System.Main_Path,...
    'Selcet folder containing the results to be merged...');
if ~ischar(Main_Path)
    str='No valid path!';
    mh.add_error(str);
    errordlg(str, title_str);
    refresh_message_text_operation_finished (handles);
    return;
end

% Make a destination folder for the merged data:
Merge_Save_Path = [Main_Path,filesep,'Merged'];
if ~isfolder(Merge_Save_Path)
    mkdir(Merge_Save_Path)
end

% save the date of merging:
simdate = now;
simdatestr = datestr(simdate,'yyyy_mm_dd-HH.MM.SS');
log_path = [Merge_Save_Path,filesep,'Res_',simdatestr,' - Log.log'];
mh.mark_sub_log(log_path);

mh.add_line('Searching for data in "',Main_Path,'"');
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
clear simprefix

if valid_data == 0
    str='No valid data present for merging!';
    mh.add_error(str);
    errordlg(str, title_str);
    mh.stop_sub_log(log_path);
    refresh_message_text_operation_finished (handles);
    return;
elseif valid_data < 2
    str1='Not enough results present to be merged! ';
    str2='(Only one set of result data found.)';
    mh.add_error(str1,str2);
    errordlg({str1;str2}, title_str);
    mh.stop_sub_log(log_path);
    refresh_message_text_operation_finished (handles);
    return;
end

mh.add_line('Selection of the results to be merged by user...');
% User dialogs to select the desired files to be merged:
[File_Sel,File_ok] = listdlg(...
    'ListString',valid_results,...
    'Name','Selection of the results to be merged',...
    'PromptString',{'Selection of the results to be merged';...
    ' (Multiple selection possible):'},...
    'CancelString','Cancel',...
    'ListSize', [200, 150]);
if ~File_ok
    str='No data selected for merging!';
    mh.add_error(str);
    errordlg(str, title_str);
    mh.stop_sub_log(log_path);
    refresh_message_text_operation_finished (handles);
    return;
end

% Output of selected result files:
mh.add_listselection(valid_results, File_Sel);

% investegate the settings and decide what to do
mh.add_line('Going through the found results...');
mh.level_up();
% Create a structure with data on wich it can be decided, how data can be merged...
merge.present_grids = {};
merge.present_scenarios = {};
merge.present_datasets = [];
merge.file_allocation = {};
for i=1:numel(File_Sel)
    mh.add_line('"',valid_results{File_Sel(i)},'" (',i,' of ',numel(File_Sel),' results)');
    % Load the settings of the current results-file ('Current_Settings')
    load([Main_Path,filesep,valid_results{File_Sel(i)},' - Settings.mat'],'Current_Settings');
    sim = Current_Settings.Simulation;
    scn = sim.Scenarios;
    dat = Current_Settings.Data_Extract;
    fgr = Current_Settings.Files.Grid;
    
    if i==1
        % save the important settings of the first dataset (to be extended by the other
        % ones)...
        Simulation = sim;
        Data_Extract = dat;
        Files_Grid = fgr;
    end
    
    % Quick check, if data of the following result files is compatible:
    if dat.Timepoints_per_dataset ~= Data_Extract.Timepoints_per_dataset
        str1='Different Number of Timepoints! ';
        str2='Data can''t be merged.';
        mh.add_error(str1,str2);
        errordlg({str1;str2}, title_str);
        mh.stop_sub_log(log_path);
        refresh_message_text_operation_finished (handles);
        return;
    end
    if (sim.use_05_Quantile_Value ~= Simulation.use_05_Quantile_Value) ||...
            (sim.use_95_Quantile_Value ~= Simulation.use_95_Quantile_Value) ||...
            (sim.use_Max_Value ~= Simulation.use_Max_Value) ||...
            (sim.use_Mean_Value ~= Simulation.use_Mean_Value) ||...
            (sim.use_Min_Value ~= Simulation.use_Min_Value) ||...
            (sim.use_Sample_Value ~= Simulation.use_Sample_Value)
        str1='Different settings of data type (Min, Max, Mean, ...)! ';
        str2='Data can''t be merged.';
        mh.add_error(str1,str2);
        errordlg({str1;str2}, title_str);
        mh.stop_sub_log(log_path);
        refresh_message_text_operation_finished (handles);
        return;
    end
    if (sim.Voltage_Violation_Analysis ~= Simulation.Voltage_Violation_Analysis) ||...
            (sim.Branch_Violation_Analysis ~= Simulation.Branch_Violation_Analysis) ||...
            (sim.Power_Loss_Analysis ~= Simulation.Power_Loss_Analysis)
        str1='Different settings of analyzing functions (Voltage Violaton, ...)! ';
        str2='Data can''t be merged.';
        mh.add_error(str1,str2);
        errordlg({str1;str2}, title_str);
        mh.stop_sub_log(log_path);
        refresh_message_text_operation_finished (handles);
        return;
    end
    
    % which grids are present in the current data:
    if ~isempty(sim.Grid_List)
        grds = sim.Grid_List;
    else
        grds = {};
        grds{1} = fgr.Name;
    end
    
    % add the present grids to the possible merge structure
    for j=1:numel(grds)
        if isempty(find(strcmp(merge.present_grids,grds{j}), 1))
            merge.present_grids{end+1} = grds{j};
        end
    end
    
    % get all scenarios and number of present datasets
    for j=1:scn.Number
        idx_scn = find(strcmp(merge.present_scenarios,scn.Names{j}), 1);
        if isempty(idx_scn)
            merge.present_scenarios{end+1} = scn.Names{j};
            merge.present_datasets(end+1,1:numel(merge.present_grids)) = 0;
            merge.file_allocation{end+1,numel(merge.present_grids)} = {};
            idx_scn = numel(merge.present_scenarios);
        else
            if size(merge.present_datasets,2) < numel(merge.present_grids)
                merge.present_datasets(:,end+1) = 0;
                merge.file_allocation(:,end+1) = deal(cell(numel(merge.present_scenarios),1));
            end
        end
        % Update the also the scenario description structure if needed, so
        % here all presen scenarios can be found:
        if isempty(find(strcmp(Simulation.Scenarios.Names,scn.Names{j}),1))
            % New scenario, add it:
            Simulation.Scenarios.Number = Simulation.Scenarios.Number + 1;
            Simulation.Scenarios.(['Sc_',num2str(Simulation.Scenarios.Number)])=...
                scn.(['Sc_',num2str(j)]);
            % add the scenario name to names field:
            Simulation.Scenarios.Names{end+1} = scn.Names{j};
        end
        % add the number of datasets:
        for k=1:numel(grds)
            idx_grd = find(strcmp(merge.present_grids,grds{k}), 1);
            merge.present_datasets(idx_scn, idx_grd) = ...
                merge.present_datasets(idx_scn, idx_grd) + dat.Number_Data_Sets;
            merge.file_allocation{idx_scn, idx_grd}{end+1} = valid_results{File_Sel(i)};
        end
    end
end
mh.level_down();

% check the loaded results, if some adjustments have to be made
datasets = merge.present_datasets;
% quick check, if e.g. over all scenarios and grids the same number of
% datasets are present:
datasets = datasets - datasets(1,1);
if sum(datasets, 'all') > 0
    uneven_distribuiton_datasets = true;
else
    uneven_distribuiton_datasets = false;
end
clear datasets

% Sort the scnearios according to their names:
scen_old = Simulation.Scenarios;
scen_new.Number = scen_old.Number;
[scen_new.Names,IX] = sort(scen_old.Names);
for i=1:scen_new.Number
    scen_new.(['Sc_',num2str(i)]) = scen_old.(['Sc_',num2str(IX(i))]);
end
merge.present_scenarios = merge.present_scenarios(IX);
merge.present_datasets  = merge.present_datasets(IX,:);
merge.file_allocation   = merge.file_allocation(IX,:);
scen_new.Data_avaliable = 1;
Simulation.Scenarios = scen_new;
clear button i j k scen_new fgr grds idx_grd idx_scn IX scn scen_old dat sim

if uneven_distribuiton_datasets
    button = questdlg({['ATTENTION: You are about to merge results with uneven numbers of ',...
        'datasets in the results'];'';['It can happen that not all scenarios or grid ',...
        'variants are present in the final result'];'';'Proceed?'},title_str,...
        'Yes','No','Yes');
    
    if strcmp(button,'No')
        mh.add_line('Canceled by user.');
        refresh_message_text_operation_finished (handles);
        return;
    end
end

if Simulation.Scenarios.Number > 1
    mh.add_line('Selection of the scenarios to be used by user...');
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
        str='No data selected for merging!';
        mh.add_error(str);
        errordlg(str, title_str);
        mh.stop_sub_log(log_path);
        refresh_message_text_operation_finished (handles);
        return;
    end
    % adapt the Scenario-Settings according to the selection:
    scen_old = Simulation.Scenarios;
    merge_old = merge;
    merge.present_scenarios = {};
    merge.present_datasets = zeros(0,numel(merge_old.present_grids));
    merge.file_allocation = {};
    scen_new.Number = numel(Scen_Sel);
    scen_new.Names = cell(1,scen_new.Number);
    for i=1:scen_new.Number
        scen_new.Names{i} = scen_old.Names{Scen_Sel(i)};
        scen_new.(['Sc_',num2str(i)]) = scen_old.(['Sc_',num2str(Scen_Sel(i))]);
        merge.present_scenarios{i} = scen_old.Names{Scen_Sel(i)};
        merge.present_datasets(i,:) = merge_old.present_datasets(Scen_Sel(i),:);
        merge.file_allocation(i,:) = merge_old.file_allocation(Scen_Sel(i),:);
    end
    scen_new.Data_avaliable = 1;
    Simulation.Scenarios = scen_new;
end
% Output of selected scenarios:
mh.add_listselection(scen_old.Names, Scen_Sel);
clear scen_new scen_old merge_old

% After this selection check, which grids can be merged:
if Simulation.Scenarios.Number > 1
    Grid_Sel = logical(1 - (sum(merge.present_datasets > 0) < Simulation.Scenarios.Number));
else
    Grid_Sel = merge.present_datasets > 0;
end

if isempty(merge.present_grids(Grid_Sel))
    str1='No matching grid simulation found in all scenario data! ';
    str2='Data can''t be merged.';
    str3='At least one grid should be simulated in every scenario to be merged!';
    mh.add_error(str1,str2);
    mh.level_up();
    mh.add_error(str3);
    mh.level_down();
    errordlg({str1;str2;str3}, title_str);
    mh.stop_sub_log(log_path);
    refresh_message_text_operation_finished (handles);
    return;
end
merge.present_grids = merge.present_grids(Grid_Sel);
merge.present_datasets = merge.present_datasets(:,Grid_Sel);
merge.file_allocation = merge.file_allocation(:,Grid_Sel);


if numel(merge.present_grids) > 1
    % Ask user, which grid simulation he want's to merge:
    mh.add_line('Selection of the grids to be used by user...');
    [Grid_Sel,Grid_ok] = listdlg(...
        'ListString',merge.present_grids,...
        'Name','Selection of the grids to be merged',...
        'PromptString',{'Selection of the grids, which should be present';...
        ' in the merged results';'(Multiple selection possible):'},...
        'CancelString','Cancel',...
        'ListSize', [250, 150]);
    if ~Grid_ok
        str='No data selected for merging!';
        mh.add_error(str);
        errordlg(str, title_str);
        mh.stop_sub_log(log_path);
        refresh_message_text_operation_finished (handles);
        return;
    end
    
    % Output of selected grids:
    mh.add_listselection(merge.present_grids, Grid_Sel);
    
    merge.present_grids = merge.present_grids(Grid_Sel);
    merge.present_datasets = merge.present_datasets(:,Grid_Sel);
    merge.file_allocation = merge.file_allocation(:,Grid_Sel);
end

% Save also the grid selection in the settings structures:
if numel(merge.present_grids) > 1
    Simulation.Grid_List = merge.present_grids;
    Simulation.Use_Grid_Variants = 1;
else
    Simulation.Grid_List = {};
    Simulation.Use_Grid_Variants = 0;
end
Files_Grid.Name = merge.present_grids{1};

% Now it can be determined, how many datasets are possible within this
% merger:
merge.number_datasets = min(merge.present_datasets,[],'all');
Data_Extract.Number_Data_Sets = merge.number_datasets;
Simulation.Number_Runs = merge.number_datasets;
mh.add_info('A total of ',merge.number_datasets,' datasets can be merged!');

% now merge the Data:
mh.add_line('Start with merging...');
mh.level_up();
for i=1:Simulation.Scenarios.Number
    mh.add_line('Processing "',...
        Simulation.Scenarios.(['Sc_',num2str(i)]).Filename,...
        '" (Scenario ',i,' of ',Simulation.Scenarios.Number,')');
    
    files_to_load = {};
    for j=1:numel(merge.present_grids)
        files = merge.file_allocation{i,j};
        for k=1:numel(files)
            files_to_load{end+1} = files{k}; %#ok<AGROW>
        end
    end
    
    % remove empty or double entries:
    files_to_load(cellfun('isempty',files_to_load)) = []; %#ok<AGROW>
    files_to_load = unique(files_to_load);
    % merge the data:
    mh.level_up();
    Result = [];
    Load_Infeed_Data = [];
    Debug = [];
    for j=1:numel(files_to_load)
        mh.add_line('Processing "',...
            files_to_load{j},...
            '" (File ',j,' of ',numel(files_to_load),')');
        res = load([Main_Path,filesep,files_to_load{j},' - ',Simulation.Scenarios.(['Sc_',num2str(i)]).Filename,'.mat']);
        if j<2
            Load_Infeed_Data = res.Load_Infeed_Data;
        else
            Load_Infeed_Data = merge_results_loadinfeed (Load_Infeed_Data, res,...
                merge.number_datasets);
        end
        
        for k=1:numel(merge.present_grids)
            % read in current gridname (without fileending)
            if ~isempty(strfind(merge.present_grids{k},'.sin'))
                cur_grd = merge.present_grids{k}(1:end-4);
            else
                cur_grd = merge.present_grids{k};
            end
            if isfield(res.Result,cur_grd)
                if j<2
                    Result.(cur_grd) = res.Result.(cur_grd);
                    Grid.(cur_grd) = res.Grid.(cur_grd);
%                     if isfield(res, 'Debug')
%                         Debug.(cur_grd) = res.Debug.(cur_grd);
%                     end
                else
                    [Result, Debug] = merge_results_grid (Result,...
                        Debug, res, cur_grd, merge.number_datasets);
                end
            end
        end
    end
    mh.level_down();
    % Save the new merged Scenario-File
    filename = ['Res_',simdatestr,' - ',Simulation.Scenarios.(['Sc_',num2str(i)]).Filename,'.mat'];
    mh.add_line('Saving data in "',filename,'"');
    save([Merge_Save_Path,filesep,filename],...
        'Result', 'Grid', 'Load_Infeed_Data','Debug','-v7.3');
end
mh.level_down();

% Update the Current_Settings with the settings for the merged data:
Current_Settings.Simulation = Simulation;
Current_Settings.Data_Extract = Data_Extract;
Current_Settings.Files.Grid = Files_Grid;
Current_Settings.Files.Save.Result.Simdate = simdate;

% Save the Current_Settings
filename = ['Res_',simdatestr,' - Settings.mat'];
mh.add_line('Saving settings in "',filename,'"');
save([Merge_Save_Path,filesep,filename],'Current_Settings','-v7.3');

% Inform the user:
str = 'NAT results data successfully merged!';
helpdlg(str, title_str);
mh.add_line(str);
mh.reset_level();
mh.divider('- ');
mh.save_message_text();
mh.reset_sub_logs();
mh.reset_all_display_marker();

% load the OAT data of the file...
handles = update_NVIEW_control_panel(handles, str, 'clear');

% update GUI:
handles = refresh_display_NVIEW_main_gui(handles);

% update handles structure:
guidata(hObject, handles);
end

