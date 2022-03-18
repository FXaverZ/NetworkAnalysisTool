function Data_Boundaries = calculate_rms_error(Data)
Data_Diff = Data(:,2:end,:) - Data(:,1:end-1,:);
	Data_Diff = sqrt(Data_Diff .* Data_Diff);
	Data_Diff = squeeze(sum(Data_Diff))./squeeze(sum(Data(:,1:end-1,:)));
	Data_Boundaries = 100*[min(Data_Diff,[],2), max(Data_Diff,[],2), mean(Data_Diff,2)];
end

