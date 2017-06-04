function handles = get_figure_data(handles)

check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
active_figures_log = 0;

for i = 1 :  numel(check_active_figures)
    % Get figure table
    Table = getappdata(findobj(check_active_figures(i),'type','figure'),'table');
    
	if ~isempty(Table)
		% Get name definition
		clear output ident
		[output,ident] = get_figure_data_connection(check_active_figures(i));
		% Changelog FZ 1.3 Start
		if ~isempty(output) && isempty(find(active_figures_log==output,1))
		% Changelog FZ 1.3 End
			% Figure-data was not yet processed for exporting
			file = []; Data_List = [];
			file = write_header_to_excel(handles,ident);
			% Check table fields
			Data_List = fields(Table);
			Data_List = setdiff(Data_List,'ColumnName');
			Data_List = setdiff(Data_List,'Fields');
			
			for j = 1 : size(Data_List,1)
				clear RowID Table_rf
				RowID(1,:) = Table.ColumnName;
				
				Table_rf.Description = Table.(Data_List{j}).Description;
				Table_rf.Description = strrep(Table_rf.Description,lower('Voltage'),'U');
				Table_rf.Description = strrep(Table_rf.Description,lower('Current'),'I');
				Table_rf.Description = strrep(Table_rf.Description,'violations','viol.');
				Table_rf.Description = strrep(Table_rf.Description,'timeline at grids for','T for');
				Table_rf.Description = strrep(Table_rf.Description,'Total number of','Sum-');
				Table_rf.Description = strrep(Table_rf.Description,'timeline','T');
				Table_rf.Description = strrep(Table_rf.Description,'Average','Avr.');
				Table_rf.Description = strrep(Table_rf.Description,'average','avr.');
				Table_rf.Description = strrep(Table_rf.Description,'loading','load.');
				Table_rf.Description = strrep(Table_rf.Description,'branch','br.');
				Table_rf.Description = strrep(Table_rf.Description,'for all datasets for','for');
				Table_rf.Description = strrep(Table_rf.Description,'Electric losses','El. loss.');
				Table_rf.Description = strrep(Table_rf.Description,'El. loss. sum for all datasets at','Sum- El. loss. for');
				Table_rf.Description = strrep(Table_rf.Description,'El. loss. sum for all datasets T for' ,'Sum- El. loss. for');
				if size(Table_rf.Description,2) > 31
					Table_rf.Description = [Table_rf.Description(1:28),'...'];
				end
				
				Table_rf.Values = cell(3,size(Table.(Data_List{j}).Values,2)); % Descriptionm, Row
				Table_rf.Values{1,1} = Table.(Data_List{j}).Description;
				Table_rf.Values{2,1} = Table.(Data_List{j}).RowName;
				Table_rf.Values = [Table_rf.Values; RowID; num2cell(Table.(Data_List{j}).Values)];
				
				write_figure_to_excel(handles,Table_rf,file);
			end
			active_figures_log = [active_figures_log;output];
		% Changelog FZ 1.3 Start
		elseif isempty(output)
			helpdlg({'The data of the plot';'';...
				['"',Table.Name,'"'];'';...
				'cannot be saved to Excel!';'';...
				'If the plot is a histogram, the data is available in the summary Excel-file!'},'Save plot data...');
		% Changelog FZ 1.3 End
		end
	end
	
end