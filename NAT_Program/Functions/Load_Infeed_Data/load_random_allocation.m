function handles = load_random_allocation(handles)
%LOAD_RANDOM_ALLOCATION Summary of this function goes here
%   Detailed explanation goes here

% Version:                 3.0
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 17.12.2014

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

% get the current settings:
Table_Network_old = handles.Current_Settings.Table_Network;
Data_Extract_old = handles.Current_Settings.Data_Extract;
% create new structures for alteration:
[Table_Network, Data_Extract] = network_table_reset(handles);

if isempty(Table_Network)
	error('load_random_allocation:NoGridLoaded','No grid is loaded!');
end

% some important data:
Table_ColumnName = Table_Network.ColumnName;
Table_Add_Column = Table_Network.Additional_Data_Content;
num_pq_nodes = size(Table_Network.Data,1);

% Set the the current time-settings:
if ~isempty(d.Simulation.Active_Scenario.Time.Season)
	% adjsut season setting:
	Data_Extract.Season = ...
		strcmp(handles.System.seasons(:,1),d.Simulation.Active_Scenario.Time.Season);
end
if ~isempty(d.Simulation.Active_Scenario.Time.Weekday)
	% adjust weekday setting:
	Data_Extract.Weekday = ...
		strcmp(handles.System.weekdays(:,1),d.Simulation.Active_Scenario.Time.Weekday);
end

if strcmp(handles.Current_Settings.Grid.Type, 'LV')
	% get the not to be changed settings in the table data back:
	
	% -----------------------------------------------------------------------------------
	% Zufällige Zuordnung der Haushalte zu den Anschlusspunkten treffen:
	% -----------------------------------------------------------------------------------
	% Where are the households in the Table_Network data:
	idx_hh_typ = strcmp(Table_ColumnName, 'Housh.type');
	% Where are the number of households in the Table_Network data?
	idx_hh_num = strcmp(Table_ColumnName, 'Hh. Number');
	% Where are the limitation of householdtyps marked (HH typ pool)?
	idx_hh_poo = strcmp(Table_Add_Column, 'HHs_Pool');
	% Where should the current selection of the households be stored?
	idx_hh_sel = strcmp(Table_Add_Column, 'HHs_Selection');
	
	% is there a limitation of the householdtyps present?
	idx_ad_hh_poo = ~cellfun(@isempty,Table_Network_old.Additional_Data(:,idx_hh_poo));
	num_ad_hh_poo = sum(idx_ad_hh_poo);
	all_equal = Data_Extract_old.Households.Selection_active_all;
	
	% Get the possible pool of householdtyps. Last entry in 'handles.System.housholds' is
	% only the marker that more typs of households can be connected here:
	poo_hh_typ = handles.System.housholds(1:end-1,:);
	
	% Die Verteilung der Haushalte umrechnen, um diese für die Zufallsauswahl
	% aufzubereiten, zunächst, falls alle Haushalte ausgewählt wurden (was den Standarfall
	% entspricht)
		if num_ad_hh_poo < num_pq_nodes && ~all_equal
		hh_dist_all = cell2mat(poo_hh_typ(:,3));
		hh_dist_all = 100*hh_dist_all/sum(hh_dist_all);
		for i = 2:numel(hh_dist_all)
			hh_dist_all(i) = hh_dist_all(i-1) + hh_dist_all(i);
		end
	end
	% Verteilung mit einer Einschränkung der Haushalte für alle gleich erstellen (nur,
	% wenn auch für alle Knoten eine Einschränkung getroffen wurde, ansonsten ist der
	% Fall, dass alle Haushalte herangezogen werden, was die obere Abfrage bereits
	% abdeckt!)
	if all_equal && num_ad_hh_poo == num_pq_nodes
		% Get the valid pool from the first row (all other are similar!):
		HHs_Selection = Table_Network_old.Additional_Data{1,idx_hh_poo};
		% Adatpt the possible pool (it's now limited for all):
		poo_hh_typ = poo_hh_typ(HHs_Selection,:);
		hh_dist_all = cell2mat(poo_hh_typ(:,3));
		hh_dist_all = 100*hh_dist_all/sum(hh_dist_all);
		for i = 2:numel(hh_dist_all)
			hh_dist_all(i) = hh_dist_all(i-1) + hh_dist_all(i);
		end
	end
	
	% Allocate Households:	
	for i=1:num_pq_nodes
		% how many are to connect to this node?
		num_hh = Table_Network_old.Data{i,idx_hh_num};
		HHs_Selection = Table_Network_old.Additional_Data{i,idx_hh_poo};
		Table_Network.Additional_Data{i,idx_hh_sel} = cell(1,num_hh);
		% based on the random number allocate household according to the additional
		% settings, first define, which probibilities and pool have to be used:
		if all_equal || isempty(HHs_Selection)
			% in this case, hh_dist_all can be used (because all nodes have the same
			% pool or the pool entry is empty a.k.a. all typs are in the pool:
			hh_dist = hh_dist_all;
			hh_pool = poo_hh_typ;
		else
			% othwise individual pools are present, so the distribution and available
			% pool has to be calculated here:
			hh_pool = poo_hh_typ(HHs_Selection,:);
			hh_dist = cell2mat(hh_pool(:,3));
			hh_dist = 100*hh_dist/sum(hh_dist);
			for j = 2:numel(hh_dist)
				hh_dist(j) = hh_dist(j-1) + hh_dist(j);
			end
		end
		% make the allocation:
		for j=1:num_hh
			% draw a random number from 0 to 100:
			fortu = ceil(rand()*100);
			% determine, which household equals that drawn number (out of the
			% probability):
			if fortu == 100
				idx = size(hh_pool,1);
			else
				idx = find(hh_dist >= fortu, 1);
			end
			% add this household to the selected ones:
			Table_Network.Additional_Data{i,idx_hh_sel}{j} = hh_pool{idx,1};
		end
		% Finally, set the selected typ in the network table if only ohne household is
		% present, otherwise to to various-tag. Addationally also copy the number of
		% households and pool limitation of the node...
		if num_hh == 1
			Table_Network.Data{i,idx_hh_typ} = Table_Network.Additional_Data{i,idx_hh_sel}{1,1};
		else
			Table_Network.Data{i,idx_hh_typ} = handles.System.housholds{end,1};
		end
		Table_Network.Data{i,idx_hh_num} = num_hh;
		Table_Network.Additional_Data{i,idx_hh_poo} = HHs_Selection;
	end
	
	% Anzahl der jeweiligen Haushalte ermitteln:
	Data_Extract.Households.Number = handles.System.housholds(1:end-1,1);
	[Data_Extract.Households.Number{:,end+1}] = deal(0); 
	for i=1:num_pq_nodes
		num_hh = Table_Network.Data{i,idx_hh_num};
		for j=1:num_hh
			hh_typ = Table_Network.Additional_Data{i,idx_hh_sel}{j};
			idx = strcmp(Data_Extract.Households.Number(:,1),hh_typ);
			Data_Extract.Households.Number{idx,2} = ...
				Data_Extract.Households.Number{idx,2} + 1;
		end
	end
	
	% set the current worst case.
	Data_Extract.Worstcase_Housholds = ...
		find(strcmp(...
		handles.System.wc_households(:,2),...
		d.Simulation.Active_Scenario.Households.WC_Selection),1);
	
	% -----------------------------------------------------------------------------------
	% Solaranlagen anordnen:
	% -----------------------------------------------------------------------------------
	% Where are the pv-plants in the Table_Network data:
	idx_pv = strcmp(Table_ColumnName, 'PV-Plant');
	% Where is the additional data?
	idx_pv_add = strcmp(Table_Add_Column, 'PV_Plant_Name');
	% get the settings:
	sola_settin = Data_Extract.Solar;
	% Get the current scenario settings:
	Solar = d.Simulation.Active_Scenario.Solar;
	
	% Wirkliche Anzahl der Anlagen ermitteln:
	Solar.Number = round(size(Table_Network.Data,1)*Solar.Number/100);
	
	% Index-Array erstellen, aus denen die Anschlusspunkte ausgewählt werden:
	row_idxes = 1:num_pq_nodes;
	
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
		Table_Network.Additional_Data{row_act,idx_pv_add} = name;
		
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
		
		Table_Network.Data{row_act,idx_pv} = long_na;
	end
	Data_Extract.Solar = sola_settin;
	
	% set the current worst case.
	Data_Extract.Worstcase_Generation = ...
		find(strcmp(...
		handles.System.wc_households(:,2),...
		d.Simulation.Active_Scenario.Solar.WC_Selection),1);
	
	% update the network table:
	Table_Network.ColumnFormat{idx_pv} = Data_Extract.Solar.Selectable(:,1)';
	
	% -----------------------------------------------------------------------------------
	% Elektrofahrzeugen einfügen:
	% -----------------------------------------------------------------------------------
	% Where are the emobility-settings in the Table_Network data:
	idx_em = strcmp(Table_ColumnName, 'El. Mob.');
	% Get the settings:
	El_Mobility = d.Simulation.Active_Scenario.El_Mobility;
	% get the real number of mobiles out of the share and number of connection
	% nodes:
	El_Mobility.Number = round(size(Table_Network.Data,1)*El_Mobility.Number/100);
	
	% Index-Array erstellen, aus denen die Anschlusspunkte ausgewählt werden:
	row_idxes = 1:num_pq_nodes;
	for i=1:El_Mobility.Number(1)
		% Zufällig Punkt auswählen, an den Anlage angeschlossen wird:
		idx = ceil(rand*numel(row_idxes));
		row_act = row_idxes(idx);
		row_idxes(idx)=[];
		Table_Network.Data{row_act,idx_em} = Table_Network.Data{row_act,idx_em} + 1;
	end
	
	% ermitteln, wieviele Elektrofahrzeuge gesamt im Netz enthalten sind:
	handles.Current_Settings.Data_Extract.El_Mobility.Number = ...
		sum(cell2mat(Table_Network.Data(:,idx_em)));
	
	% Add information, which got lost during the recreation of the network table:
	idx_pq_node_act = strcmp(Table_ColumnName, 'Active');
	Table_Network.Data(:,idx_pq_node_act) = Table_Network_old.Data(:,idx_pq_node_act);
	
elseif strcmp(handles.Current_Settings.Grid.Type, 'MV')
	% -----------------------------------------------------------------------------------
	% allocate LV-Grids:
	% -----------------------------------------------------------------------------------
	% Where are the LV-grids in the Table_Network data:
	idx_lv = strcmp(Table_ColumnName, 'LV-Grid');
	% how many possible grids are available?
	num_grds = numel(Data_Extract.LV_Grids_List);
	% Calculate distribution:
	dis_grds = 0:100/num_grds:100;
	dis_grds = dis_grds(2:end);
	
	for i=1:num_pq_nodes
		fortu = rand().*100;
		idx = find( fortu <= dis_grds, 1);
		Table_Network.Data{i,idx_lv} = Data_Extract.LV_Grids_List{idx,1};
	end
	
	% randomly allocate controllers:
	if handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active
		eq_lv = handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Equipment_Share;
		idx_emobc = strcmp(Table_Network.ColumnName, 'EMob Ctr.');
		
		if eq_lv > 0
			Table_Network.Data(:,idx_emobc) = num2cell(rand(1,size(Table_Network.Data,1)).*100 <= eq_lv);
		elseif eq_lv <= 0
			Table_Network.Data(:,idx_emobc) = num2cell(false(1,size(Table_Network.Data,1)));
		end
	end
end
	
if used_default
	% If default values were used, erase the created field, that it will
	% not occur further:
	d.Simulation = rmfield(d.Simulation, 'Active_Scenario');
end

% Save the altered Table Data:
handles.Current_Settings.Table_Network = Table_Network;
handles.Current_Settings.Data_Extract = Data_Extract;
end
