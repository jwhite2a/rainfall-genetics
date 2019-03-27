function vel = velocity_up(pump_a,pump_b, pump_c,Cf_total,elevation_tank, tower_height, length_up, filterLocation_var)

globals();
global K
global f;
global rho
global g
global area
global diameter
global height_up
%constants

conversion = (1/area) / (1000*60);
height  = elevation_tank + height_up + tower_height;

if filterLocation_var == 1 Cf_check = 1; else Cf_check = 0; end

a_coeff = (f*length_up*rho / (2*diameter)) + (K*rho / 2) - (pump_a*1000 * conversion^2);
b_coeff = (Cf_check*Cf_total) - (conversion * pump_b*1000);
c_coeff = (g*rho*height) - (pump_c*1000);

discrim = b_coeff^2 - 4*a_coeff*c_coeff;

if discrim < 0 
%    failure = 1;
    vel = 0;
    return
end

vel = (-1*b_coeff + sqrt(discrim))/(2*a_coeff);
%failure = 0;

end

