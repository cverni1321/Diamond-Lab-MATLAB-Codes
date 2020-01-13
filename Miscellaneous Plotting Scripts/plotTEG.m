function [time,positiveamplitude,negativeamplitude] = plotTEG(R,K,alpha,MA,LY30)

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

totaltime = 2*(R+K+30); % Not sure if 2K is accurate but good estimation
time = 0:0.1:totaltime;
positiveamplitude = zeros(length(time),1);
negativeamplitude = zeros(length(time),1);
alpha = alpha*2*pi()/360; % Convert degrees to radians

% Plot lag time first as just straight line centered at 0
initialtime = R*10+1;
for i = 1:initialtime
    positiveamplitude(i) = 0;
    negativeamplitude(i) = 0;
end

% Plot part of curve from R to K using alpha angle
clottime = initialtime+K*10;
alphaamplitude = K*tan(alpha); % Height of right triangle formed by alpha
slope = alphaamplitude/K;
for j = initialtime+1:clottime
    positiveamplitude(j) = slope*(time(j)-R);
    negativeamplitude(j) = -slope*(time(j)-R);
end

% Finish curve to MA
netMA = MA/2-alphaamplitude; % The actual MA value includes both the + and - portions
MAslope = slope*2/3; % Make another estimate here
halfMAtime = (netMA/2)/MAslope*10/2;
halfMAtime = round(halfMAtime)+clottime;
for k = clottime+1:halfMAtime
    positiveamplitude(k) = MAslope*(time(k)-(R+K+0.1))+alphaamplitude;
    negativeamplitude(k) = -MAslope*(time(k)-(R+K+0.1))-alphaamplitude;
end

restofMA = MA/2-positiveamplitude(halfMAtime);
restofMAslope = MAslope*2/3;
restofMAtime = restofMA/restofMAslope*10;
restofMAtime = round(restofMAtime)+halfMAtime;
for l = halfMAtime+1:restofMAtime
    positiveamplitude(l) = restofMAslope*(time(l)-time(halfMAtime)-0.1)+positiveamplitude(halfMAtime);
    negativeamplitude(l) = -restofMAslope*(time(l)-time(halfMAtime)-0.1)-positiveamplitude(halfMAtime);
end

% Now finish curve for lysis part
finalamplitude = MA*(100-LY30)/100;
LYslope = (finalamplitude-MA)/30;
for m = restofMAtime+1:restofMAtime+300
    positiveamplitude(m) = LYslope*(time(m)-time(restofMAtime)-0.01)+positiveamplitude(restofMAtime);
    negativeamplitude(m) = -LYslope*(time(m)-time(restofMAtime)-0.01)-positiveamplitude(restofMAtime);
end

time(restofMAtime+301:end)=[];
positiveamplitude(restofMAtime+301:end)=[];
negativeamplitude(restofMAtime+301:end)=[];

% Smooth data
%positiveamplitude = smooth(positiveamplitude,'lowess');
%negativeamplitude = smooth(negativeamplitude);

figure
plot(time,positiveamplitude,'k')
hold on
plot(time,negativeamplitude,'k')
xlabel('Time (min)')
ylabel('Amplitude (mm)')
ylim([-50 50])

end

