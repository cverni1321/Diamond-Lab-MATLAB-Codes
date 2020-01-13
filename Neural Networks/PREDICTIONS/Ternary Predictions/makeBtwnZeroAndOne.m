function [ActualTriExpt, alldataregular, meandataregular] = makeBtwnZeroAndOne(ActualTriExpt, expt)
% expt is the regular PAS expt
% addpath('./NaN');

% option.npoints = 10;%Number of points to show errorbars at
% option.linewidth = 1.25;
% option = setopt(option, varargin{:});

regularplatelets = ActualTriExpt; % actual ternary experiment
PASplatelets = expt; % actual PAS experiment

%Subtract the mean baseline off from every curve (buffer well is the first
%one) 
meanbaseline = regularplatelets.samewells(regularplatelets.whereiscontrol).datamean;
numberofreps = size(regularplatelets.samewells(1).data,2);%assuming you had no reason to throw out any of the control replicates
% !!!MYL: PROBLEM#3 - assumes that there is the same numberofreps for every
% well. 


%First get all the data
% alldataregular (first,:,:)=which conditions in the expt structure
% alldataregular (:,second,:)=which replicate are we talking about
% alldataregular (:,:,third)=all the data
alldataregular = NaN(length(regularplatelets.samewells),numberofreps,length(meanbaseline));
for i = 1:length(regularplatelets.samewells)
    for replcatenumber = 1:size(regularplatelets.samewells(i).data,2)
        alldataregular(i,replcatenumber,:) = regularplatelets.samewells(i).data(:,replcatenumber)-meanbaseline;
    end
end

%Throw out the stuff which is below the mean baseline (This is the same as what Jeremy and I did for the Nat.BTech paper)
alldataregular(alldataregular<0)=0;

% maxdataregular=max(max(max(alldataregular)));%calculate the maxdata of all the replicates (remember this also contains the wells that contained 3 agonists)
% maxdataregular=max(max(max(alldataregular(~whereare3,:,:))));%Maxdata ignoring the three agonist combinations
% calculate the meandata
meandataregular=squeeze(mean(alldataregular,2));maxdataregular=max(max(meandataregular)); %calculate the max only using the mean curves of the double agonist combinations

%%% For regular PAS
%Subtract the mean baseline off from every curve (buffer well is the first
%one) 
meanbaseline_PAS = PASplatelets.samewells(PASplatelets.whereiscontrol).datamean;
numberofreps_PAS = size(PASplatelets.samewells(1).data,2);%assuming you had no reason to throw out any of the control replicates
% !!!MYL: PROBLEM#3 - assumes that there is the same numberofreps for every
% well. 


%First get all the data
% alldataregular (first,:,:)=which conditions in the expt structure
% alldataregular (:,second,:)=which replicate are we talking about
% alldataregular (:,:,third)=all the data
alldataregular_PAS = NaN(length(PASplatelets.samewells),numberofreps_PAS,length(meanbaseline_PAS));
for i = 1:length(PASplatelets.samewells)
    for replcatenumber_PAS = 1:size(PASplatelets.samewells(i).data,2)
        alldataregular_PAS(i,replcatenumber_PAS,:) = PASplatelets.samewells(i).data(:,replcatenumber_PAS)-meanbaseline_PAS;
    end
end

%Throw out the stuff which is below the mean baseline (This is the same as what Jeremy and I did for the Nat.BTech paper)
alldataregular_PAS(alldataregular_PAS<0)=0;


% maxdataregular=max(max(max(alldataregular)));%calculate the maxdata of all the replicates (remember this also contains the wells that contained 3 agonists)
% maxdataregular=max(max(max(alldataregular(~whereare3,:,:))));%Maxdata ignoring the three agonist combinations
% calculate the meandata
meandataregular_PAS=squeeze(mean(alldataregular_PAS,2));maxdataregular_PAS=max(max(meandataregular_PAS)); %calculate the max only using the mean curves of the double agonist combinations


% %Get the maximum of the entire plate and calculae the fraction of the
% %maximum signal we had
allmax = max(maxdataregular, maxdataregular_PAS);
alldataregular = alldataregular/allmax; meandataregular = meandataregular/allmax; % we are still only interested in scaling the ternary experiments

for i=1:length(regularplatelets.samewells)
    regularplatelets.samewells(i).datamean = (meandataregular(i,:))';
    for j = 1:size(alldataregular,2)
        regularplatelets.samewells(i).data(:,j) = squeeze(alldataregular(i,j,:));
    end
    regularplatelets.samewells(i).datastd = std(regularplatelets.samewells(i).data,[],2);
end

ActualTriExpt = regularplatelets;

end