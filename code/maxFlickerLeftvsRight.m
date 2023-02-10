% A script to make contra-ipsi plots

% House keeping
clear
close all

%% Variable declaration
scratchSaveDir = tempdir;

% Create the functional tmp save dir if it does not exist
saveDir = fullfile(scratchSaveDir,'mriLDOGSAnalysis');
if ~exist(saveDir,'dir')
    mkdir(saveDir);
end

%% Open the flywheel object
fw = flywheel.Flywheel(getpref('flywheelMRSupport','flywheelAPIKey'));

%% Max flicker sessions
subjectNames = {'EM404', 'EM404', ...  % Ses 2 first
                'EM533', 'EM532', ...
                'EM499', 'EM501'};
subjectSaveNames = {'EM404_Ses2', 'EM404_Ses1', ...  % Ses 2 first
                    'EM533', 'EM532', ...
                    'EM499', 'EM501'};
sessionLabels = {'628beaacbcc8f465c7e3246c', '61646b08f86d3c467fa80e3a', ...
                 '615f26b83b72c9ea19a80d73', '615c8cf30743604ae7eb3d8e', ...
                 '60cb8476fa591f5814c9a7d9', '60b90d4f498d1b43432a8819'};

% Get the left and the right hemisphers
projectID = '5bb4ade9e849c300150d0d99';

leftHemiSaveName = fullfile(saveDir, 'leftV1.nii.gz');
rightHemiSaveName = fullfile(saveDir, 'rightV1.nii.gz');
leftHemiMask = MRIread(fw.downloadFileFromProject(projectID, 'left_canineV1all.nii.gz', leftHemiSaveName));
rightHemiMask = MRIread(fw.downloadFileFromProject(projectID, 'right_canineV1all.nii.gz', rightHemiSaveName));
leftHemiMask = find(leftHemiMask.vol(:));
rightHemiMask = find(rightHemiMask.vol(:));
allV1Mask = [leftHemiMask; rightHemiMask];

jitterRight = 0.9;
jitterLeft = 1.9;
jitterMinus = 2.9;
for ii = 1:length(subjectNames)
    analysisList = fw.getSessionAnalyses(sessionLabels{ii});
    for aa = 1:length(analysisList)
        if contains(analysisList{aa}.label, 'forwardmodel') && ~contains(analysisList{aa}.label, 'NoPseudo')
            analysisSaveName = fullfile(saveDir, [subjectSaveNames{ii} '_mtSinai_results.mat']);  
            fw.downloadOutputFromAnalysis(analysisList{aa}.id,[subjectNames{ii} '_mtSinai_results.mat'],analysisSaveName);
            
            load(analysisSaveName)
            leftEye = mean(results.params(allV1Mask, 1:9),2);
            rightEye = mean(results.params(allV1Mask, 10:18),2);
            leftMinusRightEye = abs(leftEye) - abs(rightEye);
            [leftEyeCI,leftEyeMeans] = bootci(1000,{@(x)mean(x,'omitnan'),leftEye});
            [rightEyeCI,rightEyeMeans] = bootci(1000,{@(x)mean(x,'omitnan'),rightEye});
            [leftMinusRightEyeCI,leftMinusRightEyeMeans] = bootci(1000,{@(x)mean(x,'omitnan'),leftMinusRightEye});
            leftEyeMeans = mean(leftEyeMeans);
            rightEyeMeans = mean(rightEyeMeans);
            leftMinusRightEyeMeans = mean(leftMinusRightEyeMeans);
            
            if strcmp(subjectNames{ii}, 'EM404')
                color = [1 0 0];
            else
                color = [0 1 0];
            end

            
            plot([jitterRight jitterRight], [rightEyeCI(1) rightEyeCI(2)], '-', 'LineWidth',2, 'Color', color)
            hold on
            plot(jitterRight, rightEyeMeans, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', color);  
            jitterRight = jitterRight + 0.05;            
            plot([jitterLeft jitterLeft], [leftEyeCI(1) leftEyeCI(2)], '-', 'LineWidth',2, 'Color', color)
            plot(jitterLeft, leftEyeMeans, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', color);
            jitterLeft = jitterLeft + 0.05;
            plot([jitterMinus jitterMinus], [leftMinusRightEyeCI(1) leftMinusRightEyeCI(2)], '-', 'LineWidth',2, 'Color', color)
            plot(jitterMinus, leftMinusRightEyeMeans, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', color);
            jitterMinus = jitterMinus + 0.05;            
        end
    end
end
ylim([-0.4 1])
xticks([1:3]);
xticklabels({'rightEye','leftEye (treated)', 'leftMinusrightEye'}); 
plot([0 4],[0 0],':k')