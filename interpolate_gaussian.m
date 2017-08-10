%calculates the average RMSEs for each plot for the AUV and human trials,
%and returns an array of the overall average RMSEs
function [avg_arr] = interpolate_gaussian ()
%plot the auv and human averages
[auv_avg,~] = plot_full_auv_human(true,false);
hold on
[human_avg,~] = plot_full_auv_human(false,false);
hold off

%set different aspects of the plot
title('AUV vs. Human Average RMSE')
legend ({'AUV', 'Human Average'})
xlabel('Plot Number')
ylabel('RMSE') 
drawnow

%create a cell array of the averages, and add a header
avg_arr = [["AUV","Human"]; num2cell([auv_avg, human_avg])];
end