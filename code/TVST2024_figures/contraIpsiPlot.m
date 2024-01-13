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
volumeSaveName = fullfile(saveDir, 'N344_maps_volumetric.zip');

% surface calculation folder
ldogSurfaceCalculationFolder = '/home/ozzy/Desktop/invivo2exvivo/';
origImage = fullfile(ldogSurfaceCalculationFolder, 'Woofsurfer', 'mri', 'T1.nii');
warp = fullfile(ldogSurfaceCalculationFolder,'exvivo_warp_files', 'toEx1Warp.nii.gz');
secondaryLinear = fullfile(ldogSurfaceCalculationFolder,'exvivo_warp_files', 'secondLinearAnts.mat');
primaryLinear = fullfile(ldogSurfaceCalculationFolder,'exvivo_warp_files', 'initialLinearAnts.mat');
registerDat = fullfile(ldogSurfaceCalculationFolder, 'exvivo_warp_files', 'register.dat');
leftSurface = fullfile(ldogSurfaceCalculationFolder, 'Woofsurfer', 'surf', 'lh.inflated');
rightSurface = fullfile(ldogSurfaceCalculationFolder, 'Woofsurfer', 'surf', 'rh.inflated');
leftPatch = fullfile(ldogSurfaceCalculationFolder, 'Woofsurfer', 'surf', 'lh.flattened_cut');
rightPatch = fullfile(ldogSurfaceCalculationFolder, 'Woofsurfer', 'surf', 'rh.flattened_cut');
invivoTemplate = fullfile('/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/invivoTemplate.nii.gz');
binaryTemplate = fullfile('/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/binaryTemplate_eroded.nii.gz');
erodedBinaryForLGN = fullfile('/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/binaryTemplate_erodedForLGN.nii.gz');
identityMatrix = fullfile('/home/ozzy/fsl/etc/flirtsch/ident.mat');

for ii = 1:length(analysisList)
    if contains(analysisList{ii}.label, 'IpsiContra')
        analysis = analysisList{ii};
        fw.downloadOutputFromAnalysis(analysis.id,"N344_mtSinai_results.mat",analysisSaveName);
        fw.downloadOutputFromAnalysis(analysis.id,"N344_maps_volumetric.zip",volumeSaveName);
        unzip(volumeSaveName, saveDir)
    end
end
load(analysisSaveName)

% Mask the results
leftHemiMaskedVertexMean = nanmean(results.params(leftHemi, 1:18));
rightHemiMaskedVertexMean = nanmean(results.params(rightHemi, 1:18));

leftHemiMeans = [nanmean(leftHemiMaskedVertexMean([4:6, 13:15])), nanmean(leftHemiMaskedVertexMean([1:3, 10:12])), nanmean(leftHemiMaskedVertexMean([7:9, 16:18]))];
rightHemiMeans = [nanmean(rightHemiMaskedVertexMean([4:6, 13:15])), nanmean(rightHemiMaskedVertexMean([1:3, 10:12])), nanmean(rightHemiMaskedVertexMean([7:9, 16:18]))];

leftHemiSE = [std(leftHemiMaskedVertexMean([4:6, 13:15]))/sqrt(length(leftHemiMaskedVertexMean([4:6, 13:15]))), std(leftHemiMaskedVertexMean([1:3, 10:12]))/sqrt(length(leftHemiMaskedVertexMean([1:3, 10:12]))), std(leftHemiMaskedVertexMean([7:9, 16:18]))/sqrt(length(leftHemiMaskedVertexMean([7:9, 16:18])))];
rightHemiSE = [std(rightHemiMaskedVertexMean([4:6, 13:15]))/sqrt(length(rightHemiMaskedVertexMean([4:6, 13:15]))), std(rightHemiMaskedVertexMean([1:3, 10:12]))/sqrt(length(rightHemiMaskedVertexMean([1:3, 10:12]))), std(rightHemiMaskedVertexMean([7:9, 16:18]))/sqrt(length(rightHemiMaskedVertexMean([7:9, 16:18])))];

% Plot
jitterWithin = 0.1;
jitterBetween = 2;
colors = {[1 0 0], [0.5 0.5 0.5]};
figure
for ii = 1:3
    hold on 
    plot([jitterBetween jitterBetween],[leftHemiMeans(ii)-leftHemiSE(ii) leftHemiMeans(ii)+leftHemiSE(ii)], '-', 'LineWidth',2, 'Color', colors{1})
    plt{ii} = plot(jitterBetween, leftHemiMeans(ii), 'o', 'MarkerFaceColor', colors{1}, 'MarkerEdgeColor', colors{1}, 'MarkerSize', 6, 'MarkerEdgeColor','k');    
    
    plot([jitterBetween+jitterWithin jitterBetween+jitterWithin],[rightHemiMeans(ii)-rightHemiSE(ii) rightHemiMeans(ii)+rightHemiSE(ii)], '-', 'LineWidth',2, 'Color', colors{2})
    plt{ii+3} = plot(jitterBetween+jitterWithin, rightHemiMeans(ii), 's', 'MarkerFaceColor', colors{2}, 'MarkerEdgeColor', colors{2}, 'MarkerSize', 6, 'MarkerEdgeColor','k');

    
    jitterBetween = jitterBetween+1;
end
ylim([0 0.8])
yticks([0:0.2:0.8])
xticks([2.05:4.05]);
xlim([1.8,4.5])
xticklabels({'N349','N347','N344'});
plot([1.8,4.5],[0 0],':k')
legend([plt{1}, plt{4}], {'contra','ipsi'}, 'location', 'best')
ylabel('BOLD response [%△]')

% Get the flatten maps
output = '/home/ozzy/Desktop/ipsiContraSave';
if ~isfolder(output)
    mkdir(output)
end
% 
% % Save surface plots
% setenv('LD_LIBRARY_PATH', ['/usr/lib/x86_64-linux-gnu:',getenv('LD_LIBRARY_PATH')]);
% threshold = '0.2,0.5';
% r2Results = fullfile(saveDir, 'N344_R2_map.nii.gz');
% resampledImage = fullfile(saveDir, ['resampled_R2.nii.gz']);
% system(['flirt -in ' r2Results ' -ref ' invivoTemplate ' -interp nearestneighbour -applyxfm -init ' identityMatrix ' -o ' resampledImage])
% resampledImageLoaded = MRIread(resampledImage);
% binaryImage = MRIread(binaryTemplate);
% binaryImage = binaryImage.vol;
% resampledImageLoaded.vol(find(binaryImage == 0)) = 0;
% MRIwrite(resampledImageLoaded, resampledImage);
% interpolatedMap = fullfile(saveDir, 'interpolatedMap.nii.gz');
% system(['antsApplyTransforms -d 3 -i ' r2Results ' -r ' origImage ' -o ' interpolatedMap ' -t ' warp ' -t ' secondaryLinear ' -t ' primaryLinear])
% leftHemiFile = fullfile(saveDir, 'lh.mgz');
% rightHemiFile = fullfile(saveDir, 'rh.mgz');
% system(['mri_vol2surf --mov ' interpolatedMap ' --ref ' interpolatedMap  ' --reg ' registerDat ' --srcsubject Woofsurfer ' '--hemi ' 'lh' ' --o ' leftHemiFile]);
% system(['mri_vol2surf --mov ' interpolatedMap ' --ref ' interpolatedMap  ' --reg ' registerDat ' --srcsubject Woofsurfer ' '--hemi ' 'rh' ' --o ' rightHemiFile]);
% leftHemiFlattened = fullfile(output, 'left_flattened.png');
% rightHemiFlattened = fullfile(output,  'right_flattened.png');
% system(['freeview --surface ' leftSurface ':patch=' leftPatch ':curvature_method=binary:overlay=' leftHemiFile ':overlay_threshold=' threshold ' --cam Elevation 100 --viewport 3d --colorscale --screenshot ' leftHemiFlattened ' 2']);
% system(['freeview --surface ' rightSurface ':patch=' rightPatch ':curvature_method=binary:overlay=' rightHemiFile ':overlay_threshold=' threshold ' --cam Elevation 100 --viewport 3d --colorscale --screenshot ' rightHemiFlattened ' 2']);
% leftHemiInflated = fullfile(output, 'left_inflated.png');
% rightHemiInflated = fullfile(output,  'right_inflated.png');
% system(['freeview --surface ' leftSurface ':curvature_method=binary:overlay=' leftHemiFile ':overlay_threshold=' threshold ' --cam Azimuth 180 --viewport 3d --colorscale --screenshot ' leftHemiInflated ' 2']);
% system(['freeview --surface ' rightSurface ':curvature_method=binary:overlay=' rightHemiFile ':overlay_threshold=' threshold ' --viewport 3d --colorscale --screenshot ' rightHemiInflated ' 2']);