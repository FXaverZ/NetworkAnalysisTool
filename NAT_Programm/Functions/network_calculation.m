function handles = network_calculation(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 2.1
% Erstellt von:            Franz Zeilinger - 05.02.2013
% Letzte Änderung durch:   Matej Rejc     - 29.04.2013

% Zugriff auf Datenobjekt:

d = handles.NAT_Data;

if ~(handles.Current_Settings.Simulation.Voltage_Violation_Analysis || ...
		handles.Current_Settings.Simulation.Branch_Violation_Analysis || ...
		handles.Current_Settings.Simulation.Power_Loss_Analysis)
	fprintf('\nNo active analysis function! Abort simulation...\n')
	return;
end

% getting infos about the grids to be simulated:
Grid_List = handles.Current_Settings.Simulation.Grid_List;
Grids_Path = handles.Current_Settings.Simulation.Grids_Path;
% If just one grid has to be simulated, adopt the informations of this one
% grid:
if isempty(handles.Current_Settings.Simulation.Grid_List)
	Grid_List{1} = [handles.Current_Settings.Files.Grid.Name,...
		handles.Current_Settings.Files.Grid.Exte];
	Grids_Path = handles.Current_Settings.Files.Grid.Path;
end

handles.Current_Settings.Files.Grid.Path = Grids_Path;

% -- changelog v1.1b ##### (start) // 20130430
if ~handles.Current_Settings.Simulation.Use_Scenarios
    % If scenarios are not used
    % Create path to results (Netze folder\Results)
    r_path = [handles.Current_Settings.Files.Grid.Path,filesep,'Results'];
    if ~isdir(r_path);
        mkdir(r_path);
    end    
    handles.Current_Settings.Files.Save.Result.Path = r_path;
    % Name of result file
    simdate = datestr(now,'yyyy-mm-dd_HH-MM-SS');    
    handles.Current_Settings.Files.Save.Result.Name = ['Res_',simdate,' - no_scenario'];

    handles.Current_Settings.Files.Save.Result.Scen_info = ...
            ['Res_',simdate,' - information'];
    % Save result information file (variants, number of datasets,
    % scenario=[])
    create_scenario_information(handles);
end
% -- changelog v1.1b ##### (end) // 20130430  

fprintf('\nStarte Netz-Simulationen...\n');
for i=1:numel(Grid_List)
	handles.Current_Settings.Files.Grid.Name = Grid_List{i}(1:end-4);
    
	% load the network data:
	handles = network_load (handles);
	
	% current grid name
	cg = handles.sin.Settings.Grid_name;
	
	fprintf(['Starte Netz-Simulation ',num2str(i)',' von ',num2str(numel(Grid_List)),...
		'\n']);
	
	% create an empty network substrucure for the results:
	d.Result.(cg) = [];
	% Clear the previous simulation information:
	d.Simulation = [];
	
	tic; %Zeitmessung start
	for j=1:handles.Current_Settings.Simulation.Number_Runs;
		%----------------------------------------------------------------------------
		% Übernehmen der akutell geladenen Daten:
		%----------------------------------------------------------------------------
		if handles.Current_Settings.Data_Extract.get_Max_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_Max;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_Max;
			Elmo_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility.Data_Max;
		end
		if handles.Current_Settings.Data_Extract.get_Min_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_Min;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_Min;
			Elmo_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility.Data_Min;
		end
		if handles.Current_Settings.Data_Extract.get_Sample_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_Sample;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_Sample;
			Elmo_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility.Data_Sample;
		end
		if handles.Current_Settings.Data_Extract.get_Mean_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_Mean;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_Mean;
			Elmo_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility.Data_Mean;
% 			DEBUG: linear increasing Load, only active Power
% 			Load_Data = zeros(size(Load_Data));
% 			Load_Data(:,1:2:end) =...
% 				repmat((500:(3000-500)/(size(Load_Data,1)):3000-1),size(Load_Data,2)/2,1)';
% 			
% 			Sola_Data = zeros(size(Sola_Data));
% % 			Sola_Data(:,1:2:end)=...
% % 				repmat((0:2000/size(Sola_Data,1):2000-1),size(Sola_Data,2)/2,1)';
% 			
% 			Elmo_Data = zeros(size(Sola_Data));
		end
		if handles.Current_Settings.Data_Extract.get_05_Quantile_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_05P_Quantil;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_05P_Quantil;
			Elmo_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility.Data_05P_Quantil;
		end
		if handles.Current_Settings.Data_Extract.get_95_Quantile_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_95P_Quantil;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_95P_Quantil;
			Elmo_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility.Data_95P_Quantil;
		end
		
		% Die Daten an SINCAL anpassen (Leistungen in MW und pos. bei Verbrauch):
		Load_Data = Load_Data/1e6;
		Elmo_Data = Elmo_Data/1e6;
		Sola_Data = Sola_Data/-1e6; %Einspeiser negativ!
		% Wieviele Zeitpunkte werden berechnet?
		handles.Current_Settings.Simulation.Timepoints = size(Load_Data,1);
		
		% Reloading the Settings of the Network:
		handles.Current_Settings.Table_Network = d.Load_Infeed_Data.(['Set_',num2str(j)]).Table_Network;
		
		% Resetting the connection points:
		d.Grid.(cg).P_Q_Node.Points.reset_connections;
		
		%--------------------------------------------------------------------------------
        % Result preallocation
        %--------------------------------------------------------------------------------
        % Options for result preallocation are currently defined within
        % result_preallocation function
        if j == 1
            % We predefine the results for all datasets for specific (cg)
            % grid at first dataset iteration
            handles = result_preallocation(handles,cg); 
            
            % -- changelog v1.1b ##### (start) // 20130506
            % Add an error-counter array
            d.Result.(cg).Error_Counter = zeros(handles.Current_Settings.Simulation.Number_Runs, handles.Current_Settings.Simulation.Timepoints);
            % -- changelog v1.1b ##### (end) // 20130506
        end        
		
				
		%--------------------------------------------------------------------------------
		% Lasten ins Netz einfügen:
		%--------------------------------------------------------------------------------
		d.Grid.(cg).Load.Loads = Unit_Time_Dependent.empty(0,numel(d.Grid.(cg).P_Q_Node.ids));
		hhs = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Number;
		for k=1:numel(d.Grid.(cg).P_Q_Node.ids)
			% Welcher Haushaltstyp soll angeschlossen werden?
			hh_typ = handles.Current_Settings.Table_Network.Data{k,2};
			idx = find(strcmp(hh_typ,d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Content));
			idx = idx(hhs.(hh_typ).Number)-1;
			hhs.(hh_typ).Number = hhs.(hh_typ).Number - 1;
			% Last-Instanz erzeugen:
			obj = Unit_Time_Dependent(...
				d.Grid.(cg).P_Q_Node.Points(k),...                   % Anschlusspunkt-Objekt
				Load_Data(:,(idx*6)+1:(idx*6)+6));       % Lastgang des Last
			% 	disp([Grid.P_Q_Node.Points(i).P_Q_Name,' --> ',hh_typ]);
			d.Grid.(cg).Load.Loads(k) = obj;
		end
		%----------------------------------------------------------------------------
		% Elektrofahrzeuge einfügen:
		%----------------------------------------------------------------------------
		if ~isempty(Elmo_Data)
			elm_num = d.Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility.Number;
			elm_count = 0;
			d.Grid.(cg).Load.Elmob = Unit_Time_Dependent.empty(0,elm_num);
			for k=1:numel(d.Grid.(cg).P_Q_Node.ids)
				% Wieviele Fahrzeuge sollen hier angeschlossen werden?
				elmoby = handles.Current_Settings.Table_Network.Data{k,4};
				% Elektromobilitätsinstanz erzeugen:
				for l=1:elmoby
					obj = Unit_Time_Dependent(...
						d.Grid.(cg).P_Q_Node.Points(k),...             % Anschlusspunkt-Objekt
						Elmo_Data(:,(elm_count*6)+1:(elm_count*6)+6)); % Lastgang des Last
					elm_count = elm_count + 1;
					d.Grid.(cg).Load.Elmob(elm_count) = obj;
				end
			end
		else
			d.Grid.(cg).Load.Elmob = Unit_Time_Dependent.empty(0,0);
		end
		%----------------------------------------------------------------------------
		% Erzeuger einfügen
		%----------------------------------------------------------------------------
		if ~isempty(Sola_Data)
			add_data = handles.Current_Settings.Table_Network.Additional_Data;
			num_unit = size(Sola_Data,2)/6;
			d.Grid.(cg).Sola.Gen_Units = Unit_Time_Dependent.empty(0,num_unit);
			plants =  d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Plants;
			gen_count = 1;
			for k=1:numel(d.Grid.(cg).P_Q_Node.ids)
				gen_unit_name = add_data{k,1};
				if isempty(gen_unit_name)
					continue;
				end
				idx = find(strcmp(gen_unit_name,d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Content));
				idx = idx(plants.(gen_unit_name).Number) - 1;
				plants.(gen_unit_name).Number = plants.(gen_unit_name).Number - 1;
				% Last-Instanz erzeugen:
				obj = Unit_Time_Dependent(...
					d.Grid.(cg).P_Q_Node.Points(k),...       % Anschlusspunkt-Objekt
					Sola_Data(:,(idx*6)+1:(idx*6)+6));       % Lastgang des Last
				d.Grid.(cg).Sola.Gen_Units(gen_count) = obj;
				gen_count = gen_count + 1;
			end
		else
			d.Grid.(cg).Sola.Gen_Units = Unit_Time_Dependent.empty(0,0);
		end
		%----------------------------------------------------------------------------
		% Netzberechnungen durchführen:
		%----------------------------------------------------------------------------
		
		% noch die aktuellen Einstellungen speichern:
		d.Simulation.Grid_act = cg;
		d.Simulation.Input_Data_act = j;
		for k=1:handles.Current_Settings.Simulation.Timepoints
			try
                    
				% aktuellen Zeipunkt speichern:
				d.Simulation.Current_timepoint = k;
				% Last- und Einspeisedaten aktualisieren:
				d.Grid.(cg).Load.Loads.update_power(k);
				d.Grid.(cg).Load.Elmob.update_power(k);
				d.Grid.(cg).Sola.Gen_Units.update_power(k);
				% der Berechnung die neuen Leistungswerte übermitteln:
				d.Grid.(cg).P_Q_Node.Points.update_power(cg, j, k, d);
				% Lastfluss rechnen:
				handles.sin.start_calculation;
				
				% here the analyzing functions are called. Because the data is stored
				% within the NAT_Data-object, on which this function has access, no
				% return value is neccesary:
				
                % -- changelog v1.1b ##### (start) // 20130502
				% Perform online voltage violation analysis (true/false
				% results)
				if handles.Current_Settings.Simulation.Voltage_Violation_Analysis
					online_voltage_violation_analysis(handles);					
                    % An additional condition for saving voltages is
                    % inside the online function                    
                end
                % -- changelog v1.1b ##### (start) // 20130502
                
				% Perform online branch violation analysis (true/false results)
				if handles.Current_Settings.Simulation.Branch_Violation_Analysis
					online_branch_violation_analysis(handles);
					if handles.Current_Settings.Simulation.Save_Branch_Results
						% Save branch results in result structure
						save_branch_values(handles);
					end
				end
				% Perform online active power loss analysis (values in W)
				if handles.Current_Settings.Simulation.Power_Loss_Analysis
					online_power_loss_analysis(handles);
					% An additional condition for power loss saving is
					% inside the online function
				end
			catch ME %#ok<NASGU>
				d = handles.NAT_Data;
				ct = d.Simulation.Current_timepoint;
				cg = d.Simulation.Grid_act;
				cd = d.Simulation.Input_Data_act;
				if isfield(d.Result.(cg), 'Voltage_Violation_Analysis')
					d.Result.(cg).Voltage_Violation_Analysis(cd,ct,:) = NaN;
				end
				if isfield(d.Result.(cg), 'Node_Voltages')
					d.Result.(cg).Node_Voltages(cd,ct,:,:) = NaN;
				end
				if isfield(d.Result.(cg), 'Branch_Violation_Analysis')
					 d.Result.(cg).Branch_Violation_Analysis(cd,ct,:) = NaN;
				end
				if isfield(d.Result.(cg), 'Branch_Values')
					d.Result.(cg).Branch_Values(cd,ct,:,:) = NaN;
				end
				d.Result.(cg).Error_Counter(cd,ct) = d.Result.(cg).Error_Counter(cd,ct) + 1;
			end
		end
		
		% Statusinfo zum Gesamtfortschritt an User:
		t = toc;
		progress = j/handles.Current_Settings.Simulation.Number_Runs;
		time_elapsed = t/progress - t;
		fprintf(['\t\tLastprofil Nr. ',num2str(j),' von ',...
			num2str(handles.Current_Settings.Simulation.Number_Runs),' abgeschlossen. Laufzeit: ',...
			sec2str(t),...
			'. Verbleibende Zeit: ',...
			sec2str(time_elapsed),'\n']);
		err_count = sum(d.Result.(cg).Error_Counter(j,:));
		if err_count > 0
			fprintf(['\t\t\tWährend der Berechnung sind ',...
				num2str(err_count),' Fehler aufgetreten!"\n']);
		end
	end
	
	% select again the first grid (because here the load-& infeeeddata is
	% stored):
	handles.Current_Settings.Files.Grid.Name = Grid_List{1}(1:end-4);
	
	% % make additional calculation to prepare the data for displaying with the
	% % data explorer:
	% % handles = adopt_data_for_display(handles);
	
end

