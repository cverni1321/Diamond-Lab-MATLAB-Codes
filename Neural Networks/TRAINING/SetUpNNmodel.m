function [net,inputs,inputStates,layerStates,targets,outputs,netc,xc,xic,aic,tc,yc,UsableConcs,UsableData,tr,trc,h1,h2,h3] = SetUpNNmodel(UsableConcs,UsableData)

% Creates patient-specific NN
% Solves an Autoregression Problem with External Input with a NARX Neural Network

% Inputs:

% UsableConcs - input time series.
% UsableData - feedback time series.


% Outputs:

% net - Narx Network (Open Form which uses true output for feedback)
% inputs - for the Open loop Network (net)(after preparation by preparets)
% inputStates - for the Open loop Network (net)(after preparation by preparets)
% layerStates - for the Open loop Network (net)(after preparation by preparets)
% targets - for the Open loop Network (net)(after preparation by preparets)
% outputs - for the Open loop Network (net)(after preparation by preparets)
% netc - Narx Network (Closed Form which uses simulated output for
% feedback) --> MAIN OUTPUT
% xc - Shifted Input (Closed Loop,netc)(after preparation by preparets)
% xic - Output States (Closed Loop,netc)(after preparation by preparets)
% aic - Layer States (Closed Loop,netc)(after preparation by preparets)
% tc - Shifted Target Series (Closed Loop,netc)(after preparation by preparets)
% yc - Ouptuts for the closed loop network netc

inputSeries = UsableConcs; % Inputs will always be agonist concentrations
targetSeries = UsableData; % Target/goal is to train NN to predict calcium traces as a function of input concs

% First let's plot up the experimental data
h1 = PlotUpPrediction(targetSeries,'Experiment'); % Not really required, but it works

% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 0;
feedbackDelays = [1 2 4 8 16 32 64 128];
hiddenLayerSize = [8 4]; % This refers to the nodal architecture of the NN --> can modify to monitor effect on performance ([8,4] is what Mei used)

net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);

% Set the default number of training epochs (Mei used 1000)
net.trainParam.epochs = 1000;

% Prepare the data for training and simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer states.
% Using PREPARETS allows you to keep your original time series data unchanged, while
% easily customizing it for networks with differing numbers of delays, with
% open loop or closed loop feedback modes.
% INPUTS has two rows - (1) the agonist concentrations and (2) the calcium
% response at the given time and combination. (The second row is also the
% same as TARGETS)
[inputs,inputStates,layerStates,targets] = preparets(net,inputSeries,{},targetSeries);

% Setup division of data for training, validation, and testing
net.divideParam.trainRatio = 90/100; % 90% for training network
net.divideParam.valRatio = 10/100; % 10% for validation
net.divideParam.testRatio = 0/100; % Start with omiting testing step

% Parameters you can turn on/off for open loop training
net.trainParam.showWindow = true;
net.trainParam.showCommandLine = true;
net.trainParam.max_fail = 5;
net.trainParam.mu_max = 1e100;

% Train the network in Open Loop form
[net,tr] = train(net,inputs,targets,inputStates,layerStates); % TR is the training record

% Test the Network
outputs = net(inputs,inputStates,layerStates);

% Now let's plot up the open loop form of the predicted data
h2 = PlotUpPrediction(outputs,'NN Prediction Open Loop form');

errors = gsubtract(targets,outputs);
openLoopPerformance = perform(net,targets,outputs);

% Plots (uncomment these lines to enable various plots)
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, plotregression(targets,outputs)
%figure, plotresponse(targets,outputs)
%figure, ploterrcorr(errors)
%figure, plotinerrcorr(inputs,errors)

% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the output layer. Basically the inputs to training the
% closed loop net are the outputs from the open loop net
netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];

% Lets make the output feedback into not just the first layer but the
% second layer as well (Don't know if we actually need to do this, but lets just try)
%netc.layerConnect = [false false true;true false true;false true false];
%netc.layerWeights{2,3}.delays = feedbackDelays;
%netc.trainFcn = 'trainbr'; % regularization

[xc,xic,aic,tc] = preparets(netc,inputSeries,{},targetSeries);

% Lets train it in the closed loop format (Mei did this because the
% predictions she got for the open loop format were awful)
[netc,trc] = train(netc,xc,tc,xic,aic);
yc = netc(xc,xic,aic);

% Now let's plot up the closed loop form of the predicted data
h3 = PlotUpPrediction(yc,'NN Prediction Closed Loop form');

closedLoopPerformance = perform(netc,tc,yc);

end

