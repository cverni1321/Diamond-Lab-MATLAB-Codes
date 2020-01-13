function[] = PlotHigherOrderPrediction(PredictedTriExpt, ActualTriExpt, concmatrix, sortfields)

% Input ternary calcium traces, and plot them.
% Both predicted and actual can be plotted together as well. 
% Plots are 2 x 4 (high is lower conc, bottom is higher conc)
% To get Predicted.mat, need to use TestTernary to produce ternary
% concmatrix and get prediction out of trained PAS data

% load('C:\Users\SLDLab\Desktop\Mei Experiments\2013\PAS with IIa\10-09-13 PAS Ternary - Donor P\Predicted_04-Oct-2013.mat')

nErrorPoints = 10; %Number of points to show errorbars at
% option.linewidth = 1.25;
% option = setopt(option, varargin{:});

% load(actualTriPAS)% BUT BEWARE IT IS EXPT 

if size(concmatrix,1) < size(concmatrix,2)
    concmatrix = concmatrix';
else
end
nSpecies = size(concmatrix,2); % concmatrix here is 161 x 6 (there are 161 conditions)
states = [-1/3 1/3]; % only two concentrations of each agonist, medium and low
expt = ActualTriExpt;
predicted_expt = PredictedTriExpt;
timemean = expt.samewells(1,1).timemean;
dispenseIdx =  find(timemean(timemean<24)); %dispense starts at 20s, dispense artifact 20-24s, so plot everything before that to be zero
timemean_pred = predicted_expt.samewells(1,1).timemean;

for i = 1:nSpecies
    for j = i+1:nSpecies
        
        place = 1:nSpecies;
        place(place==i) = [];
        place(place==j) = [];
        
        dummy = sortfields{1,i}; species1 = dummy{2};
        dummy = sortfields{1,j}; species2 = dummy{2};
                
        for k = 1:length(states)
            for l = 1:length(states)
            
                r = find(concmatrix(:,i) == states(k) & concmatrix(:,j) == states(l)); % There should be 8 
                toPlotConcs = concmatrix(r,:);
                toPlotLabels = expt.list_wells(r);
                toPlotExpts = expt.samewells(1,r);
                toPlotExptsPred = predicted_expt.samewells(1,r);
                                
                counter = 0;
                h = figure; % starts a 2 x 4 plot
%                 ConcSpecies1 = getfield(expt.samewells(1,r(1)).conc, species1);
%                 ConcSpecies2 = getfield(expt.samewells(1,r(1)).conc, species2);
%                 TitleOverall = strcat(species1, '=',num2str(ConcSpecies1), ';',species2, '=',num2str(ConcSpecies2));
                
                % Figure out title for this figure
                if states(k) == -1/3
                    state_spc1_label = 'L';
                elseif states(k) == 1/3
                     state_spc1_label = 'M';
                end
                
                if states(l) == -1/3
                    state_spc2_label = 'L';
                elseif states(l) == 1/3
                     state_spc2_label = 'M';
                end
                TitleOverall = strcat(species1, {' = '},state_spc1_label, {' ; '},species2, {' = '},state_spc2_label);
                TitleOverall = TitleOverall{1};
                for w = 1:length(place) % The 4 other agonists
                
                    z = find(toPlotConcs(:,place(w)) ~= -1); 
                    toPlotNowConcs = toPlotConcs(z,:);
                    toPlotNowLabels = toPlotLabels(z);
                    toPlotNowExpts = toPlotExpts(1,z);
%                     toPlotNowExptsStd = toPlotExpts(1,z).datastd;
                    toPlotNowExptsPred = toPlotExptsPred(1,z);
                    
                    dummy = sortfields{1,place(w)}; species3 = dummy{2};
                    
                    for x = 1:length(z) % Two conditions (M and L) for each agonists
                    counter = counter + 1;
                    
                    % Figure out title for this figure
                    if toPlotNowConcs(x,place(w)) == -1/3
                        state_spc3_label = 'L';
                        elseif toPlotNowConcs(x,place(w)) == 1/3
                        state_spc3_label = 'M';
                    end
                                        
                    TitleNow = strcat(species3, {' = '},state_spc3_label);
                                        
%                     ax_subplot = subplot(2,4,w + (x-1)*length(place)); 
                    ax_subplot = subplot(4,4,w + (x-1)*length(place)); 
%                     ax_subplot = subplot(4,2,counter);
                    ErrorPointsIdx = round(linspace(1, length(toPlotNowExpts(1,x).datamean), nErrorPoints));
                    C = setdiff(1:length(toPlotNowExpts(1,x).datastd),ErrorPointsIdx);
                    toPlotNowExpts(1,x).datastd(C) = NaN; % plot errorbars only at 10 points
                    toPlotNowExpts(1,x).datamean(dispenseIdx) = 0; % before dispense all 0
                    errorbar(timemean,toPlotNowExpts(1,x).datamean,toPlotNowExpts(1,x).datastd,'-r')
                    hold on
                    plot(timemean_pred,toPlotNowExptsPred(1,x).datamean,'-b')
                    title(TitleNow,'FontSize',10);    
                    set(ax_subplot, 'xlim', [0 300], 'ylim', [0 1.2],'FontSize',6);
                    
                    end
                
                end
%                  p = mtit('BigTitle','fontsize',14,'color',[0 0 0],'xoff',-.025,'yoff',.025);
                 p = mtit(TitleOverall,'fontsize',16,'color',[0 0 0],'xoff',-.025,'yoff',.035,'FontWeight','bold');
                 filename = TitleOverall;
                 saveas(h,filename,'fig')
                 saveas(h,filename,'pdf') 
                
                 
            end
        end    
                    
        
    end
end

