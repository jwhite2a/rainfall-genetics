function [pump_a, pump_b, pump_c, pump_cost, pump_eff, pumplife_hours] = pumplookup(pump_var)

switch pump_var
    case 1
        pump_a = -0.0191; pump_b = -0.4006; pump_c = 167.7; pump_cost = 580; pump_eff = 0.7; pumplife_hours  = 1000;
    case 2
        pump_a = -0.0039; pump_b = -0.096; pump_c = 237.68; pump_cost = 1400; pump_eff = 0.72; pumplife_hours  = 1500;
    case 3
        pump_a = -0.0151; pump_b = -0.5516; pump_c = 356.8; pump_cost = 3500; pump_eff = 0.65; pumplife_hours  = 1500;
    case 4
        pump_a = 0; pump_b = 0; pump_c = 0; pump_cost = 0; pump_eff = 1; pumplife_hours  = 0;
    otherwise
        disp("error in pumploopup")
end

