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

% Get the left and the right hemisphers
projectID = '5bb4ade9e849c300150d0d99';

leftHemiSaveName = fullfile(saveDir, 'leftV1.nii.gz');
rightHemiSaveName = fullfile(saveDir, 'rightV1.nii.gz');
leftHemi = MRIread(fw.downloadFileFromProject(projectID, 'left_canineV1all.nii.gz', leftHemiSaveName));
rightHemi = MRIread(fw.downloadFileFromProject(projectID, 'right_canineV1all.nii.gz', rightHemiSaveName));
leftHemi = find(leftHemi.vol(:));
rightHemi = find(rightHemi.vol(:));

% Get the session and download the results 
sessionID = '61f8259d9c5e882ac6ff49da';
analysisList = fw.getSessionAnalyses(sessionID);
analysisSaveName = fullfile(saveDir, 'N344_mtSinai_results.mat');

for ii = 1:length(analysisList)
    if contains(analysisList{ii}.label, 'IpsiContra')
        analysis = analysisList{ii};
        fw.downloadOutputFromAnalysis(analysis.id,"N344_mtSinai_results.mat",analysisSaveName);
    end
end
load(analysisSaveName)

% Mask the results
leftHemiMasked = results.params(leftHemi, 1:18);
rightHemiMasked = results.params(rightHemi, 1:18);

leftHemiData = [nanmean(leftHemiMasked(:,[1:3, 10:12]),2), nanmean(leftHemiMasked(:,[4:6, 13:15]),2), nanmean(leftHemiMasked(:,[7:9, 16:18]),2)];
rightHemiData = [nanmean(rightHemiMasked(:,[1:3, 10:12]),2), nanmean(rightHemiMasked(:,[4:6, 13:15]),2), nanmean(rightHemiMasked(:,[7:9, 16:18]),2)];

% Get bootstrapped means and confidence intervals 
[leftHemiCI,leftHemiMeans] = bootci(1000,{@(x)mean(x,'omitnan'),leftHemiData});
[rightHemiCI,rightHemiMeans] = bootci(1000,{@(x)mean(x,'omitnan'),rightHemiData});
leftHemiMeans = mean(leftHemiMeans);
rightHemiMeans = mean(rightHemiMeans);

% Plot
jitterLeft = 0.9;
jitterRight = 1.9;
groupColors = {[1 0 0],[0 1 0],[0 0 1]};
for ii = 1:3
    x = categorical({'contra', 'ipsi'});
    hold on 
    plot([jitterLeft jitterLeft],[leftHemiCI(1,ii) leftHemiCI(2,ii)], '-', 'LineWidth',2, 'Color', groupColors{ii})
    plt{ii} = plot(jitterLeft, leftHemiMeans(ii), 'o', 'MarkerFaceColor', groupColors{ii}, 'MarkerEdgeColor', groupColors{ii});
    jitterLeft = jitterLeft + 0.1;
    
    plot([jitterRight jitterRight],[rightHemiCI(1,ii) rightHemiCI(2,ii)], '-', 'LineWidth',2, 'Color', groupColors{ii})
    plot(jitterRight, rightHemiMeans(ii), 'o', 'MarkerFaceColor', groupColors{ii}, 'MarkerEdgeColor', groupColors{ii}) 
    jitterRight = jitterRight + 0.1;

end
ylim([0 1])
xticks([1:2]);
xticklabels({'contra','ipsi'});
legend([plt{:}], {'N347','N349','N344'}, 'location', 'best')