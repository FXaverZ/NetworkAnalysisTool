function Selected_List = listbox_selection_topology(handles,inp_selection)

% Listbox selection
Listbox_input = [];
ME = [];
Selected_List = [];
try
    Selection_list_number = handles.NVIEW_Control.Simulation_Options.Number_of_Variants;
    Selection_list_names = handles.NVIEW_Control.Simulation_Description.Variants;
    if strcmp(inp_selection,'Select nodes')
        % Select nodes
        for i = 1 : Selection_list_number
            Listbox_input.(Selection_list_names{i}) = ...
                handles.NVIEW_Results.(Selection_list_names{i}).bus_name;
            Selected_List.(Selection_list_names{i})(:,1) = 1: size(handles.NVIEW_Results.(Selection_list_names{i}).bus,1);
        end
        
    elseif strcmp(inp_selection,'Select branches')
        % Select branches
        for i = 1 : Selection_list_number
            Listbox_input.(Selection_list_names{i}) = ...
                handles.NVIEW_Results.(Selection_list_names{i}).branch_name;
            Selected_List.(Selection_list_names{i})(:,1) = 1: size(handles.NVIEW_Results.(Selection_list_names{i}).branch,1);
        end
        
    end
catch ME
end
if ~isempty(ME)
    return;
end

for j = 1 : Selection_list_number
    for i = 1 : size(Selection_list_names,1)
        if size(Listbox_input.(Selection_list_names{j}){i,1},2) >= 40
            Listbox_input.(Selection_list_names{j}){i,1} = [Listbox_input.(Selection_list_names{j}){i,1}(1:37),'...'];
        end
    end
end
clear i j


for i = 1 : Selection_list_number
	%CHANGELOG FZ 25.02.2014
	% Sort the List by names:
	[Listbox_input.(Selection_list_names{i}),IX] = sort(Listbox_input.(Selection_list_names{i}));
	%CHANGELOG FZ 25.02.2014
	
    % Pop up window
    flb.window  = figure('menubar','none','units','pixels','position',[540 200 300 400],...
        'numbertitle','off','name',[inp_selection, ' for ', Selection_list_names{i} ],'resize','off','CloseRequestFcn',{@my_closereq});
    flb.listbox = uicontrol('style','listbox','Min',1,'Max',99999,'units','pix','position',[2 50 300-2 350],'string',Listbox_input.(Selection_list_names{i}));
    flb.pb_all  = uicontrol('style','pushbutton','units','pix','position',[47.5+95+17.5 15 75 20],'string','All','callback',{@pb_all_call,flb});
    flb.pb_ok   = uicontrol('style','pushbutton','units','pix','position',[47.5+17.5 15 75 20],'string','OK','callback',{@pb_ok_call,flb});
    
    %  set(flb.pb_ok,'UserData',0);
    guidata(flb.pb_ok,flb);
    guidata(flb.pb_all,flb);
    
    gui_cond = 0;
    while gui_cond < 1
        uiwait(flb.window);
        
        % Check if ok button is pressed
        if ~isempty(get(flb.pb_ok,'UserData'))
            if get(flb.pb_ok,'UserData') == 1
                Selected_List.(Selection_list_names{i}) = get(flb.listbox,'Value')';
                if size(Selected_List.(Selection_list_names{i}),1) >= 1
                    gui_cond = 1;
                    break;
                else
                    Selected_List.(Selection_list_names{i}) = [];
                    set(flb.pb_ok,'UserData',[]);
                end
            elseif get(flb.pb_ok,'UserData') == 2
                break;
            end
        end
    end
    delete(flb.window);
	%CHANGELOG FZ 25.02.2014
	% backsorting:
	Selected_List.(Selection_list_names{i}) = IX(Selected_List.(Selection_list_names{i}));
	Selected_List.(Selection_list_names{i}) = sort(Selected_List.(Selection_list_names{i}));
	%CHANGELOG FZ 25.02.2014
end

end


function [] = my_closereq(varargin)
    flb = guidata(gcbf);
    set(flb.pb_ok,'UserData',2);
    uiresume(flb.window);
end

function [] = pb_ok_call(varargin)
    flb = guidata(gcbf);  % Get the structure.
    set(flb.pb_ok,'UserData',1)
    uiresume(flb.window)
end

function [] = pb_all_call(varargin) 
    flb = guidata(gcbf);  % Get the structure.
    set(flb.pb_all,'UserData',1);
    set(flb.listbox,'Value',[1:numel(get(flb.listbox,'String'))])
end