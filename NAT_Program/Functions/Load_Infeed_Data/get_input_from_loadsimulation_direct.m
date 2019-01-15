function handles = get_input_from_loadsimulation_direct(handles)
%PUSH_INPUT_DATA_LOADSIMULATION_LOAD_DIRECT_CALLBACK_ADD Summary of this function goes here
% hObject    handle to push_input_data_loadsimulation_load_direct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% BETA

d = handles.NAT_Data;

data_typ = '_Mean';

Main_Path_HH_Data = uigetdir([handles.Current_Settings.Files.Grid.Path,filesep,...
	handles.Current_Settings.Files.Grid.Name,'_nat'],...
	'Selcet folder with load simulation data...');
if ischar(Main_Path_HH_Data)
	% Check, if simulation data files are present in this folder:
	files = dir(Main_Path_HH_Data);
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
		'Only the first one will be processed, the other ones are ignored! '];' ';...
		['If this behaviour is not wanted please move the desired data in',...
		' a seperate folder...']},'Selcet folder with "Load-Simulation-Data"...',...
		'Continue','Abort','Continue');
end

switch but
	case 'Abort'
		return;
end

Main_Path_Solar_Data = uigetdir([handles.Current_Settings.Files.Grid.Path,filesep,...
	handles.Current_Settings.Files.Grid.Name,'_nat'],...
	'Selcet folder with solar irradiation data...');
error_solar = 0;
if ischar(Main_Path_Solar_Data)
	% Check, if simulation data files are present in this folder:
	files_solar = dir(Main_Path_Solar_Data);
	files_solar = struct2cell(files_solar);
	files_solar = files_solar(1,3:end);
	
	idx_db_set = find(strcmp(files_solar,'EDLEM_Datenbank.mat'), 1);
	
	if isempty(idx_db_set)
		error_solar = 1;
	end
else
	error_solar = 1;
end

if error_solar
	% Ask user, if data preperation should be proceeded without solar data:
	but = questdlg({'No irradiation for consideration of PV-plants found!';' ';...
		'Should the input data preperation continue only with load data?'},...
		'Selcet folder with irradiation data...',...
		'Continue','Abort','Abort');
	switch but
		case 'Continue'
			Main_Path_Solar_Data = [];
			error_solar = 0;
		case 'Abort'
			return;
	end
	
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
Solar.Plants = settin.Solar.Plants;

El_Mobility = HH;

HH.Content = {};

% load the model data for further information:
% loading structures 'Model', 'Configuration', 'Time', 'Households'
load([Main_Path_HH_Data,filesep,model_files{1}], 'Model', 'Configuration', 'Time', 'Households');

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
				% 'Result'
				load([Main_Path_HH_Data,filesep,filename],'Result');
			end
			data_raw = Result.(households_av_typs{k});
			% 			Result = rmfield(Result, households_av_typs{k});
			data_raw = data_raw(:,idx_part,:);
			% adjust the data to the needed time resolution:
			if settin.get_Mean_Value
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
			else
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
d.Load_Infeed_Data.Set_1.Households = HH;

% also store the number of different households (the allocation) for later
% use:
HH.Number = settin.Households.Number;
d.Load_Infeed_Data.Set_1.Households = HH;

% now proceed the solar data:
if ~isempty(Main_Path_Solar_Data)
	% load the database structure:
	db_fil = load([Main_Path_Solar_Data, filesep, files_solar{idx_db_set}]);
	sep = db_fil.files.sep;    % Trenner im Dateinamen (' - ')
	max_num_data_set = db_fil.setti.max_num_data_set*6;
	
	% Sind überhaupt Solaranlagen angelegt?
	if isempty(settin.Solar.Plants)
		% --> Nein, es müssen daher keine Daten ausgelesen werden:
		% (leeres) Ergebnis zurückschreiben:
		
		% Es wird nur ein Datensatz generiert, diese Direkt in die
		% Load-Infeed-Struktur einfügen:
		d.Load_Infeed_Data.Set_1.Solar = Solar;
		error_solar = 1;
		if ~isfield(d.Load_Infeed_Data.Set_1, 'Table_Network')
			d.Load_Infeed_Data.Set_1.Table_Network = table_;
		end
	end
	
	% Gesamtanzahl der zu simulierenden Anlagen ermitteln:
	plants = fieldnames(settin.Solar.Plants);
	number_plants = 0;
	for i=1:numel(plants)
		plant = settin.Solar.Plants.(plants{i});
		number_plants = number_plants + plant.Number;
	end
	
	% Überprüfen, ob überhaupt PV-Erzeugungsanlagen verarbeitet werden sollen:
	if number_plants == 0
		% (leeres) Ergebnis zurückschreiben:
		
		% Es wird nur ein Datensatz generiert, diese Direkt in die
		% Load-Infeed-Struktur einfügen:
		d.Load_Infeed_Data.Set_1.Solar = Solar;
		error_solar = 1;
		if ~isfield(d.Load_Infeed_Data.Set_1, 'Table_Network')
			d.Load_Infeed_Data.Set_1.Table_Network = table_;
		end
	end
else
	error_solar = 1;
end

if ~error_solar
	%create solar infeed data, first determine the solar irradiation data:
	% Aus den allgemeinen Strahlungsdaten und den Analgenparametern die aktuellen
	% Einstrahlungswerte interpolieren, dazu erst die entsprechenden Daten laden:
	name = ['Gene',sep,'Solar',sep,'Radiation'];
	% Daten laden (Variable 'radiation_data_fix' und 'Content'):
	load([Main_Path_Solar_Data,filesep,name,'.mat'],'radiation_data_fix','Content');
	
	% Aufbau des Arrays für geneigte Flächen (fix montiert, 'radiation_data_fix'):
	% 1. Dimension: Tag innerhalb eines Jahres (von 1.1 bis 31.12. 365 Tage)
	% 2. Dimension: Orientierung z.B. [-15°, 0°, 15°] (0° = Süd; -90° = Ost)
	% 3. Dimension: Neigung [15°, 30°, 45°, 60°, 90°] (0°  = waagrecht,
	%                                                        90° = senkrecht,
	%                                                        trac = Tracker)
	% 4. Dimension: Datenart [Zeit, Temperatur, Direkt, Diffus]
	% 5. Dimension: Werte in W/m^2 in Minutenauflösung
	%
	% Die Struktur "Content" enthält die korrekten Bezeichnungen/Werte der einzelnen
	% Dimensionen für die spätere Weiterverarbeitung (für Indexsuche bzw.
	% Interpolationen). Aufbau siehe: 'create_radiation_array.m'
	
	% Ein Datumsarray erstellen, um auf die Solardaten zugreifen zu können:
	solar_data_sets_days = 0:364;
	year = datenum(datestr(data_sets_days(1),'yyyy'),'yyyy');
	solar_data_sets_days = solar_data_sets_days + year;
	
	% Überprüfen, ob die Tag vorhanden sind, ansonsten Array duplizieren:
	while error_solar || (isempty(find(solar_data_sets_days == data_sets_days(1),1)) && ...
			isempty(find(solar_data_sets_days == data_sets_days(end),1)))
		if data_sets_days(1) < solar_data_sets_days(1)
			errordlg({'Radiation Data has not enough days';...
				'Extension has to be implemented!'},...
				'Perepare PV-Infeed data...');
			error_solar = 1;
		end
		
		if solar_data_sets_days(end) < data_sets_days(end)
			errordlg({'Radiation Data has not enough days';...
				'Extension has to be implemented!'},...
				'Perepare PV-Infeed data...');
			error_solar = 1;
		end
	end
	
	num_data_sets = [];
	data_info_sol = [];
	idx_so_dat = [];
	for i=1:numel(data_sets_days)
		[season, ~, ~] = day2sim_parameter(Model, data_sets_days(i));
		if ~isfield(num_data_sets, season)
			name = ['Gene',sep,season,sep,'Solar',sep,'Cloud_Factor',sep,'Info'];
			% Daten laden (Variable 'data_info')
			load([Main_Path_Solar_Data,filesep,name,'.mat'],'data_info');
			% wieviele Datensätze gibt es insgesamt?
			num_data_sets.(season) = size(data_info,2);
			data_info_sol.(season) = data_info;
			idx_so_dat.(season) = [];
			pool.(season) = 1:num_data_sets.(season); % Liste mit Indizes der möglichen Datensätze
		end
		
		% je nach Einstellungen die Wetterdaten des aktuellen Tages einlesen:
		switch settin.Worstcase_Generation
			case 1 % zufällige Auswahl
				% Zufällig einen Wolkendatensatz auswählen:
				% Erzeugen einer Zufallszahl im Bereich [1, Anz._verf._Datensätze]
				fortu = round(rand()*(numel(pool.(season))-1))+1;
				idx_so_dat.(season)(end+1) = pool.(season)(fortu);% Dieser Index bezeichnet den ausgewählten Datensatz!
				pool.(season)(fortu) = [];
			otherwise
				disp('Unbekannter Auswahlmodus!');
				errordlg('Worst-Case not implemented yet!!!');
				error_solar = 1;
		end
	end
end
clear pool fortu year name

if ~error_solar
	idx_counter = [];
	Solar.Content = cell(1,number_plants);
	Data_Mean = [];
	for i=1:numel(data_sets_days)
		Content_count = 1;
		% ermitteln des Wolkendatensatzes, der geladen werden muss, dazu zunächst den
		% Index auslesen:
		[season, ~, ~] = day2sim_parameter(Model, data_sets_days(i));
		if ~isfield(idx_counter, season)
			idx_counter.(season) = 1;
		end
		idx = idx_so_dat.(season)(idx_counter.(season));
		idx_counter.(season) = idx_counter.(season) + 1;
		% ermitteln, in welchem Wolkendatensatz dieser enthalten ist:
		j = ceil(idx/max_num_data_set);
		% Indexzahl korrigieren (der Index der geladenen Daten geht nur von
		% 1:max_num_datasets je Datei):
		idx_part = idx - (j-1)*max_num_data_set;
		% Name der aktuellen Teil-Datei:
		name = ['Gene',sep,season,sep,'Solar',sep,'Cloud_Factor',sep,...
			num2str(j,'%03.0f')];
		% Daten laden (Variable 'data_cloud_factor')
		load([Main_Path_Solar_Data,filesep,name,'.mat'],'data_cloud_factor');
		% die relevanten Daten auslesen:
		data_cloud_factor = data_cloud_factor(:,idx_part);
		
		% Welcher Tag in der Einstrahlungsmatrix wird gerade simuliert?
		day_solar = find(data_sets_days(1) == solar_data_sets_days);
		
		% nun stehen für die Anlagen jeweils Einstrahlungsdaten sowie Wolkeneinflussdaten zur
		% Verfügung. Mit diesen Daten sowie den definierten Anlagenparametern werden nun die
		% Anlagen simuliert:
		for k=1:numel(plants)
			plant = settin.Solar.Plants.(plants{k});
			% Inhaltsverzeichnis der Daten erstellen:
			if i == 1

			end
			switch plant.Typ
				case 1 % Fix installierte Anlage
					data_phase = model_pv_fix_yearly_profiles(plant, Content,...
						data_cloud_factor, radiation_data_fix, day_solar);
				otherwise % Tracker
					errordlg('Plant-Type not implemented yet!!!');
					error_solar = 1;
			end
			
			% adjust the data to the needed time resolution:
			switch data_typ
				case '_Mean'
					% get the number of timepoints to be treated:
					num_points = round(settin.Time_Resolution/1);
					num_time_points = 24*60*60/settin.Time_Resolution;
					if num_points <= 0
						errordlg('Time resolutions not campatible!!!');
						return;
					end
					if num_points > 1
						data_phase = data_phase(1:end-1,:);
						data_phase = reshape(data_phase,num_points,[],6);
						data_phase = squeeze(mean(data_phase));
					end
					
					if i == 1
						for j=1:plant.Number
							Solar.Content{1,Content_count} = plants{k};
							Content_count = Content_count + 1;
						end
						
						% Beginn der Zeitreihe
						Data_Mean = [Data_Mean, data_phase]; %#ok<AGROW>
					else
						for j=1:plant.Number
							% Zeitreihe wird fortgeführt:
							Data_Mean((i-1)*num_time_points+1:i*num_time_points,((Content_count-1)*6)+(1:6)) = ...
								data_phase; %#ok<AGROW>
							Content_count = Content_count + 1;
						end
					end
				otherwise
					disp('Unknown data typ!');
					errordlg('Data typ not implemented yet!!!');
					return;
			end
		end
	end
end
if ~error_solar
	Solar.Data_Mean = Data_Mean;
end

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
if ~isfolder([file.Path])
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

Data_Extract = settin;
System = handles.System; %#ok<NASGU>
save([file.Path,filesep,'Data_Settings.mat'],'Data_Extract','System');
handles.Current_Settings.Files.Auto_Load_Feed_Data = file;
handles.Current_Settings.Data_Extract = Data_Extract;
end

