function result = quickLoad(filePath, var)
    % use H5read to load a variable from a .h5 file quickly
    % filePath: path to the .h5 file
    % var: path to the variable in the .h5 file (e.g. '/data/raw/rawData')

    var = ['/' var];

    fid = H5F.open(filePath,'H5F_ACC_RDONLY','H5P_DEFAULT');
    dset_id = H5D.open(fid,var);
    result = H5D.read(dset_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT');
    H5D.close(dset_id);
    H5F.close(fid);

end