function Flow(obj, target, varargin)

    switch target
        case 'rawActMap'

            % calculate act map of all movement directions combined
            fprintf('\n▶▶▶Calculating ACT map of ALL movement direction\n')

            obj.P.folderName = regexprep(obj.P.folderName, 'MvtDir\d', 'MvtDir0');
            obj.P.select.trial.proprioception.mvtDir = 1:8;

            CalActMapHelper(obj);

            if obj.P.mvtDirFlag
                % calculate act map of each movement direction only when proprioception is on and vibration and whisker are off
                if (obj.P.select.stimType.proprioception == 1) && (obj.P.select.stimType.vibration == 0) && (obj.P.select.stimType.whisker == 0)

                    for i = 1:8
                        fprintf('\n▶▶▶Calculating ACT map of movement direction %d\n', i)
                        obj.P.folderName = regexprep(obj.P.folderName, 'MvtDir\d', ['MvtDir' num2str(i)]);
                        obj.P.select.trial.proprioception.mvtDir = i;
                        %obj.P.select.trial.proprioception.randomNtrial = 10;
                        CalActMapHelper(obj)
                    end

                end

            end

        case 'regActMap'

            % register act map of all movement directions combined
            fprintf('\n▶▶▶Register ACT map of ALL movement direction\n')

            obj.P.folderName = regexprep(obj.P.folderName, 'MvtDir\d', 'MvtDir0');
            obj.P.select.trial.proprioception.mvtDir = 1:8;

            RegActHelper(obj);

            if obj.P.mvtDirFlag
                % register act map of each movement direction only when proprioception is on and vibration and whisker are off
                if (obj.P.select.stimType.proprioception == 1) && (obj.P.select.stimType.vibration == 0) && (obj.P.select.stimType.whisker == 0)

                    for i = 1:8
                        fprintf('\n▶▶▶Register ACT map of movement direction %d\n', i)
                        obj.P.folderName = regexprep(obj.P.folderName, 'MvtDir\d', ['MvtDir' num2str(i)]);
                        obj.P.select.trial.proprioception.mvtDir = i;
                        RegActHelper(obj)
                    end

                end

            end

    end

end

function CalActMapHelper(obj)

    if ~isfield(obj.Info, 'wf')
        % orgnize file: move tifs to session foleder
        obj.Process('moveToSessionFolder');
        % get information of WF files
        obj.Get('wfInfo');
        % orgnize file: remove tifs of problem tirals
        obj.Process('removeInteruptedTrials');
    end

    if ~isfield(obj.Info, 'bpod')
        % get information of Bpod files
        obj.Get('bpodInfo');
    end

    % get reference image
    obj.Get('refImage');
    % align wf images with stimulation trigger
    obj.Process('alignTrig');
    obj.Save('trialStat');
    obj.Get('trialStat');

end

function RegActHelper(obj)

    % get all files in P.dir.ACTmaps with extension .tif and containing ACT
    filesAct = FindFiles(obj.P.dir.actMap.raw, {'.tif', 'ACT'});
    filesActPath = {filesAct.path}';
    filesActName = {filesAct.name}';

    % construct path to corresponding REG files
    filesRegName = strrep(filesActName, 'ACT', 'REG.mat');
    filesRegPath = cellfun(@(x)fullfile(obj.P.dir.actMap.reg, x), filesRegName, 'UniformOutput', false);

    % check if file exists for filesEXPpath with isfile function
    filesREGpathExists = isfile(filesRegPath);

    % remove files that already exist from fielsACTpath, filesREFpath
    filesActPath(filesREGpathExists) = [];

    % for each file in filesActPath register coordinates with allen atlas
    screenSize = get(0, 'Screensize');
    guiPosition = [screenSize(1) + 100, screenSize(2) + 100, screenSize(3) - 200, screenSize(4) - 200];

    for i = 1:length(filesActPath)
        cActPath = filesActPath{i};
        [~, cActName, cActExt] = fileparts(cActPath);

        cRefName = strrep(cActName, 'ACT', 'REF');
        cRefPath = fullfile(obj.P.dir.refImage, [cRefName, cActExt]);

        close all
        fprintf('  Registration for \n    %s\n', filesActPath{i})

        objReg = WF.Process.RegAct(cRefPath, cActPath, obj.P);

        set(findobj('Name', 'WF registration'), 'Position', guiPosition);
        waitfor(objReg, 'objButtonRegFlag', 1);
    end

end
