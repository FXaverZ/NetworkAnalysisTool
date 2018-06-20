classdef WAITBAR_handler < handle
	%WAITBAR_HANDLER   operates a waitbar within a GUI
	%   prerequisite: there are three graphical elements:
	%      handles.waitbar_white : textfield with neutral color which marks the position
	%                              of the waitbar. 'String' is empty.
	%      handles.waitbar_color : textfield with signal color to mark the current
	%                              progress. Should have the same position as the
	%                              waitbar_white textfield. 'String' is empty.
	%      handles.waitbar_text  : Textfield within the waitbar to print current progress
	%                              information.
	%
	%   WAITBAR_HANDLER is then created as follows:
	%   wb = WAITBAR_handler(handles.waitbar_white, handles.waitbar_color,...
	%      handles.waitbar_text);
	% 
	%   Sample code for usage of the waitbar handler:
	%    % 1st reset the waitbar:
	%    wb.reset();
	%    % define the working environment in form of the size of the single for loops (has
	%    % to be done in advance or just once before the coresponding for-loop starts): 
	%    counidx_i = wb.add_end_position(5);
	%    counidx_j = wb.add_end_position(10);
	%    counidx_k = wb.add_end_position(15);
	%    counidx_l = wb.add_end_position(20);
	%    % start the waitbar time measurement
	%    wb.start();
	%    for i = 1:5
	%    	% just after the for-loop intro update the corresponding counter:
	%    	wb.update_counter(counidx_i, i);
	%    	for j = 1:10
	%    		wb.update_counter(counidx_j, j);
	%    		for k=1:15
	%    			wb.update_counter(counidx_k, k);
	%    			for l=1:20
	%    				wb.update_counter(counidx_l, l);
	%    				% - - - - - - - - - - - - 
	%    				% Insert your code here, e.g. 
	%    				result = sum([i,j,k,l]);
	%    				disp(result);
	%    				% - - - - - - - - - - - - 
	%    				% if needed makr a update of the waitbar. Here the graphic is
	%    				% updated. It is recommended to reduce this operation as less as
	%    				% needed, to avoid unneccesary operations wihtin the calling
	%    				% functions: 
	%    				if mod(l,10) == 0
	%    					wb.update();
	%    				end
	%    			end
	%    		end
	%    	end
	%    end
	%    % Stop the time measurement and give the user the information about the overall needed
	%    % time:
	%    needed_time = wb.stop();
	%    disp(needed_time);
	
	% Version:                 1.1
	% Created by:              Franz Zeilinger - 09.05.2018
	% Last change by:          Franz Zeilinger - 20.06.2018
	
	properties
		handle_waitbar_white
		handle_waitbar_color
		handle_waitbar_textf
		
		counter = [];
		tic_start
		end_pos = [];
		end_pos_marker = {};
		end_pos_total = 1;
		multiplikators = [];
		
	end
	
	methods
		
		function obj = WAITBAR_handler(han_wb_wh, han_wb_co, han_wb_tf)
			obj.handle_waitbar_white = han_wb_wh;
			obj.handle_waitbar_color = han_wb_co;
			obj.handle_waitbar_textf = han_wb_tf;
		end
		
		function obj = start(obj)
			obj.tic_start = tic();
		end
		
		function add_end_position(obj, end_pos_marker, end_pos)
			idx = find(strcmp(obj.end_pos_marker, end_pos_marker), 1);
			if isempty(idx)
				obj.end_pos(end+1) = end_pos;
				obj.end_pos_marker{end+1} = end_pos_marker;
				obj.counter(end+1) = 0;
			else
				return;
			end
			
			end_pos_tot = 1;
			for a=1:numel(obj.end_pos)
				end_pos_tot = end_pos_tot*obj.end_pos(a);
			end
			obj.end_pos_total = end_pos_tot;
			
			% prepare a arry to know, how many steps were made in the underlying loop
			% iterators
			if numel(obj.end_pos) > 1
				obj.multiplikators = zeros(size(obj.end_pos));
				obj.multiplikators(end-1) = obj.end_pos(end);
				for i = numel(obj.multiplikators)-1:-1:1
					if i > 1
						obj.multiplikators(i-1) = obj.multiplikators(i) * obj.end_pos(i);
					end
				end
				obj.multiplikators = obj.multiplikators(1:end-1);
			else
				% if only one loop iterator exists, mark this with an empty array:
				obj.multiplikators = [];
			end
		end
		
		function obj = update_counter (obj, index_marker, cur_pos)
			idx = strcmp(obj.end_pos_marker, index_marker);
			obj.counter(idx) = cur_pos;
		end
		
		function obj = update(obj)
			time = toc(obj.tic_start);
			
			% add allways a dummy loop iterator to deal with the case, that only one loop
			% iterator is observed. so the following code needs no IF statement:
			cur_count = [1, obj.counter];
			cur_count(1:end-1) = cur_count(1:end-1) - 1;
			% get the current allready finished iterations
			cur_pos = sum(cur_count(1:end-1).* [0, obj.multiplikators]) + cur_count(end);
			
			% Fortschritt berechnen:
			progress = cur_pos/obj.end_pos_total;
			% Restliche Zeit ermitteln:
			sec_remain = time/progress - time;
			
			% update text:
			string = [num2str(progress*100,'%4.1f'),...
				'% done, approx. ', sec2str(sec_remain),' remaining'];
			set(obj.handle_waitbar_textf,'String',string);
			
			% Balkenlänge anpassen:
			pos = get(obj.handle_waitbar_white,'Position');
			pos(3) = progress*pos(3);
			set(obj.handle_waitbar_color,'Position',pos);
			drawnow;
		end
		
		function time = stop(obj)
			time = toc(obj.tic_start);
			string = [num2str(100,'%4.1f'),...
				'% done in ', sec2str(time)];
			set(obj.handle_waitbar_textf,'String',string);
			obj.tic_start = [];
		end
		
		function obj = reset(obj)
			obj.tic_start = [];
			obj.counter = [];
			obj.end_pos = [];
			obj.end_pos_total = 1;
			obj.multiplikators = [];
			obj.end_pos_marker = {};
			set(obj.handle_waitbar_textf,'String',' ');
			pos = get(obj.handle_waitbar_color,'Position');
			pos(3) = 0.05;
			set(obj.handle_waitbar_color,'Position',pos);
			drawnow;
		end
	end
	
end

