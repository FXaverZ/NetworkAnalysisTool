function push_input_data_loadsimulation_load_direct_Callback_Add(hObject, ~, handles)
%PUSH_INPUT_DATA_LOADSIMULATION_LOAD_DIRECT_CALLBACK_ADD Summary of this function goes here
% hObject    handle to push_input_data_loadsimulation_load_direct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Userabfrage nach neuen Datenbankpfad:

d = handles.NAT_Data;

if handles.Current_Settings.Data_Extract.get_Sample_Value
	data_typ = '_Sample';
end
if handles.Current_Settings.Data_Extract.get_Mean_Value
	data_typ = '_Mean';
end
if handles.Current_Settings.Data_Extract.get_Max_Value
	data_typ = '_Max';
end
if handles.Current_Settings.Data_Extract.get_Min_Value
	data_typ = '_Max';
end
if handles.Current_Settings.Data_Extract.get_05_Quantile_Value
	data_typ = '_05P_Quantil';
end
if handles.Current_Settings.Data_Extract.get_95_Quantile_Value
	data_typ = '_95P_Quantil';
end

Main_Path = uigetdir([handles.Current_Settings.Files.Grid.Path,filesep,...
	handles.Current_Settings.Files.Grid.Name,'_nat'],...
	'Selcet folder with grid variants...');
if ischar(Main_Path)
	% Check, if simulation data files are present in this folder:
	files = dir(Main_Path);
	files = struct2cell(files);
	files = files(1,3:end);
	model_files = files(cellfun(@(x) strcmp(x(end-13:end-4),'Modeldaten'), files));
	
	% if not, error:
	if isempty(model_files)
		errordlg({'No "Load-Simulation-Data" files found at the given loaction!';...
			'Selcet folder with simulation results of the synthetic load profile generator...'},...
			'Selcet folder with "Load-Simulation-Data"...');
		return;
	end
else
	return;
end

% see if there are different simulations present:
simulations = unique(cellfun(@(x) x(1:8),model_files,'UniformOutput',false));
but = 'Continue';
if numel(simulations) > 1
	but = questdlg({['More than one simulation run found in the specified folder! ',...
		'Only the first one will be prcessed, the other ones are ignored! '];' ';...
		['If this behaviour is not wanted please move the desired data in',...
		' a seperate folder...']},'Selcet folder with "Load-Simulation-Data"...',...
		'Continue','Abort','Continue');
end

switch but
	case 'Abort'
		return;
end

model_files = files(cellfun(@(x) strcmp(x(1:8),simulations{1}), files));
model_files = model_files(cellfun(@(x) strcmp(x(end-13:end-4),'Modeldaten'), model_files));

system = handles.System;
table_ = handles.Current_Settings.Table_Network;
settin = handles.Current_Settings.Data_Extract;

% Flag, if user once seleced, when to few simulation
% data is available that the allready used profiles should be used
% again:
repeat = 0;

% bisherige Daten löschen:
d.Load_Infeed_Data = [];

% Ergebnis-Arrays initialisieren:
HH.Data_Sample = [];
HH.Data_Mean = [];
HH.Data_Min = [];
HH.Data_Max = [];
HH.Data_05P_Quantil = [];
HH.Data_95P_Quantil = [];

Solar = HH;
El_Mobility = HH;

HH.Content = {};

% load the model data for further information:
% loading structures "Model", "Configuration", "Time", "Households"
load([Main_Path,filesep,model_files{1}]);

% get the most important information:
data_sets_number = Model.Number_Runs;
% 	data_sets_date_start = datenum(Model.Series_Date_Start,'dd.mm.yyyy');
% 	data_sets_date_end = datenum(Model.Series_Date_End,'dd.mm.yyyy');
data_sets_days = ...
	datenum(Model.Series_Date_Start,'dd.mm.yyyy'):datenum(Model.Series_Date_End,'dd.mm.yyyy');
data_time_base = Time.Base;
data_hh_content_per_set = Households.Types(:,[1 5]);
data_sep = ' - ';
data_initial_string = regexp(model_files{1}, data_sep, 'split');
data_initial_string = data_initial_string{1};
clear files model_files

% Where are the number of households in the Table_Network data?
idx_hh_num = strcmp(table_.ColumnName, 'Hh. Number');
% Where is stored the current selection of the households?
idx_hh_sel = strcmp(table_.Additional_Data_Content, 'HHs_Selection');

% Anzahl der jeweiligen Haushalte ermitteln:
settin.Households.Number = handles.System.housholds(1:end-1,1);
[settin.Households.Number{:,end+1}] = deal(0);

for i=1:size(table_.Data,1)
	num_hh = table_.Data{i,idx_hh_num};
	for j=1:num_hh
		hh_typ = table_.Additional_Data{i,idx_hh_sel}{j};
		idx = strcmp(settin.Households.Number(:,1),hh_typ);
		settin.Households.Number{idx,2} = ...
			settin.Households.Number{idx,2} + 1;
	end
end

clear idx_hh_num idx_hh_sel hh_typ num_hh

% die einzelnen Haushaltsklassen durchgehen:
idx_hh_sel = [];

for i=1:size(system.housholds,1)-1
	% Anzahl der Haushalte gemäß Einstellungen auslesen:
	idx = find(strcmp(settin.Households.Number(:,1), system.housholds{i,1}));
	if isempty(idx)
		% this householdtyp does not exist, contiune to next one:
		continue;
	end
	number_hh = settin.Households.Number{idx,2};
	if number_hh < 1
		% Falls für diesen Haushalt keine Daten extrahiert werden sollen
		% (Anzahl = 0), überspringen:
		continue;
	end
	
	% wieviele Datensätze gibt es insgesamt?
	idx = find(strcmp(data_hh_content_per_set(:,1), system.housholds{i,1}));
	if isempty(idx)
		disp('Household not present in Simulation Data!');
		errordlg(['The specifeid Household "',system.housholds{i,1},'" is not ',...
			'present in Simulation Data!']);
		return;
	end
	num_data_sets = data_hh_content_per_set{idx,2}*data_sets_number;
	
	% Je nach Einstellung Datensätze auswählen:
	switch system.wc_households{settin.Worstcase_Housholds,2}
		case 'none_' % Einstellung: Zufällige Auswahl
			% eine Indexliste erstellen, mit zufällig ausgewählten Datensätzen:
			pool = 1:num_data_sets;   % Liste mit Indizes der möglichen Datensätze
			idx_hh_sel.(system.housholds{i,1}) = zeros(number_hh,1); % Liste mit Indizes der ausgewählten Datensätze
			% (mit 0 intialisieren)
			for j = 1:number_hh
				if isempty(pool) && ~ repeat
					answer = questdlg({...
						'To few simulation data available than needed!';...
						'';...
						'Should the allready used data be used again?'},...
						'Running out of load simulation data...',...
						'Yes','Abort','Abort');
					if strcmp(answer, 'Yes')
						repeat = 1;
					else
						return;
					end
				end
				if isempty(pool) && repeat
					pool = 1:num_data_sets;
				end
				
				% Erzeugen einer Zufallszahl im Bereich [1, Anz._verf._Datensätze]
				fortu = round(rand()*(numel(pool)-1))+1;
				idx_hh_sel.(system.housholds{i,1})(j) = pool(fortu); % diesen Index in Indexliste aufnehmen
				% gezogenen Datensatz aus der Auswahlmöglickeit entfernen (damit er
				% nicht mehr gezogen werden kann):
				pool(fortu) = [];
			end
		otherwise
			disp('Unbekannter Auswahlmodus!');
			errordlg('Worst-Case not implemented yet!!!');
			return;
	end
	
	% die ermittelten Indizes sortieren (für effektiveres Abarbeiten):
	idx_hh_sel.(system.housholds{i,1}) = sort(idx_hh_sel.(system.housholds{i,1}));
end
clear repeat num_data_sets pool fortu answer number_hh

% Ein einzelner Datensatz soll ausgelesen werden...
fprintf('\n\tAuslesen der Lastdaten (für Einzeldurchlauf)...\n');
tic;
settin.Date_Extraktion = now;
households_av_typs = fields(idx_hh_sel);
% nun die einzelnen Datensätze aus den jeweiligen Teildateien laden:
for i=1:data_sets_number
	% Avoid Matlab "hang":
	drawnow(); pause(0.005);
	fprintf(['\t\tProcessing input set ',num2str(i),' of ',...
		num2str(data_sets_number),'...\n']);
	
	Data_Mean = [];
	% über die einzelnen Tage:
	for j=1:numel(data_sets_days)
		% durch alle Haushalte iterieren:
		data_loaded = 0;
		hh_counter = 0;
		for k=1:numel(households_av_typs)
			max_num_data_set = data_hh_content_per_set{k,2};
			idx = idx_hh_sel.(households_av_typs{k});
			% jene Indizes ermitteln, die in aktueller Teil-Datei enthalten sind
			idx_part = idx(idx > (i-1)*max_num_data_set & idx <= i*max_num_data_set);
			if isempty(idx_part)
				% sind keine Daten in für diesen Haushalt, die ausgelesen werden müssen, diese
				% überspringen:
				continue;
			end
			% Indexzahl korrigieren (der Index der geladenen Daten geht nur von
			% 1:max_num_datasets):
			idx_part = idx_part- (i-1)*max_num_data_set;
			if ~data_loaded
				% Nun die Daten laden und zusammenführen:
				[season, weekday] = day2sim_parameter(Model,data_sets_days(j));
				date = datestr(data_sets_days(j),'yyyy-mm-dd');
				% e.g. 15_12.52 - 1 - 2013-01-20 - Winter - Sunday - 10s.mat
				filename = [data_initial_string,data_sep,num2str(i),data_sep,...
					date,data_sep,season,data_sep,weekday,data_sep,...
					Model.Sim_Resolution,'.mat'];
				% "Result"
				load([Main_Path,filesep,filename]);
			end
			data_raw = Result.(households_av_typs{k});
			% 			Result = rmfield(Result, households_av_typs{k});
			data_raw = data_raw(:,idx_part,:);
			% adjust the data to the needed time resolution:
			switch data_typ
				case '_Mean'
					% get the number of timepoints to be treated:
					num_points = round(settin.Time_Resolution/data_time_base);
					num_time_points = 24*60*60/settin.Time_Resolution;
					if num_points <= 0
						errordlg('Time resolutions not campatible!!!');
						return;
					end
					for l=1:numel(idx_part)
						hh_data = squeeze(data_raw(:,l,:))';
						% 						data_raw(:,end,:) = [];
						hh_data = hh_data(1:end-1,[1 4 2 5 3 6]);
						if num_points > 1
							hh_data = reshape(hh_data,num_points,[],6);
							hh_data = squeeze(mean(hh_data));
						end
						if j == 1
							% Beginn der Zeitreihe
							Data_Mean = [Data_Mean, hh_data]; %#ok<AGROW>
							HH.Content{end+1} = households_av_typs{k};
						else
							% Zeitreihe wird fortgeführt:
							Data_Mean((j-1)*num_time_points+1:j*num_time_points,(hh_counter*6)+((l-1)*6+1:l*6)) = ...
								hh_data; %#ok<AGROW>
						end
					end
				otherwise
					disp('Unknown data typ!');
					errordlg('Data typ not implemented yet!!!');
					return;
			end
			hh_counter = hh_counter + numel(idx_part);
		end
	end
	HH.Data_Mean = [HH.Data_Mean, Data_Mean];
	t = toc;
	
	fprintf(['\t\t\t--> finished: Elapsed time: ',sec2str(t),', remaining time: ',...
		sec2str((data_sets_number-i)*t/i),', total time: ',...
		sec2str(t+(data_sets_number-i)*t/i),'\n']);
end

% also store the number of different households (the allocation) for later
% use:
HH.Number = settin.Households.Number;

d.Load_Infeed_Data.Set_1.Households = HH;
d.Load_Infeed_Data.Set_1.Solar = Solar;
d.Load_Infeed_Data.Set_1.El_Mobility = El_Mobility;
d.Load_Infeed_Data.Set_1.Table_Network = handles.Current_Settings.Table_Network;


Load_Infeed_Data = handles.NAT_Data.Load_Infeed_Data; %#ok<NASGU>

% Speicherort = aktulles Netzfile
file = handles.Current_Settings.Files.Auto_Load_Feed_Data;
% Check, if a Subfolder for input-data is avaliable:
file.Path = [handles.Current_Settings.Files.Grid.Path,filesep,...
	handles.Current_Settings.Files.Grid.Name,'_nat',filesep,...
	'Load_Infeed_Data',filesep,...
	datestr(settin.Date_Extraktion,'yyyy_mm_dd-HH.MM.SS')];
if ~isdir([file.Path])
	mkdir([file.Path]);
end
% Save the files (on load-infeed file and one settings file:
save([file.Path,filesep,file.Name,file.Exte],...
	'Load_Infeed_Data','-v7.3');
clear Load_Infeed_Data;

settin.Timepoints_per_dataset = num_time_points*numel(data_sets_days);
settin.Number_Data_Sets = 1;
settin.Time_Series.Date_Start = Model.Series_Date_Start;
settin.Time_Series.Duration = numel(data_sets_days);
handles.Current_Settings.Data_Extract = settin;
handles.Current_Settings.Simulation.Number_Runs = 1;
handles.Current_Settings.Simulation.Use_Grid_Variants = 0;
handles.Current_Settings.Simulation.Use_Scenarios = 0;

Data_Extract = settin; %#ok<NASGU>
System = handles.System; %#ok<NASGU>
save([file.Path,filesep,'Data_Settings.mat'],'Data_Extract','System');
handles.Current_Settings.Files.Auto_Load_Feed_Data = file;

helpdlg('Daten erfolgreich geladen!', 'Laden der Input-Daten...');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);
end

