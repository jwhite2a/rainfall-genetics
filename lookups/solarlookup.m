function [solar_area, solar_cost, solar_eff, solar_GHG] = solarlookup(solar_var)

switch solar_var
    case 1 %hes-260
        solar_area = 1.6; solar_cost = 500; solar_eff = 0.17; solar_GHG = 496;
    case 2 % sw-80
        solar_area = 0.62; solar_cost = 205; solar_eff = 0.15; solar_GHG = 192;
    case 3%hes 305P
        solar_area = 2; solar_cost = 450; solar_eff = 0.13; solar_GHG = 620;
    otherwise
        disp("error in solarlookup")

end

