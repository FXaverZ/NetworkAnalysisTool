function handles = get_input_LV_from_results(handles)
%GET_INPUT_LV_FROM_RESULTS Summary of this function goes here
%   Detailed explanation goes here

mh = handles.text_message_main_handler;

errorstr = 'Currently not supported!';
errordlg(errorstr);
mh.add_error(errorstr);

%TODO: Extraction of Input-Data out of Simulation Resluts...
end

