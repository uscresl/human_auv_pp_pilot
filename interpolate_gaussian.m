%calculates the average RMSEs for each plot for the AUV and human trials,
%and returns an array of the overall average RMSEs
function [avg_arr] = interpolate_gaussian (fl_path)
%paths: '/home/sara/human_auv_pp_auvfiles/auv_adp_field_' (log gp)
%'/home/sara/human_auv_pp_auvgpfiles/gp_adp_field_' (gp)

%get the auv and human averages
[auv_avg,auv_vals] = plot_full_auv_human(true,false,fl_path);
[human_avg,human_vals] = plot_full_auv_human(false,false,fl_path);

%plot the boxplot
boxplot(human_vals)
xlabel('Plot Number')
ylabel('RMSE')
title('Human RMSE')

%plot the scatterplot
figure('pos',[200,200,900,650])
x = linspace (1,12,12);
scatter(x,auv_vals,50,'filled')
ylim ([0,0.12])
title('AUV RMSE')
xlabel('Plot Number')
ylabel('RMSE') 

%create a cell array of the averages, and add a header
avg_arr = [["AUV","Human"]; num2cell([auv_avg, human_avg])];
end