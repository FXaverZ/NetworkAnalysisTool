function refresh_message_text_operation_finished (handles)
%REFRESH_MESSAGE_TEXT_OPERATION_FINISHED Summary of this function goes here
%   Detailed explanation goes here

handles.text_message_main_handler.reset_level();
handles.text_message_main_handler.divider('- ');
handles.text_message_main_handler.save_message_text();

end

