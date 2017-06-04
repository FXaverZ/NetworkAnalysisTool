function handles = merge_unpart_simulation_runs(handles)

if handles.System.Settings.First_Run_Merge_Results == 1
    helpdlg_condition = 0;
    while helpdlg_condition == 0;
        user_response = questdlg(sprintf([...
            'SELECT DIFFERENT NAT RESULT INFORMATION FILES FOR MERGER.\n',...
            'The process will merge NAT result information files, which can be later accessed through Import (Unprocessed) NAT Results.\n\n',...
            'Press cancel in the file selection menu to end selection process!\n\n',...
            'WARNING: Result files must have the same simulation options and grid variants must be analysed!']),...
            'Merge different NAT Result information files ?',...
            'Ok','Don''t show this message again',...
            'Ok');
        switch user_response
            case 'Ok'
                handles.System.Settings.First_Run_Merge_Results = 0;
                helpdlg_condition = 1;
            case 'Don''t show this message again'
                handles.System.Settings.First_Run_Merge_Results = 0;
                set_config_settings(handles);
                helpdlg_condition = 1;
        end
    end
    clear user_response helpdlg_condition
end
% --------------------------------------------------------------------------
% Get list of "Setting" Files
[Selected_Settings.Path,Selected_Settings.Files,qdlg_Text,break_condition] = get_files_for_merger(handles);
% Exit function if no files or just one file selected
if break_condition == 1
    return;
end

% Merge selected simulation results - question dialog, Get user input
user_response = questdlg([sprintf(['Merge different NAT Result information files ?',...
    'The following result files were selected:\n',qdlg_Text,'\n',...
    'The new result information file will be saved to the ']),...
    '\NVIEW RESULTS\MERGED', sprintf([' folder and can be accessed through Import (Unprocessed) NAT Results.'])],...
    'Merge different NAT Result information files ?',...
    'Yes, Proceed With Merger and Save',...
    'Cancel Simulation Runs Merger','Yes, Proceed With Merger and Save');

clear break_condition qdlg_Text
% --------------------------------------------------------------------------

switch user_response
    case 'Yes, Proceed With Merger and Save'
        PreviousStaticText = get(handles.static_text_result_details, 'String');
        handles = update_NVIEW_control_panel_busy(handles);
        % Can the results can be paired. IF they can, begin mergin
        % process!
        [break_condition,wdlg_Text] = check_file_simulation_parameters(Selected_Settings.Path,Selected_Settings.Files);
        % Selected files do not have similiar variants/input values used/datasets/timepoints!
        if break_condition >= 1
            uiwait(msgbox(sprintf(['NAT RESULT FILES CAN NOT BE MERGED.\n\n',...
                'Different ', wdlg_Text,' detected!']),'Merge different NAT Result information files ?'));
            set(handles.static_text_result_details, 'String',PreviousStaticText);
            return;
        end
        clear break_condition wdlg_Text PreviousStaticText
        
        % Create new filename for the merged settings file with system time
        % of merger and get the sellected setting file headers
        [Merged_Settings.Header, Selected_Settings.Header] = get_merger_timestamps(Selected_Settings.Files);
        Merged_Settings.Exte = '.mat';
        % -----------------------------------------------------------------
        % Create Current_Settings with all the relevant information
        Current_Settings = [];
        
        % Read first Setting file in list
        load([Selected_Settings.Path{1,1}, Selected_Settings.Files{1,1}]);
        % Add new subarray 'Data_Merger'
        Current_Settings.Data_Merger{1} = [Selected_Settings.Path{1}, Selected_Settings.Files{1}];
        % Get list of scenarios used in the first Settings file
        scenario_counter = Current_Settings.Simulation.Scenarios.Number;
        
        % Define Scenario file headers for individiual Settings file and filepaths
        Selected_Scenarios.Path = repmat(Selected_Settings.Path(1),scenario_counter,1);
        Selected_Scenarios.File = cell(scenario_counter,1);
        Selected_Scenarios.Exte = repmat({'.mat'},scenario_counter,1);
        for i = 1 : scenario_counter
            Selected_Scenarios.File{i,1} = [Selected_Settings.Header{1,1},' - ', Current_Settings.Simulation.Scenarios.(['Sc_', int2str(i)]).Filename];
        end
        
        % Append the other settings file to 'Current_Settings'
        for i = 2 : numel(Selected_Settings.Files)
            AppendedCurrent_Settings = [];
            AppendedCurrent_Settings = load([Selected_Settings.Path{i,1}, Selected_Settings.Files{i,1}]);
            % Add Setting File name to Data_Merger field
            Current_Settings.Data_Merger{end+1,1} = [Selected_Settings.Path{i},Selected_Settings.Files{i}];
            
            % Add Scenario names and Scenario fields, which must be renumbered!
            Current_Settings.Simulation.Scenarios.Names = [Current_Settings.Simulation.Scenarios.Names, AppendedCurrent_Settings.Current_Settings.Simulation.Scenarios.Names];
            for j = 1 : AppendedCurrent_Settings.Current_Settings.Simulation.Scenarios.Number
                scenario_counter = scenario_counter + 1;
                eval(['Current_Settings.Simulation.Scenarios.Sc_', int2str(scenario_counter), '= Current_Settings.Simulation.Scenarios.Sc_', int2str(j),';']);                
                sc_filename = [];
                sc_filename = Current_Settings.Simulation.Scenarios.(['Sc_',int2str(scenario_counter)]).Filename; 
                if ~isnan(str2double(sc_filename(1:2)))
                    if i < 10
                        sc_filename(1:2) = ['0',int2str(scenario_counter)]; 
                    else
                        sc_filename(1:2) = int2str(scenario_counter);
                    end
                end
                Current_Settings.Simulation.Scenarios.(['Sc_',int2str(scenario_counter)]).Filename = sc_filename;
            end
            % Add Scenario file heders for individiual Settings file and filepaths
            for j = 1 : AppendedCurrent_Settings.Current_Settings.Simulation.Scenarios.Number
                Selected_Scenarios.Path{end+1,1} =Selected_Settings.Path{i,1};
                Selected_Scenarios.File{end+1,1} = [Selected_Settings.Header{i,1},' - ', AppendedCurrent_Settings.Current_Settings.Simulation.Scenarios.(['Sc_', int2str(j)]).Filename];
                Selected_Scenarios.Exte{end+1,1} = '.mat';
            end
        end
        Current_Settings.Simulation.Scenarios.Number = numel(Current_Settings.Simulation.Scenarios.Names);
        clear i j scenario_counter AppendedCurrent_Settings sc_filename
        % -----------------------------------------------------------------
        % Get list of files associated with the 'Selected_Scenarios'
        Selected_Files.Path = cell(1);
        Selected_Files.File = cell(1);
        Selected_Files.Exte = cell(1);
        Selected_Files.Scenario = cell(1);
        
        for i = 1 : numel(Selected_Scenarios.File)
            % Clear variables
            simprefix = [];
            filelist = [];
            search_id = [];
            files = [];
            
            % Read the files in the selected filepath
            filelist = dir(Selected_Scenarios.Path{i,1});
            filelist = struct2cell(filelist);
            filelist = filelist(1,3:end);
            search_id = strncmp(filelist,Selected_Scenarios.File{i,1}, size(Selected_Scenarios.File{i,1},2));
            
            files = filelist(search_id);
            for j = 1 : numel(files)
                [~, files{1,j}, ~] = fileparts(files{1,j});
            end
            if numel(files) == 1
                Selected_Files.File{i,1} = files{1};
                Selected_Files.Path{i,1} = Selected_Scenarios.Path{i,1};
                Selected_Files.Exte{i,1} = '.mat';
            else
                Selected_Files.File{i,1} = files;
                Selected_Files.Path{i,1} = repmat(Selected_Scenarios.Path(i,1),1,numel(files));
                Selected_Files.Exte{i,1} = repmat({'.mat'},1,numel(files));
            end
            Selected_Files.Scenario{i,1} = repmat(i,1,numel(files));
        end
        clear i j files filelist search_id
        
        % Merged folder definition
        Merged_Settings.Path = [handles.System.Main_Path,filesep,'Merged NAT Files\'];
        if isdir(Merged_Settings.Path)==0
            mkdir(Merged_Settings.Path);
        end
        
        % Define new Merged filenames of the Selected_Files
        Merged_Files.Path = cell(1);
        Merged_Files.File = cell(1);
        Merged_Files.Exte = Selected_Files.Exte;
        Merged_Files.Scenario = Selected_Files.Scenario;
        
        for i = 1 : numel(Selected_Files.File)
            if ischar(Selected_Files.File{i,1})
                simprefix = [];
                simprefix = regexp(Selected_Files.File{i,1},' - ','split');
                simprefix = simprefix{2};
                % Check if scenario file name starts with number
                if ~isnan(str2double(simprefix(1:2)))
                    if i < 10
                        simprefix(1:2) = ['0',int2str(i)];
                    else
                        simprefix(1:2) = int2str(i);
                    end
                end
                
                Merged_Files.File{i,1} = [Merged_Settings.Header, ' - ', simprefix];
                Merged_Files.Path{i,1} = Merged_Settings.Path;
            else
                for j = 1 : numel(Selected_Files.File{i,1})
                    simprefix = [];
                    simprefix = regexp(Selected_Files.File{i,1}{1,j},' - ','split');
                    simprefix = simprefix{2};
                    
                    % Check if scenario file name starts with number
                    if ~isnan(str2double(simprefix(1:2)))
                        if i < 10
                            simprefix(1:2) = ['0',int2str(i)];
                        else
                            simprefix(1:2) = int2str(i);
                        end
                    end
                    
                    Merged_Files.File{i,1}{1,j} = [Merged_Settings.Header, ' - ', simprefix];
                    Merged_Files.Path{i,1}{1,j} = Merged_Settings.Path;
                end
            end
        end
        clear i j simprefix
        % -----------------------------------------------------------------
        % Copy individiual scenarios to single folder
        
        for i = 1 : numel(Merged_Files.File)
            if ischar(Merged_Files.File{i,1})
                eval(['copyfile(''',[Selected_Files.Path{i,1},Selected_Files.File{i,1},Selected_Files.Exte{i,1}] ''',''' [Merged_Files.Path{i,1},Merged_Files.File{i,1},Merged_Files.Exte{i,1}] ''',''f'');']);
            else
                for j = 1 : numel(Selected_Files.File{i,1})
                    eval(['copyfile(''',[Selected_Files.Path{i,1}{1,j},Selected_Files.File{i,1}{1,j},Selected_Files.Exte{i,1}{1,j}] ''',''' [Merged_Files.Path{i,1}{1,j},Merged_Files.File{i,1}{1,j},Merged_Files.Exte{i,1}{1,j}] ''',''f'');']);
                end
                
            end
        end
        
        % Save Settings file, i.e. save Current_Settings to mat file
        save([Merged_Settings.Path,filesep,[Merged_Settings.Header,' - Settings'],Merged_Settings.Exte],'Current_Settings')
        
        % -----------------------------------------------------------------
        % Display text of the merger
        %path_save_merged_information_file = uigetdir;
        bulletpoints = ['\n'];
        for i = 1 : size(Selected_Settings.Files,1)
            bulletpoints = [bulletpoints,'- ',Selected_Settings.Files{i,1},'\n'];
        end
        set(handles.static_text_result_details, 'String','');
        set(handles.static_text_result_details, 'String',...
            sprintf(['The files listed below were merged and saved as ''',[Merged_Settings.Header,' - Settings',Merged_Settings.Exte],'\n', bulletpoints]));
        
    case 'Cancel Simulation Runs Merger'
        return;
end
