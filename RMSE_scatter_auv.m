% function [auv_rmse, rand_avg, gaus_avg] =  RMSE_scatter_auv(auv_files_path, interpolation_method, scenarios_file_path, gpml_location)
% calculates the RMSE for each auv plot, and also returns the average for
% the different types of scenarios (random and gaussian)
%
% Author: Sara Kangaslahti
% Institution: USC
% Date: August 2017
%
function [auv_rmse, rand_avg, gaus_avg] =  RMSE_scatter_auv(auv_files_path, interpolation_method, scenarios_file_path, gpml_location)

% initialize variables
auv_rmse = zeros(1,12);
sum_rand = 0; sum_gaus = 0;

% set default values for all function parameters
if ~exist('auv_files_path','var')
  auv_files_path = '/home/sara/human_auv_pp_auv_gp_files/';
end
if ~exist('interpolation_method','var')
  interpolation_method = 'v4';
end
if ~exist('scenarios_file_path','var')
  scenarios_file_path = '/home/sara/Notebook_Script/Data_Scenarios';
end
if ~exist('gpml_location','var')
  gpml_location = '/home/sara/gpml-matlab-v4.0-2016-10-19/';
end

run check_paths_trailing_slash;

% find all folders at the given location
folders = dir(auv_files_path);
% and skip the listings of . and ..
folders = folders(arrayfun(@(x) x.name(1), folders) ~= '.');

%loop through all the auv files and get their RMSE values
for field_num = 1:12
  % match folder to field number
  % note that we match with underscore to make sure it matches whole number
  %folder_name = folders(arrayfun(@(x)(endsWith(x.name,['_' num2str(field_num)])), folders)).name;
  % changed for Matlab R2012a:
  folder_name = folders(arrayfun(@(x)(any(regexp(x.name,['_' num2str(field_num) '$']))), folders)).name
  
  %call plot_gaussian to get the RMSEs
  auv_file_name = [auv_files_path folder_name '/auv_data.log'];
  data_file_name = [scenarios_file_path, 'field_', num2str(field_num), '.csv'];
  
  auv_rmse(field_num) = plot_gaussian(data_file_name, auv_file_name, ...
    true, false, interpolation_method, gpml_location);
  
  %calculate separate sums for the random fields and gaussian scenarios
  if (field_num < 7)
    sum_rand = sum_rand + auv_rmse(field_num);
  else
    sum_gaus = sum_gaus + auv_rmse(field_num);
  end
end

%calculate the average RMSE for random fields and gaussian scenarios
rand_avg = sum_rand/6;
gaus_avg = sum_gaus/6;
end