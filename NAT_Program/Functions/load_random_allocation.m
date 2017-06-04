function handles = load_random_allocation(handles)
%LOAD_RANDOM_ALLOCATION Summary of this function goes here
%   Detailed explanation goes here

% Version:                 2.3
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 17.10.2013

% Access to the data object:
d = handles.NAT_Data;
% Check, if an Scenario was selected, otherwise use the default settings,
% which are defined here (compare to function "get_scenarios"):
if ~isfield(d.Simulation, 'Active_Scenario')
	% no active Scenario, use default settings:
	d.Simulation.Active_Scenario = handles.System.default_scenario;
	% remember the case, that the default values were used!
	used_default = 1;
else
	used_default = 0;
end

% Clear the main Table:
[handles.Current_Settings.Table_Network, handles.Current_Settings.Data_Extract] = ...
	network_table_reset(handles);
Table_Data = handles.Current_Settings.Table_Network.Data;

% Set the the current time-settings:
if ~isempty(d.Simulation.Active_Scenario.Time.Season)
	% adjsut season setting:
	handles.Current_Settings.Data_Extract.Season = ...
		strcmp(handles.System.seasons(:,1),d.Simulation.Active_Scenario.Time.Season);
end
if ~isempty(d.Simulation.Active_Scenario.Time.Weekday)
	% adjust weekday setting:
	handles.Current_Settings.Data_Extract.Weekday = ...
		strcmp(handles.System.weekdays(:,1),d.Simulation.Active_Scenario.Time.Weekday);
end

if strcmp(handles.Current_Settings.Grid.Type, 'LV')
	% -----------------------------------------------------------------------------------
	% Zufällige Zuordnung der Haushalte zu den Anschlusspunkten treffen:
	% -----------------------------------------------------------------------------------
	% Where are the households in the Table_Network data:
	idx_hh = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Housh.type');
	% Die Verteilung der Haushalte umrechnen, um diese für die Zufallsauswahl
	% aufzubereiten:
	hh_distribution = cell2mat(handles.System.housholds(:,3));
	hh_distribution = 100*hh_distribution/sum(hh_distribution);
	for i = 2:numel(hh_distribution)
		hh_distribution(i) = hh_distribution(i-1) + hh_distribution(i);
	end
	
	for i=1:size(Table_Data,1)
		fortu = ceil(rand()*100);
		if fortu == 100
			idx = size(handles.System.housholds,1);
		else
			idx = find(hh_distribution >= fortu, 1);
		end
		Table_Data{i,idx_hh} = handles.System.housholds{idx,1};
	end
	
	% Anzahl der jeweiligen Haushalte ermitteln:
	for i=1:size(handles.System.housholds,1)
		handles.Current_Settings.Data_Extract.Households.(handles.System.housholds{i,1}).Number = ...
			sum(strcmp(handles.System.housholds{i,1},Table_Data(:,idx_hh)));
	end
	
	% set the current worst case.
	handles.Current_Settings.Data_Extract.Worstcase_Housholds = ...
		find(strcmp(...
		handles.System.wc_households(:,2),...
		d.Simulation.Active_Scenario.Households.WC_Selection),1);
	
	% -----------------------------------------------------------------------------------
	% Solaranlagen anordnen:
	% -----------------------------------------------------------------------------------
	% Where are the pv-plants in the Table_Network data:
	idx_pv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'PV-Plant');
	% Where is the additional data?
	idx_pv_add = strcmp(handles.Current_Settings.Table_Network.Additional_Data_Content, 'PV_Plant_Name');
	% get the settings:
	sola_settin = handles.Current_Settings.Data_Extract.Solar;
	add_data = handles.Current_Settings.Table_Network.Additional_Data;
	% Get the current scenarion settings:
	Solar = d.Simulation.Active_Scenario.Solar;
	
	% Wirkliche Anzahl der Anlagen ermitteln:
	Solar.Number = round(size(Table_Data,1)*Solar.Number/100);
	
	% Index-Array erstellen, aus denen die Anschlusspunkte ausgewählt werden:
	row_idxes = 1:size(Table_Data,1);
	
	% die Fix installierten Anlagen erzeugen:
	for i=1:Solar.Number(1)
		% Namen ermitteln, den die neue Anlage erhält:
		if isstruct(sola_settin.Plants)
			n_pl = numel(fieldnames(sola_settin.Plants));
			name = ['Plant_',num2str(n_pl+1)];
		else
			name = 'Plant_1';
		end
		% Default-Anlage hinzufügen:
		sola_settin.Plants.(name) = handles.System.sola.Default_Plant;
		% Zufällig Punkt auswählen, an den Anlage angeschlossen wird:
		idx = ceil(rand*numel(row_idxes));
		row_act = row_idxes(idx);
		row_idxes(idx)=[];
		add_data{row_act,idx_pv_add} = name;
		
		% Parameter der Anlage bestimmen:
		sola_settin.Plants.(name).Power_Installed = vary_parameter(Solar.Power_sgl, Solar.Power_sgl_dev);
		sola_settin.Plants.(name).Size_Collector = ...
			sola_settin.Plants.(name).Rel_Size_Collector * sola_settin.Plants.(name).Power_Installed;
		sola_settin.Plants.(name).Orientation = ...
			vary_parameter(Solar.mean_Orientation, Solar.dev_Orientation, 'Time');
		sola_settin.Plants.(name).Inclination = ...
			vary_parameter(Solar.mean_Inclination, Solar.dev_Inclination, 'Time');
		sola_settin.Plants.(name).Number = 1;
		sola_settin.Plants.(name).Efficiency = vary_parameter(Solar.Efficiency, Solar.dev_Efficiency);
		sola_settin.Plants.(name).Performance_Ratio = vary_parameter(Solar.Performance_Ratio, Solar.dev_Performance_Ratio);
		
		% Anlage der Auswahl hinzufügen:
		sola_settin.Selectable{end+1,1} = sola_settin.Selectable{end,1};
		sola_settin.Selectable{end-1,2} = name;
		
		typ = handles.System.sola.Typs{sola_settin.Plants.(name).Typ,1};
		long_na = [typ(1:4),' - ',...
			num2str(sola_settin.Plants.(name).Power_Installed),' kWp - ',...
			num2str(sola_settin.Plants.(name).Orientation),'° - ',...
			num2str(sola_settin.Plants.(name).Inclination),'°'];
		sola_settin.Selectable{end-1,1} = long_na;
		
		Table_Data{row_act,idx_pv} = long_na;
	end
	handles.Current_Settings.Data_Extract.Solar = sola_settin;
	
	% set the current worst case.
	handles.Current_Settings.Data_Extract.Worstcase_Generation = ...
		find(strcmp(...
		handles.System.wc_households(:,2),...
		d.Simulation.Active_Scenario.Solar.WC_Selection),1);
	
	% -----------------------------------------------------------------------------------
	% Elektrofahrzeugen einfügen:
	% -----------------------------------------------------------------------------------
	% Where are the emobility-settings in the Table_Network data:
	idx_em = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'El. Mob.');
	% Get the settings:
	El_Mobility = d.Simulation.Active_Scenario.El_Mobility;
	% get the real number of mobiles out of the share and number of connection
	% nodes:
	El_Mobility.Number = round(size(Table_Data,1)*El_Mobility.Number/100);
	
	% Index-Array erstellen, aus denen die Anschlusspunkte ausgewählt werden:
	row_idxes = 1:size(Table_Data,1);
	for i=1:El_Mobility.Number(1)
		% Zufällig Punkt auswählen, an den Anlage angeschlossen wird:
		idx = ceil(rand*numel(row_idxes));
		row_act = row_idxes(idx);
		row_idxes(idx)=[];
		Table_Data{row_act,idx_em} = Table_Data{row_act,idx_em} + 1;
	end
	
	% ermitteln, wieviele Elektrofahrzeuge gesamt im Netz enthalten sind:
	handles.Current_Settings.Data_Extract.El_Mobility.Number = ...
		sum(cell2mat(Table_Data(:,idx_em)));
	
	% update the network table:
	handles.Current_Settings.Table_Network.ColumnFormat{idx_pv} = sola_settin.Selectable(:,1)';
	handles.Current_Settings.Table_Network.Additional_Data = add_data;
	
elseif strcmp(handles.Current_Settings.Grid.Type, 'MV')
	% -----------------------------------------------------------------------------------
	% allocate LV-Grids:
	% -----------------------------------------------------------------------------------
	% Where are the LV-grids in the Table_Network data:
	idx_lv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
	% how many possible grids are available?
	num_grds = numel(handles.Current_Settings.Data_Extract.LV_Grids_List);
	% Calculate distribution:
	dis_grds = 0:100/num_grds:100;
	dis_grds = dis_grds(2:end);
	
	for i=1:size(Table_Data,1)
		fortu = rand().*100;
		idx = find( fortu <= dis_grds, 1);
		Table_Data{i,idx_lv} = handles.Current_Settings.Data_Extract.LV_Grids_List{idx,1};
	end
	
	% randomly allocate controllers:
	if handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active
		eq_lv = handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Equipment_Share;
		idx_emobc = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'EMob Ctr.');
		
		if eq_lv > 0
			Table_Data(:,idx_emobc) = num2cell(rand(1,size(Table_Data,1)).*100 <= eq_lv);
		elseif eq_lv <= 0
			Table_Data(:,idx_emobc) = num2cell(false(1,size(Table_Data,1)));
		end
	end
	
	if used_default
		% If default values were used, erase the created field, that it will
		% not occur further:
		d.Simulation = rmfield(d.Simulation, 'Active_Scenario');
	end
end

% Save the altered Table Data:
handles.Current_Settings.Table_Network.Data = Table_Data;
