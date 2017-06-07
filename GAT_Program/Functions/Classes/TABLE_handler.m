classdef TABLE_handler < handle
	%TABLE_HANDLER Summary of this class goes here
	%   Detailed explanation goes here
	
	% Version:                 1.0
	% Created by:              Franz Zeilinger - 07.12.2016
	% Last change by:
	
	properties
		handle_table
		Data
		ColumnName
		ColumnFormat
		ColumnEditable
		ColumnWidth
		RowName
	end
	
	methods
		function obj = TABLE_handler(handle_table, varargin)
			obj.handle_table = handle_table;
			if nargin > 1
				obj.update_settings(varargin{:});
			else
				obj.update_settings(...
					'Data'          ,{'Nothing to show',  0.0,                               'None'},...
					'ColumnName'    ,{   'Name', 'Data Value',                      'Data Selector'},...
					'ColumnFormat'  ,{   'char',    'numeric', {'Selection_1','Selection_2','None'}},...
					'ColumnEditable',[    false,        false,                                 true],...
					'ColumnWidth',   {   'auto',           80,                                  160},...
					'RowName',       {});
			end
			obj.update_table();
			
		end
		
		function update_settings(obj, varargin)
			%UPDATE_SETTINGS    Ergänzt Parametereinstellungen der Klasse
			%    genaue Beschreibung fehlt!
			
			% wurden noch Parameter übergeben?
			if nargin == 1
				return;
			end
			
			% Sind die Argumente Zweiergruppen --> wenn nicht --> Fehler:
			if (mod(nargin-1,2) == 0)
				% Durchlaufen aller Eingangsparameter (in 2er Schritten):
				for i = 1:2:nargin-1
					% Erster Teil: Parametername, ist dieser ein String -->
					% wenn nicht --> Fehler:
					if ischar(varargin{i})
						try
							obj.update_parameter(varargin{i}, varargin{i+1});
						catch ME
							% Falls Fehler passieren, dies melden und weiterreichen:
							exception = MException(...
								'TABLE_handler:UpdateSettings:Error',...
								['When processing the parameter ''',...
								varargin{i},''' a error occured!']);
							exception = addCause (ME, exception);
							throw(exception);
						end
					else
						% Fehler, weil erster Eintrag in Parameterliste kein
						% Text war:,
						exception = MException(...
							'TABLE_handler:UpdateSettings:WrongParameterName',...
							['Wrong inputarguments. Input looks like ',...
							'(''Parameter_Name'', Value)']);
						throw(exception);
					end
				end
			else
				% Fehler, weil Parameter nicht in Zweiergruppe übergeben wurde:
				exception = MException(...
					'TABLE_handler:UpdateSettings:WrongNumberArgs', ...
					['Wrong number of inputarguments. Input looks like ',...
					'(''Parameter_Name'', Value)']);
				throw(exception);
			end
		end
		
		function update_table(obj)
			set(obj.handle_table, ...
				'Data', obj.Data, ...
				'ColumnName', obj.ColumnName,...
				'ColumnFormat', obj.ColumnFormat,...
				'ColumnEditable', obj.ColumnEditable,...
				'ColumnWidth', obj.ColumnWidth,...
				'RowName', obj.RowName);
		end
		
		function edit_column(obj, Position, varargin)
			if ischar(Position)
				Position = find(strcmp(obj.ColumnName,Position),1);
				if isempty(Position)
					return;
				end
			end
			if (mod(nargin-2,2) == 0)
				% Durchlaufen aller Eingangsparameter (in 2er Schritten):
				for i = 1:2:nargin-2
					% Erster Teil: Parametername, ist dieser ein String -->
					% wenn nicht --> Fehler:
					if ischar(varargin{i})
						try
							obj.update_parameter(varargin{i}, varargin{i+1}, Position)
						catch ME
							% Falls Fehler passieren, dies melden und weiterreichen:
							exception = MException(...
								'TABLE_handler:UpdateSettings:Error',...
								['When processing the parameter ''',...
								varargin{i},''' a error occured!']);
							exception = addCause (ME, exception);
							throw(exception);
						end
					else
						% Fehler, weil erster Eintrag in Parameterliste kein
						% Text war:,
						exception = MException(...
							'TABLE_handler:UpdateSettings:WrongParameterName',...
							['Wrong inputarguments. Input looks like ',...
							'(''Parameter_Name'', Value)']);
						throw(exception);
					end
				end
			end
			
			obj.update_table();
		end
		
		function add_column(obj, Position, ColumnName, ColumnFormat, ColumnEditable, ColumnWidth, Data)
			num_cols = numel(obj.ColumnName);
			if ischar(Position)
				Position = find(strcmp(obj.ColumnName,Position),1);
			end
			if Position >= num_cols
				Position = num_cols + 1;
			end
			obj.ColumnName{end+1} = ColumnName;
			obj.ColumnFormat{end+1} = ColumnFormat;
			obj.ColumnEditable(end+1) = ColumnEditable;
			obj.ColumnWidth{end+1} = ColumnWidth;
			obj.Data{:,end+1} = deal (Data);
			
			idx = 1:num_cols+1;
			idx_new = [idx(1:Position-1),idx(end),idx(Position:end-1)];
			
			obj.ColumnName = obj.ColumnName(idx_new);
			obj.ColumnFormat = obj.ColumnFormat(idx_new);
			obj.ColumnEditable = obj.ColumnEditable(idx_new);
			obj.ColumnWidth = obj.ColumnWidth(idx_new);
			obj.Data = obj.Data(:,idx_new);
			
			obj.update_table;
		end
		
		function remove_column(obj, Position)
			obj.ColumnName(Position) = [];
			obj.ColumnFormat(Position) = [];
			obj.ColumnEditable(Position) = [];
			obj.ColumnWidth(Position) = [];
			obj.Data(:,Position) = [];
			
			obj.update_table;
		end
		
		function edit_row(obj, Position, Col_Identifier, Data)
			Position = obj.get_row_position(Position, Col_Identifier);
			if isempty(Position)
				return;
			end
				
			obj.Data(Position,:) = Data;
			obj.update_table;
		end
		
		function add_row(obj, Position, Col_Identifier, Data)
			Position = obj.get_row_position(Position, Col_Identifier);
			if isempty(Position)
				return;
			end
			
			obj.Data(end+1,:) = Data;
			idx = 1:size(obj.Data,1);
			idx_new = [idx(1:Position-1),idx(end),idx(Position:end-1)];
			
			obj.Data = obj.Data(idx_new,:);
		end
		
		function remove_row (obj, Position, Col_Identifier)
			Position = obj.get_row_position(Position, Col_Identifier);
			if isempty(Position)
				return;
			end
			
			obj.Data(Position,:) = [];
		end
	end
	
	methods (Hidden)
		
		function Position = get_row_position(obj, Position, Col_Identifier)
			if ~isempty(Col_Identifier) && ischar(Col_Identifier)
				idx_col = find(strcmp(obj.ColumnName,Col_Identifier),1);
			elseif ~isempty(Col_Identifier)
				idx_col = Col_Identifier;
			else
				idx_col = [];
			end
			
			if ischar(Position) && ~isempty(idx_col) && strcmpi(obj.ColumnFormat{idx_col},'char')
				Position = find(strcmp(obj.Data(:,idx_col),Position),1);
			elseif ischar(Position) && (isempty(idx_col) || ~strcmpi(obj.ColumnFormat{idx_col},'char'))
				Position = [];
			end
			if isnumeric(Position)
				if Position > size(obj.Data,1)
					Position = size(obj.Data,1);
				end
			else
				Position = [];
			end
		end
		
		function update_parameter(obj, parameter_name, input, varargin)
			if nargin == 4
				idx = varargin{1};
			else
				idx = [];
			end
			switch lower(parameter_name)
				case 'data'
					if isempty(idx)
						obj.Data = input;
					else
						obj.Data{:,idx} = deal(input);
					end
				case 'columnname'
					if isempty(idx)
						obj.ColumnName = input;
					else
						obj.ColumnName{idx} = input;
					end
				case 'columnformat'
					if isempty(idx)
						obj.ColumnFormat = input;
					else
						obj.ColumnFormat{idx} = input;
					end
				case 'columneditable'
					if isempty(idx)
						obj.ColumnEditable = input;
					else
						obj.ColumnEditable(idx) = input;
					end
				case 'columnwidth'
					if isempty(idx)
						obj.ColumnWidth = input;
					else
						obj.ColumnWidth{idx} = input;
					end
				case 'rowname'
					if isempty(idx)
						obj.RowName = input;
					else
						obj.RowName{idx} = input;
					end
				otherwise
					exception = MException(...
						'TABLE_handler:UpdateParameter:UnknownParameter', ...
						'Parameter ''',parameter_name,''' is unknown!');
					throw(exception);
			end
		end
	end
end

