function output = listbox_ctc_sg(Selected_List,check_to)
% listbox_conditional_table_clear for scenarios and grids
output = false(1);

% For scenarios/grids

check_value = zeros(size(check_to));
check_value(Selected_List)=1;

if sum(abs(check_to - check_value)) > 0
    output = true(1);
end