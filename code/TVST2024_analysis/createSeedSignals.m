% Compile results from Flywheel forwardModel analyses

% House keeping
clear
close all

%% Variable declaration
scratchSaveDir = tempdir;

% Create the functional tmp save dir if it does not exist
saveDirStem = fullfile(scratchSaveDir,'funcData');
if ~exist(saveDirStem,'dir')
    mkdir(saveDirStem);
end

% project ID
projectID = '5bb4ade9e849c300150d0d99';

% session IDs
analysisIDs = {...
    '6297bc453e46a68d9c35c847','6297bc5a448df488629076fd',...
    '6297bb802c4cd38c6180112a','6297bb90d77e2b9b1f90ce34'};
laterality = {'Left','Right','Left','Right'};
nSessions = length(analysisIDs);

filesToDownload = {'EM404_maxFlicker_LeftEye.zip','EM404_maxFlicker_RightEye.zip','EM404_maxFlicker_LeftEye.zip','EM404_maxFlicker_RightEye.zip'};

% Create a flywheel object. You need to set your flywheelAPIKey in the
% "flywheelMRSupport" local hook.
fw = flywheel.Flywheel(getpref('flywheelMRSupport','flywheelAPIKey'));

% Download the ROI mask and load into memory
fileName = 'LGN_ROI.nii.gz';
maskFilePath = fullfile(saveDirStem,fileName);
fw.downloadFileFromProject(projectID,fileName,maskFilePath);
ROI = niftiread(maskFilePath);
ROI = reshape(ROI,prod(size(ROI)),1);

stimulus = {};
for aa=1:length(analysisIDs)
    % Download and unzip the func data
    tmpPath = fullfile(saveDirStem,filesToDownload{aa});
    saveDir = fullfile(saveDirStem,sprintf('file_%d',aa));
    fw.downloadOutputFromAnalysis(analysisIDs{aa},filesToDownload{aa},tmpPath);
    command = ['unzip -q -n '  escapeFileCharacters(tmpPath) ' -d ' escapeFileCharacters(saveDir)];
    system(command);

    % Load the data and extract the mean timeseries from the ROI
    for ii = 1:9
        fileName = fullfile(saveDirStem,sprintf('file_%d',aa),sprintf('EPI_0%d',ii));
        tmp = dir(fileName);
        fileName = fullfile(fileName,tmp(end).name);
        niftiData = niftiread(fileName);
        niftiData = reshape(niftiData,prod(size(niftiData,1:3)),size(niftiData,4));
        stimulus{end+1} = mean(niftiData(ROI==1,:));
    end
end


