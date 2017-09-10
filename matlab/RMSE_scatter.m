% function [user_rmse, rand_avg, gaus_avg] = function [user_rmse, rand_avg, gaus_avg] = RMSE_scatter(...
%   interpolation_method, files_path, scenarios_file_path, gpml_location)
% 
% calculates the RMSE for each plot inside of a user's folder and returns
% the array of RMSE values and the average RMSE for the random field and
% gaussian scenarios
%
% Author: Sara Kangaslahti
% Institution: USC
% Date: August 2017
%
function [user_rmse, rand_avg, gaus_avg] = RMSE_scatter(...
  interpolation_method, files_path, scenarios_file_path, gpml_location)

% initialize variables
sum_rand = 0; sum_gaus = 0;
% create a zero array to hold the user's RMSE values
user_rmse = zeros (1,12);

%set default file paths so the latter two input arguments are not necessary
if ~exist('files_path','var')
  disp('ERROR: need files_path')
  return
end
if ~exist('scenarios_file_path','var')
  scenarios_file_path = '/home/sara/Notebook_Script/Data_Scenarios';
end
if ~exist('gpml_location','var')
  gpml_location = '/home/sara/gpml-matlab-v4.0-2016-10-19/';
end
if ~exist('interpolation_method','var')
  interpolation_method = 'v4';
end

run check_paths_trailing_slash;

%loop through each file in the folder, and call the calc_RMSE function
%to get the RMSE values
for field_nr = 1:12
  % get the filenames for the field data file
  % and user (auv or human) data file
  field_file = [scenarios_file_path 'field_',num2str(field_nr),'.csv'];
  user_file = [files_path, 'field_', num2str(field_nr), '.csv'];
  if ~exist(user_file, 'file')
    user_file = [files_path(1:length(files_path)-1), '_path_', num2str(field_nr), '.csv'];
  end
  if ~exist(user_file, 'file')
    error(['ERROR: cannot find: ' user_file]);
    return
  end
  
  %set the values in the user rmse array
  user_rmse(field_nr) = calc_RMSE(field_file, user_file, false, ...
    interpolation_method, gpml_location);
  
  %add the RMSEs of the first six plots (random fields) and the second
  %six plots (gaussian fields) separately
  if field_nr < 7
    sum_rand = sum_rand + user_rmse(field_nr);
  else
    sum_gaus = sum_gaus + user_rmse(field_nr);
  end
end
%calculate the averages
rand_avg = sum_rand/6;
gaus_avg = sum_gaus/6;
end