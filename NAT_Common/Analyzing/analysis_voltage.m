function [...
	voltage_violations,...
	bus_violations_number,...
	voltage_violation_statistics,...
	voltage_violation_numbers, ...
	violated_nodes_number, ...
	bus_deviation_summary, ...
	voltage_values...
	] = analysis_voltage (bus_voltages, bus_info, Timepoints, Datasets, Umin, Umax)

nodes_afflicted = cell(size(bus_voltages,2),size(bus_voltages,1));
voltage_violations = zeros(size(bus_voltages,1),size(bus_voltages,2),size(bus_voltages,3),size(bus_voltages,4));
voltage_values = zeros([size(voltage_violations) 3]);
violated_nodes_number = zeros(size(bus_voltages,2),size(bus_voltages,1));

if isempty(bus_voltages)
	bus_violations_number = [];
	voltage_violation_statistics = [];
	voltage_violation_numbers = [];
	bus_deviation_summary = [];
	return
end

for s = 1 : size(bus_voltages,1) % scenario
	for d = 1 : size(bus_voltages,2) % dataset
		for t = 1 : size(bus_voltages,3) % timepoint
			for n = 1 : size(bus_voltages,4) % node
				
				if sum(bus_voltages(s,d,t,n,:)==0) > 0
					bus_voltages(s,d,t,n,:) = NaN;
				end
				
				voltage_values (s,d,t,n,:) = bus_voltages(s,d,t,n,:) / bus_info(n,3);
				
				voltage_violations(s,d,t,n) = ((bus_voltages(s,d,t,n,1) / bus_info(n,3)) < Umin) ||((bus_voltages(s,d,t,n,1) / bus_info(n,3)) > Umax) ||...
					((bus_voltages(s,d,t,n,2) / bus_info(n,3)) < Umin) ||((bus_voltages(s,d,t,n,2) / bus_info(n,3)) > Umax) ||...
					((bus_voltages(s,d,t,n,3) / bus_info(n,3)) < Umin) ||((bus_voltages(s,d,t,n,3) / bus_info(n,3)) > Umax);
				
			end % node
			nodes_afflicted{d,s} = unique([nodes_afflicted{d,s}; find(squeeze(voltage_violations(s,d,t,:)) == 1)]);
		end % timepoint
	end % dataset
end % scenario

voltage_violation_numbers = nansum(nansum(voltage_violations,4)>0,3);
for s = 1 : size(bus_voltages,1) % scenario
	for d = 1 : size(bus_voltages,2) % dataset
		violated_nodes_number(d,s) = numel(nodes_afflicted{d,s});
	end
end

for s = 1 : size(bus_voltages,1) % scenario
	voltage_violation_statistics(:,s) =[sum(voltage_violation_numbers(s,:));
		100*sum(voltage_violation_numbers(s,:))/(Timepoints*Datasets);
		sum(violated_nodes_number(:,s));
		100*sum(violated_nodes_number(:,s))/(size(bus_info,1)*Datasets);]; %#ok<AGROW>
end

voltage_violation_numbers = voltage_violation_numbers';

bus_violations_number = zeros(size(bus_voltages,4),size(bus_voltages,1));
for s = 1 : size(bus_voltages,1) % scenario
	for d = 1 : size(bus_voltages,2) % dataset
		if ~isempty(nodes_afflicted{d,s})
			for n = 1 : numel(nodes_afflicted{d,s})
				
				bus_violations_number(nodes_afflicted{d,s}(n),s) = bus_violations_number(nodes_afflicted{d,s}(n),s) + 1;
			end
		end
	end
end

bus_deviations =  nan(size(bus_voltages,1),size(bus_voltages,2)*size(bus_voltages,3)*size(bus_voltages,4),size(bus_voltages,5));

for s = 1 : size(bus_voltages,1) % scenario
	counter = 0;
	for d = 1 : size(bus_voltages,2) % dataset
		for t = 1 : size(bus_voltages,3) % timepoint
			if size(bus_voltages,4) ~= 1
				voltage_statistics = squeeze(bus_voltages(s,d,t,:,:))./ repmat(bus_info(:,3),1,3);
			else
				voltage_statistics = squeeze(bus_voltages(s,d,t,:,:))'./ repmat(bus_info(:,3),1,3);
			end
			
			bus_deviations(s,counter + (1:size(voltage_statistics,1)),:) = voltage_statistics;
			counter = max(counter + (1:size(voltage_statistics,1)));
		end
	end
	bus_deviation_summary(s,:,:) = [nanmax(squeeze(bus_deviations(s,:,:)),[],1);
		nanmean(squeeze(bus_deviations(s,:,:)),1);
		nanmin(squeeze(bus_deviations(s,:,:)),[],1)]; %#ok<AGROW>
end
end

