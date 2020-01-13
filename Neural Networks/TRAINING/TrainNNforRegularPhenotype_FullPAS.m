% Driver code for generating patient-specific NNs

Donors = {'WW'}; % Specify this each time based on what you got in the directory
numRuns = 1; % Specify the number of NNs for each donor to be made
    
for i = 1:length(Donors)
    regularplts = strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Full PAS (Trauma)\','Full_PAS_Trauma_Agonists_Donor_',Donors{i});
    for j = 1:numRuns
        % Take PAS data and get it in right format
        [concmatrix,data,meantimes] = GetBasicResults(regularplts);
        [concmatrix,data] = RearrangeConcmatrix_FullPAS(concmatrix,data);
     
        % Check concmatrix format (Mei had written this so I'll keep it)
        unique_vals = unique(concmatrix);
        lia = unique_vals - [-1 -1/3 1/3 1]';
        tol = 5.5511e-16; % tolerance for roundoff
        for count = 1:length(lia)
            if abs(lia(count)) > tol
                error('concmatrix values is not -1 -1/3 -1/3 1')
            else
            end
        end

        % Next it calls InterpolateData
    	[ProcessedTimes,ProcessedData,UsableTimes,UsableData,UsableConcs,SingleMatrixOfUsableConcs,SingleMatrixOfUsableData] = InterpolateData(concmatrix,data,meantimes);

        % Next it calls SetUpNN
        [net,inputs,inputStates,layerStates,targets,outputs,netc,xc,xic,aic,tc,yc,UsableConcs,UsableData,tr,trc,h1,h2,h3] = SetUpNNmodel(UsableConcs,UsableData);

        % Next it calls ConvertNNOutputs (I added this)
        [predictedData,actualData] = ConvertNNOutputs(yc,targets,concmatrix);
        
        % Calculate the correlation coefficient (I added this)
        [r,p,rlo,rup] = corrcoef(predictedData,actualData);
        
        save(strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Full PAS (Trauma)\Trained NNs\','Donor_',Donors{i},'_NN',num2str(j+1)));
    end
end