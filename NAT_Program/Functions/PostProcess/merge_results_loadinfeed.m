function Load_Infeed_Data = merge_results_loadinfeed (Load_Infeed_Data, Raw_Results, number_datasets)

tmp_load_infeed    = Load_Infeed_Data;
tmp_add_loadinfeed = Raw_Results.Load_Infeed_Data;

number_datasets_current   = size(fields(tmp_load_infeed),1);
number_datasets_available = size(fields(tmp_add_loadinfeed),1);
number_datasets_after_add = number_datasets_current + number_datasets_available;
if number_datasets < number_datasets_after_add
    number_datasets_add = number_datasets - number_datasets_current;
    if number_datasets_add < 1
        return;
    end
else
    number_datasets_add = number_datasets_available;
end

for i=1:number_datasets_add
    tmp_load_infeed.(['Set_',num2str(number_datasets_current+i)]) = ...
        tmp_add_loadinfeed.(['Set_',num2str(i)]);
end

Load_Infeed_Data = tmp_load_infeed;

end

