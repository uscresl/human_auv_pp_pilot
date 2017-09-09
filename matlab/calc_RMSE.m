% function [RMSE] = plot_gaussian (field_file, user_file, auv, plot_on, interpolation_method)
% uses data from the user file to interpolate a full field, then finds the
% RMSE of the two sets of data values
%
% Author: Sara Kangaslahti
% Institution: USC
% Date: August 2017
%
function [RMSE] = calc_RMSE (field_file, user_file, auv, plot_on, interpolation_method, gpml_location)

%set the name that the variables will be saved under
[pathstr,name,~] = fileparts(user_file);
full_path = [pathstr,'/',name,'xyc_',interpolation_method,'.mat'];

%only do calculations if the x, y, c variables have not been stored to file
if exist(full_path, 'file') ~= 2
  %get the values for the full field
  all_vals = csvread (field_file,3,0);

  disp(['Evaluating: ' user_file]);

  user_vals = csvread (user_file,1,0);
  %separate the x, y, and c vals in the user data
  user_x = user_vals (:,1);
  user_y = user_vals (:,2);
  user_c = user_vals (:,3);

  %separate the x, y, and c vals for the field data
  field_x = all_vals (:,1);
  field_y = all_vals (:,2);
  field_c = all_vals (:,3);

  %gaussian interpolation using the downloaded gp library
  if strcmp(interpolation_method,'gp') == 1
    
    %start the gp library
    gpml_startup = [gpml_location 'startup.m'];
    run(gpml_startup);    
    
    %set variables
    x = [user_x,user_y];
    y = user_c;
    xs = [field_x,field_y];
    meanfunc = [];                    % empty: don't use a mean function
    covfunc = @covSEiso;              % Squared Exponental covariance function
    likfunc = @likGauss;
    
    %calculate the hyperparams
    hyp = struct('mean', [], 'cov', [-7.5, 1.5], 'lik', -1);
    hyp2 = minimize(hyp, @gp, -500, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
    
    %interpolate the full field
    [mu, ~] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs);
    user_interp_c = mu;
    
  else
    %interpolate the full grid from the user data
    user_interp_c = griddata(user_x, user_y, user_c, field_x, field_y, 'v4');
  end
  
  %save the variables to file
  save(full_path,'user_x','user_y','user_interp_c','field_c');
else
  %load the variables from file
  load(full_path);
end

%print out for seeing the number of data pionts in the path
%num_points = [pathstr, ': ', num2str(length(user_x))]

%find the min and max values for the colorbar
min_val = min(min(field_c),min(user_interp_c));
max_val = max(max(field_c),max(user_interp_c));

%remove all NaN values so that the RMSE can be calculated
full_c_ok = user_interp_c(~isnan(user_interp_c));
field_vals_ok = field_c(~isnan(user_interp_c));

%calculate RMSE
square_error = sum((full_c_ok-field_vals_ok).^2);
RMSE = sqrt(square_error)/length(field_vals_ok);

%plot the data
if plot_on == true
  %plot the user data
  figure
  scatter(user_x,user_y,50,user_c,'filled')
  colorbar
  caxis([min_val, max_val])

  %plot the user interpolated data
  figure
  scatter(field_x,field_y,50,user_interp_c,'filled')
  colorbar
  caxis([min_val, max_val])
end

end