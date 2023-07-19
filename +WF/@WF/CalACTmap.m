%% WF process pipelines
function CalACTmap(obj)
    obj.callCount.CalACTmap = obj.callCount.CalACTmap +1;
    % calculate act map of each movement direction only when proprioception is on and vibration and whisker are off
    if (obj.p.select.stimType.proprioception == 1)...
            && (obj.p.select.stimType.vibration == 0)...
            && (obj.p.select.stimType.whisker == 0)...
            && (obj.callCount.CalACTmap == 1)
        
        switch obj.p.act.flag.mapForEachMvtDir 
            case 0 % do NOT calculate act map of each movement direction
                    obj.GetParams('updateFolder',fullfile(obj.p.folderName,'AllMvtDir'));
                    obj.p.act.flag.mapForEachMvtDir = false;
                    CalACTmapHelper(obj)
            case 1 % calculate act map of each movement direction
                folderName = obj.p.folderName;
                for i = 1:8
                    fprintf('Calculating act map of movement direction %d\n',i)
                    obj.GetParams('updateFolder',fullfile(folderName,['MvtDir', num2str(i)]))
                    obj.p.select.trial.proprioception.moveDirection = i;
                    obj.p.act.flag.mapForEachMvtDir = true;
                    CalACTmapHelper(obj)
                end
        end
    else

      CalACTmapHelper(obj)
      
    end
end

function CalACTmapHelper(obj)
    obj.GetParams('process',1);
    % orgnize file: move tifs to session foleder
    obj.OrgnizeMoveToSessionFolder();
    % get information of WF files
    obj.GetWFinfo();
    % orgnize file: remove tifs of problem tirals
    obj.OrgnizeRemoveInteruptedTrials()
    % get information of Bpod files
    obj.GetBpodInfo();
    % get reference image
    obj.GetREFimages();
    % align wf images with stimulation trigger
    obj.AlignTrig();
end