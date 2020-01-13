% 'conc.ADP|conc.CVX|conc.IIa|conc.U46619|conc.U46619_Enzo|conc.Epi|conc.Epi_bi|conc.Ilo';  
% Output: a matrix of the 4 parameters
%         results[m,1]=min
%         results[m,2]=max
%         results[m,3]=ec50
%         results[m,4]=Hill coefficient
conc=conc_matrix;
responses=avg_responses_matrix;
min_vector = zeros(size(conc,2),1);
max_vector = zeros(size(conc,2),1);
ec50_vector = zeros(size(conc,2),1);
hill_vector = zeros(size(conc,2),1);
modelResponses = zeros(size(responses));

for i = 1:size(conc,2)
    
results = ec50(conc(:,i),responses(:,i));
% min_vector(i) = results(1);
% max_vector(i) = results(2);
min_vector(i) = min(responses(:,i));
max_vector(i) = max(responses(:,i));
ec50_vector(i) = results(3);
hill_vector(i) = results(4);
modelResponses(:,i) = max_vector(i) + ((min_vector(i)-max_vector(i))./(1 + (conc(:,i)./ec50_vector(i)).^hill_vector(i)));

end




figure
semilogx(conc(:,1),responses(:,1),'o',conc(:,1),modelResponses(:,1),'--');
title('ADP')
figure
semilogx(conc(:,2),responses(:,2),'o',conc(:,2),modelResponses(:,2),'--');
title('CVX')
figure
semilogx(conc(:,3),responses(:,3),'o',conc(:,3),modelResponses(:,3),'--');
title('IIa')
figure
semilogx(conc(:,4),responses(:,4),'o',conc(:,4),modelResponses(:,4),'--');
title('U46619')
figure
semilogx(conc(:,5),responses(:,5),'o',conc(:,5),modelResponses(:,5),'--');
title('U46619_Enzo')
figure
semilogx(conc(:,6),responses(:,6),'o',conc(:,6),modelResponses(:,6),'--');
title('Epi')
figure
semilogx(conc(:,7),responses(:,7),'o',conc(:,7),modelResponses(:,7),'--');
title('Epi-bi')
figure
semilogx(conc(:,8),responses(:,8),'o',conc(:,8),modelResponses(:,8),'--');
title('ilo')