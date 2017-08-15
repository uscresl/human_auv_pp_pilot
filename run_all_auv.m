%file for plotting all AUV results

%all file paths
auv_files_char = ['/home/sara/human_auv_pp_auv_lgp_files/           '; ...
  '/home/sara/human_auv_pp_auv_gp_files/            '; ...
  '/home/sara/human_auv_pp_auv_random_files/        '; ...
  '/home/sara/human_auv_pp_auv_lm_files/            '; ...
  '/home/sara/human_auv_pp_auv_lgp_files_shorter/   '; ...
  '/home/sara/human_auv_pp_auv_gp_files_shorter/    '; ...
  '/home/sara/human_auv_pp_auv_random_files_shorter/'];
auv_files_path = cellstr(auv_files_char)';

gpml_location = '/home/sara/gpml-matlab-v4.0-2016-10-19/';
%gpml_location = '/home/resl/gpml-matlab-v4.0-2016-10-19/';

user_files_path = '/home/sara/human_auv_pp_userfiles';
%user_files_path = '/home/resl/human_auv_pp_userfiles';

scenarios_file_path = '/home/sara/Notebook_Script/Data_Scenarios';
%scenarios_file_path = '/home/resl/human_auv_pp_scenarios';

%initialize variables
x = linspace (1,12,12);
index = 1;
figure ('pos', [0 550 600 400]);
marker = 'o';
auv_avg_gp = zeros (1,7);
auv_avg_v4 = zeros (1,7);

%loop through each auv file
for file = auv_files_path
  %get the RMSE vals for the plot (gp)
  [auv_avg_g,auv_vals_g] = plot_full_auv_human(true, false, 'gp', char(file), ...
  user_files_path, gpml_location, scenarios_file_path);
  hold on;
  
  %make the scatterplot (gp)
  scatter(x,auv_vals_g,60,marker,'filled')
  
  %change the marker
  if strcmp(marker, 'o') == 1
    marker = '^';
  elseif strcmp (marker, '^') == 1
    marker = 's';
  elseif strcmp (marker, 's') == 1
    marker = 'p';
  end
  
  %set different markers for lm, short, and other paths
  if index == 4
    %set options in the plot
    ylim([0 0.14]);
    title('AUV RMSE (gp)')
    xlabel('Plot Number')
    ylabel('RMSE')
    label_arr = {'log gp','gp', 'random waypoints', 'lawnmower'};
    legend(label_arr)
    
    %create a new figure
    figure ('pos', [700 550 600 400]);
    hold on;
    set(gca,'ColorOrderIndex',4);
    scatter(x,auv_vals_g,60,marker,'filled')
    set(gca,'ColorOrderIndex',1);
    marker = 'o';
  end
  
  %add to the array of AUV average RMSEs
  auv_avg_gp(index) = auv_avg_g;
  index = index + 1;
end
index = 1;
marker = 'o';
%set options in the plot
ylim([0 0.14]);
title('AUV RMSE (gp)')
xlabel('Plot Number')
ylabel('RMSE')
label_arr = {'lawnmower', 'lgp short', 'gp short', 'random short'};
legend(label_arr)
hold off;
drawnow;
figure ('pos', [0 0 600 400]);
for file = auv_files_path
  %get the RMSE vals for the plot
  [auv_avg_g,auv_vals_g] = plot_full_auv_human(true, false, 'v4', char(file), ...
  user_files_path, gpml_location, scenarios_file_path);
  hold on;
  
  %make the scatterplot
  scatter(x,auv_vals_g,60,marker,'filled')
  
  %change the marker
  if strcmp(marker, 'o') == 1
    marker = '^';
  elseif strcmp (marker, '^') == 1
    marker = 's';
  elseif strcmp (marker, 's') == 1
    marker = 'p';
  end
  
  %set different markers for lm, short, and other paths
  if index == 4
    %set options in the plot
    ylim([0 0.14]);
    title('AUV RMSE (v4)')
    xlabel('Plot Number')
    ylabel('RMSE')
    label_arr = {'log gp','gp', 'random waypoints', 'lawnmower'};
    legend(label_arr)
    hold off;
    drawnow;
    
    %create a new figure
    figure ('pos', [700 0 600 400]);
    hold on;
    set(gca,'ColorOrderIndex',4);
    scatter(x,auv_vals_g,60,marker,'filled')
    set(gca,'ColorOrderIndex',1);
    marker = 'o';
  end
  
  %add to the array of AUV average RMSEs
  auv_avg_v4(index) = auv_avg_g;
  index = index + 1;
end
%set options in the plot
ylim([0 0.14]);
title('AUV RMSE (v4)')
xlabel('Plot Number')
ylabel('RMSE')
label_arr = {'lawnmower', 'lgp short', 'gp short', 'random short'};
legend(label_arr)
hold off;
drawnow;

label_arr = {'log gp', 'gp', 'random waypoints', 'lawnmower', 'lgp short', ...
  'gp short', 'random short'};
%label the avg array
auv_avg_labeled = [label_arr; num2cell(auv_avg_gp); num2cell(auv_avg_v4)];

