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

fname_auv1 = 'auv1_rmse_per_timestep_per_field.mat';
fname_auv2 = 'auv2_rmse_per_timestep_per_field.mat';
fname_auv3 = 'auv3_rmse_per_timestep_per_field.mat';
fname_humans = 'human_rmse_per_timestep_per_participant_per_field.mat';

% only run analysis if not done before
if ( ~exist(fname_auv1,'file') || ...
     ~exist(fname_auv2,'file') || ...
     ~exist(fname_auv3,'file') || ...
     ~exist(fname_humans,'file') )

all_auv1 = zeros(nr_fields, nr_timesteps);
all_auv2 = zeros(nr_fields, nr_timesteps);
all_auv3 = zeros(nr_fields, nr_timesteps);
all_humans = zeros(nr_fields, nr_participants, nr_timesteps);

%% load data
if ( exist(fname_auv1,'file') )
  load(fname_auv1); % loads all_auv1
end
if ( exist(fname_auv2,'file') )
  load(fname_auv2); % loads all_auv2
end
if ( exist(fname_auv3,'file') )
  load(fname_auv3); % loads all_auv3
end
if ( exist(fname_humans,'file') )
  load(fname_humans); % loads all_humans
end

cols = autumn(nr_fields);
cols_h = winter(nr_fields);
for field_nr = 1:nr_fields;
  
  figure('Position',[0 0 1400 1000]);
  hold on;
  
  % get field data
  field_file = [scenarios_file_path 'field_',num2str(field_nr),'.csv']
  % get the values for the full field
  field_data = csvread (field_file,3,0);
  field_lon = field_data(:,1);
  field_lat = field_data(:,2);
  field_val = field_data(:,3);
  
  field_locations = [field_lon, field_lat];
  
  % human data
  if ( ~exist(fname_humans,'file') )
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

      all_humans(field_nr, part_idx, :) = user_rmse_per_timestep(part_idx,:);
    end
    bp(field_nr,:,:) = boxplot(user_rmse_per_timestep, ...
      'symbol', '+', 'Color', cols_h(field_nr,:));
    set(bp,'LineWidth', 3, 'Color', cols_h(field_nr,:));
  end
  
  % auv data
  % auv first method
  if ( ~exist(fname_auv1,'file') )
    auv_file1 = [auv_files_path1 'field_' num2str(field_nr) '.csv']
    auv_data1 = csvread(auv_file1, 3, 0);
    all_auv1(field_nr,:) = rmse_per_timestep(nr_timesteps, ...
      squares_per_time_step, ...
      auv_data1, field_data);
  end
  s1(field_nr) = scatter(1:nr_timesteps, all_auv1(field_nr,:), 50, ...
    cols(field_nr,:), 'o', 'LineWidth', 3);
  
  % auv second method
  if ( ~exist(fname_auv2,'file') )
    auv_file2 = [auv_files_path2 'field_' num2str(field_nr) '.csv']
    auv_data2 = csvread(auv_file2, 3, 0);
    all_auv2(field_nr,:) = rmse_per_timestep(nr_timesteps, ...
      squares_per_time_step, ...
      auv_data2, field_data);
  end
  s2(field_nr) = scatter(1:nr_timesteps, all_auv2(field_nr,:), 50, ...
    cols(field_nr,:), '*', 'LineWidth', 3);
  
  % auv third method
  if ( ~exist(fname_auv3,'file') )
    auv_file3 = [auv_files_path3 'field_' num2str(field_nr) '.csv']
    auv_data3 = csvread(auv_file3, 3, 0);
    all_auv3(field_nr,:) = rmse_per_timestep(nr_timesteps, ...
      squares_per_time_step, ...
      auv_data3, field_data);
  end
  s3(field_nr) = scatter(1:nr_timesteps, all_auv3(field_nr,:), 50, ...
    cols(field_nr,:), '^', 'LineWidth', 3);
  
  % finish figure per field
  legend([bp(field_nr,3), s1(field_nr), s2(field_nr), s3(field_nr)], {'Human boxplot', ...
auv_labels{1}, auv_labels{2}, auv_labels{3}}, ...
'Location','NorthEast')
  finish_font
  hold off;
end % for-loop field

if ( ~exist(fname_auv1,'file') )
  save(fname_auv1,'all_auv1');
end
if ( ~exist(fname_auv2,'file') )
  save(fname_auv2,'all_auv2');
end
if ( ~exist(fname_auv3,'file') )
  save(fname_auv3,'all_auv3');
end
if ( ~exist(fname_humans,'file') )
  save(fname_humans,'all_humans');
end

else
  load(fname_humans); % loads all_humans
  load(fname_auv1);   % loads all_auv1
  load(fname_auv2);   % loads all_auv2
  load(fname_auv3);   % loads all_auv3
end

% prep data for easier plotting
auv1_field1to6 = all_auv1(1:6,:);
auv1_field7to12 = all_auv1(7:12,:);
auv2_field1to6 = all_auv2(1:6,:);
auv2_field7to12 = all_auv2(7:12,:);
auv3_field1to6 = all_auv3(1:6,:);
auv3_field7to12 = all_auv3(7:12,:);
humans_field1to6 = all_humans(1:6,:,:);
humans_field7to12 = all_humans(7:12,:,:);

auv_mu1_1 = mean(auv1_field1to6,1);
auv_mu2_1 = mean(auv2_field1to6,1);
auv_mu3_1 = mean(auv3_field1to6,1);
hu_mu_m1 = mean(humans_field1to6,1);
hu_mu_1 = reshape(hu_mu_m1, nr_participants, nr_timesteps);

auv_mu1_2 = mean(auv1_field7to12,1);
auv_mu2_2 = mean(auv2_field7to12,1);
auv_mu3_2 = mean(auv3_field7to12,1);
hu_mu_m2 = mean(humans_field7to12,1);
hu_mu_2 = reshape(hu_mu_m2, nr_participants, nr_timesteps);

%% figures over subsets of fields

% use colors as before
bplot_colors = {[0.8 0.5 0], [0 0.8 0], [1 0 0.5], [0 0 0], [0 0.1 1]};

% averages

figure('Position',[0 0 1400 1000]);
hold on;
boxplot(hu_mu_1);
scatter(1:nr_timesteps, auv_mu1_1, 50, 'g')
scatter(1:nr_timesteps, auv_mu2_1, 50, 'c')
scatter(1:nr_timesteps, auv_mu3_1, 50, 'm')
title('Averages Fields 1-6')
finish_font

figure('Position',[0 0 1400 1000]);
hold on;
boxplot(hu_mu_2);
scatter(1:nr_timesteps, auv_mu1_2, 50, 'g')
scatter(1:nr_timesteps, auv_mu2_2, 50, 'b')
scatter(1:nr_timesteps, auv_mu3_2, 50, 'r')
title('Averages Fields 7-12')
finish_font

% boxplots

% general boxplot config
width = .1;

% Fields 1 - 6
figure('Position',[0 0 1400 1000]);
hold on;

% group data to be able to display boxplots next to each other
grouped_data = {hu_mu_1 auv1_field1to6 auv2_field1to6 auv3_field1to6};
run plot_grouped_data_timesteps
title('Fields 1-6')
run finish_figure_timesteps

% Fields 7 - 12
figure('Position',[0 0 1400 1000]);
hold on;
% group data to be able to display boxplots next to each other
grouped_data = {hu_mu_2 auv1_field7to12 auv2_field7to12 auv3_field7to12};
run plot_grouped_data_timesteps
title('Fields 7-12')
run finish_figure_timesteps