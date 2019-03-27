function [failed_day_count, total_fuel, total_generator_running,solar_failure, ...
         total_cl, maintence_filters, tot_1um, tot_5um, tot_200um, total_pump_hours]...
         ...%% 
         = rainsim2(area_roof, area_catch, z_catch, tower, elevation_tank,...
         vol_collection, vol_storage, userdemand, ...
         power_var, solar_eff, solar_area, num_solar, num_battery,...
         pump_eff, UV_power,...
         chemical_var, ... %1 for chlorine, 2  for ozone
         fliterLocation,filter5um_var,filter200um_var, filter1um_life, filter5um_life, filter200um_life,...
         vel_up)   
 %% globals    
     
globals();
global height_up
global battery_eff
global battery_energystor
global transformer_eff
global area

global rho
global g

chlorine_conversion = (100/10)*(20/1000); %results in kg of chlorine solution (20mult for concentration)
ozone_conversion = (50/10)*2000000 ;%volume to joules of energy
generator_conversion  = (1/(0.35*40000000));%joules to L of fuel
ztotal_tank = tower+elevation_tank+height_up;

%varibles (import)
% area_roof = 100;
% area_catch = 40;
% z_catch = 10;
% 
% 
% vol_collection = 10;
% vol_storage  = 50;
% userdemand = 0.3;
% 
% 
% power_var  = 1; % 1for solar, 2 for disel
% solar_eff = 0.17;
% solar_area = 4.2;
% num_solar = 10;
% 
% num_battery = 2;
% 
% pump_eff = 0.7;
% UV_power = 36;
% 
% chemical_var = 1; %1 for chlorine, 2  for ozone
% 
% fliterLocation = 2; % 1 is up, 2 is down
% filter5um_var = 1; %0 or 1
% filter200um_var =  1; %0 or 1
% filter1um_life = 20;
% filter5um_life = 20;
% filter200um_life = 20;

%other vars
delaydays = 31; %%IMPORTANT
failed_day_count = 0;
currentdelayday = 0;
solar_failure = 0;
total_pump_hours = 0;

tic();

days_total = (365*5) + 2;
cols = 22;
M = zeros(days_total, cols);

%% initial conditions
%%time
currentdate = datetime(1999, 12, 31);
M(1, 1) = year(currentdate);
M(1, 2) = month(currentdate);
M(1, 3) = day(currentdate);

%rain
M(1, 4) = round(rand); % wet or dry,  0 = dry
%% loop

for i = 2:days_total
   %% date col 1, 2, 3
    currentdate = currentdate+1;
    if(month(currentdate) == 2 && day(currentdate) == 29) currentdate = currentdate+1; end
   M(i, 1) = year(currentdate);
   M(i, 2) = month(currentdate);
   M(i, 3) = day(currentdate);
   
   currentdelayday = currentdelayday+1; 
   if currentdelayday <= delaydays
       delayfactor = 0;
   else
       delayfactor = 1;
   end
   
  %% rainfall prediction / solar rad
   M(i, 4) = markovchain( M(i-1, 4), M(i, 2)); %markov chain
   if M(i,4) == 0 M(i,5) = 0;
   else M(i,5) = gammarain(M(i,2)); end
   
   M(i, 6) = solarrad(M(i, 2), M(i, 5));%solar rad
   M(i, 7) = solarhours(M(i, 2), M(i, 5));%solar hours
%% Volume calcs
    M(i, 8) = area_roof * M(i, 5);
    M(i, 9) = area_catch * M(i, 5);
    
    %water in collection tank
    if z_catch >= ztotal_tank
        M(i, 10) = M(i, 8);
        catchmentcheck = 1 ;%for including additional catchment in colecltion tank or not
    else
        M(i, 10) = M(i, 8) + M(i, 9);
        catchmentcheck = 0;
    end
    if M(i, 10) > vol_collection M(i, 10) = vol_collection; end    
    
    %net water
    M(i, 11) = M(i,10) + (catchmentcheck*M(i, 9)) - (delayfactor*userdemand);
    
    %total water
    if M(i,11) + M(i-1, 12) >= 0
        M(i, 12) = M(i-1, 12) + M(i,11);
    else
        M(i, 12) = M(i-1, 12) + M(i,11) + userdemand;% previous day + net water + userdemand(no user demand)
        failed_day_count = failed_day_count + 1;
    end 
    if M(i, 12) > vol_storage M(i, 12) = vol_storage; end %check for max of water tank
    
    total_pump_hours = total_pump_hours+M(i, 9)/(vel_up * area*3600) ;
    
   %% chemical cals
   volume_into_tank = M(i,10) + (catchmentcheck*M(i, 9));  
   if chemical_var == 2 %for ozone
       M(i, 14)  = volume_into_tank*ozone_conversion;%joules of energy
   else %for chlorine
       M(i, 13) = volume_into_tank*chlorine_conversion;%amount of chlorine solution
   end
   %% energy calculations
   if pump_eff == 0, M(i, 15) = M(i,14); else
   M(i, 15) = (M(i,10)*rho*g*ztotal_tank/pump_eff) + M(i,14); end%energy needed to pump up all water + ozone
   
   %%power 
   if power_var == 1 % solar
        
       M(i, 16) = M(i-1, 18) - ((24-M(i, 7))*0.5*3600*UV_power*delayfactor/battery_eff);
       M(i, 17) = M(i, 16) - ( M(i, 7)*3600*UV_power*delayfactor) + (solar_area*num_solar*solar_eff*battery_eff*M(i,7)*3600*M(i,6));
       if M(i,17) > (battery_energystor * num_battery) M(i,17) = (num_battery * battery_energystor ); end
       M(i, 18) = M(i, 17) - ((24-M(i, 7))*0.5*3600*UV_power*delayfactor/battery_eff) - (M(i,15)/(battery_eff*transformer_eff));
       
       if M(i, 16) < 0 || M(i, 17) < 0 || M(i, 18) < 0
           solar_failure = 1; end %need a return
   else    % diesel
       M(i, 19) = ((M(i,15)) + (24*3600*UV_power*delayfactor /(transformer_eff*battery_eff*battery_eff) ))*(generator_conversion);   
   end
   
%% filter calculations

maintence_filters = 0;
maintencecheck = 0;
tot_1um = 0;
tot_5um = 0;
tot_200um = 0;


if fliterLocation == 1 %up
    volume_processed_filter = M(i,10) + (catchmentcheck*M(i, 9));
else %down
    volume_processed_filter = delayfactor*userdemand;
end

M(i, 20) = volume_processed_filter + M(i-1, 20);
M(i, 21) = filter5um_var*volume_processed_filter + M(i-1, 21);
M(i, 22) = filter200um_var*volume_processed_filter + M(i-1, 22);

if M(i, 20) > filter1um_life
    M(i, 20) = M(i, 20) - filter1um_life;
    maintencecheck = 1;
    tot_1um = tot_1um +1;
end
if M(i, 21) > filter5um_life
    M(i, 21) = M(i, 21) - filter5um_life;
    maintencecheck = 1;
    tot_5um = tot_5um +1;
end
if M(i, 22) > filter200um_life
    M(i, 22) = M(i, 22) - filter200um_life;
    maintencecheck = 1;
    tot_200um = tot_200um +1;
end
maintence_filters = maintence_filters+ maintencecheck;

%toc()
end

failed_day_count;
%diesel
total_fuel = sum(M(:, 19)); %in litres
total_generator_running = ((total_fuel*40000000)/4000)/3600; %hours running total

solar_failure;
total_cl = sum(M(:,13)); % kg of cl solution

maintence_filters;
tot_1um;
tot_5um;
tot_200um;


%toc()
%M(1:10,:)
