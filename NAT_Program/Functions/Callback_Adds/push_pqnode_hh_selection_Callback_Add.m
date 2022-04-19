function push_pqnode_hh_selection_Callback_Add(hObject, ~, handles)
%PUSH_PQNODE_HH_SELECTION_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

row_act = handles.Current_Settings.Table_Network.Selected_Row;
add_dat = handles.Current_Settings.Table_Network.Additional_Data;
add_nam = handles.Current_Settings.Table_Network.Additional_Data_Content;

idx = strcmp(add_nam,'HHs_Pool');
HHs_Selection = add_dat{row_act,idx};
num_typs = numel(handles.System.housholds(1:end-1,2));

if isempty(HHs_Selection)
	HHs_Selection = 1:num_typs;
end

[HHs_Selection,HH_ok] = listdlg(...
	'ListString',handles.System.housholds(1:end-1,2),...
	'Name','Selection of available household typs...',...
	'InitialValue', HHs_Selection,...
	'PromptString',{'Selection of the household typs, which should be';...
	'taken into account during random selection.';...
	'(Multiple selections possible):'},...
	'CancelString','Cancel',...
	'ListSize', [320, 150]);

if ~HH_ok
	% no Selection (a.k.a. select all)
	HHs_Selection = [];
else
	if sum(HHs_Selection>=1) == num_typs
		% all scenarios were selected (a.k.a. select all)
		HHs_Selection = [];
	end
end
if handles.Current_Settings.Data_Extract.Households.Selection_active_all
	[handles.Current_Settings.Table_Network.Additional_Data{:,idx}] = deal(HHs_Selection);
else
	handles.Current_Settings.Table_Network.Additional_Data{row_act,idx} = HHs_Selection;
end

% update GUI:
handles = refresh_display_NAT_main_gui(handles);

% update handles structure:
guidata(hObject, handles);
end

