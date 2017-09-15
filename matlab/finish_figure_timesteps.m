% y axis
ylim auto
curr_ylim = ylim;
ylim([0 max(curr_ylim)]);
ylabel('RMSE')

% legend
lh = legend(bp_handles, 'Human', auv_labels{1}, auv_labels{2}, auv_labels{3}, ...
  'Location','NorthEast');
set(lh,'Position',[0.63 0.72 0.26 0.19]);


% x axis
set(gca,'XTick',1:nr_timesteps)
set(gca,'XTickLabel',x_labels)
xlim([0 nr_timesteps+0.5])
xlabel('nr of samples * 20')

% finishing up
grid on;
finish_font

% move xlabel down
moveLabel(30)