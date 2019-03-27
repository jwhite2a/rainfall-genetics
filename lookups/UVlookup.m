function [UVcost, UVreplacementcost, powerusage_watts, UV_maxflow] = UVlookup(uv_var)
switch uv_var
    case 1
       UVcost = 500; UVreplacementcost = 90; powerusage_watts = 30; UV_maxflow = 25; 
    case 2
       UVcost= 750; UVreplacementcost= 110; powerusage_watts = 50; UV_maxflow = 35;
    otherwise
        disp('error in UVlookup');
end

