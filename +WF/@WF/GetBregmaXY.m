function GetBregmaXY(obj)
%% get XY distance to bregma for each pixel
% get all the files with bregma coordinates for each session
regFiles = WF.Helper.FindFiles(obj.p.folder,'_XYreg.mat',{},'table_out',true);
FindMouse = @(X)regexp(X,'[a-zA-Z]\d{4}(?=_)','match','once');
FindSession = @(X)regexp(X,'(?<=_)2[3-9][0-1][0-9][0-3][0-9](?=_)','match','once');
regFiles.mouse = cellfun(@(X)FindMouse(X),regFiles.name,'UniformOutput',false);
regFiles.session = cellfun(@(X)FindSession(X),regFiles.name,'UniformOutput',false);
regFiles.mouseID = cellfun(@(X)str2double(X(2:end)),regFiles.mouse);
regFiles.sessionID = cellfun(@(X)str2double(X),regFiles.session);
% for each unique mouseID and sessionID combination, get the bregma coordinates
[~,uniqueIdx] = unique(regFiles.namefull);
regFiles = regFiles(uniqueIdx,{'mouse','session','mouseID','sessionID','path'});
% get the bregma coordinates for each mouse and session
for i = 1:height(regFiles)
    load(regFiles.path{i},'XYrefCTX');
    bregmaX = XYrefCTX(1,1);
    bregmaY = XYrefCTX(1,2);
    % calculate the coordinates of each pixel with respect to bregma as the origin
    [X,Y] = meshgrid(1:512,1:512);
    X = X - bregmaX;
    Y = Y - bregmaY;
    % covert pixel coordinates to mm, 1 pixel = 0.019 mm
    X = X * 0.019;
    Y = Y * 0.019;
    % save the coordinates
    regFiles.X{i} = X;
    regFiles.Y{i} = Y;
    regFiles.XYs{i} = [bregmaX,bregmaY];
end
% save the coordinates
obj.CoordPixels = regFiles;