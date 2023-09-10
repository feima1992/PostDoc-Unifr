function ActRoi_ApplyMask(obj)

    obj.RegCall(mfilename);
    
    fprintf('▶  Applying masks to act maps\n');

    obj.ActRoi_ApplyMaskRaw(); obj.ActRoi_ApplyMaskReg();

end
