% function [avg_arr] = interpolate_gaussian (plots, auv_files_path, ...
%   user_files_path, gpml_location, scenarios_file_path)
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
function [avg_arr] = interpolate_gaussian (plots, auv_files_path, user_files_path,...
  gpml_location, scenarios_file_path,short_file_path,plot_human)

if nargin < 1
  auv_files_path = uigetdir;
end
if ( auv_files_path == 0 )
  error('Need a path for auv files');
end

%set the interpolation methods (if plots is bestv4, then plot v4)
int_mthd1 = 'gp';
int_mthd2 = 'v4';
if strcmp(plots, 'bestv4') == 1
  int_mthd1 = 'v4';
  int_mthd2 = 'gp';
end

if strcmp(plots, 'all') == 1
  if plot_human == false
    %get the v4 auv and human averages
    [auv_avg,auv_vals] = plot_full_auv_human(true, false, int_mthd2, ...
      auv_files_path, gpml_location, scenarios_file_path,plot_human);
  end
  [human_avg,human_vals] = plot_full_auv_human(false, false, int_mthd2, ...
    user_files_path, gpml_location, scenarios_file_path,plot_human);
end
%get the gaussian process auv and human averages
if (plot_human == false)
  [auv_avg_g,auv_vals_g] = plot_full_auv_human(true, false, int_mthd1, auv_files_path, ...
    gpml_location, scenarios_file_path,plot_human);
  [auv_avg_short, auv_vals_short] = plot_full_auv_human(true,false, int_mthd1, short_file_path, ...
    gpml_location, scenarios_file_path,plot_human);
else
  grid on
  figure()
  map = [lines(7); [0 0 0]; [0.5 0.5 0.5]; [1,1,0]; [1, 0, 1]];
  set(gcf,'defaultAxesColorOrder',map)
end
[human_avg_g,human_vals_g] = plot_full_auv_human(false, false, int_mthd1, ...
  user_files_path, gpml_location, scenarios_file_path,plot_human);

if (plot_human == false)
  % plot config
  y_limits = [0 0.2];

  %plot the boxplot
  b1color = [0 0 0.8];
 % figure('Position',[0 0 1000 800])
  bp1 = boxplot(human_vals_g, 'symbol', '+-.', 'Color', b1color);
  set(bp1, 'LineWidth',3,'Color',b1color);
  hold on

  if strcmp(plots, 'all') == 1
    % color in RGB
    m3c1 = [0 0.8 0];

    %plot the 2nd boxplot in the same figure and add a legend/title
    bp2 = boxplot(human_vals,'symbol','+--','Color',m3c1);
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
    sp1 = scatter(x,auv_vals,50,'filled');
    hold on
  end

  %plot the second scatterplot
  sp2 = scatter(x,auv_vals_g,50,[0,0.8,0],'filled');
  sps = scatter (x, auv_vals_short,50, [1, 0, 1], '^', 'filled');
  if strcmp(plots, 'all') == 0
    if strcmp (plots, 'bestv4') == 1
      title('Human vs Best AUV RMSE (v4)')
    else
      title('Human vs Best AUV RMSE (gp)')
    end
    legend([bp1(3),sp2, sps], {'Human', 'AUV gp long', 'AUV gp short'});
  else
    ylim (y_limits) % same as previous
    title('AUV RMSE')
    xlabel('Plot Number')
    ylabel('RMSE')  
    legend('auv v4','auv gp', 'auv short (gp)')
  end

  %create a cell array of the averages, and add a header
  %avg_arr = [["AUV","Human"]; num2cell([auv_avg, human_avg])];
  if strcmp(plots,'all') == 1
    avg_arr = [[auv_avg_g, human_avg_g]; [auv_avg, human_avg]];
  else
    avg_arr = [auv_avg_g, auv_avg_short, human_avg_g];
    
  end
else
  r_avg_g = sum(human_vals_g(:,1))/11;
  g_avg_g = sum(human_vals_g(:,2))/11;
  r_avg = sum(human_vals(:,1))/11;
  g_avg = sum(human_vals(:,2))/11;
  avg_arr = [r_avg_g g_avg_g; r_avg g_avg];
end
end