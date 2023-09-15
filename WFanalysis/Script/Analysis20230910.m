%% Get diff map for mouse m1691, m1694
objActReg = FileTableActReg().Filter('mouse',{'m1693','m1694'},'mvtDir',0, 'nTrial', 'All').LoadDeltaFoverF();

filePairAct = FileTableActPair( 'allMethod', objActReg).CalPairDiffMap();