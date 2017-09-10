% file with all parameters for running evaluation

% use the prepath if you put all data files and matlab lib into one dir
prepath = '/home/stephanie/data_happ/';

gpml_location = strcat(prepath,'gpml-matlab-v4.0-2016-10-19');

scenarios_file_path = strcat(prepath,'scenarios');

auv_files_path1 = strcat(prepath,'auv_gp_entropy/');
auv_files_path2 = strcat(prepath,'auv_gp_entropy_plus_mean/');
auv_files_path3 = strcat(prepath,'auv_random/');

user_files_path = strcat(prepath,'humans');

map = [lines(7); [0 0 0]; [0.5 0.5 0.5]; [1,1,0]; [1, 0, 1]];
set(gcf,'defaultAxesColorOrder',map)

% interpolate_gaussian('best',auv_files_path, user_files_path, ...
%   gpml_location, scenarios_file_path, auv_files_path_short,false)
interpolate_gaussian('all', user_files_path, ...
  gpml_location, scenarios_file_path, ...
  auv_files_path1, auv_files_path2, auv_files_path3, false)

grid on
