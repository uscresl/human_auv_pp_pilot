% file with all parameters for running evaluation

% use the prepath if you put all data files and matlab lib into one dir
prepath = '/mnt/hdd/happ/';

%gpml_location = '/home/resl/gpml-matlab-v4.0-2016-10-19/';
gpml_location = strcat(prepath,'gpml-matlab-v4.0-2016-10-19');

%scenarios_file_path = '/home/resl/human_auv_pp_scenarios';
scenarios_file_path = strcat(prepath,'scenarios');

%auv_files_path = '/home/resl/human_auv_pp_auv_gp_files/';
auv_files_path = strcat(prepath,'auv_gp/'); % gp
% auv_files_path = strcat(prepath,'auv_lgp/'); % lgp
% auv_files_path = strcat(prepath,'auv_random/'); % random
% auv_files_path = strcat(prepath,'auv_lm/'); % lm

%auv_files_path_short = '/home/resl/human_auv_pp_auv_lgp_files_shorter/';
% auv_files_path = strcat(prepath,'auv_gp_shorter/'); % gp
auv_files_path_short = strcat(prepath,'auv_lgp_shorter/'); % lgp
% auv_files_path = strcat(prepath,'auv_random_shorter/'); % random

%user_files_path = '/home/resl/human_auv_pp_userfiles';
user_files_path = strcat(prepath,'humans');

map = [lines(7); [0 0 0]; [0.5 0.5 0.5]; [1,1,0]; [1, 0, 1]];
set(gcf,'defaultAxesColorOrder',map)

interpolate_gaussian('best',auv_files_path, user_files_path, ...
  gpml_location, scenarios_file_path, auv_files_path_short,false)

grid on