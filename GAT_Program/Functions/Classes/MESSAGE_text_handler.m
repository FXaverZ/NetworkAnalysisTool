classdef MESSAGE_text_handler < handle
	%MESSAGE_TEXT_HANDLER   Class to provide methods to manage GUI text fields
	%   Detailed explanation goes here

	% Version:                 1.0
	% Created by:              Franz Zeilinger - 01.10.2015
	% Last change by:          

	properties
		Current_Text_to_Display
		Current_Text_to_Save
		MAX_Lines = 0
		Line_Count
		handle_textfield
	end
	
	methods
		function obj = MESSAGE_text_handler(handle_textfield, varargin)
			obj.handle_textfield = handle_textfield;
			if nargin > 1
				 warning('Feature not inplemented yet')
			end
		end
		
	end
	
end

