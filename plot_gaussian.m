%uses data from the user file to interpolate a full field, then finds the
%RMSE of the two sets of data values
function [RMSE] = plot_gaussian (field_file, user_file, auv, plot_on, interpolation_method)
%get the values for the full field
all_vals = csvread (field_file,3,0); 

%import data differently if the user file is an auv file
if auv == true
    %import data and remove other struct fields
    user_vals = importdata(user_file, ' ', 13);
    user_vals = user_vals.data;
    
    %get only the unique data values and their indexes
    [c,ia] = unique(user_vals(:,1),'stable');
    
    if max(c) < 10
        %calculate e^c because the files are in log format
        user_c = exp(c);
    else
        user_c = c;
    end
    
    %initialize the x and y arrays and the index counter 
    user_x = zeros(1,length(user_c));
    user_y = zeros(1,length(user_c));
    index = 1;
    
    %only get the x and y vals that correspond to the data indices
    for val = ia'
        user_x(index) = user_vals(val,2);
        user_y(index) = user_vals(val,3);
        index = index + 1;
    end
    
    user_x = user_x';
    user_y = user_y';
    
else
    user_vals = csvread (user_file,1,0);

    %separate the x, y, and c vals in the user data
    user_x = user_vals (:,1);
    user_y = user_vals (:,2);
    user_c = user_vals (:,3);
end

%separate the x, y, and c vals
x_vals = all_vals (:,1);
y_vals = all_vals (:,2);
c_vals = all_vals (:,3);


if strcmp(interpolation_method,'gp') == 1
    %run /home/sara/gpml-matlab-v4.0-2016-10-19/startup.m
    run /home/resl/gpml-matlab-v4.0-2016-10-19/startup.m
    x = [user_x,user_y];               
    y = user_c; 
    xs = [x_vals,y_vals];
    meanfunc = [];                    % empty: don't use a mean function
    covfunc = @covSEiso;              % Squared Exponental covariance function
    likfunc = @likGauss; 
    hyp = struct('mean', [], 'cov', [-7.5, 1.5], 'lik', -1);
    hyp2 = minimize(hyp, @gp, -500, @infGaussLik, meanfunc, covfunc, likfunc, x, y)
    [mu s2] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs);
    full_c = mu;
else
    %interpolate the full grid from the user data
    full_c = griddata(user_x, user_y, user_c, x_vals, y_vals, 'v4');
end

%find the min and max values for the colorbar
min_val = min(min(c_vals),min(full_c));
max_val = max(max(c_vals),max(full_c));

%remove all NaN values so that the RMSE can be calculated
full_c_ok = full_c(~isnan(full_c));
c_vals_ok = c_vals(~isnan(full_c));

%calculate RMSE
square_error = sum((full_c_ok-c_vals_ok).^2);
RMSE = sqrt(square_error)/length(c_vals_ok);

%plot the data
if plot_on == true
    %plot the field data
    scatter(x_vals,y_vals,50,c_vals,'filled')
    colorbar
    caxis([min_val, max_val])
    
    %plot the user data
    figure
    scatter(x_vals,y_vals,50,full_c,'filled')
    colorbar
    caxis([min_val, max_val])
end
end