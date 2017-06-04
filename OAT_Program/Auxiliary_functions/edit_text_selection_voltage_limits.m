function [Umin_user,Umax_user] = edit_text_selection_voltage_limits(handles)

% Default values
Umin_user = []; Umax_user = [];
if ~isfield(handles,'NVIEW_Analysis_Selection')
    return;
end

Umin_default = handles.NVIEW_Analysis_Selection.Umin;
Umax_default = handles.NVIEW_Analysis_Selection.Umax;

% Pop up window
flb.window  = figure('menubar','none','units','pixels','position',[540 400 300 120],...
    'numbertitle','off','name','Voltage limit violations','resize','off','CloseRequestFcn',{@my_closereq});

flb.statictext_title =  uicontrol('style','text','units','pix','position',[10 95 175 20],'string','Node Voltage violation limit selection','BackgroundColor', get(flb.window,'Color' ));

flb.editbox_Umin = uicontrol('style','edit','units','pix','position',[160 70 125 20],'string',int2str(Umin_default));
flb.editbox_Umax = uicontrol('style','edit','units','pix','position',[160 42 125 20],'string',int2str(Umax_default));

flb.text_Umin =  uicontrol('style','text','units','pix','position',[10 70 125 20],'string','Minimum voltages ... %','BackgroundColor', get(flb.window,'Color' ));
flb.text_Umax =  uicontrol('style','text','units','pix','position',[10 42 125 20],'string','Maximum voltages ... %','BackgroundColor', get(flb.window,'Color' ));

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
            Umin_user = str2double(get(flb.editbox_Umin,'String'));
            Umax_user = str2double(get(flb.editbox_Umax,'String'));            
            
            if ~(isnan(Umin_user) || isnan(Umax_user) || (sign(Umin_user) == -1 || sign(Umax_user) == -1 || Umin_user == 0 || Umax_user == 0) || (abs(Umax_user) <= abs(Umin_user)) )% Values should be positive!
                gui_cond = 1;                
                break;
            else
                % Invalid number, reset to default values
                % Which value is erronous
                Umin_input_error = isnan(Umin_user) || sign(Umin_user) == -1 || Umin_user == 0 || (abs(Umax_user) <= abs(Umin_user));
                Umax_input_error = isnan(Umax_user) || sign(Umax_user) == -1 || Umax_user == 0 || (abs(Umax_user) <= abs(Umin_user));
                
                if Umin_input_error && ~Umax_input_error
                     set(flb.editbox_Umin,'String',int2str(Umin_default));
                     set(flb.editbox_Umin,'String',int2str(Umax_user));
                elseif ~Umin_input_error && Umax_input_error
                    set(flb.editbox_Umin,'String',int2str(Umin_user));
                    set(flb.editbox_Umax,'String',int2str(Umax_default));                    
                elseif  Umin_input_error && Umax_input_error
                    set(flb.editbox_Umin,'String',int2str(Umin_default));
                    set(flb.editbox_Umax,'String',int2str(Umax_default));
                end
                Umin_user = [];
                Umax_user = [];
                set(flb.pb_ok_edit,'UserData',[]);
            end
            
        elseif get(flb.pb_ok_edit,'UserData') == 2
            Umin_user = [];
            Umax_user = [];
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