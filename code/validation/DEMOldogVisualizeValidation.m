[~, userID] = system('whoami');
userID = strtrim(userID);

directionObj = fullfile('/Users',userID,'Dropbox\ \(Aguirre-Brainard\ Lab\)', 'LDOG_data', 'Experiments','OLApproach_TrialSequenceMR','MRScotoLDOG','DirectionObjects', 'EM426', '2020-03-12', 'directionObject.mat');
whatToPlot = 'bgOnOff';
  % Other WhatToPlot options
  % bgOnOff-compares background/mirrorOn/mirrorOff creates pre and post val
  % measuredVsPredictedBG - measured vs predicted background. Pre and post
  % measuredVsPredictedMirrorsOn - measured vs predicted On. Pre and post
  % measuredVsPredictedMirrorsOff - measured vs predicted Off. Pre and post

results = ldogVisulizeValidation(directionObj, 'median', whatToPlot);
