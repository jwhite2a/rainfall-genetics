function ave_satis = objectiveFunction(X)
tic();
globals();
global Cf
global area

loopsize = 3;
ave_satis = 0;
satis = zeros(loopsize, 1);
failure = 0;


catch_x =                X(1);
catch_y =                X(2);
tank_x =                 X(3);
tank_y  =                X(4);
roof_var =               X(5); % 1=none 2=half 3=full  %%**No roof case broken
catchArea =              X(6);
collectionTank_var  =    X(7); % 1=none, 2 through 5
userConsumption =        X(8);
tank_volume =            X(9);
tank_height =            X(10);
pump_var =               X(11); %4 is none, 1 through 3 %%** no pump case broken
fliterLocation =         X(12); % 1 is up, 2 is down
filter5um_var =          X(13); %0 or 1
filter200um_var =        X(14); %0 or 1
UV_var =                 X(15);
chemical_var =           X(16); %1 for chlorine, 2  for ozone
power_var =              X(17); % 1for solar, 2 for disel
numbatteries =           X(18);
numsolarpanels =         X(19);
solar_var =              X(20);

%% elevations
tank_z = elevation(tank_x, tank_y);
catch_z = elevation(catch_x, catch_y);

%% length pipe stor to house
pipe_HouseToStorage = lengthpipe(0, 0, 0, tank_x, tank_y, tank_z);

%% length catchment
if (tank_z + tank_height) > catch_z
    pipe_catch  = lengthpipe(catch_x, catch_y, catch_z, 0, 0, 0);
else
    pipe_catch  = lengthpipe(catch_x, catch_y, catch_z, tank_x, tank_y, tank_z);
end

%% pump varibles
[pump_a, pump_b, pump_c, pump_cost, pump_eff, pumplife_hours] = pumplookup(pump_var);

%% Cf total value

Cf_total  = (2*Cf) + (Cf*filter5um_var) + (Cf*0.05*filter200um_var);


%% velocity up and down 
 
vel_up = velocity_up(pump_a, pump_b, pump_c, Cf_total, tank_z, tank_height, pipe_HouseToStorage, fliterLocation); 
if ((vel_up == 0) && (pump_var ~= 4)), ave_satis = 0; return; end

vel_down = velocity_down(Cf_total, tank_z, tank_height, pipe_HouseToStorage, fliterLocation);
if (vel_down <= 0), ave_satis = 0; return; end


%% Roof var
[roof_area, roof_cost] = rooflookup(roof_var);
%% Catchment tank var
[collection_vol, collection_cost] = collectiontanklookup(collectionTank_var);
%% filter lifes
[life_1um, life_5um, life_200um] = filterlifelookup(filter5um_var, filter200um_var);
%% UV var 
[UVcost, UVreplacementcost, UVpowerusage_watts, UV_maxflow] = UVlookup(UV_var);
%% solar lookup
solar_cost = 0;
solar_GHG = 0;
solar_area = 0;
solar_eff = 1;
if power_var == 1;
    [solar_area, solar_cost, solar_eff, solar_GHG] = solarlookup(solar_var);
end

%% sim

for j = 1:loopsize %%loop for 3 sims

[failed_day_count, total_fuel, total_generator_running,solar_failure, ...
         total_cl, maintence_filters, tot_1um, tot_5um, tot_200um,total_pump_hours] = ...
rainsim2(roof_area, catchArea, catch_z, tank_height, tank_z,...
         collection_vol, tank_volume, userConsumption, ...
         power_var, solar_eff, solar_area, numsolarpanels, numbatteries,...
         pump_eff, UVpowerusage_watts,...
         chemical_var, ... %1 for chlorine, 2  for ozone
         fliterLocation,filter5um_var,filter200um_var, life_1um, life_5um, life_200um,...
         vel_up );
     
%% S(con)
scon_max = 0.6;
scon_min = 0.135;
scon_val = userConsumption;
if scon_val > scon_max scon_val = scon_max; 
elseif scon_val < scon_min scon_val = scon_min; failure = 1;
    end
Scon = 0.5*(1- cos( (scon_val - scon_min)* pi /(scon_max - scon_min)));

%% S(reliable)
srel_max = 365*5;
srel_min = 200*5;
srel_val = (365*5) - failed_day_count;
if srel_val > srel_max, srel_val = srel_max; 
elseif srel_val < srel_min, srel_val = srel_min; failure = 1;
end
Srel = 0.5*(1- cos( (srel_val - srel_min)* pi /(srel_max - srel_min)));


     
%% S(cost)
%cost constants
price_additional = 150; %per m^2
price_pipe  = 45; %per meter
price_storageVolume = 275; %per m^3
cost_transformer = 2369;
price_battery = 390;
price_generator = 3250;
price_oil = 50;
oiltime = 250; %hours
shipmentsizediesel = 100; %in L
price_dieselshipment  = 325; 
price_1um_i = 125;
price_5um_i = 110;
price_200um_i = 100;
price_1um_r = 75;
price_5um_r = 60;
price_200um_r = 50;
price_chlorine = 700;
price_chlorine_chem = 100; %per 3kg bottle
chlorinebottlesize = 3; %3kg
price_ozone = 4000;
price_watershipment = 75; 

roof_cost;
additionalcatchment_cost = price_additional * catchArea;
collection_cost;

catchpipemult = 1;
if catchArea == 0, catchpipemult = 0; end
uppipemult = 1;
if roof_var == 1, uppipemult = 0; end
pipe_cost = price_pipe*(pipe_HouseToStorage + (uppipemult*pipe_HouseToStorage) + (pipe_catch*catchpipemult));

storagevol_cost = price_storageVolume*tank_volume;
tower_cost = (27*tank_volume^1.6) + (140*tank_height^1.7);

pumpmult = 1;
if pump_var ==4, pumpmult = 0; pump_cost_replacements = 0;
else
pump_cost_replacements = pumpmult*pump_cost* ceil(total_pump_hours/pumplife_hours);
end
pump_cost_inital = pump_cost*pumpmult;
UVcost;
UVreplacement_cost = 5*UVreplacementcost;

%power mults
solarmult = 1;
generatormult = 1;
if power_var == 2, solarmult=0; else generatormult=0; end
solarpanel_cost = solarmult*solar_cost*numsolarpanels;

cost_transformer;
cost_batteries = price_battery*numbatteries;
cost_generator = generatormult*price_generator;

if oiltime == 0, cost_oil = 0;else
cost_oil = ceil(total_generator_running / oiltime) * generatormult*price_oil;end

cost_shipments_oil = ceil(total_fuel / shipmentsizediesel) * generatormult*price_dieselshipment;

cost_filter_i = price_1um_i + (filter5um_var*price_5um_i) + (filter200um_var*price_200um_i);
cost_filter_r = (price_1um_r*tot_1um) + (price_5um_r*tot_5um) + (price_200um_r*tot_200um);

%chemical mult
chlormult = 1;
ozonemult = 1;
if chemical_var == 1, ozonemult=0; else chlormult = 0; end

cost_chlorine_sys = price_chlorine * chlormult;
cost_chlorine_chem = price_chlorine_chem* ceil( total_cl/ chlorinebottlesize) * chlormult;
cost_ozone = price_ozone * ozonemult;

cost_shippingwater = price_watershipment * failed_day_count;

defaultcost = 80000;

relativecost = ((roof_cost + additionalcatchment_cost + collection_cost+ pipe_cost+ ...
storagevol_cost+ tower_cost+ pump_cost_inital+ pump_cost_replacements+ ... 
UVcost+ UVreplacement_cost+ ...
solarpanel_cost+cost_transformer+ cost_batteries+ cost_generator+... 
cost_oil+ cost_shipments_oil+ cost_filter_i+ cost_filter_r+ ... 
cost_chlorine_sys+ cost_chlorine_chem+ cost_ozone+ cost_shippingwater) ... 
/ defaultcost);

scos_max = 1.25;
scos_min = 0.25;
scos_val = relativecost;
if scos_val > scos_max scos_val = scos_max;failure = 1; 
elseif scos_val < scos_min scos_val = scos_min;
end
Scos = 0.5*(1+ cos( (scos_val - scos_min)* pi /(scos_max - scos_min)));

%% S(flow rate)

flowrate = vel_down*area*1000*60;
if flowrate > UV_maxflow, flowrate = UV_maxflow; end

sflo_max = 35; %LPM
sflo_min = 15; %LMP
sflo_val = flowrate;
if sflo_val > sflo_max, sflo_val = sflo_max; 
elseif sflo_val < sflo_min, sflo_val = sflo_min; failure = 1;
end
Sflo = 0.5*(1- cos( (sflo_val - sflo_min)* pi /(sflo_max - sflo_min)));

%% S(health)

%health
chlor_sev_hea  = 4;
dies_sev_hea = 2;
%environment
chlor_sev_en  = 3;
dies_sev_en = 3;

if chlormult == 1
chlor_freq = (5*365) / ceil(total_cl/ chlorinebottlesize);
else chlor_freq = 1; %irrelevant value(for errorfix) 
end
if generatormult == 1
dies_freq = (5*365) / ceil(total_fuel / shipmentsizediesel);
else
dies_freq = 1; %irrelevant value(for errorfix)
end

shea_max = 35; %LPM
shea_min = 0; %LMP
shea_val = ((riskcalc(chlor_sev_hea,chlor_freq)+riskcalc(chlor_sev_en,chlor_freq))*chlormult) +... 
            ((riskcalc(dies_sev_en, dies_freq) + riskcalc(dies_sev_hea, dies_freq))*generatormult);

if shea_val > shea_max, shea_val = shea_max; failure = 1;
elseif shea_val < shea_min, shea_val = shea_min;
end
Shea = 0.5*(1+ cos( (shea_val - shea_min)* pi /(shea_max - shea_min)));

%% S(GHG)

%constants
GHG_diesel_perL = 3.25;
GHG_generator_per = 1250;
GHG_transformer = 100;
GHG_batt_per = 240;

GHG_org  = (userConsumption*(365*5)*6.5) + 2408;

GHG_diesel = GHG_diesel_perL*total_fuel*generatormult;
GHG_generator = GHG_generator_per*generatormult;
GHG_transformer;
GHG_batt = GHG_batt_per*numbatteries;
GHG_solar = solar_GHG * numsolarpanels;

sghg_max = 1; %LPM
sghg_min = 0.2; %LMP
sghg_val = (GHG_diesel+GHG_generator+GHG_transformer+GHG_batt+GHG_solar)/GHG_org;
if sghg_val > sghg_max, sghg_val = sghg_max; failure = 1;
elseif sghg_val < sghg_min, sghg_val = sghg_min; 
end
Sghg = 0.5*(1+ cos( (sghg_val - sghg_min)* pi /(sghg_max - sghg_min)));

%% S(main)

maintence_filters;
chlor_refills = ceil(total_cl/ chlorinebottlesize) * chlormult;
ozone_cleaning = 5;
UV_bulb_replacements = 5;
if pumplife_hours == 0 pump_replacements = 0; else
pump_replacements = ceil(total_pump_hours/pumplife_hours); end
solar_cleaning = (5*4)*solarmult;
diesel_refuel = ceil(total_fuel / shipmentsizediesel)*generatormult;
if oiltime == 0, diesel_oilchanges = 0; else
diesel_oilchanges = ceil(total_generator_running / oiltime) * generatormult; end

smai_max = 75*5; %LPM
smai_min = 15*5; %LMP
smai_val = (maintence_filters+chlor_refills +ozone_cleaning +...
UV_bulb_replacements + pump_replacements + solar_cleaning +...
diesel_refuel +diesel_oilchanges);

if smai_val > smai_max, smai_val = smai_max; failure = 1;
elseif smai_val < smai_min, smai_val = smai_min; 
end
Smai = 0.5*(1+ cos( (smai_val - smai_min)* pi /(smai_max - smai_min)));

%% S TOTAL
 Scon
 Scos
 Shea
 Sghg
 Smai
 Sflo
 Srel

if solar_failure == 1, failure = 1; end 
if failure == 1, satis = 0;
else
    satis(j, 1) = (0.2*Scon)+(0.25*Scos)+(0.1*Shea)+(0.1*Sghg)+(0.1*Smai)+(0.1*Sflo)+(0.15*Srel);
end

end
%disp("time:"); toc()
ave_satis = -1*mean(satis) %-1 for minimizing function
toc();
end

