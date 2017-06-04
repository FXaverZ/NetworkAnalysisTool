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

			[obj.Controller_Active] = deal(false);
			
			for i=1:numel(obj)
				obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:) = zeros(1,6);
				obj(i).Values_Last_Step.Power_Vals = zeros(2,6);
				obj(i).Values_Last_Step.Changes_Vals = zeros(4,6);
				obj(i).Values_Last_Step.Changes_Idx = 0;
				obj(i).Values_Last_Step.Cyle_Number = 0;
			end
				
			switch lower(mode)
				case 'total'
					[obj.Shifted_Energy] = deal(zeros(1,6));		
				case 'in_simulation'
				otherwise
					% Error, unknown reset mode!
			end
		end
		
		function success = check_success(~, varargin)
			success = true;
		end
		
		function regulate(obj, varargin)
			
			for i=1:numel(obj)
				
				obj(i).Control_happened = false;
				
				% get the connected branch object:
				branch = obj(i).Connected_Branch;
				% update the current values from the previous simulation step:
% 				branch.update_current_branch_LF_USYM;
				branch.update_power_branch_LF_USYM;
				
				% Calculate the controlled power:
				pow_grd_r = zeros(1,6);
				pow_grd_l = zeros(1,6);
				
% 				if any(branch.Current > branch.Current_Limits * obj(i).Limit_Factor) || obj(i).Controller_Active
				if any(branch.Apparent_Power(1:3) > branch.App_Power_Limits * obj(i).Limit_Factor / 3) || obj(i).Controller_Active
% 				if sum(branch.Apparent_Power(1:3)) > branch.App_Power_Limits * obj(i).Limit_Factor
% 				% --- Testcode 1 START --- 
% 					pow_act = obj(i).Connection_Point.P_Q_Act(obj(i).Controlled_Unit.P_Q_Act_idx,:)*1e6;
% 					pow_grd_r(1:2:end) = -pow_act(1:2:end);
% 					pow_grd_r(2:2:end) = -pow_act(2:2:end);
% 					obj(i).Connection_Point.powers_changed = true;
% 					obj(i).Control_happened = true;
% 				% --- Testcode 1 END --- 
% 				% --- Testcode 2 START --- 
% 					pow_act = obj(i).Connection_Point.P_Q_Act(obj(i).Controlled_Unit.P_Q_Act_idx,:)*1e6;
% 					% Just turn off the overloaded phase:
% 					idx_ov = branch.Apparent_Power(1:3) > branch.App_Power_Limits * obj(i).Limit_Factor / 3;
% 					idx_ov = reshape([idx_ov;idx_ov],[],6);
% 					pow_act(~idx_ov) = 0;
% 					pow_grd_r(1:2:end) = -pow_act(1:2:end);
% 					pow_grd_r(2:2:end) = -pow_act(2:2:end);
% 					obj(i).Connection_Point.powers_changed = true;
% 					obj(i).Control_happened = true;
% 				% --- Testcode 2 END --- 
					% Limits are violated, reduce power consumption
					% get the possible power reduction (equals the power
					% consumption of the controlled unit):
					pow_pos = obj(i).Connection_Point.P_Q_Act(obj(i).Controlled_Unit.P_Q_Act_idx,:)*1e6;
					% get the current consumed power (in W)
					pow_act = pow_pos + obj(i).Values_Last_Step.Power_Vals(1,:) + obj(i).Values_Last_Step.Power_Vals(2,:);
				% --- Testcode START --- 
				    apow_ov = branch.Apparent_Power(1:3) - branch.App_Power_Limits* obj(i).Limit_Factor / 3;
				% --- Testcode END ----- 
					% how much apparent power is over the limit?
% 					apow_ov = ...
% 						(branch.Current(1:3) - branch.Current_Limits * obj(i).Limit_Factor) * ...
% 						branch.Rated_Voltage1_phase_phase/sqrt(3);
% 					apow_ov(apow_ov < 0) = 0;
					% what apparent power is currently present?
					apow_act = sqrt(pow_act(1:2:end).^2 + pow_act(2:2:end).^2);
					% reduce factor:
					fac = (apow_ov./apow_act) + 0.001;
					% this factor cannot be greater than 1, because max. all the load can
					% be disconnected:
					fac(fac > 1) = 1;
					% calculate the reduced powers:
					pow_grd_r(1:2:end) = -fac.*pow_act(1:2:end);
					pow_grd_r(2:2:end) = -fac.*pow_act(2:2:end);
					
					% Check for not possible Numbers (division trough
					% zero):
					pow_grd_r(isnan(pow_grd_r)) = 0;
					
					% Add the changed power to the allready changed power
					% (integrate it up):
					pow_grd_r = obj(i).Values_Last_Step.Power_Vals(1,:) + pow_grd_r;
					pow_grd_r(pow_grd_r > 0) = 0;
					pow_grd_r(pow_grd_r < -pow_pos) = -pow_act(pow_grd_r < -pow_pos);
	
					% get the changes compared to the last time:
					idx_l = mod(obj(i).Values_Last_Step.Changes_Idx - 1,size(obj(i).Values_Last_Step.Changes_Vals,1));
					idx_c = obj(i).Values_Last_Step.Changes_Idx;
					idx_n = mod(obj(i).Values_Last_Step.Changes_Idx + 1,size(obj(i).Values_Last_Step.Changes_Vals,1));
					
					obj(i).Values_Last_Step.Cyle_Number = obj(i).Values_Last_Step.Cyle_Number + 1;
					pow_cha = pow_grd_r - obj(i).Values_Last_Step.Power_Vals(1,:);
					
					obj(i).Values_Last_Step.Changes_Vals(idx_c+1,:) = pow_cha;
					obj(i).Values_Last_Step.Changes_Idx = idx_n;
					
					% check, if the last two cycles delivered the same
					% values (stable oszilation):
					if (obj(i).Values_Last_Step.Cyle_Number > 2)
						val_l = obj(i).Values_Last_Step.Changes_Vals(idx_l+1,:);
						idx_nz = abs(val_l)>10;
						if any(abs(val_l(idx_nz) + pow_cha(idx_nz)) < 10)
							% a allready simulated point is used again -->
							% oszillation, take the half of the change
							pow_grd_r = mean([pow_grd_r; obj(i).Values_Last_Step.Power_Vals(1,:)]);
							pow_cha = pow_grd_r - obj(i).Values_Last_Step.Power_Vals(1,:);
						end
					end
										
					% set the flag that the powers have changed:
					obj(i).Connection_Point.powers_changed = true;
					obj(i).Control_happened = true;
					
					if ~obj(i).Controller_Active
						obj(i).Controller_Active = true;
					elseif obj(i).Controller_Active && all(abs(pow_cha) < 100)
						obj(i).Controller_Active = false;
						obj(i).Connection_Point.powers_changed = false;
						obj(i).Control_happened = false;
					end

				end
% 				if any(obj(i).Shifted_Energy > 0)
% 					% calculate the remaining capacity based on the current and shifting
% 					% factor:
% 					apow_pos = (branch.Current_Limits - branch.Current(1:3))*branch.Rated_Voltage1_phase_phase/sqrt(3);
% 					% Discard overloaded phases:
% 					apow_pos(apow_pos<0)=0;
% 					% what would be the maximum power:
% 					amax_pow = obj(i).Max_Power*obj(i).Shifting_Factor;
% 					amax_pow = sqrt(amax_pow(1:2:end).^2 + amax_pow(2:2:end).^2);
% 					% if the remaining capacity exceeds the maximum power it is limited to
% 					% the maximum power:
% 					apow_pos(apow_pos > amax_pow) = amax_pow(apow_pos > amax_pow);
% 					
% 					% Calculate the power consumption according to the storage level:
% 					apow_ene = sqrt(obj(i).Shifted_Energy(1:2:end).^2 +obj(i).Shifted_Energy(2:2:end).^2);
% 					fac = apow_pos./apow_ene;
% 					fac(fac > 1) = 1;
% 					pow_grd_l(1:2:end) = fac.*obj(i).Shifted_Energy(1:2:end);
% 					pow_grd_l(2:2:end) = fac.*obj(i).Shifted_Energy(2:2:end);
% 					% set the flag that the powers have changed:
% 					obj(i).Connection_Point.powers_changed = true;
% 					% if discharge happened, controll action is valid:
% 					if any(pow_grd_l > 0)
% 						obj(i).Control_happened = true;
% 					end
% 				end
				% Update the storage level (power over time equals energy...)
				obj(i).Values_Last_Step.Power_Vals = [pow_grd_r;pow_grd_l];
				obj(i).Shifted_Energy = obj(i).Shifted_Energy - pow_grd_r - pow_grd_l;
				% Update the power array of the connection point:
				obj(i).Connection_Point.P_Q_Act(obj(i).P_Q_Act_idx,:) = (pow_grd_r + pow_grd_l)/1e6;
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

