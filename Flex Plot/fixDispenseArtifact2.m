function [expt] = fixDispenseArtifact2(expt)

if expt.dispensetime2 == 480
    t_dispense_2 = 153; % Choose 153 because thats when t = 480
elseif expt.dispensetime2 == 320
    t_dispense_2 = 102;
else
    [~,t_dispense_2] = min(abs(expt.samewells(1).timemean-expt.dispensetime2)); 
end

std_small = 5e-3;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Second Dispense %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fix Average only
for s = 1:numel(expt.samewells)
    total = 0;
    count = 0;
        
    for i = t_dispense_2-6:t_dispense_2-2
        total = total + expt.samewells(1,s).datamean(i);
        count = count + 1;
        avg = total/count;
    end

    for k = t_dispense_2-2:t_dispense_2+4
        expt.samewells(1,s).datamean(k) = avg;
        expt.samewells(1,s).datastd(k) = std_small;
    end       
end

% Fix everything
for s = 1:numel(expt.samewells)
    [r,c] = size(expt.samewells(1,s).data);   
    for col = 1:c
        total = 0;
        count = 0;
        for i = t_dispense_2-6:t_dispense_2-2
            total = total + expt.samewells(1,s).data(i,col);
            count = count + 1;
            avg = total/count;
        end
        for k = t_dispense_2-1:t_dispense_2+4
            expt.samewells(1,s).data(k,col) = avg;
        end 
    end
end

end



