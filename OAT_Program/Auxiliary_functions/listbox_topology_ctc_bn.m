function output = listbox_topology_ctc_bn(Selected_List,check_to)
% listbox_conditional_table_clear for scenarios and grids
output = false(1);

% For nodes/branches
List_fields = fields(Selected_List);

for i = 1 : size(List_fields,1)
    check_value.(List_fields{i}) = zeros(size(check_to.(List_fields{i})));
    check_value.(List_fields{i})(Selected_List.(List_fields{i}),1) = 1;
    
    

if sum(abs(check_to.(List_fields{i}) - check_value.(List_fields{i}))) > 0
    output = true(1);
end

end