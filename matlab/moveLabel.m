%
% https://stackoverflow.com/questions/14966770/distance-between-axis-label-and-axis-in-matlab-figure
% adapted by Stephanie Kemna, USC, Sept 2017
%
function moveLabel(offset)

% work on current figure only
hFig = gcf;
hAxes = gca;

% get figure position
posFig = get(hFig, 'Position');
% get axes position
posAx = get(hAxes, 'Position');

% get label position
posLabel = get(get(hAxes, 'XLabel'), 'Position');

% resize figure
posFigNew = posFig + [0 -offset 0 offset];
set(hFig, 'Position', posFigNew)

pause(1)

% move label
posLabelNew = posLabel + [0 -offset 0];
set(get(hAxes, 'XLabel'), 'Position', posLabelNew);

end