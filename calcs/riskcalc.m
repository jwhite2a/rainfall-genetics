function risk = riskcalc(severity,frequency)

if frequency <= 7
    frequency_val = (frequency* -0.16667) + 4.166667;
elseif frequency <= 30
    frequency_val = (frequency* -0.04348) + 3.304348;
else
    frequency_val = (frequency* -0.00299) + 2.089552; 
end
    risk = frequency_val * severity;
end

