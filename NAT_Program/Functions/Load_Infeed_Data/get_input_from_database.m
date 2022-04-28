function handles = get_input_from_database(handles)
%GET_INPUT_FROM_DATABASE Summary of this function goes here
%   Detailed explanation goes here

mh = handles.text_message_main_handler;
wb = handles.waitbar_main_handler;
wb.reset();

% Lastdaten einlesen und in Struktur speichern:
if handles.Current_Settings.Simulation.Use_Scenarios
	try
		wb.start();
		handles = get_data_szenarios_load_infeed(handles);
		wb.stop();
	catch ME
		if strcmp(ME.identifier,'NAT:LoadDataGet:CanceledByUser')
			% bisherige Daten löschen:
			handles.NAT_Data.Load_Infeed_Data = [];
			wb.stop_cancel();
			mh.level_down();
			return;
		else
			rethrow(ME)
		end
	end
else
	% clear the NAT_Data simulation field (so the default extraction settings of the
	% default scenario are used):
	handles.NAT_Data.Simulation = [];
	% Save the extraction-moment:
	handles.Current_Settings.Data_Extract.Date_Extraktion = now();
	
	% Speicherort = aktulles Netzfile
	file = handles.Current_Settings.Files.Auto_Load_Feed_Data;
	% Check, if a Subfolder for input-data is avaliable:
	file.Path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_nat',filesep,...
		'Load_Infeed_Data',filesep,...
		datestr(handles.Current_Settings.Data_Extract.Date_Extraktion,'yyyy_mm_dd-HH.MM.SS')];
	if ~isfolder([file.Path])
		mkdir([file.Path]);
	end
	
	log_path = [file.Path,filesep,'Data_Extraction_Log.log'];
	mh.mark_sub_log(log_path);
	mh.add_line('Load data for single szenario simulation...');
	mh.level_up();
	
	% Check, if the data has to be partitioned:
	if handles.Current_Settings.Simulation.Number_Runs > handles.System.number_max_datasets
		% The data has to be partitioned!
		errorstr = 'Partitioned data for non scenario-simulation currently not supported!';
		mh.add_error(errorstr);
		errordlg(errorstr);
		% bisherige Daten löschen:
		handles.NAT_Data.Load_Infeed_Data = [];
		wb.stop_cancel();
		mh.stop_sub_log(log_path);
		mh.level_down();
		return;
		% TODO: Implementation of data partioning of non
		% scenario-simulations
	else
		% get the data:
		wb.start();
		try
			handles = loaddata_get(handles);
			wb.stop();
		catch ME
			if strcmp(ME.identifier,'NAT:LoadDataGet:CanceledByUser')
				% bisherige Daten löschen:
				handles.NAT_Data.Load_Infeed_Data = [];
				wb.stop_cancel();
				mh.stop_sub_log(log_path);
				mh.level_down();
				return;
			else
				rethrow(ME)
			end
		end
	end
	% Die Daten + zugehörige Einstellungen in aktuelles Netzverzeichnis speichern:
	% Save the files (one load-infeed file and one settings file):
	handles.NAT_Data.save_LoadInfeedData_as_mat(...
		file.Path, file.Name);
	Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
	System = handles.System; %#ok<NASGU>
	save([file.Path,filesep,file.Data_Settings,file.Exte],'Data_Extract','System');
	handles.Current_Settings.Files.Auto_Load_Feed_Data = file;
	
	mh.add_line('Saved file: ',file.Path, filesep, file.Name, file.Exte,...
		' (Settings: ',file.Data_Settings,file.Exte,')');
	mh.stop_sub_log(log_path);
	mh.level_down();
end
end

