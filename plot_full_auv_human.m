% function [all_avg, val_arr] = plot_full_auv_human(auv, plot_on, interpolation_method, auv_files_path, user_files_path, gpml_location, scenarios_file_path)
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
function [all_avg, val_arr] = plot_full_auv_human(auv, plot_on, interpolation_method, auv_files_path, ...
  user_files_path, gpml_location, scenarios_file_path, user_plot_on)

if auv == true %looping through AUV paths
  %set the average values to the output of the RMSE scatter auv
  %function
  [val_arr, r_avg, g_avg] = RMSE_scatter_auv(auv_files_path, ...
    interpolation_method, scenarios_file_path, gpml_location);
  
  %compute the average AUV RMSE
  all_avg = (r_avg + g_avg)/2;
  %all_avg = [r_avg, g_avg];
  
  %make the x axis for the scatterplot
  x = linspace (1,12,12);
  
  if plot_on == true
    %adjust the size of the figure
    figure('Position',[200,200,900,650])
    
    %plot the AUV RMSE points
    scatter(x,val_arr,50,'filled');
    title('AUV RMSEs')
    ylim([0,0.12])
    %ylim([0,max(avg_arr)+.01])
  end
else
  %set the default file path
  if ~exist('user_files_path','var')
    user_files_path = '/home/sara/human_auv_pp_userfiles';
    %user_files_path = '/home/resl/human_auv_pp_userfiles';
  end
  
  %create an array of each folder in the directory
  files = dir (user_files_path);
  
  %initialize zero arrays so the sum of the RMSEs for each plot and the
  %average RMSE for each person can be calculated in the for loop
  val_arr = zeros(length(files)-2,12);
  user_avg = zeros(1,length(files)-2);
  
  %make the x axis for the scatterplot
  x = linspace (1,12,12);
  
  marker = 'o';
  
  %initialize variables for the highest RMSE value and loop index
  max_val = 0; user_index = 1;
  
  %create an array of spaces to hold the names of each person
  name_arr = repmat(" ", [1 length(files)-2]);
  
  %use the RMSE values for each user to plot all the RMSE values and
  %calculate the average RMSE value for each plot
  for file = files'
    %check that the file is a directory and not a hidden directory
    if file.isdir == true && ~strcmpi(file.name,'.') && ~strcmpi(file.name,'..')
      %see RMSE_scatter function below
      [RMSE,r_avg,g_avg] = RMSE_scatter(file.name, interpolation_method, ...
        user_files_path, scenarios_file_path, gpml_location);
      
      %get the highest RMSE value in all the plots so that the y axis
      %bounds are correct
      if max_val < max(RMSE)
        max_val = max(RMSE);
      end
      
      if user_plot_on == true
        scatter(x,RMSE,70,marker,'filled');
        hold on
%         if strcmp(marker, 'o') == 1
%           marker = '^';
%         elseif strcmp(marker, '^') == 1
%           marker = '>';
%         elseif strcmp(marker, '>') == 1
%           marker = '<';
%         elseif strcmp(marker, '<') == 1
%           marker = 'v';
%         elseif strcmp(marker, 'v') == 1
%           marker = 's';
%         elseif strcmp(marker, 's') == 1
%           marker = 'd';
%         elseif strcmp(marker, 'd') == 1
%           marker = 'p';
%         elseif strcmp(marker, 'p') == 1
%           marker = 'h';
%         end
        val_arr(user_index,1) = r_avg;
        val_arr(user_index,2) = g_avg;
      else
        %add the RMSE vals to the value array
        val_arr(user_index,:) = RMSE;
      end
      
      %get the name of the file for the user average array
      name_arr{user_index} = file.name;
      
      %calculate the user's average
      user_avg(user_index) = (r_avg + g_avg)/2;
      
      %increment loop index
      user_index = user_index + 1;
    end
  end
  
  if user_plot_on == true
    title (['User RMSEs (', interpolation_method, ')'])
    xlabel('Plot Number')
    ylabel('RMSE')
    legend (name_arr)
    ylim([0,0.14])
    hold off
    drawnow
  end
  if plot_on == true
    %plot the boxplot with each person's RMSE values
    figure('Position',[200,200,900,650])
    boxplot(val_arr)
    title('All RMSEs')
    ylim([0,0.14])
  end
  
  %calculate the average for all human users
  all_avg = sum(user_avg)/(length(files)-2);
  
  %add a header with names to the average array
  user_avg = [name_arr; num2cell(user_avg)];
  
  
end
end