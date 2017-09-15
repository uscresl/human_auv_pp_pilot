num_groups = numel(grouped_data);
num_ticks = size(grouped_data{1},2);
delta = linspace(-0.25, 0.25, num_groups); % calculate offsets x-axis
% fixes for x axis
for idx = 1:num_ticks,
  x_labels_empty{idx} = '';
  x_labels{idx} = num2str(idx);
end
% bplot_colors_arr = hsv(num_groups);
% for idg = 1:num_groups,
%   bplot_colors{idg} = bplot_colors_arr(idg,:);
% end
bp = zeros(num_groups, 7, num_ticks);
for bpidx = 1:num_groups,
  bp(bpidx,:,:) = boxplot(grouped_data{bpidx}, ...
    'Color', bplot_colors{bpidx}, ...
    'position', (1:num_ticks)+delta(bpidx), ...
    'widths', width, ...
    'labels', x_labels_empty, ...
    'symbol', '+');
  set(bp(bpidx,:,:), 'LineWidth', 3, 'Color', bplot_colors{bpidx});
  bp_handles(bpidx) = bp(bpidx,3);
end