classdef Charge_Controller < SG_Controller
	%CHARGE_CONTROLLER Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		Shifted_Energy = zeros(1,6)
		Shifting_Factor = 1
		Shifting_Loading_Limit = 1
		Max_Power = zeros(1,6)
		Connected_Branch
		Control_happened = false
		Limit_Factor = 1
		Controller_Active = false
	end
	
	methods
		function obj = Charge_Controller (cn_point, varargin)
			% Superklassenkonstruktor:
			obj = obj@SG_Controller(cn_point,varargin{:});
			% get the branch, over which this unit is conneted (to look for
			% problems):
		end
		
		function reset_controller(obj, varargin)
			if nargin == 1
				mode = 'Total';
			elseif nargin > 1 && nargin < 3
				mode = varargin{1};
			end

% 			[obj.Controller_Active] = deal(false);
			
			for i=1:numel(obj)
				obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:) = zeros(1,6);
				obj(i).Values_Last_Step.Power_Vals = zeros(2,6);
				obj(i).Values_Last_Step.Changes_Vals = zeros(4,6);
				obj(i).Values_Last_Step.Changes_Idx = 0;
				obj(i).Values_Last_Step.Cyle_Number = 0;
                obj(i).Controller_Active = false;
			end
				
			switch lower(mode)
				case 'total'
% 					[obj.Shifted_Energy] = deal(zeros(1,6));
                    for i=1:numel(obj)
                        obj(i).Shifted_Energy = zeros(1,6);
                    end
				case 'in_simulation'
				otherwise
					% Error, unknown reset mode!
			end
		end
		
		function success = check_success(~, varargin)
			success = true;
		end
		
		function full_load_reduction(obj, varargin)
			% This function is called, if the load-flow did not converege in the previous
			% attempt. So the controlled load is reduced by the maximum possible value, to
			% try, if this is sufficient enough to overcome this problem...
			for i=1:numel(obj)
				% Calculate the controlled power:
				pow_grd_l = zeros(1,6);
				
				% get the possible power reduction (equals the power consumption
				% of the controlled unit):
				pow_pos = obj(i).Connection_Point.P_Q_Act(obj(i).Controlled_Unit.P_Q_Act_idx,:)*1e6;
				pow_grd_r = -pow_pos;
				
				% set the flag that the powers have changed:
				obj(i).Connection_Point.powers_changed = true;
				obj(i).Control_happened = true;
				
				% indexes in the last values (off by one due to modulo
				% operation):
				idx_c = obj(i).Values_Last_Step.Changes_Idx;
				idx_n = mod(...
					obj(i).Values_Last_Step.Changes_Idx + 1,...
					size(obj(i).Values_Last_Step.Changes_Vals,1)...
					);
				% update the cycle informations:
				obj(i).Values_Last_Step.Cyle_Number = obj(i).Values_Last_Step.Cyle_Number + 1;
				obj(i).Values_Last_Step.Changes_Idx = idx_n;
				
				% calculate power changes:
				pow_cha = ...
					pow_grd_r - obj(i).Values_Last_Step.Power_Vals(1,:) - ...
					pow_grd_l + obj(i).Values_Last_Step.Power_Vals(2,:);
				obj(i).Values_Last_Step.Changes_Vals(idx_c+1,:) = pow_cha;
				
				% Save the last values (for further use):
				obj(i).Values_Last_Step.Power_Vals = [pow_grd_r;pow_grd_l];
				% Update the power array of the connection point:
				obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:) = (pow_grd_r + pow_grd_l)/1e6;
				
				% first Controll-Cycle, set controller active:
				if any(abs(pow_grd_r) > 1)
					obj(i).Controller_Active = true;
				end
			end
		end
		
		function regulate(obj, varargin)
			
			for i=1:numel(obj)
				
				obj(i).Control_happened = false;
				
				% get the connected branch object:
				branch = obj(i).Connected_Branch;
				% update the current values from the previous simulation step:
				branch.update_power_branch_LF_USYM;
				
				% Calculate the controlled power:
				pow_grd_r = zeros(1,6);
				pow_grd_l = zeros(1,6);
				
				% how much apparent power is over the limit?
				apow_ov = branch.Apparent_Power(1:3) - branch.App_Power_Limits*obj(i).Limit_Factor / 3;
				
				if any(apow_ov > 0) || ...
						any((obj(i).Shifted_Energy(1:2:end) > 0) & (apow_ov < -10)) || ...
						obj(i).Controller_Active

					% Limits are violated, reduce power consumption OR ...
					% Storage is not empty and it is possible to discharge it OR ...
					% Controller operation is active
					
					% ---------------------------------------------------------------
					% Calculate power reduction (if no overloading is present, the
					%     power reduction is calculated to zero): 
					% ---------------------------------------------------------------
					
					% get the possible power reduction (equals the power consumption
					% of the controlled unit): 
					pow_pos = obj(i).Connection_Point.P_Q_Act(obj(i).Controlled_Unit.P_Q_Act_idx,:)*1e6;
					% get the current consumed power (in W) (equals the power
					% consumption of the controlled element + the changes of the
					% previous control cycle) and calculate the apprent power:
					pow_act = pow_pos + obj(i).Values_Last_Step.Power_Vals(1,:) + obj(i).Values_Last_Step.Power_Vals(2,:);
					apow_act = sqrt(pow_act(1:2:end).^2 + pow_act(2:2:end).^2);
					
					% calculate the reduce factors for each phase:
					fac = (apow_ov./apow_act);
					% this factor cannot be greater than 1, because max. all the load
					% of the controlled element can  be disconnected:
					fac(fac > 1) = 1;
					% calculate the reduced powers:
					pow_grd_r(1:2:end) = -fac.*pow_act(1:2:end);
					pow_grd_r(2:2:end) = -fac.*pow_act(2:2:end);
					
					% Check for not possible Numbers (division trough
					% zero causing NaNs - this happens, if no power-value for one
					% phase is given for the specific time point): 
					pow_grd_r(isnan(pow_grd_r)) = 0;
					
					% Add the changed power to the allready changed power (integrate
					% it up): 
					pow_grd_r = obj(i).Values_Last_Step.Power_Vals(1,:) + pow_grd_r;
					pow_grd_r(pow_grd_r > 0) = 0;
					pow_grd_r(pow_grd_r < -pow_pos) = -pow_act(pow_grd_r < -pow_pos);
					
					% ---------------------------------------------------------------
					% Calculate power injection (if no energy was stored of previous
					%     power reductions, the power injection is calculated to
					%     zero): 
					% ---------------------------------------------------------------
					
					% calculate the remaining capacity based on the current and shifting
					% factor:
					apow_chrg = sqrt(obj(i).Values_Last_Step.Power_Vals(2,1:2:end).^2 +obj(i).Values_Last_Step.Power_Vals(2,2:2:end).^2);
					% Calculate the power consumption according to the storage level:
					apow_ene = sqrt(obj(i).Shifted_Energy(1:2:end).^2 +obj(i).Shifted_Energy(2:2:end).^2);
					
					% what would be the maximum possible power for discharge:
					apow_pos = -apow_ov;
					amax_pow = obj(i).Max_Power*obj(i).Shifting_Factor;
					amax_pow = sqrt(amax_pow(1:2:end).^2 + amax_pow(2:2:end).^2);
					amax_pow = amax_pow - apow_chrg;
					% if the remaining capacity exceeds the maximum power it is limited to
					% the maximum power:
					apow_pos(apow_pos > amax_pow) = amax_pow(apow_pos > amax_pow);
					% The remaining capacity is also limited by the storage level (if in
					% this timestep the starage can be discharged fully!):
					amax_pow = apow_ene - apow_chrg;
					apow_pos(apow_pos > amax_pow - 1) = amax_pow(apow_pos > amax_pow - 1);
					
					fac = apow_pos./apow_ene;
					fac(fac > 1) = 1;
					pow_grd_l(1:2:end) = fac.*obj(i).Shifted_Energy(1:2:end);
					pow_grd_l(2:2:end) = fac.*obj(i).Shifted_Energy(2:2:end);
					
					% Check for not possible Numbers (division trough
					% zero causing NaNs - this happens, if no power-value for one
					% phase is given for the specific time point):
					pow_grd_l(isnan(pow_grd_l)) = 0;
					
					% Add the changed power to the allready changed power (integrate
					% it up): 
					pow_grd_l = obj(i).Values_Last_Step.Power_Vals(2,:) + pow_grd_l;
					pow_grd_l(pow_grd_l < 0) = 0;
					% all phases, which are reducing their power consumption,
					% can't also participate in discharging of the storage:
					pow_grd_l(pow_grd_r < -10) = 0;
					
					% ---------------------------------------------------------------
					% get and save the changes compared to the last controll cylce,
					% controll if oszilations in the calculations apear, get rid of
					% them:
					% ---------------------------------------------------------------
					
					% indexes in the last values (off by one due to modulo
					% operation):
					idx_l = mod(...
						obj(i).Values_Last_Step.Changes_Idx - 1,...
						size(obj(i).Values_Last_Step.Changes_Vals,1)...
						);
					idx_c = obj(i).Values_Last_Step.Changes_Idx;
					idx_n = mod(...
						obj(i).Values_Last_Step.Changes_Idx + 1,...
						size(obj(i).Values_Last_Step.Changes_Vals,1)...
						);
					% update the cycle informations:
					obj(i).Values_Last_Step.Cyle_Number = obj(i).Values_Last_Step.Cyle_Number + 1;
					obj(i).Values_Last_Step.Changes_Idx = idx_n;
					
					% calculate power changes:
					pow_cha = ...
						pow_grd_r - obj(i).Values_Last_Step.Power_Vals(1,:) - ...
						pow_grd_l + obj(i).Values_Last_Step.Power_Vals(2,:);
					obj(i).Values_Last_Step.Changes_Vals(idx_c+1,:) = pow_cha;
					
					% check, if the last two cycles delivered the same values
					% (because of stable oszilation):
					if (obj(i).Values_Last_Step.Cyle_Number > 2)
						val_l = obj(i).Values_Last_Step.Changes_Vals(idx_l+1,:);
						idx_nz = abs(val_l)>10;
						idx_os = abs(val_l + pow_cha) < 10;
						idx_os = idx_os & idx_nz;
						if any(idx_os)
							% a allready simulated point is used again -->
							% oszillation, use only the half of the current change: 
							pow_grd_r(idx_os) = mean([pow_grd_r(idx_os); obj(i).Values_Last_Step.Power_Vals(1,idx_os)]);
							pow_grd_l(idx_os) = mean([pow_grd_l(idx_os); obj(i).Values_Last_Step.Power_Vals(2,idx_os)]);
							% all phases, which are reducing their power consumption,
							% can't also participate in discharging of the storage:
							pow_grd_l(pow_grd_r < 0) = 0;
							pow_cha = ...
								pow_grd_r - obj(i).Values_Last_Step.Power_Vals(1,:) - ...
								pow_grd_l + obj(i).Values_Last_Step.Power_Vals(2,:);
						end
					end
										
					% set the flag that the powers have changed:
					obj(i).Connection_Point.powers_changed = true;
					obj(i).Control_happened = true;
					
					% set the controller active flag (for outside controll) or see,
					% if the controller is finished:
					if ~obj(i).Controller_Active && obj(i).Values_Last_Step.Cyle_Number == 1
						% first Controll-Cycle, set controller active:
						obj(i).Controller_Active = true;
					elseif obj(i).Controller_Active && all(abs(pow_cha) < 100)
						% if the power-changes du to controll operation is under a
						% certain limit, stop controller operation:
						obj(i).Controller_Active = false;
						obj(i).Connection_Point.powers_changed = false;
						obj(i).Control_happened = false;
					end

				end

				% Save the last values (for further use):
				obj(i).Values_Last_Step.Power_Vals = [pow_grd_r;pow_grd_l];
				% Update the power array of the connection point:
				obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:) = (pow_grd_r + pow_grd_l)/1e6;
			end
		end
		
		function update_storage(obj, varargin)
			for i=1:numel(obj)
				obj(i).Shifted_Energy = obj(i).Shifted_Energy ...
					- obj(i).Values_Last_Step.Power_Vals(1,:)...
					- obj(i).Values_Last_Step.Power_Vals(2,:);
			end
		end
		
		function update_obj_parameter(obj, parameter_name, input)
			switch lower(parameter_name)
				case 'controlled_unit'
					obj.Controlled_Unit = input;
				case 'connected_branch'
					obj.Connected_Branch = input;
				case 'max_power'
					obj.Max_Power = input;
				case 'shifting_factor'
					obj.Shifting_Factor = input;
				case 'shifting_loading_limit'
					obj.Shifting_Loading_Limit = input;
				case 'limit_factor'
					obj.Limit_Factor = input;
				otherwise
					exception = MException(...
						'CHARGE_CONTROLLER:UpdateSettings:UnkownParameterName',...
						['Unknown parameternam. Parameter ''',parameter_name,...
						''' cannot be processed!']);
					throw(exception);
			end
		end
	end
	
end

