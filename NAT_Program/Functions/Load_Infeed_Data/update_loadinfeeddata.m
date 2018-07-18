clear;
%Beispieldatensatz für neue Datenstrukutur:
Data_Scheme_New = load('D:\Projekte\Analysetool für NS-Netze\7_Testen, Überprüfen\NAT_NVIEW_Testdaten_mini\MV_Grids\josefstadt_schematisch_red_ist_20140220_nat\Load_Infeed_Data_f_Scenarios\2014_04_30-15.25.20\09_High_load_Medium_infeed_High_e_mobility_Winter_Workda.mat');

Path_Data = 'D:\Projekte\REstrukt-DEA\01a_Small_Campaign\MV_Grids\josefstadt_schematisch_red_soll_20140314_nat\Load_Infeed_Data_f_Scenarios\';
Date_Data = '2014_03_16-22.36.43';

content_file_names = dir([Path_Data,Date_Data]);
content_file_names  = {content_file_names.name};
content_file_names = content_file_names(3:end);

conv_datestr = datestr(now,'yyyy_mm_dd-HH.MM.SS');

mkdir([Path_Data,conv_datestr]);

tabl_new = Data_Scheme_New.Load_Infeed_Data.Set_1.Table_Network;

for i=1:numel(content_file_names)
	
	load([Path_Data,Date_Data,filesep,content_file_names{i}]);
	
	if strcmp(content_file_names{i},'Scenario_Settings.mat')
		Data_Extract.Time_Resolution = 600;
		save([Path_Data,conv_datestr,filesep,content_file_names{i}],'Scenarios_Settings','Data_Extract');
	else
		set_names = fields(Load_Infeed_Data);
		for j=1:numel(set_names);
			tabl_old = Load_Infeed_Data.(set_names{j}).Table_Network;
			tabl_old.ColumnFormat{end+1} = tabl_new.ColumnFormat{end};
			tabl_old.ColumnName = tabl_new.ColumnName;
			tabl_old.ColumnWidth = tabl_new.ColumnWidth;
			tabl_old.ColumnEditable = tabl_new.ColumnEditable;
			idx = strcmp(tabl_old.ColumnName, 'EMob Ctr.');
			tabl_old.Data(:,end+1) = num2cell(true(size(tabl_old.Data(:,1),1),1));
			Load_Infeed_Data.(set_names{j}).Table_Network = tabl_old;
		end
	
	save([Path_Data,conv_datestr,filesep,content_file_names{i}],'Load_Infeed_Data');
	end
end

clear;