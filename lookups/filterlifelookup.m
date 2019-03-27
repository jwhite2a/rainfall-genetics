function [life_1um, life_um5, life_um200] = filterlifelookup(um5,um200)
%%
life_um200  = 20; 
%%
if (um200 == 1)
    life_um5  = 20;
else
    life_um5  = 10;
end
%%
if(um200 == 1 && um5 == 1)
    life_1um = 20;
elseif (um200 == 1 && um5==0)
    life_1um = 15;
elseif (um200 == 0 && um5 == 1)
    life_1um = 20;
else 
    life_1um = 5;
end

end

