function [Merged_Settings_Header, Selected_Settings_Header] = get_merger_timestamps(SettingFiles)
% Create new filename with time of merger

% Get system clock
tc = clock;
yyyy = int2str(tc(1));
if tc(2) < 10,  
    mm = ['0',int2str(tc(2))];  
else, 
    mm = int2str(tc(2)); 
end
if tc(3) < 10, 
    dd = ['0',int2str(tc(3))];  
else,
    dd = int2str(tc(3)); 
end
if tc(4) < 10,  
    HH = ['0',int2str(tc(4))];  
else, 
    HH = int2str(tc(4)); 
end
if tc(5) < 10,  
    MM = ['0',int2str(tc(5))];  
else, 
    MM = int2str(tc(5)); 
end
if tc(6) < 10, 
    SS = ['0',int2str(tc(6))];  
else, 
    SS = int2str(tc(6)); 
end

% Result_Information_File
Merged_Settings_Header = ['Res_', yyyy,'_',mm,'_',dd,'-',HH,'.',MM,'.',SS];

Selected_Settings_Header = cell(numel(SettingFiles),1);
for i = 1 : numel(SettingFiles)
    simprefix = [];
    simprefix = regexp(SettingFiles{i,1},' - ','split');
    Selected_Settings_Header{i,1} = simprefix{1};
end
