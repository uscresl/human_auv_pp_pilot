% script for running AUV simulations
% close all;
clear all;
format long;

% user params
% prepath = '/home/stephanie/data_happ/';
prepath = '/mnt/hdd/happ/';
wpt_selection_method = 'random';
disp(['Waypoint selection method: ' wpt_selection_method])

% specify all paths
scenarios_location = strcat(prepath,'scenarios/');
% import the GP libraries
gpml_location = strcat(prepath,'gpml-matlab-v4.0-2016-10-19/');
gpml_startup_script = strcat(gpml_location, 'startup.m');
run(gpml_startup_script);

% seed the random number generator with current time
rng(round(mod(datenum(clock),1)*1000000))

% converting to grid space for determining length path
lon_deg_to_m = 92287.2080;
lat_deg_to_m = 110923.9912;

% figure out spacing from file
% example_file = [scenarios_location, 'field_1.csv'];
% first_lonlats = csvread(scenario_file, 3, 0, [3 0 4 1]);
% lon1 = first_lonlats(1);
% lon2 = first_lonlats(2);
grid_spacing = 10;
grid_spacing_lon = grid_spacing / lon_deg_to_m;
grid_spacing_lat = grid_spacing / lat_deg_to_m;

budget = 190;

figure('Position',[60, 10, 1000, 700]);
hold on;

% we know that we have 12 scenarios, so harcoded here
for field_id = 1:1, %12, test
  % construct filename
  scenario_file = [scenarios_location, 'field_', num2str(field_id), '.csv'];
  disp(['Field: ' scenario_file]);
  % load data, starting at row 3 column 0
  field_all_data = csvread(scenario_file, 3, 0);
  field_lon = field_all_data(:,1);
  field_lat = field_all_data(:,2);
  field_data = field_all_data(:,3);
  scatter(field_lon, field_lat, 10, 'o')
  
  % for the GP, take the locations of data for the grid
  % where we make predictions over
  sample_locations = [field_lon, field_lat];
  
  % we want to start a GP, and then iteratively decide on new
  % waypoints, for as long as we have budget, where we can
  % re-calculate the hyperparameters as we go
  
  meanfunc = [];        % empty: don't use a mean function
  covfunc = @covSEiso;  % Squared Exponental covariance function
  likfunc = @likGauss;
  
  path_length = 0;
  
  % do not prealloc wpt_x and wpt_y, because we do not always
  % get the same size, depending on distance betw waypoints
  % and start from top left, given user study design
  wpts_x(1) = min(field_lon);
  wpts_y(1) = max(field_lat);
  path_counter = 1;
  for wpt_idx = 2:20,
    if ( path_counter < budget )
      % get a new waypoint
      if ( strcmp(wpt_selection_method,'gp') == 1 )
        %TODO add other methods for choosing waypoint
      else
        % random wpts
        rand_lon = field_lon(randi(length(field_lon)));
        wpts_x(wpt_idx) = rand_lon;
        rand_lat = field_lat(randi(length(field_lat)));
        wpts_y(wpt_idx) = rand_lat;
        disp(['Random wpt: ' num2str(rand_lon) ',' num2str(rand_lat)]);
      end
      
      new_wpt_x = wpts_x(wpt_idx);
      new_wpt_y = wpts_y(wpt_idx);
      last_wpt_x = wpts_x(wpt_idx-1);
      last_wpt_y = wpts_y(wpt_idx-1);
      min_x = min(new_wpt_x, last_wpt_x);
      max_x = max(new_wpt_x, last_wpt_x);
      min_y = min(new_wpt_y, last_wpt_y);
      max_y = max(new_wpt_y, last_wpt_y);

      % find all pts along line from last to current
      % code similar to what is in Grapher.ipynb

      % calculate the slope
      if ( new_wpt_x - last_wpt_x ~= 0 )
        slope = (new_wpt_y - last_wpt_y)/(new_wpt_x - last_wpt_x);
      else
        slope = 0;
      end

      % iterate over x or y? check:
      if ( (max_x - min_x) > (max_y - min_y) )
        % iterate over x
        % check which x,y pair corresponds to min_x
        if ( min_x == last_wpt_x )
          corresponding_y = last_wpt_y;
          increment_amount = grid_spacing_lon;
        else
          corresponding_y = new_wpt_y;
          increment_amount = -grid_spacing_lon;
        end
        for reveal_pt_x = last_wpt_x:increment_amount:new_wpt_x
          reveal_pt_y = slope * (reveal_pt_x - min_x) + corresponding_y;
          if ( path_counter < budget )
            % round calculated y value to grid pt
            y_mod = mod(reveal_pt_y,grid_spacing_lat);
            if ( y_mod > grid_spacing_lat/2 )
              rev_pt_y = reveal_pt_y - y_mod + grid_spacing_lat;
            else
              rev_pt_y = reveal_pt_y - y_mod;
            end
            rev_pt = [reveal_pt_x rev_pt_y];
            if ( path_counter == 1 )
              reveal_points(path_counter,:) = rev_pt;
              path_counter = path_counter+1;
              scatter(rev_pt(1), rev_pt(2), 50, '*', 'LineWidth', 2)            
            else
              if ( ~ismember(rev_pt, reveal_points, 'rows') )
                reveal_points(path_counter,:) = rev_pt;
                path_counter = path_counter+1;
                scatter(rev_pt(1), rev_pt(2), 50, '*', 'LineWidth', 2)
              end
            end
          else
            break;
          end
        end
      else
        % iterate over y
        % check which x,y pair corresponds to min_y
        if ( min_y == last_wpt_y )
          corresponding_x = last_wpt_x;
          increment_amount = grid_spacing_lat;
        else
          corresponding_x = new_wpt_x;
          increment_amount = -grid_spacing_lat;
        end

        if ( new_wpt_x ~= last_wpt_x )  
          for reveal_pt_y = last_wpt_y:increment_amount:new_wpt_y
            if ( path_counter < budget )
              reveal_pt_x = ((reveal_pt_y - min_y) / slope) + corresponding_x;
              x_mod = mod(reveal_pt_x,grid_spacing_lon);
              if ( x_mod > grid_spacing_lon/2 )
                rev_pt_x = reveal_pt_x - x_mod + grid_spacing_lon;
              else
                rev_pt_x = reveal_pt_x - x_mod;
              end
              
              rev_pt = [reveal_pt_x reveal_pt_y];
              if ( path_counter == 1 )csvwrite
                reveal_points(path_counter,:) = rev_pt;
                path_counter = path_counter+1;
                scatter(rev_pt(1), rev_pt(2), 50, 'x', 'LineWidth', 2)
              else
                if ( ~ismember(rev_pt, reveal_points, 'rows') )
                  reveal_points(path_counter,:) = rev_pt;
                  path_counter = path_counter+1;
                  scatter(rev_pt(1), rev_pt(2), 50, 'x', 'LineWidth', 2)
                end
              end
            else
              break;
            end
          end
        else
          % delta_x is zero, vertical line
          increment_amount = grid_spacing_lat;
          for reveal_pt_y = min_y:increment_amount:max_y %+increment_amount
            if ( path_counter < budget )
              reveal_pt_x = new_wpt_x;
              rev_pt = [reveal_pt_x reveal_pt_y];
              if ( path_counter == 1 )
                reveal_points(path_counter,:) = rev_pt;
                scatter(reveal_pt_x, reveal_pt_y, 50, 'o', 'LineWidth', 2);
              else
                if ( ~ismember(rev_pt, reveal_points, 'rows') )
                  reveal_points(path_counter,:) = rev_pt;
                  scatter(reveal_pt_x, reveal_pt_y, 50, 'o', 'LineWidth', 2);
                end
              end
            else
              break;
            end
          end
        end      
      end
    end
  end
  disp(['Total path length: ' num2str(path_counter)])
  
  scatter(wpts_x, wpts_y, 30);
  for idx = 1:length(wpts_x)-1,
    line(wpts_x(idx:idx+1),wpts_y(idx:idx+1),'Color','k')
  end
  xlim([min(field_lon) max(field_lon)])
  ylim([min(field_lat) max(field_lat)])

  
%   x_train = wpts_x;
%   y_train = wpts_y;
%   
%   % calculate the hyperparameters
%   hyp = struct('mean', [], 'cov', [-7.5, 1.5], 'lik', -1);
%   hyp2 = minimize(hyp, @gp, -500, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
%     
  
  %% for all revealed points, get the data from the field file

  %% store the revealed points
  filenm = [prepath 'auv_' wpt_selection_method '/field_' num2str(field_id) '.csv'];
  disp(['Storing data to: ' filenm]);
  dlmwrite(filenm,'Longitude,Latitude,Total Water Column (m)');
  %%TODO TODO: figure out how to match this with the field data
  dlmwrite(filenm,1,0,reveal_points);
  


end