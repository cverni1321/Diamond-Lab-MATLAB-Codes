Donors = {'m'};   

% Assumes there are two reps and can only do inter-donor average

for i = 1:length(Donors)    
        traumaplts = strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\','Donor_',Donors{i},'_Abridged_PAS_1');
        load(traumaplts,'expt')
        expt1 = expt;
        clear expt
        traumaplts = strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\','Donor_',Donors{i},'_Abridged_PAS_2');
        load(traumaplts,'expt')
        expt2 = expt;
        clear expt
        
        CombinedPAS_expt = expt1;

        for j = 1:length(CombinedPAS_expt.samewells)
            
            a = expt1.samewells(j).data;
            b = expt2.samewells(j).data;
            data = [a b];

            a = expt1.samewells(j).rawdata;
            b = expt2.samewells(j).rawdata;
            rawdata = [a b];
            
            a = expt1.samewells(j).time;
            b = expt2.samewells(j).time;
            time = [a b];
            
            datamean = mean(data,2);
            datastd = std(data,[],2);
            timemean = mean(time,2);
            timestd = std(time,[],2);
                      
            CombinedPAS_expt.newsamewells(j).label = expt1.samewells(j).label;
            CombinedPAS_expt.newsamewells(j).conc = expt1.samewells(j).conc;
            CombinedPAS_expt.newsamewells(j).units = expt1.samewells(j).units;
            CombinedPAS_expt.newsamewells(j).data = data;
            CombinedPAS_expt.newsamewells(j).rawdata = rawdata;
            CombinedPAS_expt.newsamewells(j).time = time;
            CombinedPAS_expt.newsamewells(j).datamean = datamean;
            CombinedPAS_expt.newsamewells(j).datastd = datastd;
            CombinedPAS_expt.newsamewells(j).timemean = timemean;
            CombinedPAS_expt.newsamewells(j).timestd = timestd;
            
        end
        
        CombinedPAS_expt.samewells = CombinedPAS_expt.newsamewells;
        fields = {'newsamewells'};
        blah = rmfield(CombinedPAS_expt,fields);
        CombinedPAS_expt = blah;
        expt = CombinedPAS_expt;
        
        save(strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\','Donor_',Donors{i},'_Abridged_PAS_AVG'),'expt')
             
end
