function expt = AF_calcdata(expt)

% Calculate the initiation time and other necessary parameters from the
% data

expt.initsetmaxtime = 1;
expt.initpercent = 0.05;
expt.discardflatlined = 'n';

expt = AF_calculations(expt, 'maxtime', @AF_calcmaxtime, @AF_calcmaxtime);
expt = AF_calculations(expt, 'maxrate', @AF_calcmaxrate, @AF_calcmaxrate);
expt = AF_calculations(expt, 'initiationtime', @AF_calcinitiationtime, ...
    @AF_calcinitiationtime, 'setmax', expt.initsetmaxtime, 'percent', expt.initpercent);
expt = AF_calculations(expt, 'integratedarea', @AF_calcintegratedarea, @AF_calcintegratedarea);
expt = AF_calculations(expt, 'maxdata', @AF_calcmaxdata, @AF_calcmaxdata);
% Mei also had calculated the inital slope/velocity of activation (might be
% interesting to look into)

end
