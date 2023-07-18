% load data
data1 = load('dataGroupIDPair_4_6.mat');
data1 = data1.data(1:end-1,1:end-1);
data2 = load('dataGroupIDPair_4_7.mat');
data2 = data2.data(1:end-1,1:end-1);
% vertical concatenation
data = [data1; data2];
% load ABM template
ABMtemplate = WFA.Load('ABMtemplate');
% number of rows and columns
nRow = size(data,1); nCol = size(data,2); 
% each column is a mouse
mouse = {'M1221','M1222','M1223','M1224','All'}; 
% each row is a session
session = {'R&G_1W','R&G_2W','R&G_3W','R&G_4W','R&G_5W','R&G_6W','Wash_1W','Wash_2W','Wash_3W'};

% initialize plot titles
plotTitles = cell(nRow,nCol); 
for i = 1:nRow
    for j = 1:nCol
        plotTitles{i,j} = [mouse{j} ' ' session{i}];
    end
end

% generate figure with tiled layout
hfig = figure; set(hfig,'Color','w');
t = tiledlayout(nRow,nCol,'TileSpacing','compact','Padding','compact');
% calculate the common colorbar limits
climLow = min(cellfun(@(x) min(x(:),[],'all'), data),[],'all');
climHigh = max(cellfun(@(x) max(x(:),[],'all'), data),[],'all');
% keep the colorbar limits symmetric
clim = max(abs(climLow),abs(climHigh));
climLow = -clim; climHigh = clim;
% plot each row and column
for i = 1:nRow
    for j = 1:nCol
        % create axes
        ax = nexttile;
        % plot data
        dataTemp = data{i,j};
        imagesc(dataTemp);
        % add ABM template
        hold on;
        contour(ABMtemplate, [0.5 0.5], 'Color', 'k', 'LineWidth', 0.05);
        hold off;
        % image axis
        axis image;
        % hide axis
        set(gca,'Visible','off');
        % colormap
        colormap(polarmap);
        % clim
        caxis([climLow climHigh]);
        % title
        title(plotTitles{i,j});
    end
end
% add a common colorbar
c = colorbar('eastoutside');
c.Label.String = 'diff \DeltaF/F';
c.Layout.Tile = 'east';