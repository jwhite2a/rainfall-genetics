function vel = velocity_down(Cf_Total,elevation_tank, tower_height, length_down, filterLocation_var)

globals();
global K
global f;
global rho
global g
global diameter
global height_down
%constants

height  = elevation_tank + height_down + tower_height;

if filterLocation_var == 2 Cf_check = 1; else Cf_check = 0; end

a_coeff = (f*length_down*rho / (2*diameter)) + (K*rho / 2);
b_coeff = (Cf_check*Cf_Total);
c_coeff = -(g*rho*height);

discrim = b_coeff^2 - 4*a_coeff*c_coeff;

if discrim < 0 
%    failure = 1;
    vel = 0;
    return
end

vel = (-1*b_coeff + sqrt(discrim))/(2*a_coeff);
%failure = 0;

end

