function handles = update_NVIEW_control_panel(handles, text, append_strategy)

% Update NVIEW control panel
if strcmpi(append_strategy, 'append')
    old_text = get(handles.static_text_result_details, 'String');
    old_text_oneline = [];
    for i=1:(size(old_text,1)-1)
        old_text_oneline = [old_text_oneline,old_text(i,:),'\n']; %#ok<AGROW>
    end
    old_text_oneline = [old_text_oneline,strtrim(old_text(i+1,:))];
    new_text = [old_text_oneline,text];
    text = new_text;
elseif strcmpi(append_strategy, 'clear')
    set(handles.static_text_result_details, 'String','','FontName','MS Sans Serif');
else
    error('Unknown append strategy.')
end

% Update static text result details - NVIEW Content panel

set(handles.static_text_result_details, 'String', ...
    sprintf(text));

drawnow;
return;