%% deltaFoverF
function CalDeltaFoverF(obj,options)
% CalDeltaFoverF: calculate the deltaFoverF for the frames
% infoTable: table with columns: 'mouseID', 'SessionID', 'mouseSession', 'group', 'file'
% options: struct with the options

% validation
arguments
    obj
    options.overwrite (1,1) logical = false
end

for i = 1:height(infoTable)
    
    % find wehther 'deltaFoverF' exists in the file
    fileInfo = who('-file',infoTable.file{i});
    % if overwrite is true or 'deltaFoverF' does not exist
    if (~ismember('deltaFoverF',fileInfo))|| options.overwrite
        % show the progress i/height(infoTable)
        disp(['Processing ',infoTable.mouseSession{i},' ',num2str(i),'/',num2str(height(infoTable))]);
        % load data
        data = load(infoTable.file{i});
        % calculate the deltaFoverF
        indxBaseline = data.t >= p.act.win.baseline(1) & data.t <= p.act.win.baseline(2);
        % get the raw signal
        im = data.IMcorrREG;
        % scale im to 0-1
        im = (im - min(im(:)))/(max(im(:)) - min(im(:)));
        % calculate the deltaFoverF
        [x,y,z] = size(im);
        deltaFoverF = zeros(x,y,z);
        % calculate the mean of im(fIdx)
        baselineFrames = im(:,:,indxBaseline);
        meanF = mean(baselineFrames,3);
        % calculate the deltaF/F
        for j = 1:z
            deltaFoverF(:,:,j) = (im(:,:,j)-meanF)./meanF;
        end
        % save the result
        save(infoTable.file{i},'deltaFoverF','-append');
    else
        disp(['Skip ',infoTable.mouseSession{i},' ',num2str(i),'/',num2str(height(infoTable))]);
    end
end
end