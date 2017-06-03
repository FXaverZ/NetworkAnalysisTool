function handles = network_calculation(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 2.0
% Erstellt von:            Franz Zeilinger - 05.02.2013
% Letzte Änderung durch:   Matej Rejc      - 24.04.2013

% Zugriff auf Datenobjekt:
d = handles.NAT_Data;
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
fprintf('\nStarte Netz-Simulationen...\n');
for i=1:numel(Grid_List)
	handles.Current_Settings.Files.Grid.Name = Grid_List{i}(1:end-4);
	
	% load the network data:
	handles = network_load (handles);
	
	% current grid name
	cg = handles.sin.Settings.Grid_name;
   
    fprintf(['Starte Netz-Simulation ',num2str(i)',' von ',num2str(numel(Grid_List)),...
		'\n']);
	
    % -- changelog v1.1b ##### (start) // 20130423
    % Leeres Netz-Array erstellen:
    d.Result.(cg) = [];
    % Clear the previous simulation information:
    d.Simulation = [];   
    % -- changelog v1.1b ##### (end) // 20130423
        
	tic; %Zeitmessung start    
	for j=1:handles.Current_Settings.Simulation.Number_Runs;
		%--------------------------------------------------------------------------------
		% Übernehmen der akutell geladen Daten:
		%--------------------------------------------------------------------------------
		if handles.Current_Settings.Data_Extract.get_Max_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_Max;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_Max;
		end
		if handles.Current_Settings.Data_Extract.get_Min_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_Min;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_Min;
		end
		if handles.Current_Settings.Data_Extract.get_Sample_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_Sample;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_Sample;
		end
		if handles.Current_Settings.Data_Extract.get_Mean_Value
			Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Data_Mean;
			Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.Data_Mean;
		end
		
		Table_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Table_Network.Data;
		
		% Die Daten an SINCAL anpassen (Leistungen in MW und pos. bei Verbrauch):
		Load_Data = Load_Data/1e6;
		Sola_Data = Sola_Data/-1e6; %Einspeiser negativ!
		% Wieviele Zeitpunkte werden berechnet?
		handles.Current_Settings.Simulation.Timepoints = size(Load_Data,1);

        % -- changelog v1.1b ##### (start) // 20130423
        %--------------------------------------------------------------------------------
        % Result preallocation
        %--------------------------------------------------------------------------------
        % Options for result preallocation
        voltage_violation_analysis = 1; % Voltage violation analysis function is used
        % voltage_violation_analysis = 0; % Voltage violation analysis function is not used
        save_voltage_results = 1 ; % Save voltage results
        % save_voltage_results = 0 ; % Do not save voltage results
        branch_violation_analysis = 1; % Branch violation analysis function is used
        % branch_violation_analysis = 0; % Branch violation analysis function is not used
        save_branch_results = 1; % Save branch results
        % save_branch_results = 0; % Do not save branch results
        %---------------               
         
        if voltage_violation_analysis == 1 && j == 1
            % - If we have the information regarding the timepoints before the five if conditions 
            % above we can put this completely outside the for dataset loop!            
            % - Preallocation is performed at first dataset iteration, so all
            % dimensions are created at first dataset and resizing of
            % result array is not needed at every dataset step            
            % - Assumption: All datasets have the same number of timepoints
            
            d.Result.(cg).Voltage_Violation_Analysis(...
                1:handles.Current_Settings.Simulation.Number_Runs,...
                1:handles.Current_Settings.Simulation.Timepoints,...
                1:numel(d.Grid.(cg).All_Node.Points)) = ...
                    zeros(handles.Current_Settings.Simulation.Number_Runs,...
                    handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.(cg).All_Node.Points) );
            % Determine voltage limits within the online analysis
            d.Simulation.Voltage_Violation_Analysis.node_rated_voltages = ...
                vertcat(d.Grid.(cg).All_Node.Points.Rated_Voltage_phase_earth);
            % Recalculate voltage limits in p.u.
            d.Simulation.Voltage_Violation_Analysis.voltage_limit_values_pu = ...
                vertcat(d.Grid.(cg).All_Node.Points.Voltage_Limits)/100;
            % voltage_limits defined as 4 element matrix
            % [upper_U_limit  lower_U_limit  upper_U_limit2   lower_U_limit2]
            
            % Determine number of voltage limits per node
            d.Simulation.Voltage_Violation_Analysis.number_of_voltage_limits = ...
                vertcat(d.Grid.(cg).All_Node.Points.Number_of_Voltage_Violation_limits);
        end  
        
        if save_voltage_results == 1 && j == 1            
            d.Result.(cg).Node_Voltages(...
                1:handles.Current_Settings.Simulation.Number_Runs,...
                1:handles.Current_Settings.Simulation.Timepoints,...
                1:numel(d.Grid.(cg).All_Node.Points),...
                1:3) = ...
                    zeros(handles.Current_Settings.Simulation.Number_Runs,...
                    handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.(cg).All_Node.Points),3);  % Three phase values 
        end
                
        if branch_violation_analysis == 1 && j == 1
            % Elements (lines and transformers) are merged 
            % NOTE: LINES ARE ALWAYS FIRST, THEN COME THE 2W TRANSF!
            d.Result.(cg).Branch_Violation_Analysis(...
                1:handles.Current_Settings.Simulation.Number_Runs,...
                1:handles.Current_Settings.Simulation.Timepoints,...
                1: numel(d.Grid.(cg).Branches.Grouped) ) = ...
                    zeros(handles.Current_Settings.Simulation.Number_Runs,...
                    handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.(cg).Branches.Grouped) );   
            
            % Line limits are in most cases given in A, therefore we will check
            % limit values by comparing I to Ilim
            
            d.Simulation.Branch_Violation_analysis.element_type = vertcat(d.Grid.(cg).Branches.Grouped.Branch_Type_ID);
            % d.Simulation.Branch_Violation_analysis.element_type is 1 if element is a line or 2 if element is a
            % 2w transformer
            
            d.Simulation.Branch_Violation_analysis.line_current_limits = vertcat(d.Grid.(cg).Branches.Lines.Current_Limits);
            % Transf. limits are in most cases given in VA, therefore we will check
            % limit values by comparing S to Smax
            d.Simulation.Branch_Violation_analysis.transf_app_power_limits = vertcat(d.Grid.(cg).Branches.Transf.App_Power_Limits);
            
            d.Simulation.Branch_Violation_analysis.branch_limits = ...
                [d.Simulation.Branch_Violation_analysis.line_current_limits;
                 d.Simulation.Branch_Violation_analysis.transf_app_power_limits];
            % d.Simulation.Branch_Violation_analysis.branch_limits has the
            % limits to all branch elements - WARNING: the values here
            % should only be used in conjunction with
            % "d.Simulation.Branch_Violation_analysis.element_type", 
            % as the values are not the same unit (Amps for lines, VA for
            % transformers) !!
            
        end
        
        if save_branch_results == 1 && j == 1
            % Branch_Values include both lines and 2w transformers
            d.Result.(cg).Branch_Values(...
                1:handles.Current_Settings.Simulation.Number_Runs,...
                1:handles.Current_Settings.Simulation.Timepoints,...
                1:numel(d.Grid.(cg).Branches.Grouped),...
                1:16) = ...
                    zeros(handles.Current_Settings.Simulation.Number_Runs,...
                    handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.(cg).Branches.Grouped),16); 
        end
        % -- changelog v1.1b ##### (end) // 20130423
		%--------------------------------------------------------------------------------
		% Lasten ins Netz einfügen:
		%--------------------------------------------------------------------------------
		d.Grid.(cg).Load.Loads = Unit_Time_Dependent.empty(0,numel(d.Grid.(cg).P_Q_Node.ids));
		hhs = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.Number;
		for k=1:numel(d.Grid.(cg).P_Q_Node.ids)
			% Welcher Haushaltstyp soll angeschlossen werden?
			hh_typ = Table_Data{k,3};
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
		
		%--------------------------------------------------------------------------------
		% Erzeuger einfügen
		%--------------------------------------------------------------------------------
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
		%--------------------------------------------------------------------------------
		% Netzberechnungen durchführen:
		%--------------------------------------------------------------------------------
		
		% noch die aktuellen Einstellungen speichern:
		d.Simulation.Grid_act = cg;
		d.Simulation.Input_Data_act = j;
		
		
		for k=1:handles.Current_Settings.Simulation.Timepoints
			% aktuellen Zeipunkt speichern:
			d.Simulation.Current_timepoint = k;
			% Last- und Einspeisedaten aktualisieren:
			d.Grid.(cg).Load.Loads.update_power(k);
			d.Grid.(cg).Sola.Gen_Units.update_power(k);
			
			% der Berechnung die neuen Leistungswerte übermitteln:
			d.Grid.(cg).P_Q_Node.Points.update_power;
			% Lastfluss rechnen:
			handles.sin.start_calculation;
			
			% here the analyzing function is called. Because the data is stored
			% within the NAT_Data-object, on which this function has access, no
			% return value is neccesary:

            % -- changelog v1.1b ##### (start) // 20130423
            % Perform online voltage violation analysis (true/false
            % results)
			online_voltage_violation_analysis(handles);
            % Save voltage results in result structure
            save_node_values(handles);
            % Perform online branch violation analysis (true/false results)
			online_branch_violation_analysis(handles);
            % Save branch results in result structure
            save_branch_values(handles);
            % -- changelog v1.1b ##### (end) // 20130423
            
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
	end
	fprintf('\t\t--> erledigt!\n');
	fprintf(['\tBerechnungen beendet nach ',sec2str(t),'\n']);
end
% handles = adopt_data_for_display(handles);

end

