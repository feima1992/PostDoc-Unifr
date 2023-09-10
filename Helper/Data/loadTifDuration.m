function duration = loadTifDuration(tifFile)

    % show information about the tif file
    % fprintf('   Read WF record duration: %s\n', tifFile);

    try
        duration = length(imfinfo(tifFile)) / 40;
    catch
        duration = nan;
    end

end
