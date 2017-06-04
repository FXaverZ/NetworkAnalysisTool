function Selected_List = listbox_selection(handles,inp_selection)

% Listbox selection
Listbox_input = [];
ME = [];
Selected_List = [];
try
    if strcmp(inp_selection,'Select grid variants')
        Listbox_input = handles.NVIEW_Control.Simulation_Description.Variants(:,1);
    elseif strcmp(inp_selection,'Select scenarios')
        Listbox_input = handles.NVIEW_Control.Simulation_Description.Scenario(:,1);        
    end
catch ME
end
if ~isempty(ME)
    return;
end

for i = 1 : size(Listbox_input)
   if size(Listbox_input{i,1},2) >= 40
       Listbox_input{i,1} = [Listbox_input{i,1}(1:37),'...'];
   end
end

% Pop up window
flb.window  = figure('menubar','none','units','pixels','position',[540 200 300 400],...
    'numbertitle','off','name',inp_selection,'resize','off','CloseRequestFcn',{@my_closereq});
flb.listbox = uicontrol('style','listbox','Min',1,'Max',999,'units','pix','position',[2 50 300-2 350],'string',Listbox_input);
flb.pb_all  = uicontrol('style','pushbutton','units','pix','position',[95+17.5 15 75 20],'string','All','callback',{@pb_all_call,flb});
flb.pb_none = uicontrol('style','pushbutton','units','pix','position',[187.5+17.5 15 75 20],'string','None','callback',{@pb_none_call,flb});
flb.pb_ok   = uicontrol('style','pushbutton','units','pix','position',[17.5 15 75 20],'string','OK','callback',{@pb_ok_call,flb});

%  set(flb.pb_ok,'UserData',0);
guidata(flb.pb_ok,flb);
guidata(flb.pb_all,flb);
guidata(flb.pb_none,flb);

gui_cond = 0;
while gui_cond < 1
    uiwait(flb.window);
    
    % Check if ok button is pressed
    if ~isempty(get(flb.pb_ok,'UserData'))
        if get(flb.pb_ok,'UserData') == 1
            Selected_List = get(flb.listbox,'Value')';
            if size(Selected_List,1) >= 1
                gui_cond = 1;    
                break;
            else
                Selected_List = [];
                set(flb.pb_ok,'UserData',[]);
            end
        elseif get(flb.pb_ok,'UserData') == 2
            break;
        end
    end
end
delete(flb.window)
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
    set(flb.pb_none,'UserData',[]);
    set(flb.pb_all,'UserData',1);
    set(flb.listbox,'Value',[1:numel(get(flb.listbox,'String'))])
end
function [] = pb_none_call(varargin)
    flb = guidata(gcbf);  % Get the structure.
    set(flb.pb_all,'UserData',[]);
    set(flb.pb_none,'UserData',1);
    set(flb.listbox,'Value',[])
end