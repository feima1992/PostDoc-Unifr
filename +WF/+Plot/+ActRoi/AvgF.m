function AvgF(avgF, mask, P, varargin)
    fprintf('▶  Plotting avg F of Roi\n')

    if isfield(avgF, 'raw') && isfield(mask, 'raw')
        
        WF.Plot.Roi.AvgF.Raw(avgF.raw, mask.raw, P, varargin{:})
        WF.Plot.Roi.AvgF.RawMean(avgF.raw, mask.raw, P)
        
    end
    
    
    if isfield(avgF, 'rawDiff') && isfield(mask, 'raw')
        
        WF.Plot.Roi.AvgF.RawDiff(avgF.rawDiff, mask.raw, P, varargin{:})
        WF.Plot.Roi.AvgF.RawDiffMean(avgF.rawDiff, mask.raw, P, varargin{:})
    end

    if isfield(avgF, 'reg') && isfield(mask, 'reg')

        WF.Plot.Roi.AvgF.Reg(avgF.reg, P, varargin{:});
        WF.Plot.Roi.AvgF.RegMean(avgF.reg, P)

    end
    
    if isfield(avgF, 'regDiff') && isfield(mask, 'reg')

        WF.Plot.Roi.AvgF.RegDiff(avgF.regDiff, P, varargin{:});
        WF.Plot.Roi.AvgF.RegDiffMean(avgF.regDiff,P, varargin{:})

    end

end
