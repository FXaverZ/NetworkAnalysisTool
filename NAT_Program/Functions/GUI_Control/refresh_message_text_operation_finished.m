function refresh_message_text_operation_finished (handles)
%REFRESH_MESSAGE_TEXT_OPERATION_FINISHED Summary of this function goes here
%   Detailed explanation goes here

mh = handles.text_message_main_handler;

mh.reset_level();
mh.divider('- ');
mh.save_message_text();
mh.reset_sub_logs();
mh.reset_all_display_marker();
end

