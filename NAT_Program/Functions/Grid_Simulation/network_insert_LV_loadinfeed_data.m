function nd = network_insert_LV_loadinfeed_data(nd, cg, data_typ, dataset_counter)
%NETWORK_INSERT_LOADINFEED_DATA   inserts the load and infeed data into the grid objects
%   Detailed explanation goes here

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 11.07.2018
% Letzte Änderung durch:

%----------------------------------------------------------------------------
% Übernehmen der akutell geladenen Daten:
%----------------------------------------------------------------------------
Load_Data = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Households.(['Data',data_typ]);
Sola_Data = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Solar.(['Data',data_typ]);
Elmo_Data = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).El_Mobility.(['Data',data_typ]);
cur_set.Table_Network = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Table_Network;

% % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% 		% Debug: generate debug input data:
% 		if dataset_counter==1
% 			factor = 1;
% 		elseif dataset_counter==2;
% 			factor = 1.25;
% 		else
% 			factor = 3;
% 		end
%
% 		% Debug: set all Values to zero:
% 		Load_Data = zeros(size(Load_Data));
% 		Sola_Data = zeros(size(Sola_Data));
% 		Elmo_Data = zeros(size(Elmo_Data));
% 		LVGr_Data = zeros(size(LVGr_Data));
%
% 		idx = 0:15;
%
% 		idx_1 = [(0:71),(72:-1:1)]';
% 		idx_1 = idx_1 / max(idx_1);
% 		idx_2 = [(71:-1:0),(1:1:72)]';
% 		idx_2 = idx_2 / max(idx_2);
% 		idx_3 = [idx_1(50:end);idx_1(1:49)];
% 		%figure;plot([idx_1,idx_2,idx_3]);
% 		Elmo_Data(:,idx*6+1) = repmat(idx_1,1,size(Elmo_Data(:,idx*6+1),2))*25000*factor;
% 		Elmo_Data(:,idx*6+3) = repmat(idx_2,1,size(Elmo_Data(:,idx*6+3),2))*25000*factor;
% 		Elmo_Data(:,idx*6+5) = repmat(idx_3,1,size(Elmo_Data(:,idx*6+5),2))*25000*factor;
% 		%figure;plot(Elmo_Data(:,[1 3 5]+18));
%
% 		Load_Data(:,1:6:end) = ones(size(Load_Data(:,1:6:end))) * 30000;
% 		Load_Data(:,3:6:end) = ones(size(Load_Data(:,1:6:end))) * 30000;
% 		Load_Data(:,5:6:end) = ones(size(Load_Data(:,1:6:end))) * 30000;
% 		LVGr_Data = Load_Data + Elmo_Data;
% 		%figure;plot(LVGr_Data(:,[1 3 5]));
% % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if ~isempty(Load_Data)
	[Load_Data, Sola_Data, Elmo_Data] = adapt_input_data(Load_Data, Sola_Data, Elmo_Data);
end

% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% 		% Quick Add-in: If a day is simulated in seconds resolution, just simulate a
% 		% few hours:
% 		curtailed_data = false;
% 		if size(Load_Data,1) > 86000
% 			curtailed_data = true;
% 			% section of day to be simulated in h:
% 			time_start = 7;
% 			time_end = time_start + 6;
% 			time_start = time_start*60*60;
% 			time_end = time_end*60*60;
% 			Load_Data = Load_Data(time_start:time_end,:);
% 			dat_ext.Time_Series.Date_Start = time_start/(24*60*60);
% 			dat_ext.Time_Series.Duration = (time_end - time_start)/(24*60*60);
% 			dat_ext.Timepoints_per_dataset = size(Load_Data,1);
% 		end
% 		dat_ext.Time_Series.curtailed_data = curtailed_data;
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Save the maybe altered Data for the OAT-Programm:
nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Households.(['Data',data_typ]) = Load_Data;
nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Solar.(['Data',data_typ]) = Sola_Data;
nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).El_Mobility.(['Data',data_typ]) = Elmo_Data;

if isempty(Load_Data) && isempty(Elmo_Data) && isempty(Sola_Data)
	errorstr = 'Not enough input-Data for simulation!';
	errordlg(errorstr);
	mh.add_error(errorstr);
	exception = MException(...
		'NAT:NetworkCalculationLV:NotEnoughInputData',...
		errorstr);
	throw(exception);
end

% Die Daten an SINCAL anpassen (Leistungen in MW und pos. bei Verbrauch):
Load_Data = Load_Data/1e6;
Elmo_Data = Elmo_Data/1e6;
Sola_Data = Sola_Data/-1e6; %Einspeiser negativ!

% Resetting the connection points:
nd.Grid.(cg).P_Q_Node.Points.reset_connections;
% add needed empty fields:
nd.Grid.(cg).Sola.Gen_Units = Unit_Time_Dependent.empty(0,0);
nd.Grid.(cg).Load.Elmob = Unit_Time_Dependent.empty(0,0);
%------------------------------------------------------------------------
% Haushalts-Lasten ins Netz einfügen:
%------------------------------------------------------------------------
% get important information, first content of the loaded profiles
hh_conten = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Households.Content;
% total number of present households:
hh_num_to = numel(hh_conten);
% number of households per typ:
hh_number = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Households.Number;
% where are the PQ-Node names in the network table?
idx_pq_na = strcmp(cur_set.Table_Network.ColumnName, 'Names');
% where are the number of households of the node?
idx_hh_nu = strcmp(cur_set.Table_Network.ColumnName, 'Hh. Number');
% where in the additional table are the household typs?
idx_hh_ty = strcmp(cur_set.Table_Network.Additional_Data_Content, 'HHs_Selection');

% create emtpy instances of the Class Unit_Time_Dependet according to the number
% of households to be connected:
nd.Grid.(cg).Load.Loads = Unit_Time_Dependent.empty(0,hh_num_to);

% go through all P_Q_Nodes and connect the household loads to them according to
% their number and typ selection:
load_counter = 1; % counter for load-objects
for i=1:numel(nd.Grid.(cg).P_Q_Node.ids)
	% where ist the entry of the current point in the network table?
	pq_name = nd.Grid.(cg).P_Q_Node.Points(i).P_Q_Name;
	idx_pq_nt = strcmp(cur_set.Table_Network.Data(:,idx_pq_na),pq_name);
	% How many Households have to be connected at that point?
	hh_pq_num = cur_set.Table_Network.Data{idx_pq_nt,idx_hh_nu};
	
	% go through all households at that point
	for l=1:hh_pq_num
		% Welcher Haushaltstyp soll angeschlossen werden?
		hh_typ = cur_set.Table_Network.Additional_Data{idx_pq_nt,idx_hh_ty}{l};
		% get the positions of the data of the households of this type
		idx = find(strcmp(hh_typ,hh_conten));
		% how many of these households have to be connected?
		idx_hh_typ_number = strcmp(hh_number(:,1),hh_typ);
		hh_typ_number = hh_number{idx_hh_typ_number,2};
		
		% according to the remaining number of housholds to be connected select
		% the last dataset of this typ (to ensure, that every dataset is only
		% connected to onnce!
		idx = idx(hh_typ_number);
		% Last-Instanz erzeugen und dem Objektarray hinzufügen:
		obj = Unit_Time_Dependent(...
			nd.Grid.(cg).P_Q_Node.Points(i),...         % Anschlusspunkt-Objekt
			true, ...                                  % Objekt aktiv
			Load_Data(:,((idx-1)*6)+1:((idx-1)*6)+6)); % Lastgang des Last
		nd.Grid.(cg).Load.Loads(load_counter) = obj;
		
		% 				disp([num2str(k),': ',nd.Grid.(cg).P_Q_Node.Points(k).P_Q_Name,' --> '...
		% 					,hh_typ,'(',num2str(l),')']);
		
		%incread counter for load objects and decrease number of households of
		%this typ to be connected:
		load_counter = load_counter + 1;
		hh_typ_number = hh_typ_number - 1;
		hh_number{idx_hh_typ_number,2} = hh_typ_number;
	end
end
clear hh_conten hh_num_to hh_number load_counter l k pq_name hh_pq_num hh_typ obj
clear idx_hh_nu idx_hh_ty idx_pq_na idx_pq_nt idx idx_hh_typ_number hh_typ_number
%------------------------------------------------------------------------
% Elektrofahrzeuge einfügen:
%------------------------------------------------------------------------
if ~isempty(Elmo_Data)
	elm_num = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).El_Mobility.Number;
	elm_count = 0;
	nd.Grid.(cg).Load.Elmob = Unit_Time_Dependent.empty(0,elm_num);
	idx_em = strcmp(...
		cur_set.Table_Network.ColumnName,...
		'El. Mob.');
	for i=1:numel(nd.Grid.(cg).P_Q_Node.ids)
		% Wieviele Fahrzeuge sollen hier angeschlossen werden?
		elmoby = cur_set.Table_Network.Data{i,idx_em};
		% Elektromobilitätsinstanz erzeugen:
		for l=1:elmoby
			obj = Unit_Time_Dependent(...
				nd.Grid.(cg).P_Q_Node.Points(i),...             % Anschlusspunkt-Objekt
				true,...                                       % Objekt inaktiv
				Elmo_Data(:,(elm_count*6)+1:(elm_count*6)+6)); % Lastgang des Last
			elm_count = elm_count + 1;
			nd.Grid.(cg).Load.Elmob(elm_count) = obj;
		end
	end
end
%------------------------------------------------------------------------
% Erzeuger einfügen
%------------------------------------------------------------------------
if ~isempty(Sola_Data)
	add_data = cur_set.Table_Network.Additional_Data;
	idx_pv_add = strcmp(...
		cur_set.Table_Network.Additional_Data_Content,...
		'PV_Plant_Name');
	num_unit = size(Sola_Data,2)/6;
	nd.Grid.(cg).Sola.Gen_Units = Unit_Time_Dependent.empty(0,num_unit);
	plants =  nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Solar.Plants;
	gen_count = 1;
	for i=1:numel(nd.Grid.(cg).P_Q_Node.ids)
		gen_unit_name = add_data{i,idx_pv_add};
		if isempty(gen_unit_name)
			continue;
		end
		idx = find(strcmp(gen_unit_name,nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Solar.Content));
		idx = idx(plants.(gen_unit_name).Number) - 1;
		plants.(gen_unit_name).Number = plants.(gen_unit_name).Number - 1;
		% Last-Instanz erzeugen:
		obj = Unit_Time_Dependent(...
			nd.Grid.(cg).P_Q_Node.Points(i),...       % Anschlusspunkt-Objekt
			true,...                                 % Objekt aktiv
			Sola_Data(:,(idx*6)+1:(idx*6)+6));       % Lastgang des Last
		nd.Grid.(cg).Sola.Gen_Units(gen_count) = obj;
		gen_count = gen_count + 1;
	end
	clear k gen_count obj gen_unit_name add_data idx_pv_add num_unit plants
end
end

