function plateletScore = OverallPlateletActivation(expt)

% Compute the overall platelet activation status for a given donor
% (motivated by Leytin et al (2000) paper using P-selectin measurements)

[~,~,baselinediff,~] = NormalizedCalciumAUC(expt);

for i = 1:length(baselinediff)
    if baselinediff(i) < 0
        baselinediff(i) = 0;
    else
    end
end

plateletScore = sum(baselinediff);