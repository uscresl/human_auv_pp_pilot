%if auv is true, plots the auv RMSE values for each field, otherwise plots
%all the human values for each field, and the average human values for each
%field. returns the average RMSE for all the fields and the array of
%average RMSE values (separated by field)
function [all_avg, avg_arr] = plot_full_auv_human(auv,plot_on,file_path)
if auv == true %looping through AUV paths
    %set the average values to the output of the RMSE scatter auv
    %function
    [avg_arr, r_avg, g_avg] = RMSE_scatter_auv();

    %compute the average AUV RMSE
    all_avg = (r_avg + g_avg)/2;

    %make the x axis for the scatterplot
    x = linspace (1,12,12);

    %adjust the size of the figure
    figure('pos',[200,200,900,650])

    %plot the AUV RMSE points
    scatter(x,avg_arr,50,'filled');
    title("AUV RMSEs")
    ylim([0,0.12])
    %ylim([0,max(avg_arr)+.01])
else
    %set the default file path
    if ~exist('file_path','var')
         file_path = '/home/sara/human_auv_pp_userfiles';
    end

    %create an array of each folder in the directory
    files = dir (file_path);

    %initialize zero arrays so the sum of the RMSEs for each plot and the
    %average RMSE for each person can be calculated in the for loop
    sum_rmse = zeros (1,12);
    avg_arr = zeros(1,length(files)-2);

    %create an x axis for the scatterplots
    x = linspace (1,12,12);

    %initialize variables for the highest RMSE value and loop index
    max_val = 0; index = 1;

    %create an array of spaces to hold the names of each person
    name_arr = repmat(" ", [1 length(files)-2]);

    if plot_on == true
        figure('pos',[200,200,900,650])
    end

    %use the RMSE values for each user to plot all the RMSE values and
    %calculate the average RMSE value for each plot
    for file = files'
        %wait to plot the scatter plots until hold is turned off
        hold on

        %check that the file is a directory and not a hidden directory
        if file.isdir == true && ~strcmpi(file.name,'.') && ~strcmpi(file.name,'..')
            %see RMSE_scatter function below
            [RMSE,r_avg,g_avg] = RMSE_scatter(file.name);

            %get the highest RMSE value in all the plots so that the y axis
            %bounds are correct
            if max_val < max(RMSE)
                max_val = max(RMSE);
            end

            %calculate the total average and add it to the average array
            t_avg = (r_avg+g_avg)/2;
            avg_arr(index) = t_avg;

            %get the name of the file for the legend
            name_arr(index) = file.name;

            %add the user's RMSE array to the sum array (so avg can be
            %calculated)
            sum_rmse = sum_rmse + RMSE;
            
            %plot each user's data if plot_on is true
            if plot_on == true
                %plot the graph
                scatter(x,RMSE,50,'filled');
            end

            %increment loop index
            index = index + 1;
        end
    end

    if plot_on == true
    %make a legend and plot the scatterplot with each person's RMSE values
        legend(name_arr, 'Location', 'Best');
        hold off
        drawnow
        title("All RMSEs")
        ylim([0,max_val+.01])
    end

    %calculate the average RMSEs for each plot
    avg_rmse = sum_rmse/(length(files)-2);

    %plot the average RMSE graph
    if plot_on == true
        figure('pos',[200,200,900,650])
    end
    scatter(x,avg_rmse,50,'filled')
    ylim([0,max_val+.01])
    title("Average RMSEs")

    %calculate the average RMSE for all the users and graphs
    all_avg = sum(avg_arr)/(index-1);

    %add a header with names to the average array
    avg_arr = [name_arr; num2cell(avg_arr)];
end
end