% function [avg_arr] = interpolate_gaussian (plots, auv_files_path, user_files_path, gpml_location, scenarios_file_path)
% calculates the average RMSEs for each plot for the AUV and human trials,
% and returns an array of the overall average RMSEs
%
% Author: Sara Kangaslahti
% Institution: USC
% Date: August 2017
%
function [avg_arr] = interpolate_gaussian (plots, auv_files_path, user_files_path, gpml_location, scenarios_file_path)

if nargin < 1
  auv_files_path = uigetdir;
end
if ( auv_files_path == 0 )
  error('Need a path for auv files');
end

if strcmp(plots, 'all') == 1
  %get the v4 auv and human averages
  [auv_avg,auv_vals] = plot_full_auv_human(true, false, 'v4', auv_files_path, ...
    user_files_path, gpml_location, scenarios_file_path);
  [human_avg,human_vals] = plot_full_auv_human(false, false, 'v4', auv_files_path, ...
    user_files_path, gpml_location, scenarios_file_path);
end
%get the gaussian process auv and human averages
[auv_avg_g,auv_vals_g] = plot_full_auv_human(true, false, 'gp', auv_files_path, ...
  user_files_path, gpml_location, scenarios_file_path);
[human_avg_g,human_vals_g] = plot_full_auv_human(false, false, 'gp', auv_files_path, ...
  user_files_path, gpml_location, scenarios_file_path);

% plot config
y_limits = [0 0.2];

%plot the boxplot
b1color = [0 0 0.8];
figure('Position',[0 0 1000 800])
bp1 = boxplot(human_vals_g, 'symbol', '+-.', 'Color', b1color);
set(bp1, 'LineWidth',3,'Color',b1color);
hold on

if strcmp(plots, 'all') == 1
  % color in RGB
  m3c1 = [0 0.8 0];
  bp2 = boxplot(human_vals,'symbol','+--','Color',m3c1);
  set(bp2,'LineWidth',3,'Color',m3c1);
  legend([bp1(3),bp2(3)], {'Human GP', 'Human v4'});

  title('Human RMSE')
end
xlabel('Plot Number')
ylabel('RMSE')
ylim (y_limits)

x = linspace (1,12,12);

%plot the scatterplot
if strcmp(plots, 'all') == 1
  figure('Position',[0 0 1000 800])
  sp1 = scatter(x,auv_vals,50,'filled');
  hold on
end

sp2 = scatter(x,auv_vals_g,50,[0,0.8,0],'filled');
if strcmp(plots, 'all') == 0
  title('Human vs Best AUV RMSE')
  legend([bp1(3),sp2], {'Human', 'Best AUV'});
else
  ylim (y_limits) % same as previous
  title('AUV RMSE')
  xlabel('Plot Number')
  ylabel('RMSE')  
  legend('auv v4','auv gp')
end

%create a cell array of the averages, and add a header
%avg_arr = [["AUV","Human"]; num2cell([auv_avg, human_avg])];
if strcmp(plots,'all') == 1
  avg_arr = [[auv_avg_g, human_avg_g]; [auv_avg, human_avg]];
else
  avg_arr = [auv_avg_g, human_avg_g];
end
end