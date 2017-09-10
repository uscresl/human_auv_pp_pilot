% function [lon_lat_data_pt] = revealPoint(all_data, lon_query, lat_query, min_lon, min_lat, ...
%                                          grid_spacing_lon, grid_spacing_lat, grid_width)
%
% Author: Stephanie Kemna
% Institution: USC
% Date: Sept 1, 2017
%
function [lon_lat_data_pt] = revealPoint(all_data, lon_query, lat_query, min_lon, min_lat, ...
                                         grid_spacing_lon, grid_spacing_lat, grid_width)

  % calculate the longitude and latitude index
  lon_idx = round((lon_query-min_lon)/grid_spacing_lon) + 1;
  lat_idx = round((lat_query-min_lat)/grid_spacing_lat) + 1;
  
  % grab the corresponding data point, and return
  find_index = (grid_width * (lat_idx-1)) + lon_idx;
  if ( find_index < 861 ) 
    lon_lat_data_pt = all_data(find_index,:);
  else
    % not sure why it would get here? grab last
    lon_lat_data_pt = all_data(size(all_data,1), :);
  end
end