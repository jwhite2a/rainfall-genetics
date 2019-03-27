function [x,fval,exitflag,output,population,scores] = optimizeScript()

fun = @objectiveFunction;
nvars = 20;
A = [];
b = [];

lb = [0    0    0   0  2  0  1 0.135 1   0  1 1 0 0 1 1 1 1 1 1];
ub = [100  20  100  20 3  30 5 0.6   50  20 3 2 1 1 2 2 2 4 10 3];
    % 
intCon = [5 7 9 11 12 13 14 15 16 17  18 19 20]; %include all varible that are ints
nonlcon = [];
options  = gaoptimset('PopulationSize',25,...
                      'Generations',15,...
                      'PlotFcns',@gaplotbestf);

 [x,fval,exitflag,output,population,scores] = ...
    ga(fun,nvars,A,b,[],[],lb,ub,nonlcon,intCon, options)

end

