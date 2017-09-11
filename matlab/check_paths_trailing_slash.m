% this is a helper script to make sure paths end with a slash
%
% Stephanie Kemna
% University of Southern California
% August 2017
%

% check all paths to make sure they end with '/'

% append '/' to paths if necessary
if ( exist('scenarios_file_path','var') && scenarios_file_path(length(scenarios_file_path)) ~= '/' )
  scenarios_file_path = [scenarios_file_path '/'];
end
if ( exist('gpml_location','var') && gpml_location(length(gpml_location)) ~= '/' )
  gpml_location = [gpml_location '/'];
end
if ( exist('files_path','var') && files_path(length(files_path)) ~= '/' )
  files_path = [files_path '/'];
end
if ( exist('user_files_path','var') && files_path(length(user_files_path)) ~= '/' )
  user_files_path = [files_path '/'];
end