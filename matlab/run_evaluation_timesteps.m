%% config
squares_per_time_step = 20;
max_path_length = 190;
nr_timesteps = ceil(max_path_length/squares_per_time_step);
nr_fields = 12;

% all figures white background
set(0,'defaultfigurecolor',[1 1 1])

% use the prepath if you put all data files and matlab lib into one dir
% prepath = '/home/stephanie/data_happ/';
prepath = '/mnt/hdd/happ/';

%% file locations
gpml_location = strcat(prepath,'gpml-matlab-v4.0-2016-10-19/');
gpml_startup = [gpml_location 'startup.m'];
run(gpml_startup);

scenarios_file_path = strcat(prepath,'scenarios/');

auv_files_path1 = strcat(prepath,'auv_gp_entropy/');
auv_files_path2 = strcat(prepath,'auv_gp_entropy_plus_mean/');
auv_files_path3 = strcat(prepath,'auv_random/');
auv_labels = {'GP + entropy', 'GP + entropy + mean', 'random'};

user_files_path = strcat(prepath,'humans/');
%create an array of each folder in the directory
participants = dir (user_files_path);
% remove . and ..
participants = participants(3:length(participants));
nr_participants = length(participants);


%% load data
cols = autumn(nr_fields);
cols_h = winter(nr_fields);
for field_nr = 1:nr_fields;
  
  if ( field_nr == 1 || field_nr == 6 )
    figure('Position',[0 0 1400 1000]);
    hold on;
  end
  
  % get field data
  field_file = [scenarios_file_path 'field_',num2str(field_nr),'.csv']
  % get the values for the full field
  field_data = csvread (field_file,3,0);
  field_lon = field_data(:,1);
  field_lat = field_data(:,2);
  field_val = field_data(:,3);
  
  field_locations = [field_lon, field_lat];
  
  % human data
  user_rmse_per_timestep = zeros(nr_participants,nr_timesteps);
  for part_idx = 1:nr_participants,
    % get data for user
    username = participants(part_idx).name;
    user_path = [user_files_path username '/' username];
    user_file = [user_path '_path_', num2str(field_nr), '.csv']
    user_data = csvread(user_file, 3, 0);
    
    user_rmse_per_timestep(part_idx,:) = rmse_per_timestep(nr_timesteps, ...
      squares_per_time_step, ...
      user_data, field_data);
  end
  bp(field_nr,:,:) = boxplot(user_rmse_per_timestep, ...
    'symbol', '+', 'Color', cols_h(field_nr,:));
  set(bp,'LineWidth', 3, 'Color', cols_h(field_nr,:));
  
  % auv data
  auv_file1 = [auv_files_path1 'field_' num2str(field_nr) '.csv']
  auv_data1 = csvread(auv_file1, 3, 0);
  auv_rmse_per_timestep1 = rmse_per_timestep(nr_timesteps, ...
    squares_per_time_step, ...
    auv_data1, field_data);
  s1(field_nr) = scatter(1:nr_timesteps, auv_rmse_per_timestep1, 50, ...
    cols(field_nr,:), 'o', 'LineWidth', 3);
  
  auv_file2 = [auv_files_path2 'field_' num2str(field_nr) '.csv']
  auv_data2 = csvread(auv_file2, 3, 0);
  auv_rmse_per_timestep2 = rmse_per_timestep(nr_timesteps, ...
    squares_per_time_step, ...
    auv_data2, field_data);
  s2(field_nr) = scatter(1:nr_timesteps, auv_rmse_per_timestep2, 50, ...
    cols(field_nr,:), '*', 'LineWidth', 3);
  
  auv_file3 = [auv_files_path3 'field_' num2str(field_nr) '.csv']
  auv_data3 = csvread(auv_file3, 3, 0);
  auv_rmse_per_timestep3 = rmse_per_timestep(nr_timesteps, ...
    squares_per_time_step, ...
    auv_data3, field_data);
  s3(field_nr) = scatter(1:nr_timesteps, auv_rmse_per_timestep3, 50, ...
    cols(field_nr,:), '^', 'LineWidth', 3);  
end

legend([bp(1,3), s1(1), s2(1), s3(1)], {'Human boxplot', ...
auv_labels{1}, auv_labels{2}, auv_labels{3}}, ...
'Location','NorthEast')

finish_font