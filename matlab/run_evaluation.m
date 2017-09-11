% file with all parameters for running evaluation

% all figures white background
set(0,'defaultfigurecolor',[1 1 1])

% use the prepath if you put all data files and matlab lib into one dir
% prepath = '/home/stephanie/data_happ/';
prepath = '/mnt/hdd/happ/';

gpml_location = strcat(prepath,'gpml-matlab-v4.0-2016-10-19');

scenarios_file_path = strcat(prepath,'scenarios');

auv_files_path1 = strcat(prepath,'auv_gp_entropy/');
auv_files_path2 = strcat(prepath,'auv_gp_entropy_plus_mean/');
auv_files_path3 = strcat(prepath,'auv_random/');

user_files_path = strcat(prepath,'humans');

% % plot all results for human participants
% plot_human_performance(gpml_location, scenarios_file_path, user_files_path, 'all')
% % pause(5)
% % plot_human_performance(gpml_location, scenarios_file_path, user_files_path, 'best')

% comparison humans vs AUV
% interpolate_gaussian('best',auv_files_path, user_files_path, ...
%   gpml_location, scenarios_file_path, auv_files_path_short,false)
auv_labels = {'AUV GP + entropy', 'AUV GP + entropy + mean', 'AUV random'};
interpolate_gaussian('all', user_files_path, ...
  gpml_location, scenarios_file_path, ...
  auv_files_path1, auv_files_path2, auv_files_path3, auv_labels)


