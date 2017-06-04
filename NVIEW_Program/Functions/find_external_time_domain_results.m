function handles = find_external_time_domain_results(handles)
% append_time_domain_results

% Select default result file path
default_filepath = handles.NVIEW_Control.NVIEW_Result_Information_File.Path;
% Open UI window and select result information file path
selected_filepath = [];
selected_filepath = uigetdir(default_filepath);

% Check whether an invalid location has been specified:
if isequal(selected_filepath,0)
    % If filepath is invalid, exit this function and update display of main window    
    % Update detail result panel with error information, not yet implemented
    % Update handles structure
	return;
end

% Find time domain files
% Define header id for files
simprefix = regexp(handles.NVIEW_Control.NVIEW_Result_Information_File.Name,' - ','split');
simprefix = simprefix{1};
fdir = [];
fdir = dir([selected_filepath, filesep, [simprefix,' - TD_*.mat']]);

% Look for the corresponding time domain result files
if isempty(fdir)
    % If no files were found
    % Missing NAT Result files
    helpdlg_condition = 0;
    while helpdlg_condition == 0;
        
        user_response = questdlg(sprintf([...
            'Can''t find the corresponding time domain result files in the selected folder!']),...
            'Can''t find time domain result files!',...
            'Ok','Ok');
        switch user_response
            case 'Ok'
                helpdlg_condition = 1;            
        end
    end
    clear user_response helpdlg_condition
    return;
else    
    % Get list of files    
    files = struct2cell(fdir);
    files = files(1,cell2mat(files(3,:)) ~= 0);
    
    file_time_period = cell(size(files,2),1);
    for i = 1 : size(files,2)        
        simprefix_name = [];
        simprefix_name = regexp(files{1,i},' - TD_','split');
        simprefix_name = simprefix_name{2};
        simprefix_td = regexp(simprefix_name,'.mat','split');
        simprefix_td = simprefix_td{1};
        
        file_ident = zeros(24,1);        
        for j = 1 : size(simprefix_td,2)
            file_ident(j,1) = str2double(simprefix_td(1,j));
        end
        id_ = [];
        id_ = find(file_ident)-1;        
   
        if isempty(find(id_(1:end-1)-id_(2:end)~=-1))
            file_time_period{i,1} = [files{1,i}, ' - Results include time domain data for : ' ,int2str(min(id_)),' - ', int2str(max(id_)) ,' h'];
        else
            file_time_period{i,1} = [files{1,i}, ' - Results include time domain data for : ' ];            
            for j = 1 : numel(id_)
                if j == numel(id_)
                    file_time_period{i,1} = [file_time_period{i,1},int2str(id_(j)),' h'];
                else
                    file_time_period{i,1} = [file_time_period{i,1},int2str(id_(j)),','];
                end
            end
        end
        Selected_Time_Results = [];
        % Load results
        load([selected_filepath,filesep,files{1,i}]);

        % Append the results
        handles = append_selected_time_results(handles,Selected_Time_Results,simprefix_td,[],[]);
        
    end
    
    text_output = ['The following time domain results were loaded :'];
    for i = 1 : size(file_time_period,1)
        text_output = [text_output,'\n',file_time_period{i,1}];
    end
           
    set(handles.static_text_result_details, 'String', ...
        sprintf(text_output));
    
    % Assign id value
    handles.NVIEW_Analysis_Selection.Appended_External_Results = 1;
    handles.NVIEW_Analysis_Selection.Appended_External_Results_Text = [];
    handles.NVIEW_Analysis_Selection.Appended_External_Results_Text = text_output;
end
    
    

end