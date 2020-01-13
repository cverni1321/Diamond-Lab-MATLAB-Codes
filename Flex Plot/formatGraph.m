% Use this script to format a graph from flexplot into a publication-ready
% display

function gca = formatGraph(gca)

box on
gca.LineWidth = 2;
set(gca,'fontsize',16)
title('')
xlabel('Time (s)')
ylabel('F/Fo')

legend('Location','northwest')
legend('boxoff')

end