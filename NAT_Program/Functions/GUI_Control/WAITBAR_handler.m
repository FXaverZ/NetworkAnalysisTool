classdef WAITBAR_handler < handle
	%WAITBAR_HANDLER   operates a waitbar within a GUI
	%   Detailed explanation goes here
	
	% Version:                 1.0
	% Created by:              Franz Zeilinger - 09.05.2018
	% Last change by:
	
	properties
		handle_waitbar_white
		handle_waitbar_color
		handle_waitbar_textf
		
		counter
		tic_start
		end_pos
	end
	
	methods
		
		function obj = WAITBAR_handler(han_wb_wh, han_wb_co, han_wb_tf)
			obj.handle_waitbar_white = han_wb_wh;
			obj.handle_waitbar_color = han_wb_co;
			obj.handle_waitbar_textf = han_wb_tf;
		end
		
		function obj = start(obj, end_pos)
			obj.reset();
			obj.counter = 1;
			obj.tic_start = tic();
			obj.end_pos = end_pos;
		end
		
		function obj = update(obj, cur_pos)
			time = toc(obj.tic_start);
			
			% Fortschritt berechnen:
			progress = cur_pos/obj.end_pos;
			% Restliche Zeit ermitteln:
			sec_remain = time/progress - time;
			
			string = [num2str(progress*100,'%4.1f'),...
				' % erledigt, ca. ', sec2str(sec_remain),' Restdauer'];
			
			set(obj.handle_waitbar_textf,'String',string);
			% Balkenlänge anpassen:
			pos = get(obj.handle_waitbar_white,'Position');
			pos(3) = progress*pos(3);
			set(obj.handle_waitbar_color,'Position',pos);
			drawnow;
		end
		
		function obj = reset(obj)
			obj.tic_start = [];
			
			set(obj.handle_waitbar_textf,'String',' ');
			pos = get(obj.handle_waitbar_color,'Position');
			pos(3) = 0.05;
			set(obj.handle_waitbar_color,'Position',pos);
			drawnow;
		end
	end
	
end

