function  gammaplot(month)
months = {'January', 'February', 'March', 'April', 'May', 'June', ...
	'July', 'August', 'September', 'October', 'November', 'December'};

AB = [0.6147038028	0.02484085404;
      1.031734007	0.01186836909;
    0.6714386386	0.02415880307;
    1.279017517	0.01032737138;
    0.4170896041	0.01352732172;
    0.960127968	0.007545290509;
    0.6351320849	0.01236377718;
    1.118635086	0.009970942529;
    0.5121916265	0.026266211;
    1.470667088	0.01163281625;
    1.210628793	0.01646097063;
    1.411536621	0.01157080054;
    ]; 
x = 0:0.0001:1;
pdf = gampdf(x, AB(month, 1), AB(month, 2));
pdf(1) = pdf(2);
titlegraph = ['Gammapdf of Rainfall in ', months(month)];
plot(x,pdf)
axis([0 0.1 0 80]);
title(titlegraph);
xlabel('Rainfall (m)');
ylabel();

end

