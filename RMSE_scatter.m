%calculates the RMSE for each plot inside of a user's folder and returns
%the array of RMSE values and the average RMSE for the random field and
%gaussian scenarios
function [user_rmse, rand_avg, gaus_avg] = RMSE_scatter(user_name, my_file_path, data_file_path)
    rand_sum = 0; gaus_sum = 0;

    %set default file paths so the latter two input arguments are not necessary
    if ~exist('my_file_path','var')
         my_file_path = '/home/sara/human_auv_pp_userfiles';
    end
    if ~exist('data_file_path','var')
         data_file_path = '/home/sara/Notebook_Script/Data_Scenarios';
    end

    %create a zero array to hold the user's RMSE values
    user_rmse = zeros (1,12);

    %loop through each file in the folder, and call the plot_gaussian function
    %to get the RMSE values
    for index = 1:12
        %get the file names for the full field and user path files
        field_file = [data_file_path, '/'...
            'field_',num2str(index),'.csv'];
        user_file = [my_file_path,'/',...
            user_name, '/',user_name, '_path_',num2str(index), '.csv'];

        %set the values in the user rmse array
        user_rmse(index) = plot_gaussian(field_file,user_file, false,false);

        %add the RMSEs of the first six plots (random fields) and the second
        %six plots (gaussian fields) separately
        if index < 7
            rand_sum = rand_sum + user_rmse(index);
        else
            gaus_sum = gaus_sum + user_rmse(index);
        end
    end
    %calculate the averages
    rand_avg = rand_sum/6;
    gaus_avg = gaus_sum/6;
end