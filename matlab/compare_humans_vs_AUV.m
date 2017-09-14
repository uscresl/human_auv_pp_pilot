% function [avg_arr] = compare_humans_vs_AUV(plots, user_files_path,...
%   gpml_location, scenarios_file_path, ...
%   auv_files_path1, auv_files_path2, auv_files_path3, auv_labels)
%
% if plots is 'all', plots a figure with boxplots of the v4 and gp RMSEs
% for the human trials, and a figure with scatterplots of the v4 and gp
% RMSEs for the given auv trial; otherwise plots the human(boxplot) and 
% AUV(scatter) gp RMSEs in the same figure
%
% Author: Sara Kangaslahti, Stephanie Kemna
% Institution: USC
% Date: August - September 2017
%
function [all_averages] = compare_humans_vs_AUV(plots, user_files_path,...
  gpml_location, scenarios_file_path, ...
  auv_files_path1, auv_files_path2, auv_files_path3, auv_labels)

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

% one figure for all results
figure('Position',[0 0 1800 900])
hold on
individual_plots = false;

% plot config
x_vals = linspace (1,12,12);
scatter_size = 75;
% color in RGB
b1color = [0 0 0.8]; % blue
b2color = [0.5 0.5 0.5]; % grey
auv1color = [0 0.8 0]; % green
auv2color = [0.8 0 0.8]; % magenta
auv3color = [0 0 0]; % black

% remove boxplot labels to not mess with axes
for idl = 1:length(x_vals),
  xlabels_empty{idl} = '';
end

if strcmp(plots, 'all') == 1
  % get the v4 auv and human averages
  [auv_avg_v4_1, ~, auv_all_rmse_v4_1] = plot_full_auv_human(true, ...
    individual_plots, int_mthd2, ...
    auv_files_path1, gpml_location, scenarios_file_path);
  [auv_avg_v4_2, ~, auv_all_rmse_v4_2] = plot_full_auv_human(true, ...
    individual_plots, int_mthd2, ...
    auv_files_path2, gpml_location, scenarios_file_path);
  [auv_avg_v4_3, ~, auv_all_rmse_v4_3] = plot_full_auv_human(true, ...
    individual_plots, int_mthd2, ...
    auv_files_path3, gpml_location, scenarios_file_path);
  
  [human_avg_v4, ~, human_all_rmse_v4] = plot_full_auv_human(false, ...
    individual_plots, int_mthd2, ...
    user_files_path, gpml_location, scenarios_file_path);
end

% get the gaussian process auv and human averages
[auv_avg1, ~, auv_all_rmse1] = plot_full_auv_human(true, ...
  individual_plots, int_mthd1, ...
  auv_files_path1, ...
  gpml_location, scenarios_file_path);
[auv_avg2, ~, auv_all_rmse2] = plot_full_auv_human(true, ...
  individual_plots, int_mthd1, ...
  auv_files_path2, ...
  gpml_location, scenarios_file_path);
[auv_avg3, ~, auv_all_rmse3] = plot_full_auv_human(true, ...
  individual_plots, int_mthd1, ...
  auv_files_path3, ...
gpml_location, scenarios_file_path);

[human_avg_g, ~, human_all_rmse1] = plot_full_auv_human(false, ...
  individual_plots, int_mthd1, ...
  user_files_path, gpml_location, scenarios_file_path);

% plot the boxplot with human data
bp1 = boxplot(human_all_rmse1, 'symbol', '+-.', 'Color', b1color, ...
  'labels', xlabels_empty);
set(bp1, 'LineWidth',3,'Color',b1color);

% AUV scatterplots
sp_auv1 = scatter(x_vals, auv_all_rmse1, scatter_size, auv1color, '^', 'LineWidth', 3);
sp_auv2 = scatter(x_vals, auv_all_rmse2, scatter_size, auv2color, '^', 'LineWidth', 3);
sp_auv3 = scatter(x_vals, auv_all_rmse3, scatter_size, auv3color, '^', 'LineWidth', 3);

if ( strcmp (plots, 'bestv4') == 1 )
  title('Human vs robot RMSE (V4)')
else
  title('Human vs robot RMSE (GP)')
end
legend([bp1(3), sp_auv1, sp_auv2 sp_auv3], ...
  {'Human', auv_labels{1}, auv_labels{2}, auv_labels{3}}, ...
  'Location', 'NorthEastOutside');
run finish_figure
pause(1)
hold off

if strcmp(plots, 'all') == 1
  % figure with alternate interp method, for 'all' the alternate is v4
  figure('Position',[0 0 1800 900])
  hold on

  % plot the human v4 data
  bp2 = boxplot(human_all_rmse_v4, 'symbol', '+--', 'Color', b2color, ...
    'labels', xlabels_empty);
  set(bp2,'LineWidth',3,'Color',b2color);
  % plot the AUV v4 data as well
  sp_v4_1 = scatter(x_vals, auv_all_rmse_v4_1, scatter_size, auv1color, 'filled');
  sp_v4_2 = scatter(x_vals, auv_all_rmse_v4_2, scatter_size, auv2color, 'filled');
  sp_v4_3 = scatter(x_vals, auv_all_rmse_v4_3, scatter_size, auv3color, 'filled');  

  title('Human vs robot RMSE (V4)')
  legend([bp2(3), sp_v4_1, sp_v4_2 sp_v4_3], ...
    {'Human', auv_labels{1}, auv_labels{2}, auv_labels{3}}, ...
    'Location', 'NorthEastOutside');
  run finish_figure
  pause(1)
  hold off
  
  
  % figure with EVERYTHING
  figure('Position',[0 0 1800 900])
  hold on

  % plot the boxplot with human gp data
  bp1 = boxplot(human_all_rmse1, 'symbol', '+-.', 'Color', b1color, ...
    'labels', xlabels_empty);
  set(bp1, 'LineWidth',3,'Color',b1color);
  % plot the human v4 data
  bp2 = boxplot(human_all_rmse_v4, 'symbol', '+--', 'Color', b2color, ...
    'labels', xlabels_empty);
  set(bp2,'LineWidth',3,'Color',b2color);
  % plot the AUV gp data
  sp_auv1 = scatter(x_vals, auv_all_rmse1, scatter_size, auv1color, '^', 'LineWidth', 3);
  sp_auv2 = scatter(x_vals, auv_all_rmse2, scatter_size, auv2color, '^', 'LineWidth', 3);
  sp_auv3 = scatter(x_vals, auv_all_rmse3, scatter_size, auv3color, '^', 'LineWidth', 3);
  % plot the AUV v4
  sp_v4_1 = scatter(x_vals, auv_all_rmse_v4_1, scatter_size, auv1color, 'filled');
  sp_v4_2 = scatter(x_vals, auv_all_rmse_v4_2, scatter_size, auv2color, 'filled');
  sp_v4_3 = scatter(x_vals, auv_all_rmse_v4_3, scatter_size, auv3color, 'filled');

  % all AUV results
  title('Human vs. all robot performance for both interpolation methods')
  %      hum gp   hum v4  auv v4            auv gp
  legend([bp1(3), bp2(3), sp_auv1, sp_auv2, sp_auv3, sp_v4_1, sp_v4_2, sp_v4_3, ], ...
    {'Human - GP', 'Human - V4', ...
     [auv_labels{1} ' - ' upper(int_mthd1)], [auv_labels{2} ' - ' upper(int_mthd1)], [auv_labels{3} ' - ' upper(int_mthd1)], ...
     [auv_labels{1} ' - ' upper(int_mthd2)], [auv_labels{2} ' - ' upper(int_mthd2)], [auv_labels{3} ' - ' upper(int_mthd2)]}, ...
    'Location', 'NorthEastOutside');  

  run finish_figure
  pause(1)
  hold off
end

% create a struct of all the averages for output
all_averages.human_gp = human_avg_g;
all_averages.auv_gp1 = auv_avg1;
all_averages.auv_gp2 = auv_avg2;
all_averages.auv_gp3 = auv_avg3;
if strcmp(plots,'all') == 1
  all_averages.human_v4 = human_avg_v4;
  all_averages.auv_v41 = auv_avg_v4_1;
  all_averages.auv_v42 = auv_avg_v4_2;
  all_averages.auv_v43 = auv_avg_v4_3;
end

end