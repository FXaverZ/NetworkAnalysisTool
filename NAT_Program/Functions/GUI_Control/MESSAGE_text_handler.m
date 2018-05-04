classdef MESSAGE_text_handler < handle
	%MESSAGE_TEXT_HANDLER   Class to provide methods to manage GUI text fields
	%   Detailed explanation goes here

	% Version:                 1.1
	% Created by:              Franz Zeilinger - 01.10.2015
	% Last change by:          Franz Zeilinger - 04.05.2018

	properties
		Current_Text_to_Display = {}
		Current_Text_to_Save = {}
		MAX_Lines = 0
		MAX_Colum = 0
		
		Line_Count_Display = 0
		Line_Count_Overall = 0
		Line_Count_Saved = 0
		
		handle_textfield
		
		OutputToConsole = false
		
		OutputFile = []
		
		Current_Level = 0
		Blanks_per_Level = 4;
		
		OutputFile_handle
		
		Sub_Log_Marker = {
			'Line_Count_Overall';...
			'Current_Level';...
			'OutputFileHandle';...
			'OutputFile';...
			};
	end
	
	methods
		function obj = MESSAGE_text_handler(handle_textfield, varargin)
			obj.handle_textfield = handle_textfield;
			
			% Sind die Argumente Zweiergruppen --> wenn nicht --> Fehler:
			if (mod(nargin-1,2) == 0)
				% Durchlaufen aller Eingangsparameter (in 2er Schritten):
				for i = 1:2:(nargin-1)
					% Erster Teil: Parametername, ist dieser ein String -->
					% wenn nicht --> Fehler:
					if ischar(varargin{i})
						try
							obj.(varargin{i}) = varargin{i+1};
						catch ME
							error('messagetexthandler:paramlist',...
								['Fehler beim Bearbeiten des Parameters ''',...
								varargin{i},''' ist folgender Fehler aufgetreten: ',...
								ME.message]);
						end
					else
						% Fehler, weil erster Eintrag in Parameterliste kein
						% Text war:
						error('messagetexthandler:paramlist', ['Wrong inputarguments.',...
							' Input looks like (''Parameter_Name'',',...
							' Parameter Value)']);
					end
				end
			else
				% Fehler, weil Parameter nicht in Dreiergruppe übergeben wurde:
				error('messagetexthandler:paramlist', ['Wrong inputarguments.',...
					' Input looks like (''Parameter_Name'',',...
					' Parameter Value)']);
			end
			
			obj.handle_textfield.set('Units','points','FontName','Courier New');
			fs = get(obj.handle_textfield,'FontSize');
			if (fs > 9.5) && (fs <= 10.5)
				obj.MAX_Lines = floor(...
					obj.handle_textfield.Position(4)/(fs*1.1928));
				obj.MAX_Colum = floor(...
					obj.handle_textfield.Position(3)/(fs*0.5988));
			elseif (fs > 7.5) && (fs <= 8.5)
				obj.MAX_Lines = ceil(...
					obj.handle_textfield.Position(4)/(fs*1.3047))-1;
				obj.MAX_Colum = ceil(...
					obj.handle_textfield.Position(3)/(fs*0.66))+1;
			else
				error('messagetexthandler:paramlist', ['Wrong fontsize.',...
					' Currently only fontsizes of 10 and 8 points are supported!']);
			end
			
			obj.handle_textfield.set('String','');
		end
		
		function delete(obj)
			if ~isempty(obj.OutputFile_handle)
				fclose(obj.OutputFile_handle);
			end
		end
		
		function obj = add_line(obj, varargin)
			if obj.Line_Count_Display >= obj.MAX_Lines
				obj.rem_first_line();
			end
			add_string = [];
			for a=1:nargin-1
				str = varargin{a};
				if ~ischar(str)
					try
						str = num2str(str);
					catch
						str = '';
					end
				end
				add_string = [add_string, str]; %#ok<AGROW>
			end
			
			add_string = [blanks(obj.Current_Level*obj.Blanks_per_Level),add_string];
			obj.Current_Text_to_Save{end+1} = add_string;
			obj.Line_Count_Overall = obj.Line_Count_Overall + 1;
			if obj.OutputToConsole
				disp(add_string);
			end
			
			if numel(add_string) >= obj.MAX_Colum
				add_string=[add_string(1:obj.MAX_Colum-5),' ...'];
			end
			
			obj.Current_Text_to_Display{end+1} = add_string;
			obj.Line_Count_Display = obj.Line_Count_Display + 1;
			
			obj.handle_textfield.set('String',obj.Current_Text_to_Display);
		end
		
		function obj = add_error(obj, varargin)
			obj.add_line('ERROR: ',varargin{:});
		end
		
		function obj = add_warning(obj, varargin)
			obj.add_line('WARNING: ',varargin{:});
		end
		
		function obj = remove_line (obj, varargin)
			if nargin == 1
				lines_to_remove = 1;
			elseif nargin == 2
				lines_to_remove = varargin{1};
			end
			if lines_to_remove > obj.Line_Count_Display
				obj.reset_text();
				return;
			end
			obj.Current_Text_to_Display = obj.Current_Text_to_Display(1:end-lines_to_remove);
			obj.Line_Count_Display = obj.Line_Count_Display - lines_to_remove;
			if obj.Line_Count_Display < 0
				obj.Line_Count_Display = 0;
			end
			obj.handle_textfield.set('String',obj.Current_Text_to_Display);
		end
		
		function obj = rem_first_line(obj)
			obj.Current_Text_to_Display = obj.Current_Text_to_Display(2:end);
			obj.Line_Count_Display = obj.Line_Count_Display - 1;
			if obj.Line_Count_Display < 0
				obj.Line_Count_Display = 0;
			end
			obj.handle_textfield.set('String',obj.Current_Text_to_Display);
		end
		
		function obj = reset_text(obj)
			obj.Current_Text_to_Display = {};
			obj.Line_Count_Display = 0;
			obj.handle_textfield.set('String',obj.Current_Text_to_Display);
		end
		
		function obj = level_down(obj)
			obj.Current_Level = obj.Current_Level - 1;
			if obj.Current_Level < 0
				obj.Current_Level = 0;
			end
		end
		
		function obj = level_up(obj)
			obj.Current_Level = obj.Current_Level + 1;
		end
		
		function obj = reset_level(obj)
			obj.Current_Level = 0;
		end
		
		function obj = set_OutputFile (obj, outputfilename)
			obj.OutputFile = outputfilename;
		end
		
		function obj = save_message_text(obj)
			if isempty(obj.OutputFile)
				warning('No outputfile was specified!');
				return;
			end
			
			if isempty(obj.OutputFile_handle)
				obj.OutputFile_handle = fopen(obj.OutputFile,'a');
			end
			for i=obj.Line_Count_Saved+1:numel(obj.Current_Text_to_Save)
				savestr = strrep(obj.Current_Text_to_Save{i},'\','\\');
				fprintf(obj.OutputFile_handle,[savestr,'\n']);
			end
			
			obj.Line_Count_Saved = obj.Line_Count_Overall;
		end
		
		function obj = divider(obj, charakter, varargin)
			if nargin == 2
				str = repmat(charakter,1,obj.MAX_Colum-1);
				str = str(1:obj.MAX_Colum-1);
			else
			end
			obj.add_line(str);
		end
		
		function obj = mark_sub_log (obj, outputfilename)
			obj.clear_saved_text();
			obj.Sub_Log_Marker{1,end+1} = obj.Line_Count_Overall;
			obj.Sub_Log_Marker{2,end} = obj.Current_Level;
			obj.Sub_Log_Marker{3,end} = fopen(outputfilename,'a');
			obj.Sub_Log_Marker{4,end} = outputfilename;
		end
		
		function obj = reset_sub_logs (obj)
			obj.write_sub_logs();
			for a = 2:size(obj.Sub_Log_Marker,2)
				fclose(obj.Sub_Log_Marker{3,a});
			end
			obj.Sub_Log_Marker = {
				'Line_Count_Overall';...
				'Current_Level';...
				'OutputFileHandle';...
				'OutputFile';...
				};
			obj.clear_saved_text();
		end
		
		function obj = stop_sub_log (obj, outputfilename)
			idx = strcmp(outputfilename, obj.Sub_Log_Marker(4,:));
			fclose(obj.Sub_Log_Marker{3,idx});
			obj.Sub_Log_Marker = obj.Sub_Log_Marker(:,~idx);
		end
		
		function obj = clear_saved_text(obj)
			if obj.Line_Count_Saved == obj.Line_Count_Overall
				obj.Line_Count_Saved = 0;
				obj.Line_Count_Overall = 0;
				obj.Current_Text_to_Save = {};
			end
			obj.Current_Text_to_Save = obj.Current_Text_to_Save(obj.Line_Count_Saved+1:obj.Line_Count_Overall);
			obj.Line_Count_Overall = numel(obj.Current_Text_to_Save);
			obj.Line_Count_Saved = 0;
		end
		
		function write_sub_logs (obj)
			for a = 2:size(obj.Sub_Log_Marker,2)
				if obj.Sub_Log_Marker{1,a} >= obj.Line_Count_Overall
					continue;
				end
				for b = obj.Sub_Log_Marker{1,a}+1:numel(obj.Current_Text_to_Save)
					savestr = strrep(obj.Current_Text_to_Save{b},'\','\\');
					savestr = savestr(obj.Blanks_per_Level*obj.Sub_Log_Marker{2,a}+1:end);
					fprintf(obj.Sub_Log_Marker{3,a},[savestr,'\n']);
				end
				obj.Sub_Log_Marker{1,a} = obj.Line_Count_Overall;
			end
			obj.clear_saved_text();
		end
	end
	
end

