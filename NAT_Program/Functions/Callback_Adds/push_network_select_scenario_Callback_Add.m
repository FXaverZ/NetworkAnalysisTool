function push_network_select_scenario_Callback_Add (hObject, handles)
% --- Executes on button press in push_network_select_scenario.
% hObject    handle to push_network_select_scenario (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

[Scenarios_Selection,Scen_ok] = listdlg(...
	'ListString',handles.Current_Settings.Simulation.Scenarios.Names,...
	'Name','Selection of Scenarios...',...
	'InitialValue', handles.Current_Settings.Simulation.Scenarios_Selection,...
	'PromptString',{'Selection of the Scenarios to be simulated';...
	' (Multiple selections possible):'},...
	'CancelString','Cancel',...
	'ListSize', [320, 300]);
if ~Scen_ok
	% no Selection (a.k.a. select all)
	handles.Current_Settings.Simulation.Scenarios_Selection = [];
else
	if sum(Scenarios_Selection>=1) == handles.Current_Settings.Simulation.Scenarios.Number
		% all scenarios were selected (a.k.a. select all)
		handles.Current_Settings.Simulation.Scenarios_Selection = [];
	else
	handles.Current_Settings.Simulation.Scenarios_Selection = Scenarios_Selection;
	end
end

% update GUI:
handles = refresh_display_NAT_main_gui(handles);

% update handles structure:
guidata(hObject, handles);
end

