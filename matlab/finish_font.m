% function [] = finish_font(fsize)
%
% this is a helper function to increase font size on plots to the size
% given, default 26
%
% Stephanie Kemna
% University of Southern California
% Spring 2016
%
function [] = finish_font(fsize)

if nargin < 1
    fsize = 26;
end

% make all text in the figure to size 
set(gca,'FontSize',fsize)
set(findall(gcf,'type','text'),'FontSize',fsize)

end