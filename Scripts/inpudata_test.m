% This is a simple testscript to look deeper into the data to see, if the
% profiles were allocated correctly...

Saved_OAT_Data = [];
Saved_InputData = [];
laodInfeedDataPath = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';
% laodInfeedDataPath = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';

oatDataPath = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Results_mean\01_Merged_OAT-Data\';

%% show the first three sets of each input dataset
folders = dir(laodInfeedDataPath);
folders = struct2cell(folders);
folders = folders(1,3:end);
figure; tiledlayout(5,3);

show_power_sum = true;
% show_power_sum = false;

scen_sel = {
	1, '01_SB_Base_Winter_Workda';...
	2, '02_SB_Base_Summer_Workda';...
	3, '03_S1_LowLoadHighInfeed_Winter_Workda';...
	4, '04_S1_LowLoadHighInfeed_Summer_Workda';...
	5, '05_S2_HighLoadHighInfeed_Winter_Workda';...
	6, '06_S2_HighLoadHighInfeed_Summer_Workda';...
	7, '07_S3_HighLoadHighInfeed2Nodes_Winter_Workda';...
	8, '08_S3_HighLoadHighInfeed2Nodes_Summer_Workda';...
	9, '09_S4_MediumLoadHighInfeed2Nodes_Winter_Workda';...
	10,'10_S4_MediumLoadHighInfeed2Nodes_Summer_Workda';...
	};

num_profiles = 10;

max_value_plot = -1;
% max_value_plot = 60000;
% max_value_plot = 4000;

% loadtype = 'Households';
loadtype = 'Solar';
% loadtype = 'El_Mobility';

for i = 1: numel(folders)
	nexttile;
	if ~isfield(Saved_InputData,['Saved_',num2str(i)])
		Saved_InputData.(['Saved_',num2str(i)]) = [];
	end
	Labels = {};
	for j = 1 : size(scen_sel,1)
		if ~isfield(Saved_InputData.(['Saved_',num2str(i)]),['Saved_',num2str(scen_sel{j,1})])
			load([laodInfeedDataPath,filesep,folders{i},'\',scen_sel{j,2},'.mat']);
			Saved_InputData.(['Saved_',num2str(i)]).(['Saved_',num2str(scen_sel{j,1})]).Load_Infeed_Data = Load_Infeed_Data;
		else
			Load_Infeed_Data = Saved_InputData.(['Saved_',num2str(i)]).(['Saved_',num2str(scen_sel{j,1})]).Load_Infeed_Data;
		end
		
		Data = [];
		for k = 1 : num_profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(loadtype).Data_Mean]; %#ok<AGROW>
			
		end
		if show_power_sum
			Data = sum(Data,2);
			num_active = 9999;
			switch loadtype
				case 'Households'
					num_active = sum(cell2mat(Load_Infeed_Data.Set_1.Households.Number(:,2)));
					Labels{end+1} = [num2str(num_active),' Act.'];
				case 'Solar'
					num_active = size(Load_Infeed_Data.(['Set_',num2str(k)]).Solar_Plants.Selectable,1)-2;
					if num_active > 0
						Labels{end+1} = [num2str(num_active),' Act.'];
					end
				case 'El_Mobility'
					num_active = Load_Infeed_Data.(['Set_',num2str(k)]).(loadtype).Number;
					if num_active > 0
						Labels{end+1} = [num2str(num_active),' Act.'];
					end
				otherwise
					num_active = 0;
			end
			
		end
		plot(Data);
		drawnow;
		if j <=1
			hold on;
			if max_value_plot > 0 
				ylim([0 max_value_plot]);
			end
			title(['Dataset ',num2str(i),' - Source - "',loadtype,'"']);
		end
	end
	hold off;
	if show_power_sum
		legend(Labels{:})
	end
end
%%
folders = dir(oatDataPath);
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
		load([oatDataPath,...
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
	hold off;
end