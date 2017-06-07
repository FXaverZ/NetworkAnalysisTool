classdef MESSAGE_text_handler < handle
	%MESSAGE_TEXT_HANDLER   Class to provide methods to manage GUI text fields
	%   Detailed explanation goes here

	% Version:                 1.0
	% Created by:              Franz Zeilinger - 01.10.2015
	% Last change by:          Franz Zeilinger - 07.12.2016

	properties
		Current_Text_to_Display = {}
		Current_Text_to_Save = {}
		MAX_Lines = 0
		MAX_Colum = 0
		Line_Count_Display = 0
		Line_Count_Overall = 0
		handle_textfield
		
		OutputFile = []
		
		Current_Level = 0
		Blanks_per_Level = 4;
		
		OutputFile_handle
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
					obj.handle_textfield.Position(4)/(fs*1.3047));
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
		
		function obj = add_lines(obj, add_cell)
			if ~iscell(add_cell)
				exception = MException('MESSAGEtestHandler:WrongInput',...
					'Only cells can be proczessed!');
				throw(exception);
			end
			if ~ndims(add_cell) == 2
				exception = MException('MESSAGEtestHandler:WrongInput',...
					'Only two dimensional cells can be processed!');
				throw(exception);
			end
			s = size (add_cell);
			for i=1:s(1)
				obj.add_line(add_cell{i,:});
			end
		end
		
		function obj = add_line(obj, add_string, varargin)
			if obj.Line_Count_Display >= obj.MAX_Lines
				obj.rem_first_line();
			end
			
			if nargin > 2
				for i=1:nargin-2
					str = varargin{i};
					if isnumeric(str)
						str = num2str(str);
					end
					add_string = [add_string, str]; %#ok<AGROW>
				end
			end
			
			add_string = strrep(add_string,'\','\\');
			add_string = sprintf([blanks(obj.Current_Level*obj.Blanks_per_Level),add_string]);
			
			obj.Current_Text_to_Save{end+1} = add_string;
			obj.Line_Count_Overall = obj.Line_Count_Overall + 1;
			
			if numel(add_string) >= obj.MAX_Colum
				add_string=[add_string(1:obj.MAX_Colum-5),' ...'];
			end
			
			obj.Current_Text_to_Display{end+1} = add_string;
			obj.Line_Count_Display = obj.Line_Count_Display + 1;
			
			obj.handle_textfield.set('String',obj.Current_Text_to_Display);
		end
		
		function obj = rem_line(obj)
			obj.Current_Text_to_Display = obj.Current_Text_to_Display(1:end-1);
			obj.Line_Count_Display = obj.Line_Count_Display - 1;
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
		
		function obj = level_up(obj, varargin)
			if nargin > 1
				obj.Current_Level = obj.Current_Level - varargin{1};
			else
				obj.Current_Level = obj.Current_Level - 1;
			end
			if obj.Current_Level < 0
				obj.Current_Level = 0;
			end
		end
		
		function obj = level_down(obj, varargin)
			if nargin > 1
				obj.Current_Level = obj.Current_Level + varargin{1};
			else
				obj.Current_Level = obj.Current_Level + 1;
			end
		end
		
		function obj = save_message_text(obj)
			if isempty(obj.OutputFile)
				warning('No outputfile was specified!');
				return;
			end
			
			if isempty(obj.OutputFile_handle)
				obj.OutputFile_handle = fopen(obj.OutputFile,'w');
			end
			for i=1:numel(obj.Current_Text_to_Save)
				obj.Current_Text_to_Save{i} = strrep(obj.Current_Text_to_Save{i},'\','\\');
				fprintf(obj.OutputFile_handle,[obj.Current_Text_to_Save{i},'\n']);
			end
			
			obj.Current_Text_to_Save = {};
		end
		
		function obj = divider(obj, charakter, varargin)
			if nargin == 2
				str = repmat(charakter,1,obj.MAX_Colum-1);
			else
			end
			obj.add_line(str);
		end
	end
	
end

