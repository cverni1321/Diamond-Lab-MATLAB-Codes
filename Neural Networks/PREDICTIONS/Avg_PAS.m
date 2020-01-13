
Reps = {'z','w','VV','v','p','m','e','aa'};   

% Average together multiple PAS experiments (inter- or intra-donor).
% Must specify the directory where the data is being stored and to be saved.

CombinedPAS_expt = struct();

for i = 1:length(Reps)    
    regularplts = strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\','Donor_',Reps{i},'_Abridged_PAS_1');
    load(regularplts,'expt')
    reps(i) = expt;
end
       
CombinedPAS_expt = expt;

for j = 1:length(CombinedPAS_expt.samewells)
    count = 1;
    CombinedPAS_expt.newsamewells(j).label = expt.samewells(j).label;
    CombinedPAS_expt.newsamewells(j).conc = expt.samewells(j).conc;
    CombinedPAS_expt.newsamewells(j).units = expt.samewells(j).units;
    
    for i = 1:length(reps)     
        data(:,count:count+1) = reps(i).samewells(j).data;
        time(:,count:count+1) = reps(i).samewells(j).time;
        count = count+2;
    end
    
    CombinedPAS_expt.newsamewells(j).data = data;
    CombinedPAS_expt.newsamewells(j).time = time;
    
    datamean = mean(data,2);
    datastd = std(data,[],2);
    timemean = mean(time,2);
    timestd = std(time,[],2);
    
    CombinedPAS_expt.newsamewells(j).datamean = datamean;
    CombinedPAS_expt.newsamewells(j).datastd = datastd;
    CombinedPAS_expt.newsamewells(j).timemean = timemean;
    CombinedPAS_expt.newsamewells(j).timestd = timestd;
end    
            
CombinedPAS_expt.samewells = CombinedPAS_expt.newsamewells;
fields = {'newsamewells'};
CombinedPAS_expt = rmfield(CombinedPAS_expt,fields);
expt = CombinedPAS_expt;
        
save(strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\','AVG_Abridged_PAS'),'expt')
             
