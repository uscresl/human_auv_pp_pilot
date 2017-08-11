%calculates the RMSE for each auv plot, and also returns the average for
%the different types of scenarios (random and gaussian)
function[auv_rmse,rand_avg, gaus_avg] =  RMSE_scatter_auv(auv_file_path, interpolation_method, data_file_path)

%initialize variables
auv_rmse = zeros(1,12);
sum_rand = 0; sum_gaus = 0;

%set default values for the data file path variable
if ~exist('data_file_path','var')
    %data_file_path = '/home/sara/Notebook_Script/Data_Scenarios';
    data_file_path = '/home/resl/human_auv_pp_scenarios';
end

%loop through all the auv files and get their RMSE values
for field_num = 1:12
    %call plot_gaussian to get the RMSEs
    auv_file_name = [auv_file_path, num2str(field_num), '/auv_data.log'];
    data_file_name = [data_file_path, '/field_',num2str(field_num),'.csv'];
    auv_rmse(field_num) = plot_gaussian(data_file_name, auv_file_name, true, false, interpolation_method);
    
    %calculate separate sums for the random fields and gaussian scenarios
    if (field_num < 7)
        sum_rand = sum_rand + auv_rmse(field_num);
    else
        sum_gaus = sum_gaus + auv_rmse(field_num);
    end
end

%calculate the average RMSE for random fields and gaussian scenarios
rand_avg = sum_rand/6;
gaus_avg = sum_gaus/6;
end