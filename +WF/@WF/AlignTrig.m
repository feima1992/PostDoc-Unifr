%% AlignTrigWF
function AlignTrig(obj)
% get wf and bpod file information
filesWF = obj.WFinfo;
filesBpod = obj.BpodInfo;
% filesWF sessionID is 'yymmdd' while filesBpod sessionID is 'yyyymmdd'
filesWF.sessionIDforPairing = filesWF.sessionID + 20000000;
% inner join filesWF and filesBpod based on mouseID, sessionID and trialID
filesBpodWF = innerjoin(filesBpod,filesWF, 'LeftKeys',{'mouseID','sessionID','trialID'},'RightKeys',{'mouseID','sessionIDforPairing','trialID'});
% sort filesBpod by stimType, mouse and session
filesBpodWF = sortrows(filesBpodWF,{'stimType_filesWF','mouseID','sessionID_filesWF'});
% create file path for ACTmap
filesBpodWF.ACTpath = cellfun(@(X,Y)fullfile(obj.p.dir.ACTmaps,[X,'_',Y(3:end),'_ACT.mat']),filesBpodWF.mouse_filesWF,filesBpodWF.session_filesWF,'UniformOutput',false);
% remove trials that the duration of wf and bpod not match
filesBpodWF.trialDurDiff = filesBpodWF.trialDur - filesBpodWF.trialDurWF;
% display the mouse, session and trial information that the duration of wf and bpod not match
filesUnmatch = filesBpodWF(abs(filesBpodWF.trialDurDiff) > 0.1,:);
if sum(abs(filesBpodWF.trialDurDiff) > 0.1) > 0
    fprintf('\nWarning: %d trials with duration difference (WF,Bpod) > 0.1s\n',sum(abs(filesBpodWF.trialDurDiff) > 0.1));
    disp(filesUnmatch(:,{'mouse_filesWF','session_filesWF','trialID','trialDur','trialDurWF','trialDurDiff'}));
    for i = 1:height(filesUnmatch)
        movefile(filesUnmatch.path_filesWF{i},obj.p.dir.bk)
    end
end
% keep only trials with difference < 0.1s
filesBpodWF = filesBpodWF(abs(filesBpodWF.trialDurDiff) < 0.1,:);
obj.BpodWFInfo = filesBpodWF;
% select trials based on trialOutcome, moveDirection and randomNtrial
data = SelectTrials(filesBpodWF,obj.p);
% get the discriptive statistics (groupcount) of the data, groupby mouseID, sessionID, mvtDir
try % for vibration and whisker stimulation, there is no mvtDir parameter
    obj.TrialsCount.ByDir = groupcounts(data,{'mouse_filesWF','session_filesWF','mvtDir'});
catch
    obj.TrialsCount.ByDir = 'No mvtDir for this stimType';
end
% get the discriptive statistics (groupcount) of the data, groupby mouseID, sessionID
obj.TrialsCount.BySession = groupcounts(data,{'mouse_filesWF','session_filesWF'});
% save information to info.mat
obj.SaveObj();
% for each mouseID and sessionID, align wf with bpod
mouseIDs = unique(data.mouse_filesWF); sessionIDs = unique(data.session_filesWF);
for i = 1:length(mouseIDs)
    for j = 1:length(sessionIDs)
        % get data for this mouseID and sessionID
        dataThis = data(ismember(data.mouse_filesWF,mouseIDs{i}) & ismember(data.session_filesWF,sessionIDs{j}),:);
        % skip if no data for this mouseID and sessionID
        if height(dataThis) == 0
            continue
        end
        % align with the trigger
        AlignWFwithTrigger(dataThis,obj.p);
    end
end
end

%% SelectTrials
function data = SelectTrials(data,p)
switch data.stimType_filesWF{1}
    case 'passiveMovement'
        % select trials based on trialOutcome
        data = data(ismember(data.outcomeIdx,p.select.trial.proprioception.outcome),:);
        % select trials based on moveDirection
        data = data(ismember(data.mvtDir,p.select.trial.proprioception.moveDirection),:);
        % select random n trials if specified
        if ~isempty(p.select.trial.proprioception.randomNtrial)
            if p.select.trial.proprioception.randomNtrial > height(data)
                switch p.select.trial.proprioception.randomNtrialprocess
                    case 'resample'
                        nRepeat = ceil(p.select.trial.proprioception.randomNtrial - height(data));
                        idxRepeat = randsample(height(data),nRepeat);
                        data = [data; data(idxRepeat,:)];
                    case 'skip'
                        data = data(1:0,:);
                end
            else
                idx = randsample(height(data),p.select.trial.proprioception.randomNtrial);
                data = data(idx,:);
            end
        end
end
% sort data by trialID
data = sortrows(data,'trialID');
end

%% AlignWFwithTrigger
function AlignWFwithTrigger(data,p)
tiralInfo = data;
% return if data is empty
if height(data) ==0
    return
end
% get session information
mouse = data.mouse_filesWF{1}; session = data.session_filesWF{1}; stimType = data.stimType_filesWF{1};
matSavePath = fullfile(p.dir.ACTmaps,[mouse,'_',session,'_ACT.mat']);
tifSavePath = fullfile(p.dir.ACTmaps,[mouse,'_',session,'_ACT.tif']);

% skip already been processed
if isfile(matSavePath) && isfile(tifSavePath)
    fprintf('Skip aligned: %s %s\n', mouse, session)
    return
end

% get image width and height
imAvgInfo = imfinfo(data.path_filesWF{1});
imAvgWidth = imAvgInfo(1,1).Width;
imAvgHeight = imAvgInfo(1,1).Height;

% get image time and number of frames
imAvgTimeInterval = 1/p.wf.frq;
imAvgTimes = [p.wf.win.align(1):imAvgTimeInterval:-imAvgTimeInterval, 0, imAvgTimeInterval:imAvgTimeInterval:p.wf.win.align(2)]';
t = imAvgTimes;
imAvgNframesPre = sum(imAvgTimes<0);
imAvgNframesPost = sum(imAvgTimes>0);
imAvgNframes = imAvgNframesPre + imAvgNframesPost + 1;

% preallocate average images for imAvgBlue and imAvgViolet
imAvgBlue = zeros(imAvgWidth,imAvgHeight,imAvgNframes);
imAvgViolet = zeros(imAvgWidth,imAvgHeight,imAvgNframes);

% load data frame by frame
for i = 1:height(data)
    WF.Helper.Progress(i,height(data),['Align ',mouse,' ',session])
    % file information
    imFile = data.path_filesWF{i};
    imInfo = imfinfo(imFile);
    imWidth = imInfo(1,1).Width;
    imHeight = imInfo(1,1).Height;
    imNframes = size(imInfo,1);
    imData = zeros(imWidth, imHeight, imNframes, 'uint16');
    imTimes = zeros(imNframes,1);
    for cFrame=1:imNframes
        imData(:,:,cFrame) = imread(data.path_filesWF{i}, 'Index', cFrame);
        imTimes(cFrame,1) = str2double(regexp(imInfo(cFrame,1).ImageDescription,'(?<=Relative time = )\S*','match','once'));
    end
    imTimes(:,1) = imTimes(:,1) - imTimes(1,1);
    % get blue and violet frames
    indBlue = 1:2:imNframes;
    indViolet = 2:2:imNframes;
    imBlue = double(imData(:,:,indBlue));
    imViolet = double(imData(:,:,indViolet));
    imTimesBlue = imTimes(indBlue);
    imTimesViolet = imTimes(indViolet);
    imTimesEqual = 0:imAvgTimeInterval:numel(imTimesBlue)*imAvgTimeInterval-imAvgTimeInterval;
    clear imData

    % interpolate violet and blue frames to equally spaced timepoints
    imBlue = shiftdim(imBlue,2);
    imBlue = interp1(imTimesBlue, imBlue, imTimesEqual);
    imBlue = shiftdim(imBlue,1);
    imViolet = shiftdim(imViolet,2);
    imViolet = interp1(imTimesViolet, imViolet, imTimesEqual);
    imViolet = shiftdim(imViolet,1);

    % align with the trigger
    switch stimType
        case 'passiveMovement'
            switch p.select.stim
                case 1
                    [~, frIDalignTrigger] = min(abs(imTimesBlue-data.t1stMvt(i)));
                case 2
                    [~, frIDalignTrigger] = min(abs(imTimesBlue-data.t2ndMvt(i)));
            end
        case 'vibration'
            [~, frIDalignTrigger] = min(abs(imTimesBlue-data.tStim(i)));
        case 'whisker'
            [~, frIDalignTrigger] = min(abs(imTimesBlue-data.tStim(i)));
    end
    
    imBlue = imBlue(:,:,frIDalignTrigger-imAvgNframesPre:frIDalignTrigger+imAvgNframesPost);
    imViolet = imViolet(:,:,frIDalignTrigger-imAvgNframesPre:frIDalignTrigger+imAvgNframesPost);

    imAvgBlue = imAvgBlue + imBlue/height(data);
    imAvgViolet = imAvgViolet + imViolet/height(data);
end

% flip images vertically and horizontally
imAvgBlue = imAvgBlue(end:-1:1, end:-1:1, :);
imAvgViolet = imAvgViolet(end:-1:1, end:-1:1, :);

% regress violet from blue
imAvgVioletREG = imAvgViolet;
Nfr = size(imAvgBlue,3);
for m=1:imAvgWidth
    outSig = zeros(Nfr, 1);
    inSig = zeros(Nfr, 1);
    for n=1:imAvgHeight
        outSig(:,1) = imAvgBlue(m,n,:);
        inSig(:,1) = imAvgViolet(m,n,:);
        B = regress(outSig, [ones(Nfr,1) inSig]);
        imAvgVioletREG(m,n,:) = imAvgViolet(m,n,:)*B(2)+B(1);
    end
end

% reference of baseline
F0 = mean(imAvgBlue(:,:,1:imAvgNframesPre),3);
IMblue = bsxfun(@minus, imAvgBlue, F0);
IMblue = bsxfun(@rdivide, IMblue, F0);
F0 = mean(imAvgVioletREG(:,:,1:imAvgNframesPre),3);
IMviolet = bsxfun(@minus, imAvgVioletREG, F0);
IMviolet = bsxfun(@rdivide, IMviolet, F0);

% correct blue from violet
IMcorr = IMblue-IMviolet;
F0 = mean(IMcorr(:,:,1:imAvgNframesPre),3);
IMcorr = bsxfun(@minus, IMcorr, F0);    % normalize to baseline

% smooth corrected frames
order = 2;
win = 9;
for m=1:imAvgWidth
    for n=1:imAvgHeight
        IMcorr(m,n,:) = sgolayfilt(IMcorr(m,n,:),order,win);
    end
end
% generate activation map
IMcorrNorm = (IMcorr-min(IMcorr(:)))/(max(IMcorr(:))-min(IMcorr(:)));
IMcorrNorm = imgaussfilt(IMcorrNorm, 2);
% apply masks
if p.act.flag.reuseMask
    load(p.path.ROImask, 'imMask');
else
    close all;
    imREF = imread(fullfile(p.dir.refImages, [mouse,'_', session, '_REF.tif']));
    imREF = imREF(end:-1:1, end:-1:1);
    f0 = figure();
    imshow(imREF);
    hF=drawpolygon();
    imMask=createMask(hF);
    close(f0);
    save(p.path.roiMask, 'imMask');
end
IMcorrNorm(~repmat(imMask, [1 1 size(IMcorrNorm,3)])) = nan;
peakFrame = IMcorrNorm(:,:,28); 
threshold = mean(peakFrame,"all","omitnan") + 1.96*std(peakFrame,0,"all","omitnan");
peakFrame(peakFrame<threshold) = nan;
im = ind2rgb(im2uint8(peakFrame),fire(256));
% save data to mat file
fprintf('Save file: %s %s\n', mouse, session);
switch stimType
    case 'passiveMovement'
        switch p.select.stim
            case 1
                save(matSavePath, 'p','imAvgBlue', 'imAvgViolet', 'IMcorr','imMask','t','tiralInfo');
                imwrite(im, tifSavePath, 'tif', 'Compression', 'none','WriteMode',  'overwrite');
            case 2
                save(strrep(matSavePath,'ACT.mat','ACT_Stim2.mat'), 'p','imAvgBlue', 'imAvgViolet', 'IMcorr','imMask','t','tiralInfo');
                imwrite(im, strrep(tifSavePath,'ACT.tif','ACT_Stim2.tif'), 'tif', 'Compression', 'none');
        end
    case 'vibration'
        save(matSavePath, 'p','imAvgBlue', 'imAvgViolet', 'IMcorr','imMask','t','tiralInfo');
        imwrite(im, tifSavePath, 'tif', 'Compression', 'none','WriteMode',  'overwrite');

    case 'whisker'
        save(matSavePath, 'p','imAvgBlue', 'imAvgViolet', 'IMcorr','imMask','t','tiralInfo');
        imwrite(im, tifSavePath, 'tif', 'Compression', 'none','WriteMode',  'overwrite');
end
end
