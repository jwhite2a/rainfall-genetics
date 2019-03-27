function [area,cost] = rooflookup(roof_var)

switch roof_var
    case 1
        area = 0; cost = 0;
    case 2
        area = 50; cost = 0;
    case 3
        area = 100; cost = 350;
        
    otherwise
        disp("error in rooflookup");

end

