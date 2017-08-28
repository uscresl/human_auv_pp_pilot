% file with all parameters for running evaluation

gpml_location = '/home/sara/gpml-matlab-v4.0-2016-10-19/';
%gpml_location = '/home/resl/gpml-matlab-v4.0-2016-10-19/';

scenarios_file_path = '/home/sara/Notebook_Script/Data_Scenarios';
%scenarios_file_path = '/home/resl/human_auv_pp_scenarios';

%auv_files_path = '/home/sara/human_auv_pp_auv_lgp_files/'; % log gp
auv_files_path = '/home/sara/human_auv_pp_auv_gp_files/'; % gp
%auv_files_path = '/home/sara/human_auv_pp_auv_random_files/'; % random waypoints
%auv_files_path = '/home/sara/human_auv_pp_auv_lm_files/'; % lawnmower
auv_files_path_short = '/home/sara/human_auv_pp_auv_lgp_files_shorter/';
%auv_files_path = '/home/resl/human_auv_pp_auv_gp_files/';

user_files_path = '/home/sara/human_auv_pp_userfiles';
%user_files_path = '/home/resl/human_auv_pp_userfiles';


map = [lines(7); [0 0 0]; [0.5 0.5 0.5]; [1,1,0]; [1, 0, 1]];
set(gcf,'defaultAxesColorOrder',map)

interpolate_gaussian('best',auv_files_path, user_files_path, ...
  gpml_location, scenarios_file_path, auv_files_path_short,false)
grid on