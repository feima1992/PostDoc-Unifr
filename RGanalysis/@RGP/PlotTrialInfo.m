function PlotTrialInfo(sessionInfoTable, mouse, options)
    % plot the correct trial number and the touch number
    % mouse: the mouse to plot, should be a like 'm1221' or {'m1221', 'm1222'}
    % options:
    %   - data to be plotted, should be a string, default is 'nTrialsCorrect'
    %   - cumulative, should be a boolean, default is true
    %   - imageDate, should be a vector of dates, default is []
    % validate the input
    arguments
        sessionInfoTable table
        mouse {mustBeStringOrCharOrCellstr}
        options.data = 'nTrialsCorrect'
        options.cumulative = true
        options.imageDate = []
    end
    % convert mouse to cellstr
    mouse = cellstr(mouse);
    plotdata = struct();
    % get the data for each mouse
    for i = 1:numel(mouse)
        mouseTable = sessionInfoTable(strcmp(sessionInfoTable.mouse, mouse{i}), :);
        if isempty(mouseTable)
            error('The mouse %s is not in the table', mouse{i})
        end
        % get the data for each date
        plotdata(i).mouse = mouse{i};
        plotdata(i).x = mouseTable.sessionNumberID;
        plotdata(i).xlabel = mouseTable.session;

        if options.cumulative
            plotdata(i).y = cumsum(mouseTable.(options.data));
        else
            plotdata(i).y = mouseTable.(options.data);
        end
        
        % find the image date
        if ~isempty(options.imageDate)
            [~,loc] = ismember(options.imageDate, mouseTable.sessionID);
            if any(loc == 0)
                error('The image date is not right')
            end
            plotdata(i).imageDate.x = plotdata(i).x(loc);
            plotdata(i).imageDate.y = plotdata(i).y(loc);
        else
            plotdata(i).imageDate = [];
        end
    end
    ylimUp = max(max(cat(1,plotdata.y)));
    % plot the data for each mouse
    fig = figure;
    % whight background
    set(fig,'color','w');
    % determine the number of rows and columns of the subplot
    nSubplot = size(plotdata, 2);
    if nSubplot <= 3
        nRow = 1;
        nCol = nSubplot;
    else
        nRow = ceil(sqrt(nSubplot));
        nCol = ceil(nSubplot / nRow);
    end
    % plot the data
    for i = 1:nSubplot
        subplot(nRow, nCol, i)
        plot(plotdata(i).x, plotdata(i).y, '-b.', 'LineWidth', 2, 'MarkerSize', 20)
        hold on
        if ~isempty(plotdata(i).imageDate)
            plot(plotdata(i).imageDate.x, plotdata(i).imageDate.y, 'r.','MarkerSize', 25)
        end
        hold off
        xlabel('Session')
        if options.cumulative
            ylabel([options.data ' (cumulative)'])
        else
            ylabel(options.data)
        end
        title(plotdata(i).mouse)
        % set xtick label to plotdata(i).xlabel and rotate it 30 degree
        xtickangle(30)
        xticks(plotdata(i).x)
        xticklabels(plotdata(i).xlabel)
        % set the legend
        if ~isempty(plotdata(i).imageDate)
            legend('Training session', 'Image session')
            % set the legend location to best
            legend('Location', 'best')
        end
        % set the y grid line to be on
        grid on
        ylim([0, ylimUp])
    end
end

function mustBeStringOrCharOrCellstr(input)
    if ~(isstring(input) || ischar(input) || iscellstr(input))
        error('The input must be a string, a char or a cellstr')
    end
end
