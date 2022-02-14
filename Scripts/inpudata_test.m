% This is a simple testfile to look deeper into the data to see, if the
% profiles were allocated correctly...

Saved_OAT_Data = [];
% laodInfeedDataPath = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';
laodInfeedDataPath = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';

%% show the first three sets of each input dataset
folders = dir(laodInfeedDataPath);
folders = struct2cell(folders);
folders = folders(1,3:end);
figure; tiledlayout(5,3);

show_power_sum = true;

scen_sel = {
	4, '04_S1_LowLoadHighInfeed_Summer_Workda';...
	6, '06_S2_HighLoadHighInfeed_Summer_Workda';...
	8, '08_S3_HighLoadHighInfeed2Nodes_Summer_Workda';...
% 	10,'10_S4_MediumLoadHighInfeed2Nodes_Summer_Workda';...
	};

num_profiles = 10;

% loadtype = 'Households';
loadtype = 'Solar';
% loadtype = 'El_Mobility';

for i = 1: numel(folders)
	nexttile;
	for j = 1 : size(scen_sel,1)
		load([laodInfeedDataPath,filesep,folders{i},'\',scen_sel{j,2},'.mat']);
		Data = [];
		for k = 1 : num_profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(loadtype).Data_Mean]; %#ok<AGROW>
		end
		if show_power_sum
			Data = sum(Data,2);
		end
		plot(Data);
		drawnow;
		if j <=1
			hold on;
			title(['Dataset ',num2str(i),' - Source - "',loadtype,'"']);
		end
%     load('C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios\2021_12_03-14.05.14\04_S1_LowLoadHighInfeed_Summer_Workda.mat');
%     % figure; plot(Load_Infeed_Data.Set_1.Solar.Data_Mean,'DisplayName','Load_Infeed_Data.Set_1.Solar.Data_Mean');
%     % figure; plot(Load_Infeed_Data.Set_2.Solar.Data_Mean,'DisplayName','Load_Infeed_Data.Set_1.Solar.Data_Mean');
%     % figure; plot(Load_Infeed_Data.Set_3.Solar.Data_Mean,'DisplayName','Load_Infeed_Data.Set_1.Solar.Data_Mean');
%     Data = sum([Load_Infeed_Data.Set_1.Solar.Data_Mean;Load_Infeed_Data.Set_2.Solar.Data_Mean;Load_Infeed_Data.Set_3.Solar.Data_Mean],2);
%     figure; plot(Data);
%     title('Datenset 2 - LoadInfeed Raw');
	end
	hold off;
end
%%
folders = dir('C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Results_mean\01_Merged_OAT-Data\');
folders = struct2cell(folders);
folders = folders(1,3:end);

if strcmp(loadtype, 'El_Mobility')
	loadtype = 'El_mobility';
end

sep = cell(1,numel(folders));
sep(:) = {' - '};
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
sep(:) = {'_Solar'};
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
folders = unique(folders);

figure; tiledlayout(5,3);
for i = 1: numel(folders)
	if ~isfield(Saved_OAT_Data,['Saved_',num2str(i)])
		load(['C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Results_mean\01_Merged_OAT-Data\',...
			folders{i},' - 000 - OAT-Data.mat']);
		Saved_OAT_Data.(['Saved_',num2str(i)]).NVIEW_Results = NVIEW_Results;
	else
		NVIEW_Results = Saved_OAT_Data.(['Saved_',num2str(i)]).NVIEW_Results;
	end
	
	nexttile;
	for j = 1:size(scen_sel,1)
		plot(NVIEW_Results.Input_Data.(loadtype)(1:num_profiles*144,scen_sel{j,1}));
		drawnow;
		if j <=1
			hold on;
			title(['Datenset ',num2str(i),' - OAT - "',loadtype,'"']);
		end
	end
%     load('C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Results_mean\01_Merged_OAT-Data\Res_2022_02_12-16.43.22 - 000 - OAT-Data.mat');
%     figure; plot(NVIEW_Results.Input_Data.Solar(1:3*144,4));
%     title('Datenset 2 - OAT Data');
	hold off;
end