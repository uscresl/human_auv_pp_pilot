% function [] = run_auv_sim(wpt_selection_method, inf_metric, plot_figs)
%
% script for running AUV simulations
%
% Author: Stephanie Kemna
% Institution: USC
% Date: September 2017
%
function [] = run_auv_sim(wpt_selection_method, inf_metric, plot_figs)

% make sure we keep all precision
format long;

debug_plot = 0;

%% read function arguments
if ( exist('wpt_selection_method','var') == 0 ) 
  wpt_selection_method = 'gp';
end
if ( exist('inf_metric','var') == 0 )
  inf_metric = 'entropy';
end
if ( exist('plot_figs','var') == 0 )
  plot_figs = 0;
end

disp(['Waypoint selection method: ' wpt_selection_method])
if ( strcmp(wpt_selection_method,'gp') == 1 )
  disp(['Information-theoretic metric: ' inf_metric])
end

%% user params
% prepath = '/home/stephanie/data_happ/';
prepath = '/mnt/hdd/happ/';

% specify all paths
scenarios_location = strcat(prepath,'scenarios/');
% import the GP libraries
gpml_location = strcat(prepath,'gpml-matlab-v4.0-2016-10-19/');
gpml_startup_script = strcat(gpml_location, 'startup.m');
run(gpml_startup_script);

%% prep

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

% initialize GP
if ( strcmp(wpt_selection_method,'gp') == 1 )
  hyp = struct('mean', [], 'cov', [-7.5, 1.5], 'lik', -1);
end
expl_factor = 0.25;

%% run fields

% we know that we have 12 scenarios, so harcoded here
for field_id = 1:12,

  if ( plot_figs )
    fh = figure(field_id);
    set(fh,'Position',[60, 10, 1000, 700]);
    hold on;
  end
  
  % construct filename
  scenario_file = [scenarios_location, 'field_', num2str(field_id), '.csv'];
  disp(['Field: ' scenario_file]);
  
  % load data, starting at row 3 column 0
  field_all_data = csvread(scenario_file, 3, 0);
  field_lon = field_all_data(:,1);
  field_lat = field_all_data(:,2);
  % actual data, not used here, because field_all_data is passed on
  %field_data = field_all_data(:,3);
  
  if ( plot_figs )
    % show the locations
    scatter(field_lon, field_lat, 10, 'o')
  end
  
  % store field data needed for calculating indices to pull data later.
  min_lon = min(field_lon);
  min_lat = min(field_lat);
  max_grid_lon = round((max(field_lon)-min(field_lon))/grid_spacing_lon) + 1;
  
  % for the GP, take the locations of data for the grid
  % where we make predictions over
  sample_locations = [field_lon, field_lat];
  
  % we want to start a GP, and then iteratively decide on new
  % waypoints, for as long as we have budget, where we can
  % re-calculate the hyperparameters as we go
  
  meanfunc = [];        % empty: don't use a mean function
  likfunc = @likGauss;
%   covfunc = @covSEiso;  % Squared Exponental covariance function  
  % Cov: SE iso and Noise
  covfunc = {'covSum',{'covSEiso','covNoise'}};
  % params from sim -- these don't work, it cannot recover from > -10 or so
  % hyp = struct('mean', [], 'cov', [-12.4292, 0.4055, -1.8971], 'lik', -1);
  % sim-end-based params
  hyp = struct('mean', [], 'cov', [-7.5, 0.5, 1.0], 'lik', -1);

  % reset stored data/counters between fields
  path_counter = 1;
  store_points = [];
  wpts_x = [];
  wpts_y = [];
  
  % do not prealloc wpt_x and wpt_y, because we do not always
  % get the same size, depending on distance betw waypoints
  % and start from top left, given user study design
  wpts_x(1) = min(field_lon);
  wpts_y(1) = max(field_lat);
  
%   store_points = zeros(budget,3);
  for wpt_idx = 2:40,
    if ( path_counter <= budget)
      % get a new waypoint
      if ( strcmp(wpt_selection_method,'random') == 1 || ...
           ( strcmp(wpt_selection_method,'gp') == 1 && ...
             length(wpts_x) == 1 ) )
        % random wpts
        rand_lon = field_lon(randi(length(field_lon)));
        wpts_x(wpt_idx) = rand_lon;
        rand_lat = field_lat(randi(length(field_lat)));
        wpts_y(wpt_idx) = rand_lat;
        disp(['Random wpt: ' num2str(rand_lon) ',' num2str(rand_lat)]);
      elseif ( strcmp(wpt_selection_method,'gp') == 1 )
        %TODO add other methods for choosing waypoint
        % training data is already stored as store_points
        x_train = store_points(:,1:2);
        y_train = store_points(:,3);
        % run HP optimization
        hyp_fitted = minimize(hyp, @gp, -500, @infGaussLik, meanfunc, ...
          covfunc, likfunc, x_train, y_train);
        % make predictions
        [pred_mu, pred_var] = gp(hyp_fitted, @infGaussLik, meanfunc, ...
          covfunc, likfunc, x_train, y_train, sample_locations);
        % debugging
%         figure(2);
%         scatter(x_train(:,1), x_train(:,2), 30, y_train, 'filled');
%         figure(3);
%         scatter(sample_locations(:,1), sample_locations(:,2), 30, pred_mu, 'filled')
        % calculate the entropy
        if ( strcmp(inf_metric,'entropy') == 1 )
          post_entropy = 1/2 * log( 2 * pi * exp(1) * pred_var);
        elseif ( strcmp(inf_metric,'entropy_plus_mean') == 1 )
          post_entropy = 1/2 * log( 2 * pi * exp(1) * pred_var);
          post_entropy = (post_entropy/max(post_entropy)) + expl_factor * (pred_mu/max(pred_mu));
        end
        [max_val, max_ind] = max(post_entropy);
        wpts_x(wpt_idx) = sample_locations(max_ind,1);
        wpts_y(wpt_idx) = sample_locations(max_ind,2);
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
          if ( path_counter <= budget )
            % round calculated y value to grid pt
            y_mod = mod(reveal_pt_y,grid_spacing_lat);
            if ( y_mod > grid_spacing_lat/2 )
              rev_pt_y = reveal_pt_y - y_mod + grid_spacing_lat;
            else
              rev_pt_y = reveal_pt_y - y_mod;
            end
            
            rev_pt = [reveal_pt_x rev_pt_y];
            rev_pt_full = revealPoint(field_all_data, ...
                  rev_pt(1), rev_pt(2), ...
                  min_lon, min_lat, grid_spacing_lon, grid_spacing_lat, ...
                  max_grid_lon);
            
            if ( path_counter == 1 )
              store_points(path_counter,:) = rev_pt_full;
              path_counter = path_counter+1;
              if ( plot_figs && debug_plot )
                scatter(rev_pt(1), rev_pt(2), 50, '*', 'LineWidth', 2)            
              end
            else
              if ( ~ismember(rev_pt_full, store_points, 'rows') )
                store_points(path_counter,:) = rev_pt_full;
                path_counter = path_counter+1;
                if ( plot_figs && debug_plot )
                  scatter(rev_pt(1), rev_pt(2), 50, '*', 'LineWidth', 2)
                end
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
            if ( path_counter <= budget )
              reveal_pt_x = ((reveal_pt_y - min_y) / slope) + corresponding_x;
              x_mod = mod(reveal_pt_x,grid_spacing_lon);
              if ( x_mod > grid_spacing_lon/2 )
                rev_pt_x = reveal_pt_x - x_mod + grid_spacing_lon;
              else
                rev_pt_x = reveal_pt_x - x_mod;
              end
              
              rev_pt = [rev_pt_x reveal_pt_y];
              rev_pt_full = revealPoint(field_all_data, ...
                    rev_pt(1), rev_pt(2), ...
                    min_lon, min_lat, grid_spacing_lon, grid_spacing_lat, ...
                    max_grid_lon);
              
              if ( path_counter == 1 )
                store_points(path_counter,:) = rev_pt_full;
                path_counter = path_counter+1;
                if ( plot_figs && debug_plot )
                  scatter(rev_pt(1), rev_pt(2), 50, 'x', 'LineWidth', 2)
                end
              else
                if ( ~ismember(rev_pt_full, store_points, 'rows') )
                  store_points(path_counter,:) = rev_pt_full;
                  path_counter = path_counter+1;
                  if ( plot_figs && debug_plot )
                    scatter(rev_pt(1), rev_pt(2), 50, 'x', 'LineWidth', 2)
                  end
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
            if ( path_counter <= budget )
              reveal_pt_x = new_wpt_x;
              rev_pt = [reveal_pt_x reveal_pt_y];
              rev_pt_full = revealPoint(field_all_data, ...
                    rev_pt(1), rev_pt(2), ...
                    min_lon, min_lat, grid_spacing_lon, grid_spacing_lat, ...
                    max_grid_lon);
              
              if ( path_counter == 1 )
                store_points(path_counter,:) = rev_pt_full;
                if ( plot_figs && debug_plot ) 
                  scatter(reveal_pt_x, reveal_pt_y, 50, 'o', 'LineWidth', 2);
                end
              else
                if ( ~ismember(rev_pt_full, store_points, 'rows') )
                  store_points(path_counter,:) = rev_pt_full;
                  if ( plot_figs && debug_plot )
                    scatter(reveal_pt_x, reveal_pt_y, 50, 'o', 'LineWidth', 2);
                  end
                end
              end
            else
              break;
            end
          end
        end      
      end
    else
      break;
    end
  end
  disp(['Total path length: ' num2str(path_counter-1)])
  
  if ( plot_figs )
    % show the chosen waypoints and path between them
    scatter(wpts_x, wpts_y, 30);
    for idx = 1:length(wpts_x)-1,
      line(wpts_x(idx:idx+1), wpts_y(idx:idx+1), 'Color', 'k', 'LineWidth', 2)
    end
    xlim([min(field_lon) max(field_lon)])
    ylim([min(field_lat) max(field_lat)])

    % show the stored points
    scatter(store_points(:,1), store_points(:,2), 75, 'o', 'filled')  
  end
  
  %% store the revealed points
  if ( strcmp(wpt_selection_method,'gp') == 1 )
    filenm = [prepath 'auv_' wpt_selection_method '_' inf_metric '/field_' num2str(field_id) '.csv'];
  else
    filenm = [prepath 'auv_' wpt_selection_method '/field_' num2str(field_id) '.csv'];
  end
  disp(['Storing data to: ' filenm]);
  
  % write header line
  % dlmwrite(filenm,'Longitude,Latitude,Total Water Column (m)');
  fid = fopen(filenm, 'w');
  fprintf(fid, '%s,%s,%s\n', 'Longitude', 'Latitude', 'Total Water Column (m)');  % header
  fclose(fid);
  
  % write data
  dlmwrite(filenm,store_points,'delimiter',',','precision',20,'-append');
  
  %% store the figures
  if ( plot_figs )
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 1000 700])
    if ( strcmp(wpt_selection_method,'gp') == 1 )    
      filenm = [prepath 'auv_' wpt_selection_method '_' inf_metric '/field_' num2str(field_id) '.jpg'];
    else
      filenm = [prepath 'auv_' wpt_selection_method '/field_' num2str(field_id) '.jpg'];
    end 
    print('-djpeg', '-r90', filenm);
  end
end

end