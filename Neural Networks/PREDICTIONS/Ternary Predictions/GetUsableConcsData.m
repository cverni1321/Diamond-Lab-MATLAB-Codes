function [UsableData,UsableConcs, meantimes, data, concs] = GetUsableConcsData(expt)

% Need meantimes,data,concs

addpath('./NaN');
meantimes = expt.samewells(1).timemean;

[~,~,sortfields,sortmatrix] = sortstruct(expt.samewells,expt.sortfield);

nSpecies = length(sortfields);

ec_vector_labels = cell(1,nSpecies);
ec_vector = zeros(1,nSpecies);

for i = 1:length(ec_vector)
    temp = sortfields{i};
    ec_vector_labels{i} = temp{2};   
switch ec_vector_labels{i}
    case {'ADP'}
    ec_vector(i) = 1e-6;
    case {'A'}
    ec_vector(i) = 1e-6;
    case {'CVX'}
    ec_vector(i) = 2e-9; %or 2e-9
    case {'C'}
    ec_vector(i) = 2e-9;
    case {'IIa'}
    ec_vector(i) = 2e-8;
    case {'U'}
    ec_vector(i) = 1e-6;
    case {'U46619'}
    ec_vector(i) = 1e-6;
    case {'Ilo'}
%     ec_vector(i) = 30e-6;
    ec_vector(i) = 0.5e-6;
    case {'Epi'}
    ec_vector(i) = 2e-6;
    case {'PGE2'}
    ec_vector(i) = 20e-6;
    case {'AYPGKF'}
    ec_vector(i) = 300e-6;
    case {'AYP'}
    ec_vector(i) = 300e-6;
    case {'PAR4'}
    ec_vector(i) = 100e-6;
    case {'SFLLRN'}
    ec_vector(i) = 10e-6;
    case {'SFL'}
    ec_vector(i) = 10e-6;
    case {'PAR1'}
    ec_vector(i) = 12e-6;
    case {'GSNO'}
    ec_vector(i) = 7e-6;
    otherwise
        error('unidentified agonist')   
end
end

sortmatrix = bsxfun(@rdivide,sortmatrix,ec_vector);

% MYL: Makes sure that the unique values are 0, 0.1, 1, 10 only
sortmatrix = (round(sortmatrix*1000))/1000;

% MYL: DON'T REALLY NEED IT. %Find which are the conditions that contain 3 agonists
whereare3=(sortmatrix(:,1)~=0)&(sortmatrix(:,2)~=0)&(sortmatrix(:,3)~=0);

% check
unique_vals = unique(sortmatrix);
for i = 1:length(unique_vals)
lia = ismember(unique_vals(i),[0 0.1 1 10]);
    if lia == 0
        error('sortmatrix values is not 0, 0.1, 1 or 10')
    else
    end
end

%Subtract the mean baseline off from every curve (buffer well is the first
%one) 
meanbaseline = expt.samewells(expt.whereiscontrol).datamean;
numberofreps = size(expt.samewells(1).data,2);%assuming you had no reason to throw out any of the control replicates
% !!!MYL: PROBLEM#3 - assumes that there is the same numberofreps for every
% well. 


%First get all the data
% alldataregular (first,:,:)=which conditions in the expt structure
% alldataregular (:,second,:)=which replicate are we talking about
% alldataregular (:,:,third)=all the data
alldataregular=NaN(length(expt.samewells),numberofreps,length(meanbaseline));
for i=1:length(expt.samewells)
    for replcatenumber=1:size(expt.samewells(i).data,2)
        alldataregular(i,replcatenumber,:)= expt.samewells(i).data(:,replcatenumber)-meanbaseline;
    end
end

%Throw out the stuff which is below the mean baseline (This is the same as what Jeremy and I did for the Nat.BTech paper)
alldataregular(alldataregular<0)=0;

% maxdataregular=max(max(max(alldataregular)));%calculate the maxdata of all the replicates (remember this also contains the wells that contained 3 agonists)
% maxdataregular=max(max(max(alldataregular(~whereare3,:,:))));%Maxdata ignoring the three agonist combinations
% calculate the meandata
meandataregular=squeeze(mean(alldataregular,2));maxdataregular=max(max(meandataregular(~whereare3,:))); %calculate the max only using the mean curves of the double agonist combinations


% %Get the maximum of the entire plate and calculae the fraction of the
% %maximum signal we had
allmax = max(maxdataregular);
alldataregular = alldataregular/allmax; meandataregular = meandataregular/allmax;
data = meandataregular;

% Map the concentration to a scale from [-1 to 1] consistent with what
% Jeremy had done
P = sortmatrix/10;
P(P==0) = 0.001;
P = log10(P);
P = mapminmax(P');%3*37 matrix of concentrations , again this is just to be consistent with what jeremy had done

% MYL: this is where they fixed problem1?


% fix for only 2 states per species

P(P==0) = -1/3;
P(P==1) = 1/3;

% Lets plot it up
concs = P';

%%%%%%%%%%% need meantimes,data,concs

%UNTITLED2 Interpolates times to get data at 1 second intervals

% Inputs
% meantimes = times that are produced by the M-File PatientSpecificTherapy.m
% data = Data that is produced by PatientSpecificTherapy.m (either Regdata or P2Y12 data)
% concs = Concentrations that are used in every well
% Outputs
% ProcessedTimes - Vector of Times at which the values are reported (0:end)
% ProcessedData - Interpolated data at these instants
% UsableTimes - Vector of times to actually use (-endtime.....0.....endtime)
% UsableData - Matrix of data with 0s behind t=0 for the data
% UsableConcs- Matrix of concs with concentrations in a form that
% accounts for the total duration of the signal experiment and tapped delay
% line
% (These last three things were just to account for the tapped delay lines)
% SingleMatrixOfUsableConcs- Conc Matrix in a form consistent with the NN
% toolbox
% SingleMatrixOfUsableData- Matrix of Data (Not used)

%First Let us put in artificially that the value of the response is 0 at
%time =0
ProcesedTimes=cat(1,0,meantimes);
dummy=zeros(size(data,1),1);
ProcesedData=cat(2,dummy,data);

times2use=0:1:ceil(ProcesedTimes(end));
UsableTimes=-ceil(ProcesedTimes(end)):1:ceil(ProcesedTimes(end)); % UsableTimes is 1x525

%set up the matrix to conatin the data
dummy=NaN(size(data,1),length(times2use));

for  i=1:size(data,1)
    dummy(i,:)=interp1(ProcesedTimes,ProcesedData(i,:),times2use,...
        'linear','extrap');
end
ProcessedTimes=times2use;%(1x263double, which is 0 to 264)
ProcessedData=dummy; %(154x263double)

%     UsableConcs=cell(1,size(concs,1));
% dummy=cell(length(UsableTimes),1);
% Now set up the cell array of concentrations to use
% for i=1:size(concs,1)
%     for j=1:length(UsableTimes)
%         kutta{j}=concs(i,:)';%Switch the order around to be consistent with the NN toolbox notation where each column corresponds to a different input
%     end
%     UsableConcs{i}=kutta;
%     clear kutta
% end

for i=1:length(UsableTimes)
    kutta=[];
    for j=1:size(concs,1)% for data series j
        kutta=[kutta,concs(j,:)'];%Switch the order around to be consistent with the NN toolbox notation where each column corresponds to a different input
    end
    UsableConcs{i}=kutta;
    clear kutta
end


SingleMatrixOfUsableData=NaN(length(UsableTimes),size(concs,1));
% Now set up the matrix that will contain the data to use

% for i=1:size(concs,1)
%     for j=1:length(UsableTimes);
%         if UsableTimes(j)<0
%             ShuorerBaccha{1,j}=[0];
%             SingleMatrixOfUsableData(j,i)=0;
%         else
%             ShuorerBaccha{1,j}=[ProcessedData(i,UsableTimes(j)+1)];%Plus 1 because UsableTimes also contains 0
%             SingleMatrixOfUsableData(j,i)=ProcessedData(i,UsableTimes(j)+1);%Switch the order around to be consistent with the NN toolbox notation where each column corresponds to a different input
%         end
%     end
%     UsableData{i}=ShuorerBaccha;
%     %     plot(UsableData{i});hold on;
%     clear ShuorerBaccha
% end

% clear UsableData

for i=1:length(UsableTimes)
    superdummy=[];
    for j=1:size(concs,1)% for data series j
        if UsableTimes(i)<0
            superdummy(j)=0;
        else
            superdummy(j)=ProcessedData(j,UsableTimes(i)+1);
        end
    end
    
    UsableData{i}=superdummy;% data at time instant i
    clear superdummy
end

% figure
% plot(SingleMatrixOfUsableData);
% harami=cell2mat(UsableData);
% UsableData=mat2cell(harami,size(harami,1),size(harami,2));
SingleMatrixOfUsableConcs=concs';
% SingleCellOfUsableData=mat2cell(SingleMatrixOfUsableData,,size(concs,1))

IncorrectFormOfUsableConcs = UsableConcs;
%%%%%%%%%%% fix interpolate data
totaltimesteps=length(IncorrectFormOfUsableConcs);
actualstepofdispense=((totaltimesteps+1)/2)+20;%Because dispense happens at 20s

dummy=IncorrectFormOfUsableConcs;

zerosinNNconc=-1*ones(size(IncorrectFormOfUsableConcs{1},1), size(IncorrectFormOfUsableConcs{1},2));

for i=1:actualstepofdispense
    dummy{i}=zerosinNNconc;
end

UsableConcs=dummy;


end

