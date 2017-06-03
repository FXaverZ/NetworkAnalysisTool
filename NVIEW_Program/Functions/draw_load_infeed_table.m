function handles = draw_load_infeed_table(handles,Table)

set(handles.table_results,'Visible','on');
set(handles.table_results,'Data',Table.Values_Str)
set(handles.table_results,'ColumnName',Table.ColumnName,'RowName',[])

% % findjobj help with java table formatting
jScroll = findjobj(handles.table_results);
jTable = jScroll.getViewport.getView;
jTable.setAutoResizeMode(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
% jTable.setAutoResizeMode(jTable.AUTO_RESIZE_ALL_COLUMNS);
% jTable.setAutoResizeMode(jTable.AUTO_RESIZE_OFF);
jTable.setRowHeight(ceil(jTable.getRowHeight/10)*10); % Small increase in row height
jTable.getColumnModel().getColumn(0).setPreferredWidth(jTable.getColumnModel().getColumn(0).getPreferredWidth+100);

handles.System.Graphics.Table = Table.Description;
end