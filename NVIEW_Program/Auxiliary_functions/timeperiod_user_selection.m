function [Selected_Timestamp_Id,Selected_Timestamps,Selected_Hours] = timeperiod_user_selection(handles)
Selected_Hours = [];
Selected_List = [];
Selected_Timestamps = [];
Selected_Timestamp_Id = [];
ME = [];
try
    Hours(:,1) = 0 : 23;
    % Simulation equals to one day (hardcoded)
    time_step = (60*24) / handles.NVIEW_Control.Simulation_Options.Timepoints_per_dataset; % In minutes
    
    minute_intervals(:,1) = 0 : time_step : 60-1e-6;
    Timestamps_Full = [];
    for i = 1 : numel(Hours)
        Timestamps_Full = [Timestamps_Full;repmat(Hours(i),numel(minute_intervals),1),minute_intervals];
    end
    
catch ME
end
if ~isempty(ME)
    return;
end

% Listbox selection (time perioud)
Listbox_input = [];
for i = 1 : numel(Hours)
    if Hours(i,1) < 10
        Listbox_input{i,1} = ['0',int2str(Hours(i,1))];
    else
        Listbox_input{i,1} = int2str(Hours(i,1));
    end
end
clear i ME

% ------------------------------------------------------------------------
% Pop up window
flb.window  = figure('menubar','none','units','pixels','position',[540 200 300 450],...
    'numbertitle','off','name','Select time period','resize','off','CloseRequestFcn',{@my_closereq});
flb.listbox = uicontrol('style','listbox','Min',1,'Max',999,'units','pix','position',[2 70 300-2 375],'string',Listbox_input);
flb.pb_6_20  = uicontrol('style','pushbutton','units','pix','position',[17.5 40 75 20],'string','6-20 h','callback',{@pb_6_20_call,flb});
flb.pb_8_18 = uicontrol('style','pushbutton','units','pix','position',[95+17.5 40 75 20],'string','8 - 18 h','callback',{@pb_8_18_call,flb});
flb.pb_10_14   = uicontrol('style','pushbutton','units','pix','position',[187.5+17.5 40 75 20],'string','10 - 14 h','callback',{@pb_10_14_call,flb});
flb.pb_all  = uicontrol('style','pushbutton','units','pix','position',[95+17.5 15 75 20],'string','All','callback',{@pb_all_call,flb});
flb.pb_none = uicontrol('style','pushbutton','units','pix','position',[187.5+17.5 15 75 20],'string','None','callback',{@pb_none_call,flb});
flb.pb_ok   = uicontrol('style','pushbutton','units','pix','position',[17.5 15 75 20],'string','OK','callback',{@pb_ok_call,flb});

%  set(flb.pb_ok,'UserData',0);
guidata(flb.pb_ok,flb);
guidata(flb.pb_all,flb);
guidata(flb.pb_none,flb);
guidata(flb.pb_6_20,flb);
guidata(flb.pb_8_18,flb);
guidata(flb.pb_10_14,flb);

gui_cond = 0;
while gui_cond < 1
    uiwait(flb.window);    
    % Check if ok button is pressed
    if ~isempty(get(flb.pb_ok,'UserData'))
        if get(flb.pb_ok,'UserData') == 1
            Selected_List = get(flb.listbox,'Value')';
            if size(Selected_List,1) >= 1
                gui_cond = 1;    
                Selected_Timestamps = [];
                Timestamps_Selected_Logical = zeros(size(Timestamps_Full,1),1);
                for i = 1 : numel(Selected_List)
                    ind = zeros(size(Timestamps_Full,1),1);
                    ind = (Timestamps_Full(:,1) == (Selected_List(i)-1));
                    Timestamps_Selected_Logical(ind,1) = 1;
                end                
                Selected_Timestamps = find(Timestamps_Selected_Logical);
                Selected_Hours = Selected_List - 1;
                
                % Define Timestamp ID
                Time_Selection_NumericalId = zeros(1,24); % 0 - 23 h timeframe (hardcoded)
                Time_Selection_NumericalId(1,Selected_Hours+1) = 1;
                Selected_Timestamp_Id = [];
                for i = 1 : size(Time_Selection_NumericalId,2)
                    Selected_Timestamp_Id = [Selected_Timestamp_Id,int2str(Time_Selection_NumericalId(i))];
                end
                
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
delete(flb.window);

% ------------------------------------------------------------------------


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

function [] = pb_6_20_call(varargin)
    flb = guidata(gcbf);  % Get the structure.
    set(flb.pb_none,'UserData',[]);
    set(flb.pb_all,'UserData',[]);
    set(flb.pb_6_20,'UserData',1);
    set(flb.pb_8_18,'UserData',[]);
    set(flb.pb_10_14,'UserData',[]);
    set(flb.listbox,'Value',(6:20)+1);
end
function [] = pb_8_18_call(varargin)
    flb = guidata(gcbf);  % Get the structure.
    set(flb.pb_none,'UserData',[]);
    set(flb.pb_all,'UserData',[]);
    set(flb.pb_6_20,'UserData',[]);
    set(flb.pb_8_18,'UserData',1);
    set(flb.pb_10_14,'UserData',[]);
    set(flb.listbox,'Value',(8:18)+1);
end
function [] = pb_10_14_call(varargin)
    flb = guidata(gcbf);  % Get the structure.
    set(flb.pb_none,'UserData',[]);
    set(flb.pb_all,'UserData',[]);
    set(flb.pb_6_20,'UserData',[]);
    set(flb.pb_8_18,'UserData',[]);
    set(flb.pb_10_14,'UserData',1);
    set(flb.listbox,'Value',(10:14)+1);
end