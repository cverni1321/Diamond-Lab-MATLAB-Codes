clear
clc
Donors = {'B','C','D','F','O','P','Q','R','S','U'};

nRuns = 1;
span = 15; % moving average window 15 seconds is what we are doing now

PredictedTriExpts = struct;
PredictedExpts = struct;
TriExpts = struct;
Expts = struct;
R_matrix_PAS = zeros(length(Donors),nRuns);
perf_matrix_PAS = zeros(length(Donors),nRuns);
R_matrix_Tri = zeros(length(Donors),nRuns);
perf_matrix_Tri = zeros(length(Donors),nRuns);

count = 0;
counts = 0;
countss = 0;

dirname = 'C:\Users\Chris\Desktop\Mei Stuff\NN\NN\1NN\1NN - 3 - nodes\';

for i = 1:length(Donors)  
    
    actualTriPAS = strcat('C:\Users\Chris\Desktop\Mei Stuff\S1_Dataset (Calcium Calc Paper)\Trinary\',Donors{i},'_Ternary');  
    counts = counts + 1;
    load(actualTriPAS)
    TriExpts.runs(counts) = expt;
  
    regularPAS = strcat('C:\Users\Chris\Desktop\Mei Stuff\S1_Dataset (Calcium Calc Paper)\PAS_Single_Binary\',Donors{i},'_Avg'); 
    countss = countss + 1;
    load(regularPAS)
    Expts.runs(countss) = expt;
        % when trying to do PredictedExpts remember that each regularPAS
        % experiment may be different, some has 154 conditions some has
        % both small ternary and 154 conditions. 
               
        for k = 1:nRuns
        
        count = count + 1;
%         NNOutputRegularPAS = strcat(dirname,Donors{i},'_Avg','_this_',num2str(k));               
        NNOutputRegularPAS = strcat('C:\Users\Chris\Desktop\Mei Stuff\S2_Dataset (Calcium Calc Paper)\','Donor_',Donors{i},'_NN_',num2str(k));
        [PredictedTriExpt, ActualTriExpt, R, perf, tc, yc] = TernaryPrediction(NNOutputRegularPAS, actualTriPAS, regularPAS,'noplot');
%         [PredictedTriExpt, concmatrix, sortfields, R, perf, tc, yc] = GetTriPrediction(NNOutputRegularPAS, actualTriPAS, span, 'smooth');
        PredictedTriExpts.runs(count) = PredictedTriExpt;
        R_matrix_Tri(i,k) = R;
        perf_matrix_Tri(i,k) = perf;
        PredictedTriExpts.tc{count} = tc;
        PredictedTriExpts.yc{count} = yc;        
        
%         PredictedTriExpts.labels(count) =  strcat(Donors{i},num2str(j),'_this_',num2str(k));

%         [PredictedExpt, R, perf, ~, ~] = RegularPrediction(regularPAS, NNOutputRegularPAS, span, 'smooth', 'noplot');
        %[PredictedExpt, R, perf, tc, yc] = ExtractNNPASPrediction(regularPAS, NNOutputRegularPAS);
        %PredictedExpts.runs(count) = PredictedExpt;
        %R_matrix_PAS(i,k) = R;
        %perf_matrix_PAS(i,k) = perf;
        %PredictedExpts.tc{count} = tc;
        %PredictedExpts.yc{count} = yc;   
        
        end

end
% 
% Average 2 PAS reps for each donor before using it as a standard for making Actual ternary expts between zero and one 
% CombinedExpts.runs = Expts.runs(1:(length(Expts.runs)/2)); % initialize
% 
% for i = 1:length(Expts.runs(1).samewells)
%     for j = 1:length(CombinedExpts.runs)
%     
%         a = Expts.runs(j).samewells(i).datamean;
%         b = Expts.runs(j+1).samewells(i).datamean;
%         c = mean([a b],2);
%         
%         CombinedExpts.runs(j).samewells(i).datamean = c;
%         CombinedExpts.runs(j).samewells(i).data(:,1) = a;
%         CombinedExpts.runs(j).samewells(i).data(:,2) = b;
%     end
% end

CombinedExpts.runs = Expts.runs;

% Make TriExpts values between zero and one
%for k = 1:length(TriExpts.runs)
%    [TriExpts.runs(k), alldataregular, meandataregular] = makeBtwnZeroAndOneTri(TriExpts.runs(k), CombinedExpts.runs(k));
%end


% Combine actual Ternary experiments
exptBCD_Tri = TriExpts.runs(1);
% exptBCD_Tri = TriExpts.runs(2);
for l = 1:length(exptBCD_Tri.samewells)
        exptBCD_Tri.samewells(1,l).data = [];
        exptBCD_Tri.samewells(1,l).time = [];
    
        for m = 1:length(TriExpts.runs)  

        exptBCD_Tri.samewells(1,l).data(:,m) = TriExpts.runs(m).samewells(1,l).datamean;
        exptBCD_Tri.samewells(1,l).time(:,m) = TriExpts.runs(m).samewells(1,l).timemean;
    
        end
end

for n = 1:length(exptBCD_Tri.samewells)

        exptBCD_Tri.samewells(1,n).datamean = mean(exptBCD_Tri.samewells(1,n).data,2);
        exptBCD_Tri.samewells(1,n).datastd = std(exptBCD_Tri.samewells(1,n).data,[],2);
        exptBCD_Tri.samewells(1,n).std = std(exptBCD_Tri.samewells(1,n).data,[],2);
        exptBCD_Tri.samewells(1,n).timemean = mean(exptBCD_Tri.samewells(1,n).time,2);       
   
end

% Combine actual PAS experiments
exptBCD_PAS = Expts.runs(1);
% exptBCD_PAS = Expts.runs(5);

for l = 1:length(exptBCD_PAS.samewells)
        exptBCD_PAS.samewells(1,l).data = [];
        exptBCD_PAS.samewells(1,l).time = [];
    
        for m = 1:length(TriExpts.runs)  

        exptBCD_PAS.samewells(1,l).data(:,m) = Expts.runs(m).samewells(1,l).datamean;
        exptBCD_PAS.samewells(1,l).time(:,m) = Expts.runs(m).samewells(1,l).timemean;
    
        end
end

for n = 1:length(exptBCD_PAS.samewells)

        exptBCD_PAS.samewells(1,n).datamean = mean(exptBCD_PAS.samewells(1,n).data,2);
        exptBCD_PAS.samewells(1,n).datastd = std(exptBCD_PAS.samewells(1,n).data,[],2);
        exptBCD_PAS.samewells(1,n).std = std(exptBCD_PAS.samewells(1,n).data,[],2);
        exptBCD_PAS.samewells(1,n).timemean = mean(exptBCD_PAS.samewells(1,n).time,2);       
   
end
% 
% Combine predicted Ternary experiments
exptBCD_Tri_Pred = PredictedTriExpts.runs(1);
min_length = length(PredictedTriExpts.runs(1).samewells(1,1).datamean);

for l = 1:length(exptBCD_Tri_Pred.samewells)
        exptBCD_Tri_Pred.samewells(1,l).data = [];
        exptBCD_Tri_Pred.samewells(1,l).time = [];
    
        for m = 1:length(PredictedTriExpts.runs)  
        
            if length(PredictedTriExpts.runs(m).samewells(1,l).datamean) < min_length
                min_length = length(PredictedTriExpts.runs(m).samewells(1,l).datamean);
            else
            end
            
        end
                            
        for m = 1:length(PredictedTriExpts.runs) 
            exptBCD_Tri_Pred.samewells(1,l).data(:,m) = PredictedTriExpts.runs(m).samewells(1,l).datamean(1:min_length);
            exptBCD_Tri_Pred.samewells(1,l).time(:,m) = PredictedTriExpts.runs(m).samewells(1,l).timemean(1:min_length);   

        end
end


for n = 1:length(exptBCD_Tri_Pred.samewells)

        exptBCD_Tri_Pred.samewells(1,n).datamean = mean(exptBCD_Tri_Pred.samewells(1,n).data,2);
        exptBCD_Tri_Pred.samewells(1,n).datastd = std(exptBCD_Tri_Pred.samewells(1,n).data,[],2);
        exptBCD_Tri_Pred.samewells(1,n).std = std(exptBCD_Tri_Pred.samewells(1,n).data,[],2);
        exptBCD_Tri_Pred.samewells(1,n).timemean = mean(exptBCD_Tri_Pred.samewells(1,n).time,2);       
   
end

exptBCD_Tri_Pred.tc = PredictedTriExpts.tc;
exptBCD_Tri_Pred.yc = PredictedTriExpts.yc;

% Combine predicted PAS experiments
exptBCD_PAS_Pred = PredictedExpts.runs(1);
min_length = length(PredictedExpts.runs(1).samewells(1,1).datamean);

for l = 1:length(exptBCD_PAS_Pred.samewells)
        exptBCD_PAS_Pred.samewells(1,l).data = [];
        exptBCD_PAS_Pred.samewells(1,l).time = [];
        
         for m = 1:length(PredictedExpts.runs)  

            if length(PredictedExpts.runs(m).samewells(1,l).datamean) < min_length
                min_length = length(PredictedExpts.runs(m).samewells(1,l).datamean);
            else
            end
            
         end
               
        for m = 1:length(PredictedExpts.runs) 
            exptBCD_PAS_Pred.samewells(1,l).data(:,m) = PredictedExpts.runs(m).samewells(1,l).datamean(1:min_length);
            exptBCD_PAS_Pred.samewells(1,l).time(:,m) = PredictedExpts.runs(m).samewells(1,l).timemean(1:min_length);
        end              
        
end

for n = 1:length(exptBCD_PAS_Pred.samewells)

        exptBCD_PAS_Pred.samewells(1,n).datamean = mean(exptBCD_PAS_Pred.samewells(1,n).data,2);
        exptBCD_PAS_Pred.samewells(1,n).datastd = std(exptBCD_PAS_Pred.samewells(1,n).data,[],2);
        exptBCD_PAS_Pred.samewells(1,n).std = std(exptBCD_PAS_Pred.samewells(1,n).data,[],2);
        exptBCD_PAS_Pred.samewells(1,n).timemean = mean(exptBCD_PAS_Pred.samewells(1,n).time,2);       
   
end

exptBCD_PAS_Pred.tc = PredictedExpts.tc;
exptBCD_PAS_Pred.yc = PredictedExpts.yc;

R_PAS = mean(mean(mean(abs(R_matrix_PAS))));
R_Tri = mean(mean(mean(abs(R_matrix_Tri))));

expt = exptBCD_PAS_Pred;
save(strcat(dirname,'Combined_PAS_Pred_',date),'expt','R_PAS','R_matrix_PAS','perf_matrix_PAS')
expt = exptBCD_Tri_Pred;
save(strcat(dirname,'Combined_Tri_Pred_',date),'expt','R_Tri','R_matrix_Tri','perf_matrix_Tri')
expt = exptBCD_PAS;
save(strcat(dirname,'Combined_PAS_',date),'expt')
expt = exptBCD_Tri;
save(strcat(dirname,'Combined_Tri_',date),'expt')


