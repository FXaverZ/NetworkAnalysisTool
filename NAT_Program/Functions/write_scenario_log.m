function write_scenario_log(handles,condition)
% WRITE_SCENARIO_LOG - creates a txt log about the  calculated scenarios

% Example:
% ##Scenario definition;Filepath_of_scenarios;
% Scenario_1;Description_of_scenario_1;
% Scenario_2;Description_of_scenario_2;
% 
% ##Variant definition;filepath_of_variants;
% Variant_1;
% Variant_2;
% 
% ##Number of datasets;DS;
% 
% ##Scenarios calculated;Filepath;filepath;
% Res_yyyy-MM-dd_hh-mm-ss - Scenario_1;
% Res_yyyy-MM-dd_hh-mm-ss - Scenario_2;
% 
% ##CALCULATION SUCCESSFULLY FINSIHED

%---------------------------------------------
filename = handles.Current_Settings.Files.Save.Result.Log_file;

if strcmp(condition,'create')
    % Creates new log file
    fid = fopen([handles.Current_Settings.Files.Save.Result.Path,filesep,...
        filename],'w+');
    
    fprintf(fid,'##Scenario definition;');
    fprintf(fid,'%s',handles.Current_Settings.Simulation.Scenarios_Path);
    fprintf(fid,';\r\n');
    for h = 1 : numel(handles.Current_Settings.Simulation.Scenarios.Names)
        fprintf(fid,'%s', handles.Current_Settings.Simulation.Scenarios.Names{h});
        fprintf(fid,';');
        fprintf(fid,'%s',...
            eval(['handles.Current_Settings.Simulation.Scenarios.Sc_', int2str(h),'.Description']) );
        fprintf(fid,';\r\n');
    end
    fprintf(fid,'\r\n');
    
    if handles.Current_Settings.Simulation.Use_Grid_Variants == 1
        fprintf(fid,'##Variant definition;');
        fprintf(fid,'%s',handles.Current_Settings.Simulation.Grids_Path);
        fprintf(fid,';\r\n');
        for h = 1 : numel(handles.Current_Settings.Simulation.Grid_List)
            fprintf(fid,'%s',handles.Current_Settings.Simulation.Grid_List{h}(1:end-4));
            fprintf(fid,';\r\n');
        end
        fprintf(fid,'\r\n');
    end
    
    if handles.Current_Settings.Simulation.Number_Runs > 1
        fprintf(fid,['##Number of datasets;' int2str(handles.Current_Settings.Simulation.Number_Runs), ';\r\n\r\n']);
    end
    
    fprintf(fid,'##Scenarios calculated;');
    fprintf(fid,'%s', handles.Current_Settings.Files.Save.Result.Path);
    fprintf(fid,';\r\n');
    fclose(fid);

elseif strcmp(condition,'append')==1
    % Append info to log file
    % Append what scenario was calculated
    fid = fopen([handles.Current_Settings.Files.Save.Result.Path,filesep,...
        filename],'a+');
    
    fprintf(fid,'%s',handles.Current_Settings.Files.Save.Result.Name);
    fprintf(fid,';\r\n');
    fclose(fid);

elseif strcmp(condition,'close')==1
    % Successfully finished calculations
    fid = fopen([handles.Current_Settings.Files.Save.Result.Path,filesep,...
        filename],'a+');
    fprintf(fid,'\r\n');
    fprintf(fid, '##CALCULATION SUCCESSFULLY FINISHED');
    fclose(fid);
    
end


end
