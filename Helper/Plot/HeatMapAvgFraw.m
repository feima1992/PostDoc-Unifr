function HeatMapAvgFraw(avgF, options)
    % avgF: avgeraged ΔF/F for each ROI, size: nFrames x nROIs
    % options: options for plotting
    %   options.ax: axes to plot on
    %   options.climits: colorbar limits
    %   options.colormap: colormap
    %   options.X: options.X axis labels
    %   options.Y: options.Y axis labels
    %   options.title: title for the plot

    % Validate inputs
    arguments
        avgF (:, :) double
        options.ax = gca
        options.climits (1, 2) double = max(abs(avgF(:))) * [-1, 1]
        options.colormap (:, :) double = polarmap
        options.X (1, :) double = 1:size(avgF, 2)
        options.Y (1, :) double = 1:size(avgF, 1)
        options.title (1, :) char = ''
    end

    imagesc(options.ax, avgF);
    colormap(options.ax, options.colormap);

    % ticks and labels
    set(gca, 'XTick', 1:length(options.X), 'XTickLabel', options.X, 'YTick', 1:2:length(options.Y), 'YTickLabel', options.Y(1:2:end));

    % ylim range for -0.5 to 1.5 s
    ylim([find(options.Y == -0.5), find(options.Y == 1.5)]);

    % add a marker (+) to indicate x = 0 and y = 0
    hold on;
    plot(find(options.X == 0), find(options.Y == 0), '+', 'MarkerSize', 10, 'Color', 'r');

    % xlabel: Distance from bregma (mm), ylabel: Time (s)
    xlabel('Distance from bregma (mm)');
    ylabel('Time (s)');

    % add colorbar
    c = colorbar(options.ax);
    c.Label.String = 'Avg \DeltaF/F';
    % set colorbar limits
    caxis(options.climits);
    % title
    title(options.title);
end
