% function [user_rmse, rand_avg, gaus_avg] = RMSE_scatter(user_name, interpolation_method, my_file_path, data_file_path)
% calculates the RMSE for each plot inside of a user's folder and returns
% the array of RMSE values and the average RMSE for the random field and
% gaussian scenarios
%
% Author: Sara Kangaslahti
% Institution: USC
% Date: August 2017
%
function [user_rmse, rand_avg, gaus_avg] = RMSE_scatter(user_name, interpolation_method, user_files_path, scenarios_file_path, gpml_location)

%initialize variables
sum_rand = 0; sum_gaus = 0;

%set default file paths so the latter two input arguments are not necessary
if ~exist('user_files_path','var')
  user_files_path = '/home/sara/human_auv_pp_userfiles';
end
if ~exist('scenarios_file_path','var')
  scenarios_file_path = '/home/sara/Notebook_Script/Data_Scenarios';
end
if ~exist('gpml_location','var')
  gpml_location = '/home/sara/gpml-matlab-v4.0-2016-10-19/';
end

run check_paths_trailing_slash;

%create a zero array to hold the user's RMSE values
user_rmse = zeros (1,12);

%loop through each file in the folder, and call the plot_gaussian function
%to get the RMSE values
for index = 1:12
  %get the file names for the full field and user path files
  field_file = [scenarios_file_path 'field_',num2str(index),'.csv'];
  user_file = [user_files_path, user_name, '/', user_name, '_path_', ...
    num2str(index), '.csv'];
  
  %set the values in the user rmse array
  user_rmse(index) = plot_gaussian(field_file, user_file, false, false, ...
    interpolation_method, gpml_location);
  
  %add the RMSEs of the first six plots (random fields) and the second
  %six plots (gaussian fields) separately
  if index < 7
    sum_rand = sum_rand + user_rmse(index);
  else
    sum_gaus = sum_gaus + user_rmse(index);
  end
end
%calculate the averages
rand_avg = sum_rand/6;
gaus_avg = sum_gaus/6;
end