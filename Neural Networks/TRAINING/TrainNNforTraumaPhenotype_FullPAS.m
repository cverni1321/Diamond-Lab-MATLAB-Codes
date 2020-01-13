% Driver code for generating patient-specific NNs

% Need to do in conjunction with some representative healthy data in order
% to get proper rescaling of the trauma data

regularplts = 'C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Full PAS (Trauma)\Full_PAS_Trauma_Agonists_Donor_cc';

PatientSample = {'164_T48'}; % Specify this each time based on what you got in the directory
numRuns = 5; % Specify the number of NNs for each donor to be made

for i = 1:length(PatientSample)
    traumaplts = strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Full PAS (Trauma)\','Full_PAS_Trauma_Agonists_Patient_',PatientSample{i});
    for j = 1:numRuns
        healthyexpt = load(regularplts);
        traumaexpt = load(traumaplts);
        expt = combineexperiments(healthyexpt.expt, traumaexpt.expt);
        expt.sortfield = healthyexpt.expt.sortfield;
        
        % Take healthy PAS data and get it in right format
        [healthyconcmatrix,~,healthymeantimes] = GetBasicResults(regularplts);
        
        healthydata = zeros((length(expt.samewells)/2),length(healthymeantimes));
        for healthyindex = 1:(length(expt.samewells)/2)
            healthydata(healthyindex,:) = expt.samewells(healthyindex).datamean;
        end
            
        [healthyconcmatrix,healthydata] = RearrangeConcmatrix_FullPAS(healthyconcmatrix,healthydata);
     
        % Check concmatrix format (Mei had written this so I'll keep it)
        unique_vals = unique(healthyconcmatrix);
        lia = unique_vals - [-1 -1/3 1/3 1]';
        tol = 5.5511e-16; % tolerance for roundoff
        for count = 1:length(lia)
            if abs(lia(count)) > tol
                error('concmatrix values is not -1 -1/3 -1/3 1')
            else
            end
        end
        
        % Take trauma PAS data and get it in right format
        [traumaconcmatrix,~,traumameantimes] = GetBasicResults(traumaplts);
        
        traumadata = zeros((length(expt.samewells)/2),length(traumameantimes));
        offset = length(expt.samewells)/2;
        for traumaindex = 1:(length(expt.samewells)/2)
            traumadata(traumaindex,:) = expt.samewells(traumaindex+offset).datamean;
        end
        
        [traumaconcmatrix,traumadata] = RearrangeConcmatrix_FullPAS(traumaconcmatrix,traumadata);
        
        % Check concmatrix format (Mei had written this so I'll keep it)
        unique_vals = unique(traumaconcmatrix);
        lia = unique_vals - [-1 -1/3 1/3 1]';
        tol = 5.5511e-16; % tolerance for roundoff
        for count = 1:length(lia)
            if abs(lia(count)) > tol
                error('concmatrix values is not -1 -1/3 -1/3 1')
            else
            end
        end
        
        % Combine the healthy and trauma datasets
        concmatrix = [healthyconcmatrix; traumaconcmatrix];
        data = [healthydata; traumadata];
        meantimes = healthymeantimes;
        
        datanew = RenormalizeData(data);
        
        cutoff = length(datanew)/2;
        
        datanew_healthy = datanew(1:cutoff,:);
        datanew_trauma = datanew(cutoff+1:end,:);
        
        %traumaconcmatrix(end+1,:) = 1;
        %datanew_trauma(end+1,:) = 1; % Just add in a random point at max value to scale everything down and make the colorbar work
        
        % Next it calls InterpolateData
    	[ProcessedTimes,ProcessedData,UsableTimes,UsableData,UsableConcs,SingleMatrixOfUsableConcs,SingleMatrixOfUsableData] = InterpolateData(traumaconcmatrix,datanew_trauma,meantimes);

        % Next it calls SetUpNN
        [net,inputs,inputStates,layerStates,targets,outputs,netc,xc,xic,aic,tc,yc,UsableConcs,UsableData,tr,trc,h1,h2,h3] = SetUpNNmodel(UsableConcs,UsableData);

        % Next it calls ConvertNNOutputs (I added this)
        [predictedData,actualData] = ConvertNNOutputs(yc,targets,traumaconcmatrix);
        
        % Calculate the correlation coefficient (I added this)
        [r,p,rlo,rup] = corrcoef(predictedData,actualData);
        
        save(strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Full PAS (Trauma)\Trained NNs\','Patient_',PatientSample{i},'_NN',num2str(j)));
    end
end