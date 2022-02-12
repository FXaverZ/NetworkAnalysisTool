function handles = import_nat_results(handles, varargin)
%CALL_MENU_HOME_IMPORT_NAT_RESULTS Summary of this function goes here
%   Detailed explanation goes here

askUser = true;
for setting = 1:2:nargin-1
    switch varargin{setting}
        case 'UserInput'
            askUser = varargin{setting + 1};
        otherwise
            warning(['Unknown inputparameter "',varargin{setting},'"!']);
    end
end

handles = update_NVIEW_control_panel(handles, 'Loading NAT data, please wait...\n', 'clear');

% Clear NVIEW_Results if existing
if isfield(handles,'NVIEW_Results')
    handles = rmfield(handles,'NVIEW_Results');
end
if isfield(handles,'NVIEW_Processed')
    handles = rmfield(handles,'NVIEW_Processed');
end
if isfield(handles,'NVIEW_Analysis_Selection')
    handles = rmfield(handles,'NVIEW_Analysis_Selection');
end

% Clear table if existing
if isfield(handles,'table_results')
    set(handles.table_results,'Visible','off');
    set(handles.table_results,'Data',[])
    set(handles.table_results,'ColumnName',[],'RowName',[])
end

if askUser
    % Set default location for UI get file to open at (handles >> System)
    handles.NVIEW_Control.Result_Information_File.Path = handles.System.Main_Path;
    
    % Select NAT result file
    file = handles.NVIEW_Control.Result_Information_File;
    % Open UI window and select result information file
    [file.Name,file.Path] = uigetfile([...
        {'*.mat','*.mat result information MAT-file'};...
        {'*.*','All files'}],...
        'Load result information data...',...
        [file.Path,filesep]);
    % Check whether an invalid location has been specified:
    if isequal(file.Name,0) || isequal(file.Path,0)
        % If file is invalid, exit this function and update display of main window
        % Update detail result panel with error information, not yet implemented
        % Update handles structure
        return;
    end
    
    % Selected file and location are valid.
    [~, file.Name, file.Exte] = fileparts(file.Name);
    % Remove backslash from folder name
    file.Path = file.Path(1:end-1);
    % Update NVIEW settings result information
    handles.NVIEW_Control.Result_Information_File = file;
end

% Load result information database
handles = load_result_information(handles);
% Convert unprocessed NAT results to NVIEW results
% Update GUI display with new values
handles = refresh_display_NVIEW_main_gui(handles);
% Update handles structure

if askUser
    % select user response and act accordingly
    user_response = questdlg(sprintf([...
        'The program must convert NAT results to NVIEW for result analysis.\n\n',...
        'Do you want to open the NAT result file?']),...
        'NVIEW Result Processing', 'Ok','Cancel','Ok');
else
    user_response = 'Ok';
end
switch user_response
   case 'Ok'
       handles = update_NVIEW_control_panel_busy(handles);
       [handles,NVIEW_Results,~] = convert_nat_results_to_nview(handles);
       handles.NVIEW_Results = NVIEW_Results;
       handles = set_default_analysis_selection(handles);
       
       % Refresh display
       handles = refresh_display_NVIEW_main_gui (handles);

   case 'Cancel'
       handles = get_default_values_NVIEW(handles);
       handles = refresh_display_NVIEW_main_gui (handles);
       % Clear NVIEW_Results if existing
       if isfield(handles,'NVIEW_Results')
           handles = rmfield(handles,'NVIEW_Results');
       end
       if isfield(handles,'NVIEW_Processed')
           handles = rmfield(handles,'NVIEW_Processed');
       end       
       if isfield(handles,'NVIEW_Analysis_Selection')
           handles = rmfield(handles,'NVIEW_Analysis_Selection');
       end
end
end

