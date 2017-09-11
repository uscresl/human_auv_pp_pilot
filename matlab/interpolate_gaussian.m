% function [avg_arr] = interpolate_gaussian (plots, user_files_path,...
%   gpml_location, scenarios_file_path, ...
%   auv_files_path1, auv_files_path2, auv_files_path3)
%
% if plots is 'all', plots a figure with boxplots of the v4 and gp RMSEs
% for the human trials, and a figure with scatterplots of the v4 and gp
% RMSEs for the given auv trial; otherwise plots the human(boxplot) and 
% AUV(scatter) gp RMSEs in the same figure
%
% Author: Sara Kangaslahti
% Institution: USC
% Date: August 2017
%
function [avg_arr] = interpolate_gaussian (plots, user_files_path,...
  gpml_location, scenarios_file_path, ...
  auv_files_path1, auv_files_path2, auv_files_path3)

if ( ~exist('auv_files_path1','var') )
  error('Need a path for AUV files');
end

% set the interpolation methods (if plots is bestv4, then plot v4)
int_mthd1 = 'gp';
int_mthd2 = 'v4';
if strcmp(plots, 'bestv4') == 1
  int_mthd1 = 'v4';
  int_mthd2 = 'gp';
end

figure;

if strcmp(plots, 'all') == 1
  % get the v4 auv and human averages
  [auv_avg, auv_avg_fields, auv_all_rmse] = plot_full_auv_human(true, false, int_mthd2, ...
    auv_files_path1, gpml_location, scenarios_file_path);

  [human_avg, human_vals, human_all_rmse2] = plot_full_auv_human(false, false, int_mthd2, ...
    user_files_path, gpml_location, scenarios_file_path);
end

% get the gaussian process auv and human averages
[auv_avg1, not_used, auv_all_rmse1] = plot_full_auv_human(true, false, int_mthd1, ...
  auv_files_path1, ...
  gpml_location, scenarios_file_path);
[auv_avg2, not_used, auv_all_rmse2] = plot_full_auv_human(true, false, int_mthd1, ...
  auv_files_path2, ...
  gpml_location, scenarios_file_path);
[auv_avg3, not_used, auv_all_rmse3] = plot_full_auv_human(true, false, int_mthd1, ...
  auv_files_path3, ...
gpml_location, scenarios_file_path);

[human_avg_g, human_vals_g, human_all_rmse1] = plot_full_auv_human(false, false, int_mthd1, ...
  user_files_path, gpml_location, scenarios_file_path);

% plot config
y_limits = [0 0.2];

%plot the boxplot
b1color = [0 0 0.8];
% figure('Position',[0 0 1000 800])
bp1 = boxplot(human_all_rmse1, 'symbol', '+-.', 'Color', b1color);
set(bp1, 'LineWidth',3,'Color',b1color);
hold on

if strcmp(plots, 'all') == 1
  % color in RGB
  m3c1 = [0 0.8 0];

  %plot the 2nd boxplot in the same figure and add a legend/title
  bp2 = boxplot(human_all_rmse2,'symbol','+--','Color',m3c1);
  set(bp2,'LineWidth',3,'Color',m3c1);
  legend([bp1(3),bp2(3)], {'Human GP', 'Human v4'});
  title('Human RMSE')
end
%configure plot elements
xlabel('Plot Number')
ylabel('RMSE')
ylim (y_limits)

x = linspace (1,12,12);

%plot the scatterplot
if strcmp(plots, 'all') == 1
  figure('Position',[0 0 1000 800])
  sp1 = scatter(x,auv_all_rmse,50,'filled');
  hold on
end

%plot the second scatterplot
sp2 = scatter(x, auv_all_rmse1, 50, [0,0.8,0], 'filled');
sp3 = scatter(x, auv_all_rmse2, 50, [1, 0, 1], '^', 'filled');
sp4 = scatter(x, auv_all_rmse3, 50, [0.4, 0.4, 0.4], '*', 'LineWidth', 2);
if strcmp(plots, 'all') == 0
  if strcmp (plots, 'bestv4') == 1
    title('Human vs Best AUV RMSE (v4)')
  else
    title('Human vs Best AUV RMSE (gp)')
  end
  legend([bp1(3),sp2, sp3 sp4], {'Human', 'AUV 1', 'AUV 2', 'AUV 3'});
else
  ylim (y_limits) % same as previous
  title('AUV RMSE')
  xlabel('Plot Number')
  ylabel('RMSE')  
  legend('auv v4','auv 1', 'auv 2', 'auv 3')
end

%create a cell array of the averages, and add a header
%avg_arr = [["AUV","Human"]; num2cell([auv_avg, human_avg])];
if strcmp(plots,'all') == 1
  avg_arr = [[auv_avg1, human_avg_g]; [auv_avg, human_avg]];
else
  avg_arr = [auv_avg1, auv_avg2, auv_avg3, human_avg_g];
end

end