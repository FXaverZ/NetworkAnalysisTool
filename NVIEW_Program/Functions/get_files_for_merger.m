function [SelectedPaths,SelectedFiles,SelectedText,break_condition] = get_files_for_merger(handles)

% No NVIEW Results exist. Select simulation runs
file = handles.NVIEW_Control.Result_Information_File;
file.Path = handles.System.Main_Path; % Default path
file.Name = [];

break_condition = 0;
selection_condition = 0;
SelectedFiles = [];
SelectedPaths = [];
SelectedText = [];

while selection_condition == 0
    % Open UI window and select result information file
    [file.Name,file.Path] = uigetfile([...
        {'*.mat','*.mat result information MAT-file'};...
        {'*.*','All files'}],...
        'Select different NAT result information files for merger...',...
        [file.Path,filesep],'MultiSelect','on');
    
    if ~iscell(file.Name) 
        if file.Name == 0
            selection_condition = 1;
            % If no file was selected, cancel selection process and
            % start merger!
        else
            SelectedFiles = [SelectedFiles; {file.Name}];
            SelectedPaths = [SelectedPaths; {file.Path}];  
        end
    else
        if numel(file.Name) > 1 && ~iscell(file.Path)
            % All files are in the same folder
            RepPath = repmat({file.Path},size(file.Name));
        end
        for i = 1 : numel(file.Name)
           SelectedFiles = [SelectedFiles; {file.Name{i}}]; 
           SelectedPaths = [SelectedPaths; {RepPath{i}}];
        end
    end 
end

% Check the number of selected files before proceeding
if isempty(SelectedFiles) && selection_condition == 1
    uiwait(msgbox(sprintf(['No result files selected for merger!\n',...
                           'Canceling merging process.']),...
                           'Merge different NAT Result information files ?'));
   break_condition = 1;
    return;
    % Exit function
end

if numel(SelectedFiles) < 2
    uiwait(msgbox(sprintf(['Only one result file selected. Select more than one result file for merger!\n',...
                           'Canceling merging process.']),...
                           'Merge different NAT Result information files ?'));
   
    break_condition = 1;
    return;
    % Exit function
end

% Display msg window before merger!
SelectedText = ['\n'];
for i = 1 : numel(SelectedFiles)
    SelectedText = [SelectedText,[SelectedFiles{i},'\n']];
end