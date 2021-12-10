function handles = refresh_display_PQNodefield(handles)
%REFRESH_DISPLAY_PQNODEFIELD Summary of this function goes here
%   Detailed explanation goes here
if isfield(handles.Current_Settings.Table_Network, 'Selected_Row') && ...
		~isempty(handles.Current_Settings.Table_Network.Selected_Row)
	
	% the current selected row:
	row = handles.Current_Settings.Table_Network.Selected_Row;
	% Where are the names of the PQ-Nodes:
	idx_na = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Names');
	% Where is the "active"-Flag Column:
	idx_ac = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Active');
	
	% Update the gui elements (activate them + show the information of the currently
	% selected PQ-node):
	set(handles.uipanel_detail_component,...
		'Title', ['Details for ',...
		handles.Current_Settings.Table_Network.Data{row,idx_na},':']);
	set(handles.check_pqnode_active, ...
		'Visible', 'on',...
		'Enable',  'on',...
		'Value',   handles.Current_Settings.Table_Network.Data{row,idx_ac});
	set(handles.text_pqnode_hh_typ, 'Visible', 'on');
	set(handles.popup_pqnode_hh_typ,'Visible', 'on');
	set(handles.text_pqnode_wi_typ, 'Visible', 'on');
	set(handles.text_pqnode_pv_typ, 'Visible', 'on');
	
	
	if strcmp(handles.Current_Settings.Grid.Type,'LV')
		% Where is the additional data?
		idx_pv_add = strcmp(handles.Current_Settings.Table_Network.Additional_Data_Content, 'PV_Plant_Name');
		% Where are the households?
		idx_hh = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Housh.type');
		
		% Get the PV-Plant Information:
		plant_pv_name = handles.Current_Settings.Table_Network.Additional_Data{row,idx_pv_add};
		sel_pv = find(strcmp(plant_pv_name,...
			handles.Current_Settings.Data_Extract.Solar.Selectable(:,2)));
		if isempty(sel_pv)
			sel_pv = 1;
		end
		
		set(handles.text_pqnode_hh_typ, 'String', 'Hh. Type');
		set(handles.popup_pqnode_hh_typ, 'String', handles.System.housholds(:,1));
		idx_hh_sel = find(strcmp(...
			handles.Current_Settings.Table_Network.Data{row,idx_hh},...
			handles.System.housholds(:,1)));
		set(handles.popup_pqnode_hh_typ,...
			'Value',idx_hh_sel);
		set(handles.push_pqnode_hh_selection, 'Visible', 'on', 'Enable', 'on', 'String', 'Sel. HH-typs...');
		set(handles.check_pqnode_hh_selection_all, 'Visible', 'on', 'Enable', 'on', 'Value', ...
			handles.Current_Settings.Data_Extract.Households.Selection_active_all);
		
		% is set that multiple households are connected to this point?
		if idx_hh_sel == size(handles.System.housholds,1)
			% if so, activate the corresponding input-fields for control and update
			% values
			idx_hh_num = strcmp(handles.Current_Settings.Table_Network.ColumnName,'Hh. Number');
			set(handles.edit_pqnode_hh_number, 'Visible', 'on', 'Enable', 'on',...
				'String',num2str(handles.Current_Settings.Table_Network.Data{row,idx_hh_num}));
			
			set(handles.text_pqnode_hh_number, 'Visible', 'on');
		else
			set(handles.edit_pqnode_hh_number, 'Visible', 'off');
			set(handles.text_pqnode_hh_number, 'Visible', 'off');
		end
		
		set(handles.popup_pqnode_pv_typ, 'Visible', 'on', 'Value', sel_pv);
		set(handles.text_pqnode_pv_installed_power_unit, 'Visible', 'on');
		set(handles.edit_pqnode_pv_installed_power, 'Visible', 'on');
		
		set(handles.push_pqnode_pv_parameters, 'Visible', 'on');
		if sel_pv > 1
			set(handles.edit_pqnode_pv_installed_power, 'Enable', 'on',...
				'String', ...
				num2str(handles.Current_Settings.Data_Extract.Solar.Plants.(plant_pv_name).Power_Installed/1000,'%.2f'));
			set(handles.push_pqnode_pv_parameters, 'Enable', 'on');
		else
			set(handles.push_pqnode_pv_parameters, 'Enable', 'off');
			set(handles.edit_pqnode_pv_installed_power, 'Enable', 'off');
		end
		set(handles.popup_pqnode_wi_typ, 'Visible', 'on');
		set(handles.text_pqnode_pv_typ, 'String', 'PV Gen.');
		set(handles.popup_pqnode_wi_typ, 'Visible', 'on', 'Enable', 'off');
		set(handles.edit_pqnode_wi_installed_power, 'Visible', 'on');
		set(handles.text_pqnode_wi_installed_power_unit, 'Visible', 'on');
		set(handles.push_pqnode_wi_parameters, 'Visible', 'on');
		set(handles.text_pqnode_wi_typ, 'String', 'Wind Gen.');
		
	elseif strcmp(handles.Current_Settings.Grid.Type,'MV')
		% Where are the LV-grids?
		idx_lv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
		
		set(handles.text_pqnode_hh_typ, 'String', 'LV Grid');
		set(handles.text_pqnode_pv_typ, 'String', 'PV?');
		set(handles.text_pqnode_wi_typ, 'String', 'El. Mob.?');
		set(handles.popup_pqnode_hh_typ, 'String', handles.Current_Settings.Table_Network.ColumnFormat{idx_lv});
		set(handles.popup_pqnode_hh_typ,...
			'Value', find(strcmp(...
			handles.Current_Settings.Table_Network.Data{row,idx_lv},...
			handles.Current_Settings.Table_Network.ColumnFormat{idx_lv})));
		set(handles.check_pqnode_emob_present, 'Visible', 'on');
		set(handles.check_pqnode_pv_present, 'Visible', 'on');
		
		set(handles.popup_pqnode_pv_typ, 'Visible', 'off');
		set(handles.edit_pqnode_pv_installed_power, 'Visible', 'off');
		set(handles.text_pqnode_pv_installed_power_unit, 'Visible', 'off');
		set(handles.push_pqnode_pv_parameters, 'Visible', 'off');
		set(handles.popup_pqnode_wi_typ, 'Visible', 'off');
		set(handles.edit_pqnode_wi_installed_power, 'Visible', 'off');
		set(handles.text_pqnode_wi_installed_power_unit, 'Visible', 'off');
		set(handles.push_pqnode_wi_parameters, 'Visible', 'off');
		set(handles.push_pqnode_hh_selection, 'Visible', 'off');
		set(handles.check_pqnode_hh_selection_all, 'Visible', 'off');
	end
else
	set(handles.check_pqnode_active, 'Visible', 'off');
	set(handles.popup_pqnode_hh_typ, 'Visible', 'off');
	set(handles.text_pqnode_hh_typ, 'Visible', 'off');
	set(handles.uipanel_detail_component,...
		'Title', 'No grid node selected');
	set(handles.text_pqnode_pv_typ, 'Visible', 'off');
	set(handles.popup_pqnode_pv_typ, 'Visible', 'off');
	set(handles.edit_pqnode_pv_installed_power, 'Visible', 'off');
	set(handles.text_pqnode_pv_installed_power_unit, 'Visible', 'off');
	set(handles.push_pqnode_pv_parameters, 'Visible', 'off');
	set(handles.popup_pqnode_wi_typ, 'Visible', 'off');
	set(handles.text_pqnode_wi_typ, 'Visible', 'off');
	set(handles.popup_pqnode_wi_typ, 'Visible', 'off');
	set(handles.edit_pqnode_wi_installed_power, 'Visible', 'off');
	set(handles.text_pqnode_wi_installed_power_unit, 'Visible', 'off');
	set(handles.push_pqnode_wi_parameters, 'Visible', 'off');
	set(handles.check_pqnode_emob_present, 'Visible', 'off');
	set(handles.check_pqnode_pv_present, 'Visible', 'off');
	set(handles.edit_pqnode_hh_number, 'Visible', 'off');
	set(handles.push_pqnode_hh_selection, 'Visible', 'off');
	set(handles.text_pqnode_hh_number, 'Visible', 'off')
	set(handles.check_pqnode_hh_selection_all, 'Visible', 'off');
end
end

