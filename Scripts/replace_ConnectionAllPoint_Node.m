clear;

addpath([pwd, filesep, 'Additional_Resources']);
addpath([fileparts(pwd),filesep,'NAT_Common',filesep,'Grid_Representation']);
addpath([fileparts(pwd),filesep,'NAT_Common',filesep,'Analyzing']);

warning('off','MATLAB:load:variableNotFound');
%Path of the files with old instances of "Connection_Point_All" to be
%replaced with "Node"
replacement_files_path = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Results';

fprintf('Starting with conversion...\n')

replacement_files = dir(replacement_files_path);
replacement_files = struct2cell(replacement_files);
replacement_files = replacement_files(1,3:end);

for i=1:numel(replacement_files)
    % load 'Grid', 'Load_Infeed_Data', 'Result'
    fprintf(['   File ', num2str(i), ' from ', num2str(numel(replacement_files)), ' ...']);
    
    try 
        load([replacement_files_path,filesep,replacement_files{i}],'Grid', 'Load_Infeed_Data', 'Result');
    catch 
        fprintf(' not able to load file, skipping!\n');
        continue;
    end
    
    if ~exist('Grid', 'var')
        fprintf(' no variable "Grid" present, skipping!\n');
        continue;
    end
    
    gridlist = fields(Grid);
    
    for j=1:numel(gridlist)
        Points = Grid.(gridlist{j}).All_Node.Points;
        NewPoints = Node.empty(numel(Points),0);
        for k=1:numel(Points)
            NewPoints(k) = Node('recreation', Points(k));
        end
        
        Grid.(gridlist{j}).All_Node = rmfield(Grid.(gridlist{j}).All_Node,'Points');
        Grid.(gridlist{j}).All_Node.Points = NewPoints;
    end
    
    save([replacement_files_path,filesep,replacement_files{i}],'Result', 'Grid',...
        'Load_Infeed_Data','-v7.3'),
    fprintf(' done!\n');
    
    clear Grid Load_Infeed_Data Result
    clear Points NewPoints gridlist j k
end
clear replacement_files replacement_files_path i
warning('on','MATLAB:load:variableNotFound');
fprintf('finished! \n')