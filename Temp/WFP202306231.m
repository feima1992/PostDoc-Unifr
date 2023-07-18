% plot the activation map of each movement direction (8 directions)
hFig = figure; set(hFig, 'Position', [100 100 1000 1000], 'Color', 'w');

% plot illustration of the 8 directions with 8 arrows in the center subplot(3,3,5) of the figure
subplot(3,3,5); hold on;
for i = 1:8
    arrowH = annotation('textarrow');
    arrowH.X = [0.5 0.5+0.5*cos((i-1)*pi/4)];
    arrowH.Y = [0.5 0.5+0.5*sin((i-1)*pi/4)];
    arrowH.Parent = gca;    
end
axis equal; axis([-1.5 1.5 -1.5 1.5]); axis off;

% plot the activation map of each movement direction (8 directions)
for i = 1:8
    if i < 5
        subplot(3,3,i);
        
    elseif i >= 5
        subplot(3,3,i+1);

    end
end
