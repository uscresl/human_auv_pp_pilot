function [avg_arr] = plot_human_performance (gpml_location, scenarios_file_path, ...
  user_files_path, plots)

% set the interpolation methods (if plots is bestv4, then plot v4)
int_mthd1 = 'gp';
int_mthd2 = 'v4';

plot_human = true;

if ( strcmp(plots,'all') == 1 )
  % plot_full_auv_human(auv, plot_on, interpolation_method, files_path, ...
  %  gpml_location, scenarios_file_path, user_plot_on)
  [human_avg,human_vals] = plot_full_auv_human(false, false, int_mthd2, ...
  user_files_path, gpml_location, scenarios_file_path, plot_human);
end

% figure()
% grid on
% map = [lines(7); [0 0 0]; [0.5 0.5 0.5]; [1,1,0]; [1, 0, 1]];
% set(gcf,'defaultAxesColorOrder',map)

[human_avg_g,human_vals_g] = plot_full_auv_human(false, false, int_mthd1, ...
user_files_path, gpml_location, scenarios_file_path, plot_human);

r_avg_g = sum(human_vals_g(:,1))/11;
g_avg_g = sum(human_vals_g(:,2))/11;
avg_arr = [r_avg_g g_avg_g];

if ( strcmp(plots,'all') == 1 )
  r_avg = sum(human_vals(:,1))/11;
  g_avg = sum(human_vals(:,2))/11;
  avg_arr = [r_avg_g g_avg_g; r_avg g_avg];
end

end
