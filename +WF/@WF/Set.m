function Set(obj, target, varargin)

    switch target

        case 'packagePath'

            WF.Set.PackagePath(varargin{1});

        case 'sessionPair'

            if ~isfield(obj.ActRoi, 'avgF')
                obj.Process('applyRoiMask');
            end

            obj.ActRoi.avgF = WF.Set.SessionPair(obj.ActRoi.avgF);

    end

end
