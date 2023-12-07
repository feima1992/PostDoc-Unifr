% ui to select a figure file and open it
[figFiles,figPaths] = uigetfile('*.fig','Select the figure file','F:\users\Fei\DataAnalysis\Figures','MultiSelect','on');
% cancel if no file is selected
if isequal(figFiles,0)
    disp('No figure file selected');
    return;
end
% if only one file is selected, convert it to a cell
if ~iscell(figFiles)
    figFiles = {figFiles};
end
% loop through all the files
for i = 1:length(figFiles)
    % get the full file name
    figFile = fullfile(figPaths,figFiles{i});
    figH = openfig(figFile);

    % get the axes handle from the figure
    axesH = findobj(figH,'type','axes');
    if isempty(axesH)
        disp('No axes found in figure');
        return;
    end

    % if there are only one axes handle
    if length(axesH) == 1
        % set figure size to [781,257,441,608]
        set(figH,'Position',[781,257,441,608]);
        % set axes limits
        axesH.XLim = [80,260]; axesH.YLim = [150,350];
        % save back to the same file
        saveas(figH,figFile);
        exportgraphics(figH,[figFile(1:end-4),'.png'],'Resolution',300);
        % close the figure
        close(figH);
    else
        for i = 1:length(axesH)
            % set axes limits
            axesH(i).XLim = [80,260]; axesH(i).YLim = [150,350];
            % create a new figure
            fignewH = figure('Position',[781,257,441,608]);
            % copy the axes to the new figure
            copyobj(axesH(i),fignewH);
            % set the axes position to full
            fignewH.Children.Position = [0.1300 0.1100 0.7750 0.8150];
            % save to a new file
            saveas(fignewH,[figFile(1:end-4),'_',num2str(i),'.fig']);
            exportgraphics(fignewH,[figFile(1:end-4),'_',num2str(i),'.png'],'Resolution',300);
            % close the figure
            close(fignewH);
        end
        % close the original figure
        close(figH);
    end
end
    

