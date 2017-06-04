function [] = set_config_settings(handles)

config_file = [handles.System.Main_Path,filesep,'config.ini'];

% ---------------------------------------------------
% Header definition
% ---------------------------------------------------
[default,sep,line_sep,header,setting_elements] = config_file_definitions();
% ---------------------------------------------------

fid=fopen(config_file,'w+' );
fprintf(fid,[header,line_sep]);
for i = 1 : numel(setting_elements)
    fprintf(fid,[default.(setting_elements{i,1}).Name,sep,sep,int2str(handles.System.Settings.(setting_elements{i,1})),sep]);
    if i ~= numel(setting_elements)
        fprintf(fid,line_sep);
    end
end
% Close file
fclose(fid);



end