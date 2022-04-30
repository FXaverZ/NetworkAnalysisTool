function push_network_select_scenario_Callback_Add (hObject, handles)
% --- Executes on button press in push_network_select_scenario.
% hObject    handle to push_network_select_scenario (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Version:                 1.0
% Created by:              Franz Zeilinger - 01.01.2015
% Last change by:          Franz Zeilinger - 23.05.2018

mh = handles.text_message_main_handler;
buttontext = get(hObject, 'String');
mh.add_line('"',buttontext,'" pushed, selection of scenarios by user.');
mh.level_up();

if isempty(handles.Current_Settings.Simulation.Scenarios_Selection)
	handles.Current_Settings.Simulation.Scenarios_Selection = 1:handles.Current_Settings.Simulation.Scenarios.Number;
end

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
	mh.add_listselection(handles.Current_Settings.Simulation.Scenarios.Names, Scenarios_Selection);
	if sum(Scenarios_Selection>=1) == handles.Current_Settings.Simulation.Scenarios.Number
		% all scenarios were selected (a.k.a. select all)
		handles.Current_Settings.Simulation.Scenarios_Selection = [];
	else
	handles.Current_Settings.Simulation.Scenarios_Selection = Scenarios_Selection;
	end
end
% Refresh the GUI:
handles = refresh_display_NAT_main_gui(handles);
refresh_message_text_operation_finished (handles);

% update handles structure:
guidata(hObject, handles);
end

