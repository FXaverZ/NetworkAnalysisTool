function handles = get_figure_data(handles)

check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);
active_figures_log = 0;
noexportpossible_graphs = {};
for i = 1 :  numel(check_active_figures)
    % Get figure table
    Table = getappdata(findobj(check_active_figures(i),'type','figure'),'table');
    
    if isempty(Table)
        noexportpossible_graphs{end+1} = get(check_active_figures(i),'Name'); %#ok<AGROW>
    else
        % Get name definition
        clear output ident
        [output,ident] = get_figure_data_connection(check_active_figures(i));
        % Changelog FZ 1.3 Start
        if ~isempty(output) && isempty(find(active_figures_log==output,1))
            % Changelog FZ 1.3 End
            % Figure-data was not yet processed for exporting
            file = []; Data_List = []; %#ok<NASGU>
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
                Table_rf.Description = strrep(Table_rf.Description,'Voltage','U');
                Table_rf.Description = strrep(Table_rf.Description,lower('Current'),'I');
                Table_rf.Description = strrep(Table_rf.Description,'Current','I');
                Table_rf.Description = strrep(Table_rf.Description,'violations','viol.');
                Table_rf.Description = strrep(Table_rf.Description,'values ', '');
                Table_rf.Description = strrep(Table_rf.Description,'timeline at grids for','T for');
                Table_rf.Description = strrep(Table_rf.Description,'Total number of','Sum-');
                Table_rf.Description = strrep(Table_rf.Description,'Total ','Sum-');
                Table_rf.Description = strrep(Table_rf.Description,'timeline','T');
                Table_rf.Description = strrep(Table_rf.Description,'timelines','T');
                Table_rf.Description = strrep(Table_rf.Description,'Average','Avr.');
                Table_rf.Description = strrep(Table_rf.Description,'average','avr.');
                Table_rf.Description = strrep(Table_rf.Description,'Mean','Avr.');
                Table_rf.Description = strrep(Table_rf.Description,'mean','avr.');
                Table_rf.Description = strrep(Table_rf.Description,'Maximum','Max.');
                Table_rf.Description = strrep(Table_rf.Description,'maximum','max.');
                Table_rf.Description = strrep(Table_rf.Description,'Minimum','Min.');
                Table_rf.Description = strrep(Table_rf.Description,'minimum','min.');
                Table_rf.Description = strrep(Table_rf.Description,'loading','load.');
                Table_rf.Description = strrep(Table_rf.Description,'branch','br.');
                Table_rf.Description = strrep(Table_rf.Description,'for all datasets for','for');
                Table_rf.Description = strrep(Table_rf.Description,'Electric losses','El. loss.');
                Table_rf.Description = strrep(Table_rf.Description,'El. loss. sum for all datasets at','Sum- El. loss. for');
                Table_rf.Description = strrep(Table_rf.Description,'El. loss. sum for all datasets T for' ,'Sum- El. loss. for');
                Table_rf.Description = strrep(Table_rf.Description,'for scenario','f. scen.');
                if size(Table_rf.Description,2) > 31
                    Table_rf.Description = [Table_rf.Description(1:28),'...'];
                end
                
                Table_rf.Values = cell(3,size(Table.(Data_List{j}).Values,2)); % Description, Row, Details
                Table_rf.Values{1,1} = Table.(Data_List{j}).Description;
                Table_rf.Values{2,1} = Table.(Data_List{j}).RowName;
                if isfield(Table.(Data_List{j}), 'Details')
                    Table_rf.Values{3,1} = Table.(Data_List{j}).Details; 
                end
                Table_rf.Values = [Table_rf.Values; RowID; num2cell(Table.(Data_List{j}).Values)];
                
                write_figure_to_excel(handles,Table_rf,file);
            end
            active_figures_log = [active_figures_log;output]; %#ok<AGROW>
        elseif isempty(output)
            noexportpossible_graphs{end+1} = get(check_active_figures(i),'Name'); %#ok<AGROW>
        end
    end
end

if (numel(noexportpossible_graphs) > 0)
    helptext = {'The data of the plot(s)';''};
    for i=1:numel(noexportpossible_graphs)
        helptext{end+1} = ['   - "',noexportpossible_graphs{i},'"']; %#ok<AGROW>
    end
    helptext{end+1} = 'cannot be saved to Excel!';
    helptext{end+1} = '';
    helptext{end+1} = 'If the plot(s) is a (are) histogram(s), the data is available in the summary Excel-file!';
    
    helpdlg(helptext,'Save plot data...');
end