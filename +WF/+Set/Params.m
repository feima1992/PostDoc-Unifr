function P = Params(P)

    %% Update the parameters
    P.folderPath = fullfile(P.folderParent, P.folderName);
    % directory of analysis results
    P.dir.actMap.raw = fullfile(P.folderPath, 'ActMap\Raw'); % directory of activation maps: raw
    P.dir.actMap.reg = fullfile(P.folderPath, 'ActMap\Reg'); % directory of activation maps: registered
    P.dir.actMap.rawDiff = fullfile(P.folderPath, 'ActMap\RawDiff'); % directory of activation maps: raw difference
    P.dir.actMap.regDiff = fullfile(P.folderPath, 'ActMap\RegDiff'); % directory of activation maps: registered difference

    P.dir.actRoi.raw = fullfile(P.folderPath, 'ActRoi\Raw'); % directory of activation ROI: raw
    P.dir.actRoi.reg = fullfile(P.folderPath, 'ActRoi\Reg'); % directory of activation ROI: registered
    P.dir.actRoi.rawDiff = fullfile(P.folderPath, 'ActRoi\RawDiff'); % directory of activation ROI: raw difference
    P.dir.actRoi.regDiff = fullfile(P.folderPath, 'ActRoi\RegDiff'); % directory of activation ROI: registered difference
    %% Process the parameters

    % if animal is not specified, use all animals
    if isempty(P.select.animal.proprioception)
        P.select.stimType.proprioception = 1;

        % find all the animal folders in P.dir.wf
        animalFolders = dir([P.dir.wf, filesep, '*']);
        animalFolders = {animalFolders.name};
        P.select.animal.proprioception = animalFolders(contains(animalFolders, 'm'));

        if isempty(P.select.animal.proprioception)
            error('No animal folderPath is found in the folderPath %s.', P.dir.wf);
        end

    end

  

    % create the user directory if it does not exist
    if ~exist(P.folderPath, 'dir')
        mkdir(P.folderPath);
    end

    % create folderPath for all fields of P.dir
    for i = fieldnames(P.dir)'

        cFiled = P.dir.(i{1});

        if isstruct(cFiled)
                
                for j = fieldnames(cFiled)'
    
                    if ~exist(cFiled.(j{1}), 'dir')
                        mkdir(cFiled.(j{1}));
                        fprintf('Create %s.\n', cFiled.(j{1}));
                    end
    
                end
        else
            try

                if ~exist(cFiled, 'dir')
                    mkdir(cFiled);
                    fprintf('Create %s.\n', cFiled);
                end

            catch
            end
        end

    end

%     % check if P.path.(X) is an existing file, if not, error message
%     for i = fieldnames(P.path)'
% 
%         if ~exist(P.path.(i{1}), 'file') && ~isempty(P.path.(i{1})) && ~contains(P.path.(i{1}), '.txt')
%             error(['The file ', P.path.(i{1}), ' does not exist.']);
%         end
% 
%     end

end
