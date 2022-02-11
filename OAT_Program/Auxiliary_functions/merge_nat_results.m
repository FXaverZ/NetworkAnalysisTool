function merge_nat_results(hObject, handles)
%MERGE_NAT_RESULTS merges results from NAT
% hObject    handle to menu_home_merge_nat_results (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Inform the user:
title_str = 'Merging NAT Data...';
str = {...
    'Merging of NAT results is not implemented yet!';...
    'Please use the corresponding function of the NAT...';...
};
helpdlg(str, title_str);

% Update handles structure
guidata(hObject, handles);
end

