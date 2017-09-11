% this is a helper script to finish off the plots for happ comparison
%
% Stephanie Kemna
% University of Southern California
% September 2017
%
xlim([0 13])
set(gca,'XTick',linspace(1,12,12))
set(gca,'XTickLabel',linspace(1,12,12))
pause(1)
xlabel('Plot Number')
ylabel('RMSE')
ylim ([0 0.2])
grid on;
finish_font;
pause(1)
moveLabel(30) 