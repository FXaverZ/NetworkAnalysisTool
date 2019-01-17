function push_network_select_variant_folder_Callback_Add (hObject, handles)
%PUSH_NETWORK_SELECT_VARIANT_FOLDER_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

mh = handles.text_message_main_handler;

buttontext = get(hObject, 'String');
mh.reset_display_text();
mh.add_line('"',buttontext,'" pushed, loading grid variants into NAT:');
mh.level_up();
title_str = 'Loading of grid variants...';

% Userabfrage nach neuen Datenbankpfad:
Main_Path = uigetdir(handles.Current_Settings.Simulation.Grids_Path,...
	'Selcet folder with grid variants...');
if ~ischar(Main_Path)
	mh.add_line('Canceled by user.');
	refresh_message_text_operation_finished (handles);
	return;
end

mh.add_line('Searching for grids in "',Main_Path,'" ...');

% Check, if grid-files are present in this folder:
files = dir(Main_Path);
files = struct2cell(files);
files = files(1,3:end);
files = files(cellfun(@(x) strcmp(x(end-3:end),'.sin'), files));

% if not, error:
if isempty(files)
	str1='No PSS(R)SINCAL files found at the given loaction! ';
	str2='Selcet folder with grid variants...';
	mh.add_error(str1,str2);
	errordlg({str1;str2}, title_str);
	refresh_message_text_operation_finished (handles);
	return;
end

mh.level_up();
for i=1:numel(files)
	mh.add_line('[ ] ',files{i});
end
mh.level_down();
mh.add_line('... (',numel(files),' grids) found.');

% ask user for grid-type:
user_response = questdlg(['As which type of Grid should the current one(s) be ',...
	'treated?'],'Grid type?','LV', 'MV', 'Cancel', 'Cancel');
switch user_response
	case 'LV'
		handles.Current_Settings.Grid.Type = 'LV';
	case 'MV'
		handles.Current_Settings.Grid.Type = 'MV';
	otherwise
		% leave function ('Cancel' or 'abort')
		mh.add_line('Canceled by user.');
		refresh_message_text_operation_finished (handles);
		return;
end

mh.add_line(['Grids are interpreted as type "',...
	handles.Current_Settings.Grid.Type,'"']);

% keep the folder-path:
handles.Current_Settings.Simulation.Grids_Path = Main_Path;
% save the present .sin-files for later processing of them:
handles.Current_Settings.Simulation.Grid_List = files;
% load the first grid (for getting the primary load-topology):
handles.Current_Settings.Files.Grid.Path = Main_Path;
handles.Current_Settings.Files.Grid.Name = files{1}(1:end-4);
handles.Current_Settings.Files.Grid.Exte = files{1}(end-3:end);
% mark, that grid variants will be used:
handles.Current_Settings.Simulation.Use_Grid_Variants = 1;
% Reset the stored NAT_Data:
handles.NAT_Data.reset();
% load the network data:
handles = network_load (handles);
% Tabelle mit Default-Werten befüllen:
[handles.Current_Settings.Table_Network, handles.Current_Settings.Data_Extract] = ...
	network_table_reset(handles);

% Inform the user:
str = 'Grid variants successfully loaded!';
helpdlg(str, title_str);
mh.add_line(str);

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
refresh_message_text_operation_finished (handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

