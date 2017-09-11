% function [all_avg, val_arr] = plot_full_auv_human(auv, plot_on, ...
%   interpolation_method, files_path, ...
%   gpml_location, scenarios_file_path)
%
% if auv is true, plots the auv RMSE values for each field, otherwise plots
% all the human values for each field, and the average human values for each
% field. returns the average RMSE for all the fields and the array of
% average RMSE values (separated by field)
%
% Author: Sara Kangaslahti
% Institution: USC
% Date: August 2017
%
function [all_avg, avg_human_per_fieldtype, all_rmse] = plot_full_auv_human(auv, plot_on, ...
  interpolation_method, files_path, ...
  gpml_location, scenarios_file_path, user_plot_on)

% config
nr_fields = 12;
marker = 'o';
% make the x axis for the scatterplot
x = linspace (1,12,12);

% initialize because return type
avg_human_per_fieldtype = [];

if ( user_plot_on || plot_on )
  figure('Position',[0 0 1200 700])
  map = [lines(7); [0 0 0]; [0.5 0.5 0.5]; [1,1,0]; [1, 0, 1]];
  set(gcf,'defaultAxesColorOrder',map)
end
  
if auv == true %looping through AUV paths
  %set the average values to the output of the RMSE scatter auv
  %function
  [all_rmse, avg_fields_rand_gp, avg_fields_gmm] = get_RMSE_and_averages( ...
    interpolation_method, files_path, scenarios_file_path, gpml_location);
  
  %compute the average AUV RMSE
  all_avg = (avg_fields_rand_gp + avg_fields_gmm)/2;
  %all_avg = [r_avg, g_avg];
  
  %make the x axis for the scatterplot
  x = linspace (1,12,12);
  
  if plot_on == true
    % create figure at given position with given size
%     figure('Position', [0 0 1200 700])
    
    %plot the AUV RMSE points
    scatter(x, all_rmse, 50,'filled');
    title('AUV RMSEs')
    %ylim([0,max(avg_arr)+.01])
    ylim([0,0.12])
    grid on
  end
else
  %set the default file path
  if ~exist('files_path','var')
    files_path = '/home/sara/human_auv_pp_userfiles';
  end
  
  %create an array of each folder in the directory
  participants = dir (files_path);
  % remove . and ..
  participants = participants(3:length(participants))
  nr_participants = length(participants);
  
  % initialize zero arrays so the sum of the RMSEs for each plot and the
  % average RMSE for each person can be calculated in the for loop
  if ( user_plot_on == true )
    avg_human_per_fieldtype = zeros(nr_participants, 2);
  end
  user_avg = zeros(1,nr_participants);
  all_rmse = zeros(nr_participants, nr_fields);
  
  %initialize variables for the highest RMSE value and loop index
  max_val = 0; user_index = 1;
  
  run check_paths_trailing_slash

  % use the RMSE values for each user to plot all the RMSE values and
  % calculate the average RMSE value for each plot
  for part_idx = 1:length(participants)
    %check that the file is a directory and not a hidden directory
    username = participants(part_idx).name;
    
    % see get_RMSE_and_averages function below
    user_path = [files_path username '/' username]
    
    [RMSE, avg_fields_rand_gp, avg_fields_gmm] = get_RMSE_and_averages(interpolation_method, ...
      user_path, scenarios_file_path, gpml_location);

    % get the highest RMSE value in all the plots so that the y axis
    % bounds are correct
    if max_val < max(RMSE)
      max_val = max(RMSE);
    end

    if user_plot_on == true
      scatter(x,RMSE,70,marker,'filled');
      hold on
      avg_human_per_fieldtype(user_index,1) = avg_fields_rand_gp;
      avg_human_per_fieldtype(user_index,2) = avg_fields_gmm;
    end
    % store the RMSE vals
    all_rmse(user_index,:) = RMSE;

    %get the name of the file for the user average array
    name_arr{user_index} = username;

    %calculate the user's average
    user_avg(user_index) = (avg_fields_rand_gp + avg_fields_gmm)/2;

    %increment loop index
    user_index = user_index + 1;

  end
  
  if user_plot_on == true
    title (['User RMSEs (', interpolation_method, ')'])
    xlabel('Plot Number')
    ylabel('RMSE')
    legend (name_arr, 'Location','EastOutside')
    ylim([0,0.14])
    grid on
    finish_font
    hold off
  end
  
  if plot_on == true
    % plot the boxplot with each person's RMSE values
    figure('Position',[0 0 1200 700])
    boxplot(all_rmse)
    title('All RMSEs')
    ylim([0,0.14])
    grid on
    finish_font
  end
  
  % calculate the average for all human users
  all_avg = sum(user_avg)/(length(participants)-2);
  
  % add a header with names to the average array
  user_avg = [name_arr; num2cell(user_avg)];
end

end