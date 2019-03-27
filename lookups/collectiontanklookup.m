function [volume,cost] = collectiontanklookup(collectiontank_var)

switch collectiontank_var
    case 1
        volume = 0; cost = 0;
    case 2
        volume = 0.4; cost = 200;
    case 3
        volume = 1.5; cost = 300;
    case 4
        volume = 2.5; cost = 900;
    case 5
        volume = 10; cost = 2000;
    otherwise
        disp('error in collectiontanklookup')
end

