function Process(obj, target, varargin)

    switch target

        case 'moveToSessionFolder'

            if length(varargin) < 1
                varargin{1} = false;
            end

            WF.Process.MoveToSessionFolder(obj.P, "processBackupFolder", varargin{1});

        case 'removeInteruptedTrials'

            if ~isfield(obj.Info, 'wf')
                obj.Get('wfInfo');
            end

            obj.Info.wf = WF.Process.RemoveInteruptedTrials(obj.Info.wf, obj.P);

        case 'alignTrig'

            if ~isfield(obj.Info, 'wf')
                obj.Get('wfInfo');
            end

            if ~isfield(obj.Info, 'bpod')
                obj.Get('bpodInfo');
            end

            obj.Info.wfBpod = WF.Process.AlignTrig(obj.Info.wf, obj.Info.bpod, obj.P);

        case 'calDeltaFoverF'

            if ~(isfield(obj.ActMap, 'raw') && isfield(obj.ActMap, 'reg'))
                obj.Get('actMap');
            end

            WF.Process.CalDeltaFoverF(obj.ActMap, obj.P, varargin{:});

        case 'applyRoiMask'

            if length(varargin) < 1
                varargin{1} = false;
            end

            if ~isfield(obj.ActMap, 'raw') || ~isfield(obj.ActMap, 'reg')
                obj.Get('actMap', varargin{1});
            end

            if ~isfield(obj.ActRoi, 'mask')
                obj.Set('roiMask');
            end

            obj.Get('bregmaXy');
            obj.ActRoi.avgF = WF.Process.RoiMask.Apply(obj.ActMap, obj.ActRoi.mask);

    end

end
