classdef CANCEL_button_handler < handle
	%CANCEL_BUTTON_HANDLER  Operates the cancel button within an GUI
	%   CANCEL_BUTTON_HANDLER gives the functionalities to ensure the correct behaviour of
	%   an cancel button within a GUI. 
	%   It allows to disable other graphics elements during an operation and activates
	%   them, if cancelation of a process was initiated by pushing the button with handle
	%   HANDLE_CANCELBUTTON. Within the Callback function of HANDLE_CANCELBUTTON must the
	%   method OBJ.CANCEL_BUTTON_PUSHED be called. 
	%   To get sure, the pushing of the cancel button is recognized, the function DRAWNOW
	%   has to be called at suitable points within the process. With calling this
	%   function, all callbacks are executed, which is neccessary for recognition of the
	%   canceling wish of the user. 
	
	% Version:                 1.0
	% Created by:              Franz Zeilinger - 09.05.2018
	% Last change by:
	
	properties
		handle_cancelbutton
		cancel_pushed = false
		handles_deactivated_uielements
	end
	
	methods
		function obj = CANCEL_button_handler (handle_cancelbutton)
			obj.handle_cancelbutton = handle_cancelbutton;
		end
		
		function value = was_cancel_pushed(obj)
			value = obj.cancel_pushed;
		end
		
		function obj = cancel_button_pushed(obj)
			obj.cancel_pushed = true;
		end
		
		function obj = reset_cancel_button(obj)
			obj.cancel_pushed = false;
			set(obj.handle_cancelbutton, 'Enable', 'off');
			for a=1:numel(obj.handles_deactivated_uielements)
				set(obj.handles_deactivated_uielements{a}, 'Enable', 'on');
			end
			obj.handles_deactivated_uielements = {};
		end
		
		function obj = set_cancel_button(obj, varargin)
			obj.reset_cancel_button();
			set(obj.handle_cancelbutton, 'Enable', 'on');
			obj.handles_deactivated_uielements = varargin;
			for a=1:numel(obj.handles_deactivated_uielements)
				try
					set(obj.handles_deactivated_uielements{a}, 'Enable', 'off');
				catch ME
					exception = MException(...
						'CANCEL_button_handler:SetCancelButton:InvalidGraphicsHandle',...
						'Invalid handle to a graphics object!');
					throw(exception);
				end
			end
			drawnow();
		end
	end
end

