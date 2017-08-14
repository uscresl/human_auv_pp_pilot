% function [avg_arr] = interpolate_gaussian (auv_files_path, user_files_path, gpml_location, scenarios_file_path)
% calculates the average RMSEs for each plot for the AUV and human trials,
% and returns an array of the overall average RMSEs
%
% Author: Sara Kangaslahti
% Institution: USC
% Date: August 2017
%
function [avg_arr] = interpolate_gaussian (auv_files_path, user_files_path, gpml_location, scenarios_file_path)

if nargin < 1
  auv_files_path = uigetdir;
end
if ( auv_files_path == 0 )
  error('Need a path for auv files');
end

%get the gaussian process auv and human averages
[auv_avg_g,auv_vals_g] = plot_full_auv_human(true, false, 'gp', auv_files_path, ...
  user_files_path, gpml_location, scenarios_file_path);
[human_avg_g,human_vals_g] = plot_full_auv_human(false, false, 'gp', auv_files_path, ...
  user_files_path, gpml_location, scenarios_file_path);

%get the v4 auv and human averages
[auv_avg,auv_vals] = plot_full_auv_human(true, false, 'v4', auv_files_path, ...
  user_files_path, gpml_location, scenarios_file_path);
[human_avg,human_vals] = plot_full_auv_human(false, false, 'v4', auv_files_path, ...
  user_files_path, gpml_location, scenarios_file_path);

% plot config
y_limits = [0 0.2];

%plot the boxplot
figure('Position',[0 0 1000 800])
boxplot(human_vals_g)
hold on
boxplot(human_vals)
xlabel('Plot Number')
ylabel('RMSE')
title('Human RMSE')
ylim (y_limits)
legend('humans gp','humans v4')

%plot the scatterplot
figure('Position',[0 0 1000 800])
x = linspace (1,12,12);
scatter(x,auv_vals_g,50,'filled')
hold on
scatter(x,auv_vals,50,'filled')
ylim (y_limits) % same as previous
title('AUV RMSE')
xlabel('Plot Number')
ylabel('RMSE')
legend('auv gp','auv v4')

%create a cell array of the averages, and add a header
%avg_arr = [["AUV","Human"]; num2cell([auv_avg, human_avg])];
avg_arr = [auv_avg_g, human_avg_g];
end