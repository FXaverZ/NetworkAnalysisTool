function [Ilim_user] = edit_text_selection_current_limits(handles)

% Default values
Ilim_user = [];
if ~isfield(handles,'NVIEW_Analysis_Selection')
    return;
end

Ilim_default = handles.NVIEW_Analysis_Selection.Ilim;

% Pop up window
flb.window  = figure('menubar','none','units','pixels','position',[540 400 300 100],...
    'numbertitle','off','name','Current limits','resize','off','CloseRequestFcn',{@my_closereq});

flb.statictext_title =  uicontrol('style','text','units','pix','position',[10 70 175 20],'string','Branch current limit selection','BackgroundColor', get(flb.window,'Color' ));

flb.editbox_Ilim = uicontrol('style','edit','units','pix','position',[160 45 125 20],'string',int2str(Ilim_default));

flb.text_Ilim =  uicontrol('style','text','units','pix','position',[10 45 125 20],'string','Current limit ... %','BackgroundColor', get(flb.window,'Color' ));

flb.pb_ok_edit   = uicontrol('style','pushbutton','units','pix','position',[60 10 75 20],'string','OK','callback',{@pb_ok_edit_call,flb});
flb.pb_cancel_edit = uicontrol('style','pushbutton','units','pix','position',[160 10 75 20],'string','Cancel','callback',{@pb_cancel_edit_call,flb});

%  set(flb.pb_ok,'UserData',0);
guidata(flb.pb_ok_edit,flb);
guidata(flb.pb_cancel_edit,flb);

gui_cond = 0;
while gui_cond < 1
    uiwait(flb.window);    
    % Check if ok button is pressed
    if ~isempty(get(flb.pb_ok_edit,'UserData'))
        if get(flb.pb_ok_edit,'UserData') == 1            
            Ilim_user = str2double(get(flb.editbox_Ilim,'String'));
            
            if ~(isnan(Ilim_user) || sign(Ilim_user) == -1 || Ilim_user == 0 )
                gui_cond = 1;                
                break;
            else
                % Invalid number, reset to default values
                % Which value is erronous
              
                     set(flb.editbox_Ilim,'String',int2str(Ilim_default));
                Ilim_user = [];
                Umax_user = [];
            end
            
        elseif get(flb.pb_ok_edit,'UserData') == 2
            Ilim_user = [];
            gui_cond = 1;
            break;
        end
    end
end
delete(flb.window)
end


function [] = my_closereq(varargin)
    flb = guidata(gcbf);
    set(flb.pb_ok_edit,'UserData',2);
    uiresume(flb.window);
end

function [] = pb_ok_edit_call(varargin)
    flb = guidata(gcbf);  % Get the structure.
    set(flb.pb_ok_edit,'UserData',1)
    uiresume(flb.window)
end
function [] = pb_cancel_edit_call(varargin)
    flb = guidata(gcbf);  % Get the structure.
    set(flb.pb_ok_edit,'UserData',2);
    uiresume(flb.window);
end