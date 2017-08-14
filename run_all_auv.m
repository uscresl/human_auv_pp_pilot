%file for plotting all AUV results
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

x = linspace (1,12,12);
index = 1;
marker = 'o';
auv_avg = zeros (1,7);
for file = auv_files_path
  [auv_avg_g,auv_vals_g] = plot_full_auv_human(true, false, 'gp', char(file), ...
  user_files_path, gpml_location, scenarios_file_path);
  hold on;
  if index == 4
    marker = 'p';
  elseif index > 4
    marker = '^';
  end
  scatter(x,auv_vals_g,60,marker,'filled')
  auv_avg(index) = auv_avg_g;
  index = index + 1;
end
title('AUV RMSE')
xlabel('Plot Number')
ylabel('RMSE')
label_arr = {'log gp','gp', 'random waypoints', 'lawnmower', 'lgp short'...
  'gp short', 'random short'};
legend(label_arr)
hold off;
drawnow;
auv_avg_labeled = [label_arr; num2cell(auv_avg)];

