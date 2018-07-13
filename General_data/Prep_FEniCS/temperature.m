function [temp_out] = temperature(temp_water_bolus)
%[temp_out] = TEMPERATURE()
%   Returns the temperature of body, air and water. Default unit is
%   Kelvin relative body temperature, so body temp = 0

% Sets the values for the temperatures in the same order as h_trans
% Relative body temperature

if nargin<1
    temp_water= -22;
else 
    temp_water=temp_water_bolus;
end
temp_body = 0;
temp_air = -17;

temp_out = [temp_body temp_air temp_water];


end

