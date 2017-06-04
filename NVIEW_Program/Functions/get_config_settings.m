function handles = get_config_settings(handles)

config_file = [handles.System.Main_Path,filesep,'config.ini'];

% ---------------------------------------------------
% Header definition
% ---------------------------------------------------
[default,sep,line_sep,header,setting_elements] = config_file_definitions();
% ---------------------------------------------------
    
if exist(config_file,'file') ~=2  
    
    % File does not exist, set values to default
    % Open or create new file for writing. Append data to the end of the file.
    fid=fopen(config_file,'w+' );
    % Add default FIRST_RUN value (first time the user starts the program)
    fprintf(fid,[header,line_sep]);
    
    for i = 1 : numel(setting_elements)
        fprintf(fid,[default.(setting_elements{i,1}).Name,sep,sep,int2str(default.(setting_elements{i,1}).Val),sep]);
        if i ~= numel(setting_elements)
            fprintf(fid,line_sep);
        end
        % Add default Save_Time_Domain value (save time-domain partial results)
    end
    % Close file
    fclose(fid);
    
    % Append to handles
    for i = 1 : numel(setting_elements)
        handles.System.Settings.(setting_elements{i,1}) = default.(setting_elements{i,1}).Val;
    end
else
    % File exists
    data = text_scan(handles.System.Main_Path,'config.ini');
    % Get values
    for i = 1 : size(data,1)
        if strncmp(data(i,1),'[',1) % Comments are ignored
            continue;
        end
        sep = [];
        sep = find(data(i,:)==';');        
        for j = 1 : numel(setting_elements)
            if strcmp(data(i,1:sep(1)-1),default.(setting_elements{j,1}).Name)
                file_content.(setting_elements{j,1}) = str2double(data(i,sep(2)+1:sep(3)-1));
                break;
            end
        end
    end
    clear sep i data
    
    % Catch exceptions when writting to object
    ME = [];
    try
        for i = 1 : numel(setting_elements)
            % Append to handles
            handles.System.Settings.(setting_elements{i,1}) = file_content.(setting_elements{i,1});
        end
    catch ME % Exceptions
    end
    
    % Check for exceptions
    if ~isempty(ME)
        % If error occured, one or more configuration settings were
        % not available - set defaults
        
        % Append to handles
        for i = 1 : numel(setting_elements)
            handles.System.Settings.(setting_elements{i,1}) = default.(setting_elements{i,1}).Val;
        end
        return;
    end
end


end
