function LinePlotAvgFreg(avgFmax, options)
    % validate inputs
    arguments
        avgFmax (:, :) double
        options.ax = gca
        options.X (1, :) double = 1:size(avgFmax, 2)
        options.XLabel (1, :) cell = string(1:size(avgFmax, 2))
        options.title (1, :) char = ''
        options.legend (1, :) cell = {}
        options.ylim (1, :) double = max(abs(avgFmax(:))) * [-1.05, 1.05] 
    end

    % plot avgFmax, single session or multiple sessions
    if isvector(avgFmax) % single session
        plot(options.ax, options.X, avgFmax, '.-', 'MarkerSize', 10, 'LineWidth', 1.5);
    else % multiple sessions
        % get color set
        colorSet = distinguishable_colors(size(avgFmax, 2));
        colorSet(:, 4) = 0.5;

        % plot each session
        for i = 1:size(avgFmax, 2)
            hold on
            plot(options.ax, options.X, avgFmax(:, i), '.-', 'MarkerSize', 10, 'LineWidth', 1.5, 'Color', colorSet(i, :));
        end

        % plot mean and std of sessions
        hold on;
        errorbar(options.ax, options.X, mean(avgFmax, 2), std(avgFmax, 0, 2) / sqrt(size(avgFmax, 1)), 'o', 'MarkerSize', 5, 'LineWidth', 2, 'Color', [0.2, 0.2, 0.2]);

        % legend
        if ~isempty(options.legend)
            legend(options.legend, 'Location', 'northeastoutside');
        end

        % box on
        box on;

    end

    % ticks and labels
    set(gca, 'XTick', options.X, 'XLim', [options.X(1), options.X(end)], 'YLim', options.ylim, 'XTickLabel', options.XLabel, 'XTickLabelRotation', 45);

    % xlabel: Distance from bregma (mm), ylabel: Time (s)
    xlabel('Cortex Module');
    ylabel('Avg \DeltaF/F');
    % title
    title(options.title);
end
