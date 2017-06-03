classdef Merge_Simulation_Results
    % Merge simulation campaign result files from N information files. User
    % must manually select the information files and ensure that the resulting
    % files are in the same folder
   
    properties
        filepath;
        filenames;        
    end
    
    methods        
        function obj = Merge_Simulation_Results(filepath,filenames)
           obj.filepath = filepath;
           obj.filenames = filenames;
        end
               
        function merge_files(obj)
        
            % Load and store information files in the merge_I structures
            for i = 1 : numel(obj.filenames)
                eval(['merge_' int2str(i) ' = load([obj.filepath,filesep,obj.filenames{i}]);'])
            end
        
            % Check if we can merge the files
            for i = 1 : numel(obj.filenames)
                datasets(i,1) = eval(['merge_', int2str(i),'.datasets;']); k = 1;                
                simulation_options.settings(i,k) = eval(['merge_', int2str(i),'.simulation_options.Use_Scenarios;']); k = k + 1;
                simulation_options.settings(i,k) = eval(['merge_', int2str(i),'.simulation_options.Voltage_Violation_Analysis;']); k = k + 1;
                simulation_options.settings(i,k) = eval(['merge_', int2str(i),'.simulation_options.Branch_Violation_Analysis;']); k = k + 1;
                simulation_options.settings(i,k) = eval(['merge_', int2str(i),'.simulation_options.Power_Loss_Analysis;']); k = k + 1;
                simulation_options.settings(i,k) = eval(['merge_', int2str(i),'.simulation_options.Save_Voltage_Results;']); k = k + 1;
                simulation_options.settings(i,k) = eval(['merge_', int2str(i),'.simulation_options.Save_Branch_Results;']); k = k + 1;
                simulation_options.settings(i,k) = eval(['merge_', int2str(i),'.simulation_options.Save_Power_Loss_Results;']); k = k + 1;
                simulation_options.settings(i,k) = eval(['merge_', int2str(i),'.simulation_options.Use_Grid_Variants;']);
                
                try
                    variants(i,:) = eval(['merge_', int2str(i),'.variants;']);                
                catch
                   % Dimensions of grids do not match - error
                   error('Grid variants do not match');
                end
                
                timepoints(i,1) = eval(['merge_', int2str(i),'.simulation_options.Timepoints;']);
                input_values_used{i} = eval(['merge_', int2str(i),'.simulation_options.Input_values_used;']);
            end
            simulation_options.names = set_option_names();            
            datasets = unique(datasets);
            if numel(unique(datasets)) ~= 1
               error('Datasets of simulations do not match') ;               
            end            
            variants_check = zeros(size(variants));
            variants_check(1,:) = 1;
            for j = 1 : size(variants,2)
                for i = 2 : size(variants,1)
                    if strcmp(variants{1,j},variants{i,j}) == 1
                        variants_check(i,j) = 1;
                    end                
                end
            end
            if sum(variants_check(:) == 1) ~= numel(variants_check)
                error('Grid variants do not match');
            end
            variants = variants(1,:);
            
            check_sim_options = zeros(1,size(simulation_options.settings,2));
            for j = 1 : size(simulation_options.settings,2)
                    if numel(unique(simulation_options.settings(:,j))) == 1
                        check_sim_options(1,j) = 1;
                    end
            end
            if ~isempty(find(check_sim_options == 0))
                error('Simulation options are not identical');
            end
            
            timepoints = unique(timepoints);
            if numel(unique(timepoints)) ~= 1
               error('Timepoints of simulations do not match') ;               
            end
            
            input_values_used = unique(input_values_used);
            if numel(unique(input_values_used)) ~= 1
               error('Input values of of simulations do not match') ;               
            end            
            % -------------------------
            clear k j input_values_used datasets check_sim_options i simulation_options timepoints variants
            
            % Combine the results - If all values match we take all the
            % parameter settings from the first information file
            
            simulation_options = merge_1.simulation_options;
            datasets = merge_1.datasets;
            variants = merge_1.variants;
            result_filepath = []; % Clear the filepath of the results, it is not needed
            
            
            combined_scenarios = [];
            combined_result_filename = [];
            for i = 1 : numel(obj.filenames)
                combined_scenarios = [ combined_scenarios,eval(['merge_', int2str(i) '.scenarios']) ];
                combined_result_filename = [combined_result_filename, eval(['merge_', int2str(i) '.result_filename'])];
            end
            [scenarios,idx] = sort(combined_scenarios);            
            result_filename = combined_result_filename(idx);            
            clear i combined_* idx
            
             % Date for merged file
            simdate = datestr(now,'yyyy-mm-dd_HH-MM-SS');
            file_exte = '.mat';
            
            currentFolder = pwd;
            % Rename result files to new date!
            
            for i = 1 : numel(result_filename)
                new_result_filename = [];
                new_result_filename = ['Res_' simdate ' - ' scenarios{i},file_exte];
                disp(['Renaming ', result_filename{i}, ' to ', new_result_filename ]);
                % To rename file, we move to the filepath with the location
                % of files
                cd(obj.filepath)
                % Rename file
                R = dos(['rename "' result_filename{i} '" "' new_result_filename '"']);
                if R == 1
                    disp(['Error at renaming ', result_filename{i}]);
                end
                % Move back to the original folder
                cd(currentFolder);
                % Update new filename names
                result_filename{i} = [];
                result_filename{i} = new_result_filename;                  
            end
            
            new_result_filename = ['Res_' simdate ' - information'];           
            
            save([obj.filepath,filesep,new_result_filename,file_exte],'scenarios',...
                'variants','datasets','result_filepath','result_filename',...
                'simulation_options');
   
            disp(['Merged data into file: ', [new_result_filename,file_exte]]);
            
            % Cleanup - remove the old file information
            for i = 1 : numel(obj.filenames)
               delete([obj.filepath,filesep,obj.filenames{i}]);
            end
        end
        
    end
end
         

function setting_names = set_option_names()
    k = 1;
    setting_names{k} = 'Use_Scenarios'; k = k+1;
    setting_names{k} = 'Voltage_Violation_Analysis'; k = k+1;
    setting_names{k} = 'Branch_Violation_Analysis'; k = k+1;
    setting_names{k} = 'Power_Loss_Analysis'; k = k+1;
    setting_names{k} = 'Save_Voltage_Results'; k = k+1;
    setting_names{k} = 'Save_Branch_Results'; k = k+1;
    setting_names{k} = 'Save_Power_Loss_Results'; k = k+1;
    setting_names{k} = 'Use_Grid_Variants'; k = k+1;
    
end
