% check all paths to make sure they end with '/'

% append '/' to paths if necessary
if ( exist('user_files_path','var') && user_files_path(length(user_files_path)) ~= '/' )
  user_files_path = [user_files_path '/'];
end
if ( exist('scenarios_file_path','var') && scenarios_file_path(length(scenarios_file_path)) ~= '/' )
  scenarios_file_path = [scenarios_file_path '/'];
end
if ( exist('gpml_location','var') && gpml_location(length(gpml_location)) ~= '/' )
  gpml_location = [gpml_location '/'];
end
if ( exist('auv_files_path','var') && auv_files_path(length(auv_files_path)) ~= '/' )
  auv_files_path = [auv_files_path '/'];
end