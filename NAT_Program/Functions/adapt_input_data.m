function [Load_Data, Sola_Data, Elmo_Data] = adapt_input_data(Load_Data, Sola_Data, Elmo_Data)
%ADAPT_INPUT_DATA    adapts the current input data
% Adjust reactive power: Use a constant cos(phi)

% Adjust reactive power: Use a constant cos(phi):
cosphi = 0.95;
phi = acos(cosphi);
Load_Data(:,2:2:end) = Load_Data(:,1:2:end) * tan(phi);

end

