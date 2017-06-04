function handles = clear_table_results(handles)

if strcmp(get(handles.table_results,'Visible'),'on') && ~isempty(get(handles.table_results,'Data'))
    jScroll = findjobj(handles.table_results);
    jTable = jScroll.getViewport.getView;
    jTable.setAutoResizeMode(jTable.AUTO_RESIZE_OFF);
    set(handles.table_results,'Data', {'' '';'' '';'' '';'' ''},'ColumnName','numbered','RowName','numbered');
    set(handles.table_results,'Visible','off');
    
    handles.System.Graphics.Table = 'Empty';
end