function handles = loaddata_get(handles, varargin)
%LOADDATA_GET Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.4
% Erstellt von:            Franz Zeilinger - 29.01.2013
% Letzte Änderung durch:   Franz Zeilinger - 11.07.2018

mh = handles.text_message_main_handler;
ch = handles.cancel_button_main_handler;
wb = handles.waitbar_main_handler;

% prepare the functions arguments:
if nargin == 2
	% swcond Argument tells the function, that part-files have to be created...
	save_part_files = varargin{1};
else
	save_part_files = 0;
end

% bisherige Daten löschen:
handles.NAT_Data.Load_Infeed_Data = [];
% akutelle Einstellungen des Datenauslesens mitspeichern
handles.NAT_Data.Data_Extract = handles.Current_Settings.Data_Extract;

% Anzahl an auszulesenden Datensätzen:
num_set = handles.Current_Settings.Simulation.Number_Runs;

if num_set == 1
	% Ein einzelner Datensatz soll ausgelesen werden...
	mh.add_line('Reading load data (for single set simulation) ...');
	mh.level_up();
	mh.add_line('Using allocation of loads from the GUI.');
else
	mh.add_line('Reading load data (',num_set,' sets)...');
	mh.level_up();
	mh.add_line('Using random allocation of load- and infeed.');
end


% Diese erstellen:
tic; %Zeitmessung start
file_part_count = 0;
set_count = 0;

mh.add_line('Data Extraction started.');
wb.add_end_position('set_counter',num_set);
for set_counter = 1:num_set
	wb.update_counter('set_counter', set_counter);
	
	% Avoid Matlab "hang":
	drawnow(); pause(0.01);
	
	if num_set > 1
		% Zufällige Zuordnung treffen:
		handles = load_random_allocation(handles);
	end
	
	% Daten auslesen und dem Input-Datensatz hinzufügen:
	set_count = set_count + 1;
	get_data_households(handles, set_count);
	get_data_solar(handles, set_count);
	get_data_elmob(handles, set_count);
	% create dummy values of not needed input data
	get_empty_data_lvgrids(handles, set_count);
	if set_counter > 1
		mh.remove_line(2);
	end
	if num_set > 1
		wb.update();
		% Infos to the console:
		mh.add_line('Set ',set_counter,' of ',num_set,' done... ');
		if ch.was_cancel_pushed()
			% Cancel Button pushed!
			errorstr = 'Data extraction canceled by user!';
			mh.add_line(errorstr);
			exception = MException(...
				'NAT:LoadDataGet:CanceledByUser',...
				errorstr);
			throw(exception);
		end
		t = toc;
		progress = set_counter/num_set;
		time_elapsed = t/progress - t;
		if set_counter < num_set
			mh.level_up();
			mh.add_line(' Runtime: ', sec2str(t),'. Remaining: ',...
				sec2str(time_elapsed));
			mh.level_down();
		else
			mh.remove_line;
		end
		mh.write_sub_logs();
	end
	if save_part_files && set_counter >= ((file_part_count+1) * handles.System.number_max_datasets)
		% save a part-file:
		file_part_count = file_part_count + 1;
		% Save the number of datasets in this file part:
		handles.NAT_Data.Simulation.Active_Scenario.Data_content(file_part_count) = handles.System.number_max_datasets;
		% save the extracted data within a seperate file in the grid variants
		% folder:
		mh.add_line('Save file part no. ',file_part_count);
		if file_part_count == 1
			name = handles.NAT_Data.Simulation.Active_Scenario.Filename;
		else
			name = [handles.NAT_Data.Simulation.Active_Scenario.Filename,'_',num2str(file_part_count,'%03.0f')];
		end
        handles.NAT_Data.save_LoadInfeedData_as_mat(...
			handles.Current_Settings.Simulation.Scenarios_Path, name);
		% delete the current data:
		handles.NAT_Data.Load_Infeed_Data = [];
		% reset the set-counter:
		set_count = 0;
	end
end
% save last file-part:
if save_part_files && set_counter > (file_part_count * handles.System.number_max_datasets)
	file_part_count = file_part_count + 1;
	% Save the number of datasets in this file part:
	handles.NAT_Data.Simulation.Active_Scenario.Data_content(file_part_count) = ...
		set_counter - (file_part_count-1) * handles.System.number_max_datasets;
	
	mh.add_line('Save file part no. ',file_part_count);
	name = [handles.NAT_Data.Simulation.Active_Scenario.Filename,'_',num2str(file_part_count,'%03.0f')];
% 	Load_Infeed_Data = handles.NAT_Data.Load_Infeed_Data; %#ok<NASGU>
% 	save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,name,'.mat'],...
% 		'Load_Infeed_Data');
% 	clear('Load_Infeed_Data');
	 handles.NAT_Data.save_LoadInfeedData_as_mat(...
			handles.Current_Settings.Simulation.Scenarios_Path, name);
end 
if save_part_files
	% Update the Scenario-Data:	
	handles.NAT_Data.Simulation.Active_Scenario.Data_is_divided = 1;
	handles.NAT_Data.Simulation.Active_Scenario.Data_number_parts = file_part_count;
end
t = toc;
mh.level_down();
mh.add_line('... done (in ',sec2str(t),')!');
end

