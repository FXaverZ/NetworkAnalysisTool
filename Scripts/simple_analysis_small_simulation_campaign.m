%% Initial Set Up
% This is a simple script for the analysis of the small simulation
% campaign. It is structured into individuall cells to be executed one by
% one.
% Only this cell (set up of of datastorage) and the next one (Set up and
% loading of data) have to be executed before every other cell!

clear();
Saved_Data_OAT   = [];
Saved_Data_Input = [];
Data_Path_LoadInfeed = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';
% Data_Path_LoadInfeed = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';
Data_Path_OAT = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Results_mean\01_Merged_OAT-Data\';
% Data_Path_OAT = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';

addpath([pwd, filesep, 'Additional_Resources']);
%% Additional Set Up / Configuration / Loading of Input Data

Settings_Scenario = {
	1, '01_SB_Base_Winter_Workda', [74/256, 126/256, 187/256], 'Base Winter','-';...
	2, '02_SB_Base_Summer_Workda', [74/256, 126/256, 187/256], 'Base Summer','-';...
	3, '03_S1_LowLoadHighInfeed_Winter_Workda', [190/256, 75/256, 72/256], 'Low Load High Infeed Winter','-';...
	4, '04_S1_LowLoadHighInfeed_Summer_Workda', [190/256, 75/256, 72/256], 'Low Load High Infeed Summer','-';...
	5, '05_S2_HighLoadHighInfeed_Winter_Workda',[152/256, 185/256, 84/256], 'High Load High Infeed Winter','-';...
	6, '06_S2_HighLoadHighInfeed_Summer_Workda',[152/256, 185/256, 84/256], 'High Load High Infeed Summer','-';...
	7, '07_S3_HighLoadHighInfeed2Nodes_Winter_Workda',[128/256, 100/256, 162/256], 'High Load High Infeed (2 Nodes) Winter','-';...
	8, '08_S3_HighLoadHighInfeed2Nodes_Summer_Workda',[128/256, 100/256, 162/256], 'High Load High Infeed (2 Nodes) Summer','-';...
	9, '09_S4_MediumLoadHighInfeed2Nodes_Winter_Workda',[247/256, 173/256, 36/256], 'Medium Load High Infeed (2 Nodes) Winter','-';...
	10,'10_S4_MediumLoadHighInfeed2Nodes_Summer_Workda',[247/256, 173/256, 36/256], 'Medium Load High Infeed (2 Nodes) Summer','-';...
	};

Settings_Datasets = {
	1, 'Households'  , 'Haushaltslast'   ;...
	2, 'Solar'       , 'PV Einspeisung'  ;...
	3, 'El_Mobility' , 'Elektromobilität';...
	};

Settings_Number_Profiles = 10;
Settings_Number_Bins = 50;

Option_Histogramm_max_Value = 60000;
Option_Histogramm_min_Value = 0;

Option_Histogramm_Single_max_Value = 10000;
Option_Histogramm_Single_min_Value = 0;

% Load data (Load Infeed Data)
folders = dir(Data_Path_LoadInfeed);
folders = struct2cell(folders);
folders = folders(1,3:end);

for i = 1: numel(folders)
	if ~isfield(Saved_Data_Input,['Saved_',num2str(i)])
		Saved_Data_Input.(['Saved_',num2str(i)]) = [];
	end
	for j = 1 : size(Settings_Scenario,1)
		if ~isfield(Saved_Data_Input.(['Saved_',num2str(i)]),['Saved_',num2str(Settings_Scenario{j,1})])
			load([Data_Path_LoadInfeed,filesep,folders{i},'\',Settings_Scenario{j,2},'.mat']);
			Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Settings_Scenario{j,1})]).Load_Infeed_Data = Load_Infeed_Data;
		end
	end
end

Saved_Data_Input.Number_Datasets = numel(folders);
clear folders i j Load_Infeed_Data

%% Plot Infeed analysis (Sum over all profiles and scenarios)
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Option_Active_Scenarios = 2:2:10; % Sommer
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Plot_max_Value  = 120;
Option_Plot_step_Value =  20;
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Option_Type_Load = 'Households';
% Option_Type_Load = 'Solar';
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
Active_Type = Settings_Datasets{Option_Type_Load,2};
fig_infeedsummary = figure; t = tiledlayout(5,3,'TileSpacing','Compact');
title(t,['Profilsummen über Szenarien für Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'],...
	'FontName','Palatino Linotype','FontSize',10)
xlabel(t,'Datensets',...
	'FontName','Palatino Linotype','FontSize',10)
ylabel(t,'Leistung [kW]',...
	'FontName','Palatino Linotype','FontSize',10)

tick_x_Positions = 0:144/2:144*Settings_Number_Profiles;
tick_x_Labels    = cell(1,numel(tick_x_Positions));
for i = 1 : numel(tick_x_Positions)
	if mod(i,2) == 1
		tick_x_Labels{i} = '';
	else
		tick_x_Labels{i} = i/2;
	end
end
tick_y_Positions = 0:Option_Plot_step_Value:Option_Plot_max_Value;
tick_y_Labels    = 0:Option_Plot_step_Value:Option_Plot_max_Value;

for i = 1 : Saved_Data_Input.Number_Datasets
	figure(fig_infeedsummary); nexttile;
	Labels_Activity  = {};
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		Load_Infeed_Data = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(Active_Type).Data_Mean]; %#ok<AGROW>
		end
		Data = sum(Data,2);
		Data = Data ./ 1000;
		if (~isempty(Data))
			Labels_Scenarios{end+1} = Active_Scenarios{j,4}; %#ok<SAGROW>
		end
		switch Active_Type
			case 'Households'
				num_active = sum(cell2mat(Load_Infeed_Data.Set_1.Households.Number(:,2)));
				Labels_Activity{end+1} = [num2str(num_active),' Act.']; %#ok<SAGROW>
			case 'Solar'
				num_active = size(Load_Infeed_Data.(['Set_',num2str(k)]).Solar_Plants.Selectable,1)-2;
				if num_active > 0
					Labels_Activity{end+1} = [num2str(num_active),' Act.']; %#ok<SAGROW>
				end
			case 'El_Mobility'
				num_active = Load_Infeed_Data.(['Set_',num2str(k)]).(Active_Type).Number;
				if num_active > 0
					Labels_Activity{end+1} = [num2str(num_active),' Act.']; %#ok<SAGROW>
				end
			otherwise
				num_active = 9999;
				Labels_Activity{end+1} = [num2str(num_active),' Act.']; %#ok<SAGROW>
		end
		figure(fig_infeedsummary); l = plot(Data);
		set(l, 'Color', Active_Scenarios{j,3});
		set(l, 'LineStyle', Active_Scenarios{j,5});
		drawnow;
		if j <=1
			figure(fig_infeedsummary); hold on;
		end
	end
	% Format Diagrams:
	figure(fig_infeedsummary); 
	ax = gca;
	% General:
	ax.Title.String = ['Profilsatz ',num2str(i)];
	ax.FontName     = 'Palatino Linotype';
	ax.FontSize     = 8;
	% Legend
	if i == 1
		legend(Labels_Scenarios);
		ax.Legend.FontSize    = 6;
	elseif i == 2
		legend(Labels_Activity{:});
		ax.Legend.FontSize    = 6;
	end
	% X Axis
	ax.XAxis.Limits       = [0 144*Settings_Number_Profiles];
	ax.XAxis.TickValues   = tick_x_Positions;
	ax.XAxis.TickLabels   = tick_x_Labels;
	ax.XGrid              = 'on';
	% Y Axis
	if Option_Plot_max_Value > 0
		ax.YAxis.Limits  = [0 Option_Plot_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	ax.YGrid              = 'on';
	figure(fig_infeedsummary); hold off;
end

clear Active_* Option_* tick_* i j k l Labels_Activity Labels_Scenarios 
clear Load_Infeed_Data Data num_active ax 

%%

histogrammsummary = figure; tiledlayout(5,3);
histogrammSingle = figure; tiledlayout(5,3);

for i = 1: numel(folders)
	figure(fig_infeedsummary); nexttile;
	figure(histogrammsummary); nexttile;
	figure(histogrammSingle); nexttile;
	if ~isfield(Saved_Data_Input,['Saved_',num2str(i)])
		Saved_Data_Input.(['Saved_',num2str(i)]) = [];
	end
	Labels_Activity = {};
	for j = 1 : size(Settings_Scenario,1)
		if ~isfield(Saved_Data_Input.(['Saved_',num2str(i)]),['Saved_',num2str(Settings_Scenario{j,1})])
			load([Data_Path_LoadInfeed,filesep,folders{i},'\',Settings_Scenario{j,2},'.mat']);
			Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Settings_Scenario{j,1})]).Load_Infeed_Data = Load_Infeed_Data;
		else
			Load_Infeed_Data = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Settings_Scenario{j,1})]).Load_Infeed_Data;
		end
		
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(Option_Type_Load).Data_Mean]; %#ok<AGROW>
			
		end
		
		if Option_Show_Power_Sum
			newData = [];
			for m = 1 : size(Data, 2)/ 6
				data_sing = Data(:,1+(m-1)*6:6+(m-1)*6);
				newData = [newData; data_sing]; %#ok<AGROW>
			end
			newData = sum(newData,2);
			Data = sum(Data,2);
			num_active = 9999;
			switch Option_Type_Load
				case 'Households'
					num_active = sum(cell2mat(Load_Infeed_Data.Set_1.Households.Number(:,2)));
					Labels_Activity{end+1} = [num2str(num_active),' Act.'];
				case 'Solar'
					num_active = size(Load_Infeed_Data.(['Set_',num2str(k)]).Solar_Plants.Selectable,1)-2;
					if num_active > 0
						Labels_Activity{end+1} = [num2str(num_active),' Act.'];
					end
				case 'El_Mobility'
					num_active = Load_Infeed_Data.(['Set_',num2str(k)]).(Option_Type_Load).Number;
					if num_active > 0
						Labels_Activity{end+1} = [num2str(num_active),' Act.'];
					end
				otherwise
					num_active = 0;
			end
			% histogramms of sum
			binEdges = linspace(min_hist_value,Option_Histogramm_max_Value,Settings_Number_Bins+1);
			cj = (binEdges(1:end-1)+binEdges(2:end))./2; % center
			[~,binIdx] = histc(Data,[binEdges(1:end-1),Inf]); % histc
			% calculate the number of elements in bins
			nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
			figure(histogrammsummary); 
			switch Option_Type_Load
				case 'Solar'
					b=bar(cj(2:end),100*nj(2:end)/sum(nj(2:end)),'hist');
				otherwise
					b=bar(cj,100*nj/sum(nj),'hist');
			end
			set(b,'EdgeColor','none','FaceColor',Settings_Scenario{j,3});
			alpha(b,.5)
			hold on;
			
			% histogramms of single appliances
			binEdges = linspace(Option_Histogramm_Single_min_Value,Option_Histogramm_Single_max_Value,Settings_Number_Bins+1);
			cj = (binEdges(1:end-1)+binEdges(2:end))./2; % center
			[~,binIdx] = histc(newData,[binEdges(1:end-1),Inf]); % histc
			% calculate the number of elements in bins
			nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
			figure(histogrammSingle); 
			switch Option_Type_Load
				case 'Solar'
					b=bar(cj(2:end),100*nj(2:end)/sum(nj(2:end)),'hist');
				otherwise
					b=bar(cj,100*nj/sum(nj),'hist');
			end
			set(b,'EdgeColor','none','FaceColor',Settings_Scenario{j,3});
			alpha(b,.5)
			hold on;
			
		end
		figure(fig_infeedsummary); l = plot(Data);
		set(l, 'Color', Settings_Scenario{j,3});
		drawnow;
		if j <=1
			figure(fig_infeedsummary); hold on;
			if Option_Plot_max_Value > 0 
				ylim([0 Option_Plot_max_Value]);
			end
			figure(fig_infeedsummary); title(['Dataset ',num2str(i),' - Source - "',Option_Type_Load,'"']);
			figure(histogrammsummary); title(['Histogramm ',num2str(i),' - Source - "',Option_Type_Load,'"']);
			figure(histogrammSingle); title(['Histogramm Einzel',num2str(i),' - Source - "',Option_Type_Load,'"']);
		end
	end
	if Option_Show_Power_Sum && i <= 1
		figure(fig_infeedsummary); legend(Labels_Activity{:})
		figure(histogrammsummary); legend(Settings_Scenario{:,4});
		figure(histogrammSingle); legend(Settings_Scenario{:,4});
	end
	if Option_Show_Power_Sum && i == 2
		figure(fig_infeedsummary); hold on;
		figure(fig_infeedsummary); legend(Settings_Scenario{:,4});
	end
	figure(fig_infeedsummary); hold off;
	figure(histogrammsummary); hold off;
end
%% Histogramm aufbauend
histogrammdevelopment = figure; tiledlayout(5,3);
histogrammdevelopmentSingle = figure; tiledlayout(5,3);
histData = [];
histDataSingle = [];
for i = 1: numel(folders)
	figure(histogrammdevelopment); nexttile;
	figure(histogrammdevelopmentSingle); nexttile;
	for j = 1 : size(Settings_Scenario,1)
		if (~isfield(histData, ['Saved_',num2str(Settings_Scenario{j,1})]))
			histData.(['Saved_',num2str(Settings_Scenario{j,1})]) = [];
		end
		if (~isfield(histDataSingle, ['Saved_',num2str(Settings_Scenario{j,1})]))
			histDataSingle.(['Saved_',num2str(Settings_Scenario{j,1})]) = [];
		end
		Load_Infeed_Data = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Settings_Scenario{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(Option_Type_Load).Data_Mean]; %#ok<AGROW>
		end
		histData.(['Saved_',num2str(Settings_Scenario{j,1})]) = [histData.(['Saved_',num2str(Settings_Scenario{j,1})]); sum(Data,2)];
		
		binEdges = linspace(min_hist_value,Option_Histogramm_max_Value,Settings_Number_Bins+1);
		cj = (binEdges(1:end-1)+binEdges(2:end))./2; % center
		[~,binIdx] = histc(histData.(['Saved_',num2str(Settings_Scenario{j,1})]),[binEdges(1:end-1),Inf]); % histc
		% calculate the number of elements in bins
		nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
		figure(histogrammdevelopment);
		switch Option_Type_Load
			case 'Solar'
				b=bar(cj(2:end),100*nj(2:end)/sum(nj),'hist');
			otherwise
				b=bar(cj,100*nj/sum(nj),'hist');
		end
		set(b,'EdgeColor','none','FaceColor',Settings_Scenario{j,3});
		alpha(b,.5)
		hold on;
		
		figure(histogrammdevelopmentSingle);
		newData = [];
		for k = 1 : size(Data, 2)/ 6
			data_sing = Data(:,1+(k-1)*6:6+(k-1)*6);
			newData = [newData; data_sing]; %#ok<AGROW>
		end
		histDataSingle.(['Saved_',num2str(Settings_Scenario{j,1})]) = [histDataSingle.(['Saved_',num2str(Settings_Scenario{j,1})]); sum(newData,2)];
		
		binEdges = linspace(Option_Histogramm_Single_min_Value,Option_Histogramm_Single_max_Value,Settings_Number_Bins+1);
		cj = (binEdges(1:end-1)+binEdges(2:end))./2; % center
		[~,binIdx] = histc(histDataSingle.(['Saved_',num2str(Settings_Scenario{j,1})]),[binEdges(1:end-1),Inf]); % histc
		% calculate the number of elements in bins
		nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
		figure(histogrammdevelopmentSingle);
		switch Option_Type_Load
			case 'Solar'
				b=bar(cj(2:end),100*nj(2:end)/sum(nj),'hist');
			otherwise
				b=bar(cj,100*nj/sum(nj),'hist');
		end
		set(b,'EdgeColor','none','FaceColor',Settings_Scenario{j,3});
		alpha(b,.5)
		hold on;
		
		if j <=1
			figure(histogrammdevelopment); title([num2str(i*10),' Datasets ',' - Source - "',Option_Type_Load,'"']);
		end
	end
	figure(histogrammdevelopment); hold off;
	figure(histogrammdevelopmentSingle); hold off;
end

%% OAT Data
folders = dir(Data_Path_OAT);
folders = struct2cell(folders);
folders = folders(1,3:end);

if strcmp(Option_Type_Load, 'El_Mobility')
	Option_Type_Load = 'El_mobility';
end

sep = cell(1,numel(folders));
sep(:) = {' - '};
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
sep(:) = {'_Solar'};
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
folders = unique(folders);

oatsummary = figure; tiledlayout(5,3);
for i = 1: numel(folders)
	if ~isfield(Saved_Data_OAT,['Saved_',num2str(i)])
		load([Data_Path_OAT,...
			folders{i},' - 000 - OAT-Data.mat']);
		Saved_Data_OAT.(['Saved_',num2str(i)]).NVIEW_Results = NVIEW_Results;
	else
		NVIEW_Results = Saved_Data_OAT.(['Saved_',num2str(i)]).NVIEW_Results;
	end
	
	figure(oatsummary); nexttile;
	for j = 1:size(Settings_Scenario,1)
		figure(oatsummary); plot(NVIEW_Results.Input_Data.(Option_Type_Load)(1:Settings_Number_Profiles*144,Settings_Scenario{j,1}));
		drawnow;
		if j <=1
			figure(oatsummary); hold on;
			title(['Datenset ',num2str(i),' - OAT - "',Option_Type_Load,'"']);
		end
	end
	figure(oatsummary); hold off;
end

%% Close all figures
close(fig_infeedsummary);
close(histogrammsummary);
close(oatsummary);