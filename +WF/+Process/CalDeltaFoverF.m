function CalDeltaFoverF(actMap, P, options)
    % CalDeltaFoverF: calculate the deltaFoverF for the act frames
    % options: struct with the options

    % validation
    arguments
        actMap
        P
        options.overwrite (1, 1) logical = false
    end

    fprintf('▶  Calculate deltaFoverF\n')
    % calculate detaFoverF for raw and reg act
    actType = fieldnames(actMap);

    for i = 1:length(actType)
        infoTable = actMap.(actType{i});

        for j = progress(1:height(infoTable), 'Title', ['  Calculate △F/F for ACT ', actType{i}])
            % find wehther 'deltaFoverF' exists in the file
            fileInfo = who('-file', infoTable.path{j});
            % if overwrite is true or 'deltaFoverF' does not exist
            if (~ismember('deltaFoverF', fileInfo)) || options.overwrite

                % load data
                data = load(infoTable.path{j});
                % calculate the deltaFoverF
                indxBaseline = data.t >= P.act.win.baseline(1) & data.t <= P.act.win.baseline(2);
                % get the raw signal
                switch actType{i}
                    case 'raw'
                        im = data.IMcorr;
                    case 'reg'
                        im = data.IMcorrREG;
                end

                % scale im to 0-1
                im = (im - min(im(:))) / (max(im(:)) - min(im(:)));
                % calculate the deltaFoverF
                [x, y, z] = size(im);
                deltaFoverF = zeros(x, y, z);
                % calculate the mean of im(fIdx)
                baselineFrames = im(:, :, indxBaseline);
                meanF = mean(baselineFrames, 3);
                % calculate the deltaF/F
                for k = 1:z
                    deltaFoverF(:, :, k) = (im(:, :, k) - meanF) ./ meanF;
                end

                % save the result
                save(infoTable.path{j}, 'deltaFoverF', '-append');
            else
                continue
            end

        end

    end
