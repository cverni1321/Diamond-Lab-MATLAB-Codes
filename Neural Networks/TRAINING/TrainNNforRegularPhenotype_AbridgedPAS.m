% Driver code for generating patient-specific NNs (for trauma project)

Donors = {'y'}; % Specify this each time based on what you got in the directory
numRuns = 2; % Specify the number of NNs for each donor to be made
    
for i = 1:length(Donors)
    traumaplts = strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\','Abridged_PAS_Donor_',Donors{i});
    for j = 1:numRuns
        % Take PAS data and get it in right format
        [concmatrix,data,meantimes] = GetBasicResults(traumaplts);
        
        % For TRAUMA: need to rearrange the concmatrix to mirror
        % what I have written in other codes
        concmatrix = RearrangeConcmatrix_AbridgedPAS(concmatrix);
        
        % Next it calls InterpolateData
    	[ProcessedTimes,ProcessedData,UsableTimes,UsableData,UsableConcs,SingleMatrixOfUsableConcs,SingleMatrixOfUsableData] = InterpolateData(concmatrix,data,meantimes);

        % Next it calls SetUpNNmodel
        [net,inputs,inputStates,layerStates,targets,outputs,netc,xc,xic,aic,tc,yc,UsableConcs,UsableData,tr,trc,h1,h2,h3] = SetUpNNmodel(UsableConcs,UsableData);

        % Next it calls ConvertNNOutputs (I added this)
        [predictedData,actualData] = ConvertNNOutputs(yc,targets,concmatrix);
        
        % Calculate the correlation coefficient (I added this)
        %[r,p,rlo,rup] = corrcoef(predictedData,actualData);
        save(strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\Trained NNs\','Abridged_PAS_Donor_',Donors{i},num2str(j)));
        NNOutputRegularPASdirName = strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\Trained NNs\','Abridged_PAS_Donor_',Donors{i},num2str(j));
        [R,M,B,r,perf] = GetRvalue(NNOutputRegularPASdirName,j,numRuns);
        
        % Save again (overwrite once R has been calculated)
        save(strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\Trained NNs\','Abridged_PAS_Donor_',Donors{i},num2str(j)));
    end
end