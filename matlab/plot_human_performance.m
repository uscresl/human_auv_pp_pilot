function [avg_arr] = plot_human_performance (gpml_location, scenarios_file_path, ...
  user_files_path, plots)

% set the interpolation methods (if plots is bestv4, then plot v4)
plot_human = true;

%% scatter plots

% always plot GP
[human_avg_GP, avg_human_per_fieldtype_GP, all_rmse_GP] = plot_full_auv_human(false, false, 'gp', ...
user_files_path, gpml_location, scenarios_file_path, plot_human);

r_avg_g = sum(avg_human_per_fieldtype_GP(:,1))/11;
g_avg_g = sum(avg_human_per_fieldtype_GP(:,2))/11;
avg_arr = [r_avg_g g_avg_g];

% plot v4 if 'all' selected
if ( strcmp(plots,'all') == 1 )
  % usage: plot_full_auv_human(auv, plot_on, interpolation_method, files_path, ...
  %  gpml_location, scenarios_file_path, user_plot_on)
  [human_avg_V4, avg_human_per_fieldtype_V4, all_rmse_V4] = plot_full_auv_human(false, false, 'v4', ...
  user_files_path, gpml_location, scenarios_file_path, plot_human);

  r_avg = sum(avg_human_per_fieldtype_V4(:,1))/11;
  g_avg = sum(avg_human_per_fieldtype_V4(:,2))/11;
  avg_arr = [r_avg_g g_avg_g; r_avg g_avg];
end

%% boxplots

% plot config
figure('Position',[0 0 1300 825])
map = [lines(7); [0 0 0]; [0.5 0.5 0.5]; [1,1,0]; [1, 0, 1]];
set(gcf,'defaultAxesColorOrder',map)

b1color = [0 0 0.8];
b2color = [0 0.8 0];

% plot the boxplot
bp1 = boxplot(all_rmse_GP, 'symbol', '+-.', 'Color', b1color);
set(bp1, 'LineWidth', 3,'Color', b1color);

% if also v4,
if strcmp(plots, 'all') == 1
  % plot the 2nd boxplot in the same figure and add a legend/title
  hold on
  bp2 = boxplot(all_rmse_V4, 'symbol', '+--', 'Color', b2color);
  set(bp2, 'LineWidth', 3, 'Color', b2color);
  legend([bp1(3), bp2(3)], {'Human GP', 'Human v4'});
else
  legend([bp1(3)], {'Human GP'});
end

% finish figure
title('Human RMSE')
xlabel('Plot Number')
ylabel('RMSE')
ylim auto
finish_font

end
