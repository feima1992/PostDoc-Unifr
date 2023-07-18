function RegACTmap(obj)
% update parameters
if (obj.p.select.stimType.proprioception == 1) && (obj.p.select.stimType.vibration == 0) && (obj.p.select.stimType.whisker == 0)
    
    switch obj.p.act.flag.mapForEachMvtDir 
        case 0 % do NOT calculate act map of each movement direction
                obj.GetParams('updateFolder',fullfile(obj.p.folderName,'AllMvtDir'));
                RegACThelper(obj)
        case 1 % calculate act map of each movement direction
            folderName = obj.p.folderName;
            for i = 1:8
                obj.GetParams('updateFolder',fullfile(folderName,['MvtDir', num2str(i)]))
                obj.p.select.trial.proprioception.moveDirection = i;
                RegACThelper(obj)
            end
    end
else
    RegACThelper(obj)
end

end
function RegACThelper(obj)
% get all files in p.dir.ACTmaps with extension .tif and containing ACT
filesACT = WF.Helper.FindFiles(obj.p.dir.ACTmaps,{'.tif','ACT'});
filesACTpath= {filesACT.path}';
filesACTname= {filesACT.name}';

% construct path to corresponding REG files
filesREGname = strrep(filesACTname,'ACT','REG.mat');
filesREGpath = cellfun(@(x)fullfile(obj.p.dir.ACTreg,x), filesREGname, 'UniformOutput', false);

% check if file exists for filesEXPpath with isfile function
filesREGpathExists = isfile(filesREGpath);

% remove files that already exist from fielsACTpath, filesREFpath
filesACTpath(filesREGpathExists) = [];

% for each file in filesACTpath register coordinates with allen atlas
screenSize = get(0, 'Screensize');
guiPosition = [screenSize(1)+100, screenSize(2)+100, screenSize(3)-200, screenSize(4)-200];

for i = 1:length(filesACTpath)
    cACTpath = filesACTpath{i};
    [~, cACTname, cACText] = fileparts(cACTpath);

    cREFname = strrep(cACTname,'ACT','REF');
    cREFpath = fullfile(obj.p.dir.refImages, [cREFname, cACText]);

    close all
    fprintf('\n>>> Registration for \n    %s\n', filesACTpath{i})
    
    objReg = WF.Helper.ClassRegACT(cREFpath,cACTpath,obj.p);
    
    set(findobj('Name','WF registration'), 'Position', guiPosition);
    waitfor(objReg, 'objButtonRegFlag', 1);
end
end