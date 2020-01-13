function y = Simulate_single_NN(concmatrix, NN, t_sim, t_dispense)

load(NN,'netc')

n_ts = t_sim*2 + 1;
shift = 128;
n_dispense = ((n_ts+1)/2 + t_dispense); %260 or something
span = 15;

for i = 1:n_dispense
    UsableConcs{i} = -ones(6,1);
end

count = 0;
for i = n_dispense+1:n_ts
    count = count + 1;
    UsableConcs{i} = concmatrix(:,count);
end

inputSeries = UsableConcs;

% Definitely need a targetSeries or at least a made-up aic, otherwise won't
% work. aic is the initial layer delay states. 
% [xc,xic,aic,tc,~,shift] = preparets(netc,inputSeries,{},targetSeries);

% prepareTS
xic = cell(1,0);

blah = zeros(8,1);
for i = 1:shift
    aic{1,i} = blah;
end
blah = zeros(4,1);
for i = 1:shift
    aic{2,i} = blah;
end
blah = -ones(1,1);
for i = 1:shift
    aic{3,i} = blah;
end

xc = inputSeries(shift+1:end);
yc = netc(xc,xic,aic); % need xic and aic, otherwise predictions suck

xc_plot = xc(n_dispense-shift+1:end);
a = cell2mat(xc_plot);
%plot(1:length(a),a(2,:))
%ylim([-2,2])
%xlabel('time(s)')
%ylabel('[CVX]')

% The start is actually 20 seconds before dispense
start_idx = ceil(length(inputSeries)/2)-shift;  % 133 to end
yc_used = yc(start_idx:end);
x = 0:length(yc_used)-1;
x = x';

% Change to matrix first and smooth then see  
a = cell2mat(yc_used');
a_smooth = zeros(size(a));
for i = 1:size(a,2)
a_smooth(:,i) = smooth(a(:,i),span);
end
yc_used = (mat2cell(a_smooth,ones(length(yc_used),1)))';
y = seq2con(yc_used);
y = y{1};

%%%% Plot simulation
% plot(x,y)
% ylim([0 1])

end