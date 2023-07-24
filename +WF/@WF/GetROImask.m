function GetROImask(obj,options)
% options.strip
    % parameters for the ROI type of strip, [xOrigin1, xStep, xOrigin2, xWidth, yOrigin, yHeight]
% options.module
    % module number, vector or cell array of vectors. if not specified, all modules 26 (fs1) will be used
% validate input
arguments
    obj
    options.strip (6,1) double = [-4,0.5,4,0.25,0.5,1]
    options.module (:,1) cell = {26}
end

%% get the strip ROI for raw act map
% strip parameters
xOrigin1 = options.strip(1);
xStep = options.strip(2);
xOrigin2 = options.strip(3);
xWidth = options.strip(4);
yOrigin = options.strip(5);
yHeight = options.strip(6);

Xs = xOrigin1:xStep:xOrigin2;
Ys = repmat(yOrigin,1,length(Xs));
stripROIs = [Xs-xWidth/2; Xs+xWidth/2; Ys-yHeight/2; Ys+yHeight/2];

% plot strips over ABMtemplete
ABMtemplate = imread(obj.p.path.ABMtemplate);
ABMtemplateBregmaXY = [256,256]; mm2pixel = 1/0.019;
figStripROI = figure('color','w');
axesStripROI = axes(figStripROI);
plotStripROI = imshow(ABMtemplate);
hold on;
for i = 1:length(Xs)
    faceColorSet = jet(length(Xs));
    % add alpha channel to the faceColorSet
    faceAlpha = 0.7;
    faceColorSet(:,4) = faceAlpha;
    xStrip = (Xs(i)-0)*mm2pixel+ABMtemplateBregmaXY(1); yStrip = ABMtemplateBregmaXY(2)-(Ys(i)-0)*mm2pixel;
    rectangle('Position',[xStrip-xWidth/2*mm2pixel,yStrip-yHeight/2*mm2pixel,xWidth*mm2pixel,yHeight*mm2pixel],'Curvature',0.5,'EdgeColor','none','FaceColor',faceColorSet(i,:));
    plot(xStrip,yStrip,'k+');
end
hold off;
title('Strips');
obj.ROImask.strip = stripROIs;
obj.Plot.ROImask.strip = plotStripROI;

end
