function push_network_table_import_export_Callback_Add(hObject, ~, handles)
%PUSH_NETWORK_TABLE_IMPORT_EXPORT_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

if isfield(handles.Current_Settings.Files, 'Table_Network')
	file = handles.Current_Settings.Files.Table_Network;
else
	file = handles.Current_Settings.Files.Grid;
	file.Path = [file.Path,filesep,file.Name,'_nat'];
	% Create the folder, if it is not already existing:
	if ~isdir(file.Path)
		mkdir(file.Path);
	end
	file.Name = [file.Name,'_NAT_Table'];
	file.Exte = '.xlsx';
end

% Construct a questdlg with three options
choice = questdlg({'Import a network table to MS®Excel by pressing "Import...".';...
	'Export the current network table to MS®Excel by pressing "Export".'}, ...
	'Import / Export Network Table ...', ...
	'Import...','Export...','Cancel','Import...');
% Handle response
switch choice
	case 'Import...'
		[FileName,PathName] = uigetfile(['*',file.Exte],...
			'Export Network Table to File ...',[file.Path,filesep,file.Name,file.Exte]);
		if isequal(FileName,0) || isequal(PathName,0)
			%User selected Cancel
			return;
		end
		
		% Save the new file place:
		[~, file.Name, file.Exte]= fileparts(FileName);
		file.Path = PathName(1:end-1);
		
		% the current available table will be changed:
		Table = handles.Current_Settings.Table_Network;
		Solar = handles.Current_Settings.Data_Extract.Solar;
		Wind = handles.Current_Settings.Data_Extract.Wind;
		
		% read the information about the excel data:
		[~,sheets,~] = xlsfinfo([file.Path,filesep,file.Name,file.Exte]);
		idx = ~strncmp(sheets,'Tabelle',numel('Tabelle'));
		sheets = sheets(idx);
		% to do: Check, if neccessary sheets are present
		
		% read the data of the main table:
		[~,~,raw] = xlsread([file.Path,filesep,file.Name,file.Exte], 'Main_Table_Data');
		if size(Table.Data,1) ~= size(raw,1)-1
						errordlg(['Imported table (Main_Table_Data) and loaded grid ',...
				'are not matched!'],'Importing Table Data...');
			return;
		end
		
		% allocate the data to the table
		IX = zeros(1,size(Table.Data,1));
		idx_names = strcmp(Table.ColumnName,'Names');
		idx_raw_names = find(strcmp(raw(1,:),'Names'));
		idx_activ = strcmp(Table.ColumnName, 'Active');
		idx_hh_ty = strcmp(Table.ColumnName, 'Housh.type');
		idx_hh_nu = strcmp(Table.ColumnName, 'Hh. Number');
		idx_pv_pl = strcmp(Table.ColumnName, 'PV-Plant');
		idx_emob = strcmp(Table.ColumnName, 'El. Mob.');
		idx_raw_activ = find(strcmp(raw(1,:), 'Active'));
		idx_raw_hh_ty = find(strcmp(raw(1,:), 'Housh.type'));
		idx_raw_hh_nu = find(strcmp(raw(1,:), 'Hh. Number'));
		idx_raw_pv_pl = find(strcmp(raw(1,:), 'PV-Plant'));
		idx_raw_emob = find(strcmp(raw(1,:), 'El. Mob.'));
		
		% check the data, if loadnames are present:
		if isempty(idx_raw_names)
			errordlg('No loadname column identified!','Importing Table Data...');
			return;
		end
		
		% perform the data allocation (depending on the place, where the data should
		% be, so the position is not very important!!)
		% IX is the allocation matrix, these allocation is the same for all sheets in
		% the read in excel !!
		for i=1:size(Table.Data,1)
			IX(i) = find(strcmp(Table.Data{i,idx_names},raw(2:end,idx_raw_names)));
			if ~isempty(idx_raw_activ)
			Table.Data{i,idx_activ} = raw{IX(i)+1,idx_raw_activ};
			end
			if ~isempty(idx_raw_hh_ty)
			Table.Data{i,idx_hh_ty} = raw{IX(i)+1,idx_raw_hh_ty};
			end
			if ~isempty(idx_raw_hh_nu)
			Table.Data{i,idx_hh_nu} = raw{IX(i)+1,idx_raw_hh_nu};
			end
			if ~isempty(idx_raw_pv_pl)
			Table.Data{i,idx_pv_pl} = raw{IX(i)+1,idx_raw_pv_pl};
			end
			if ~isempty(idx_raw_emob)
				Table.Data{i,idx_emob} = raw{IX(i)+1,idx_raw_emob};
			end
		end
		% check, if loadnames are double: error
		IX_t = unique(IX);
		if  size(Table.Data,1) ~= numel(IX_t)
			errordlg('Loadnames are equal!','Importing Table Data...');
			return;
		end
		clear IX_t
		
		% work with the additional data, first the "easy" cases:
		[~,~,raw] = xlsread([file.Path,filesep,file.Name,file.Exte], 'Addtitional_Table_Data');
		
		idx_add_pv_name = strcmp(Table.Additional_Data_Content, 'PV_Plant_Name');
		idx_add_wi_name = strcmp(Table.Additional_Data_Content, 'Wind_Plant_Name');
		idx_raw_add_pv_name = find(strcmp(raw(1,:), 'PV_Plant_Name'));
		idx_raw_add_wi_name = find(strcmp(raw(1,:), 'Wind_Plant_Name'));
		
		for i=1:size(Table.Data,1)
			if ~isempty(idx_raw_add_pv_name)
				if (IX(i)+1 <= size(raw,1)) && ischar(raw{IX(i)+1,idx_raw_add_pv_name})
					Table.Additional_Data{i,idx_add_pv_name} = raw{IX(i)+1,idx_raw_add_pv_name};
				end
			end
			if ~isempty(idx_raw_add_wi_name)
				if (IX(i)+1 <= size(raw,1)) && ischar(raw{IX(i)+1,idx_raw_add_wi_name})
					Table.Additional_Data{i,idx_add_wi_name} = raw{IX(i)+1,idx_raw_add_wi_name};
				end
			end
		end
		
		% now do the further tables with more "special" data:
		[~,~,raw] = xlsread([file.Path,filesep,file.Name,file.Exte], 'HHs_Selection');
		idx_add_hh_sel = strcmp(Table.Additional_Data_Content, 'HHs_Selection');
		
		raw = raw(2:end,:);
		if size(raw,1) ~= size(Table.Data,1)
			errordlg('Unsufficient entries in "HHs_Selection"!','Importing Table Data...');
			return;
		end
		for i=1:size(Table.Data,1)
			idx_entry = find(cell2mat(cellfun(@ischar,raw(IX(i),:),'UniformOutput',false)));
			if ~isempty(idx_entry)
				Table.Additional_Data {i, idx_add_hh_sel} = raw(IX(i),idx_entry);
			else
				errordlg('No empty entrys in "HHs_Selection" allowed!','Importing Table Data...');
				return;
			end
		end
		
		[~,~,raw] = xlsread([file.Path,filesep,file.Name,file.Exte], 'HHs_Pool');
		idx_add_hh_poo = strcmp(Table.Additional_Data_Content, 'HHs_Pool');
		raw = raw(2:end,:);
		for i=1:size(Table.Data,1)
			if IX(i) <= size(raw,1)
				idx_entry = find(~cell2mat(cellfun(@isnan,raw(IX(i),:),'UniformOutput',false)));
				if ~isempty(idx_entry)
					Table.Additional_Data {i, idx_add_hh_poo} = cell2mat(raw(IX(i),idx_entry));
				end
			end
		end
				
		handles.Current_Settings.Table_Network = Table;
		
		load([file.Path,filesep,file.Name,'.mat']);
		handles.Current_Settings.Data_Extract.Solar = Solar;
		handles.Current_Settings.Data_Extract.Wind = Wind;
		
		helpdlg('Data successfully loaded!','Importing Table Data...')

		
	case 'Export...'
		[FileName,PathName] = uiputfile(['*',file.Exte],...
			'Export Network Table to File ...',[file.Path,filesep,file.Name,file.Exte]);
		if isequal(FileName,0) || isequal(PathName,0)
			%User selected Cancel
			return;
		end
		
		% Save the new file place:
		[~, file.Name, file.Exte]= fileparts(FileName);
		file.Path = PathName(1:end-1);
		% delete the possibly available file:
		try
			fileattrib([file.Path,filesep,file.Name,file.Exte]);
			delete([file.Path,filesep,file.Name,file.Exte]);
		catch %#ok<CTCH>
		end
		clear choice FileName PathName
		
		% get the data to be exported:
		Table = handles.Current_Settings.Table_Network;
		Solar = handles.Current_Settings.Data_Extract.Solar;
		Wind = handles.Current_Settings.Data_Extract.Wind;
		
		% data of the main table:
		data_output = [Table.ColumnName;Table.Data];
		xls = XLS_Writer();
		xls.set_worksheet('Main_Table_Data');
		xls.write_values(data_output);
		
		% create the outputs for the additional tables:
		ad_ct = Table.Additional_Data_Content;
		ad_da = Table.Additional_Data;
		% first, for the household-selection:
		idx = strcmp(ad_ct, 'HHs_Selection');
		data = ad_da(:,idx);
		ad_da(:,idx) = [];
		ad_ct(:,idx) = [];
		xls.set_worksheet('HHs_Selection');
		xls.write_lines('HHs_Selection');
		for i=1:size(data,1)
			data_sing = data{i};
			if isempty(data_sing)
				xls.next_row;
			else
				xls.write_lines(data_sing);
			end
		end
		% second, the HHs_Pool:
		idx = strcmp(ad_ct, 'HHs_Pool');
		data = ad_da(:,idx);
		ad_da(:,idx) = [];
		ad_ct(:,idx) = [];
		xls.set_worksheet('HHs_Pool');
		xls.write_lines('HHs_Pool');
		for i=1:size(data,1)
			data_sing = data{i};
			if isempty(data_sing)
				xls.next_row;
			else
				xls.write_lines(data_sing);
			end
		end
		% remaining additional data, which can simply be written to Excel:
		data_output = [ad_ct; ad_da];
		xls.set_worksheet('Addtitional_Table_Data');
		xls.write_values(data_output);
		
		% Final output-creation:
		xls.write_output([file.Path,filesep,file.Name,file.Exte]);
		
		% Save the data also in Matlab-Format for direkt availability in NAT:
		save([file.Path,filesep,file.Name,'.mat'],'Table', 'Solar', 'Wind');
		
		helpdlg('Data successfully exported!','Exporting Table Data...')
		
	otherwise
		%do nothing
		return;
end

handles.Current_Settings.Files.Table_Network = file;

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

