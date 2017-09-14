function [rmse] = rmse_per_timestep(nr_timesteps, squares_per_timestep, ...
  sampled_data, ground_truth)

% GP setup
meanfunc = [];           % empty: don't use a mean function
covfunc = @covSEiso;     % Squared Exponental covariance function
likfunc = @likGauss;
hyp_init = struct('mean', [], 'cov', [-7.5, 1.5], 'lik', -1);

all_sampled_lon = sampled_data(:,1);
all_sampled_lat = sampled_data(:,2);
all_sampled_val = sampled_data(:,3);
nr_samples = length(all_sampled_lon);

ground_truth_lon = ground_truth(:,1);
ground_truth_lat = ground_truth(:,2);
ground_truth_val = ground_truth(:,3);
ground_truth_locations = [ground_truth_lon, ground_truth_lat];

% iteratively create a GP model for the user values,
% calculate the RMSE, and store the performance over time
rmse = zeros(nr_timesteps,1);
for t_step = 1:nr_timesteps,
  % get subset of the data
  max_idx = t_step*squares_per_timestep;
  if ( max_idx > nr_samples )
    max_idx = length(all_sampled_lon);
  end
  samples_lon = all_sampled_lon(1:max_idx);
  samples_lat = all_sampled_lat(1:max_idx);
  samples_val = all_sampled_val(1:max_idx);
  % create a GP
  gp_x = [samples_lon, samples_lat];
  gp_y = samples_val;
  % estimate hyperparameters
  hyperparams = minimize(hyp_init, @gp, -500, ...
    @infGaussLik, meanfunc, covfunc, likfunc, gp_x, gp_y);
  % make predictions from GP
  [mu, ~] = gp(hyperparams, @infGaussLik, meanfunc, covfunc, likfunc, ...
    gp_x, gp_y, ground_truth_locations);
  
  % calculate RMSE
  sum_squared_error = sum((mu - ground_truth_val).^2);
  rmse(t_step) = sqrt(sum_squared_error/length(ground_truth_val));
end

end