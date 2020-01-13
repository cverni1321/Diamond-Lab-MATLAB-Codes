function [time,positiveamplitude,negativeamplitude] = plotTEGALLTIMEPOINTS(R,K,alpha,MA,LY30)

% This script will output a TEG display given the parameters listed below

% Inputs:
% - R: Reaction time (period of time from start to initial fibrin
%   formation)
% - K: Amplification (time take to achieve a certain level of clot strength
%   where R=time 0)
% - alpha (angle): Propagation (speed at which fibrin build-up and cross-linking
%   takes place, rate of clot formation)
% - MA: Maximum amplitude (strongest point of fibrin clot, maximum dynamic
%   properties of fibrin and platelet bonding via IIb/IIIa)
% - LY30: Clot stability (percentage decrease in amplitude 30 minutes
%   post-MA, gives measure of fibrinolysis)

% First must round the parameters to nearest decimal
R = round(R,1);
K = round(K,1);
alpha = round(alpha,1);
MA = round(MA,1);
LY30 = round(LY30,1);

% Check to see that there are the same number of parameters
numParam(1) = length(R);
numParam(2) = length(K);
numParam(3) = length(alpha);
numParam(4) = length(MA);
numParam(5) = length(LY30);
if numel(unique(numParam))>1
    error('The parameter vectors are unequal')
end

for timepoint = 1:length(R)
    totaltime = 2*(R(timepoint)+K(timepoint)+30); % Not sure if 2K is accurate but good estimation
    time = 0:0.1:totaltime;
    positiveamplitude = zeros(length(time),1);
    negativeamplitude = zeros(length(time),1);
    alpha(timepoint) = alpha(timepoint)*2*pi()/360; % Convert degrees to radians

    % Plot lag time first as just straight line centered at 0
    initialtime = R(timepoint)*10+1;
    for i = 1:initialtime
        positiveamplitude(i) = 0;
        negativeamplitude(i) = 0;
    end

    % Plot part of curve from R to K using alpha angle
    clottime = initialtime+K(timepoint)*10;
    alphaamplitude = K(timepoint)*tan(alpha(timepoint)); % Height of right triangle formed by alpha
    slope = alphaamplitude/K(timepoint);
    for j = initialtime+1:clottime
        positiveamplitude(j) = slope*(time(j)-R(timepoint));
        negativeamplitude(j) = -slope*(time(j)-R(timepoint));
    end

    % Finish curve to MA
    netMA = MA(timepoint)/2-alphaamplitude; % The actual MA value includes both the + and - portions
    MAslope = slope*2/3; % Make another estimate here
    halfMAtime = (netMA/2)/MAslope*10/2;
    halfMAtime = round(halfMAtime)+clottime;
    for k = clottime+1:halfMAtime
        positiveamplitude(k) = MAslope*(time(k)-(R(timepoint)+K(timepoint)+0.1))+alphaamplitude;
        negativeamplitude(k) = -MAslope*(time(k)-(R(timepoint)+K(timepoint)+0.1))-alphaamplitude;
    end

    restofMA = MA(timepoint)/2-positiveamplitude(halfMAtime);
    restofMAslope = MAslope*2/3;
    restofMAtime = restofMA/restofMAslope*10;
    restofMAtime = round(restofMAtime)+halfMAtime;
    for l = halfMAtime+1:restofMAtime
        positiveamplitude(l) = restofMAslope*(time(l)-time(halfMAtime)-0.1)+positiveamplitude(halfMAtime);
        negativeamplitude(l) = -restofMAslope*(time(l)-time(halfMAtime)-0.1)-positiveamplitude(halfMAtime);
    end

    % Now finish curve for lysis part
    finalamplitude = MA(timepoint)*(100-LY30(timepoint))/100;
    LYslope = (finalamplitude-MA(timepoint))/30;
    for m = restofMAtime+1:restofMAtime+300
        positiveamplitude(m) = LYslope*(time(m)-time(restofMAtime)-0.1)+positiveamplitude(restofMAtime);
        negativeamplitude(m) = -LYslope*(time(m)-time(restofMAtime)-0.1)-positiveamplitude(restofMAtime);
    end

    time(restofMAtime+301:end)=[];
    timearray{:,timepoint} = num2cell(time);
    positiveamplitude(restofMAtime+301:end)=[];
    positiveamplitudearray{:,timepoint} = num2cell(positiveamplitude); % Throw the results into a cell array for plotting
    negativeamplitude(restofMAtime+301:end)=[];
    negativeamplitudearray{:,timepoint} = num2cell(negativeamplitude);

    % Smooth data
    %positiveamplitude = smooth(positiveamplitude);
    %negativeamplitude = smooth(negativeamplitude);
end

figure
h1 = plot(cell2mat(timearray{1}),cell2mat(positiveamplitudearray{1}),'y');
hold on
h2 = plot(cell2mat(timearray{1}),cell2mat(negativeamplitudearray{1}),'y');
h3 = plot(cell2mat(timearray{2}),cell2mat(positiveamplitudearray{2}),'c');
h4 = plot(cell2mat(timearray{2}),cell2mat(negativeamplitudearray{2}),'c');
h5 = plot(cell2mat(timearray{3}),cell2mat(positiveamplitudearray{3}),'m');
h6 = plot(cell2mat(timearray{3}),cell2mat(negativeamplitudearray{3}),'m');
h7 = plot(cell2mat(timearray{4}),cell2mat(positiveamplitudearray{4}),'g');
h8 = plot(cell2mat(timearray{4}),cell2mat(negativeamplitudearray{4}),'g');
h9 = plot(cell2mat(timearray{5}),cell2mat(positiveamplitudearray{5}),'r');
h10 = plot(cell2mat(timearray{5}),cell2mat(negativeamplitudearray{5}),'r');
h11 = plot(cell2mat(timearray{6}),cell2mat(positiveamplitudearray{6}),'b');
h12 = plot(cell2mat(timearray{6}),cell2mat(negativeamplitudearray{6}),'b');
h13 = plot(cell2mat(timearray{7}),cell2mat(positiveamplitudearray{7}),'k');
h14 = plot(cell2mat(timearray{7}),cell2mat(negativeamplitudearray{7}),'k');
xlabel('Time (min)')
ylabel('Amplitude (mm)')
ylim([-50 50])
legend([h1,h3,h5,h7,h9,h11,h13],'T0','T3','T6','T12','T24','T48','T120') % Only need to specify color for every other curve 
   
end

