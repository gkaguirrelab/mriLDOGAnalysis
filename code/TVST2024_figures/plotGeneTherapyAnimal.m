% A script to make contra-ipsi plots

% House keeping
clear
close all

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

% Set libraries for freesurfer plotting
setenv('LD_LIBRARY_PATH', ['/usr/lib/x86_64-linux-gnu:',getenv('LD_LIBRARY_PATH')]);

% Set threshold and output dir
threshold = '0.2,0.5'; % Lower and higher threshold
outputDir = '/home/ozzy/Desktop/geneTherapyResults';
if ~isdir(outputDir)
    mkdir(outputDir)
end
flattenedOutput = fullfile(outputDir, 'flattenedPlots');
if ~isdir(flattenedOutput)
    mkdir(flattenedOutput)
end
inflatedOutput = fullfile(outputDir, 'inflatedPlots');
if ~isdir(inflatedOutput)
    mkdir(inflatedOutput)
end
lgnOutput = fullfile(outputDir, 'lgnPlots');
if ~isdir(lgnOutput)
    mkdir(lgnOutput)
end

% tempdir 
tempdir = fullfile(tempdir, 'averagePlotTempDir');
if ~isdir(tempdir)
    mkdir(tempdir)
end

% Get Flywheel project 
fw = flywheel.Flywheel(getpref('flywheelMRSupport','flywheelAPIKey'));
project = fw.projects.findFirst('label=canineFovea');
analysis = fw.getAnalysis('63cf0ccefcfd7742b3c57be9');
files = analysis.files();
fileSaveName = fullfile(tempdir, 'WM67_mtSinai_results.mat');
for ff = 1:length(files)
    if contains(files{ff}.name, 'WM67_mtSinai_results')
        files{ff}.download(fileSaveName)
    end
end
load(fileSaveName)

% MRI template
resampledTempPath = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/2x2x2resampled_invivoTemplate.nii.gz';
template = MRIread(resampledTempPath);

% Set zero to nan 
results.params(isnan(results.params)) = 0;

% Labels 
label = {'LplusSright', 'LplusSleft', 'LminusSright', 'LminusSleft', ...
          'LFright', 'LFleft'};
label = {'LFright', 'LFleft', 'LplusSright', 'LplusSleft', 'LminusSright', 'LminusSleft'};
fulldata = {};
      
% Light Flux
fulldata{1} = reshape(mean(results.params(:,13:15),2), [53 53 54]);
fulldata{2} = reshape(mean(results.params(:,16:18),2), [53 53 54]);

% L plus S
fulldata{3} = reshape(mean(results.params(:,1:3),2), [53 53 54]);
fulldata{4} = reshape(mean(results.params(:,4:6),2), [53 53 54]);

% L minus S
fulldata{5} = reshape(mean(results.params(:,7:9),2), [53 53 54]);
fulldata{6} = reshape(mean(results.params(:,10:12),2), [53 53 54]);

for ii = 1:length(label)
    imageSaveName = fullfile(tempdir, [label{ii} '.nii.gz']);
    template.vol = fulldata{ii};
    MRIwrite(template, imageSaveName)
    resampledImage = fullfile(tempdir, ['resampled_' label{ii} '.nii.gz']);
    system(['flirt -in ' imageSaveName ' -ref ' invivoTemplate ' -interp nearestneighbour -applyxfm -init ' identityMatrix ' -o ' resampledImage])
    resampledImageLoaded = MRIread(resampledImage);
    binaryImage = MRIread(binaryTemplate);
    binaryImage = binaryImage.vol;
    resampledImageLoaded.vol(find(binaryImage == 0)) = 0;
    MRIwrite(resampledImageLoaded, resampledImage);
    interpolatedMap = fullfile(tempdir, 'interpolatedMap.nii.gz');
    system(['antsApplyTransforms -d 3 -i ' imageSaveName ' -r ' origImage ' -o ' interpolatedMap ' -t ' warp ' -t ' secondaryLinear ' -t ' primaryLinear])
    leftHemiFile = fullfile(tempdir, 'lh.mgz');
    rightHemiFile = fullfile(tempdir, 'rh.mgz');
    system(['mri_vol2surf --mov ' interpolatedMap ' --ref ' interpolatedMap  ' --reg ' registerDat ' --srcsubject Woofsurfer ' '--hemi ' 'lh' ' --o ' leftHemiFile]);
    system(['mri_vol2surf --mov ' interpolatedMap ' --ref ' interpolatedMap  ' --reg ' registerDat ' --srcsubject Woofsurfer ' '--hemi ' 'rh' ' --o ' rightHemiFile]);
    leftHemiFlattened = fullfile(flattenedOutput, [label{ii} '_left_flattened.png']);
    rightHemiFlattened = fullfile(flattenedOutput,  [label{ii} '_right_flattened.png']);
    system(['freeview --surface ' leftSurface ':patch=' leftPatch ':curvature_method=binary:overlay=' leftHemiFile ':overlay_threshold=' threshold ' --cam Elevation 100 --viewport 3d --colorscale --screenshot ' leftHemiFlattened]);
    system(['freeview --surface ' rightSurface ':patch=' rightPatch ':curvature_method=binary:overlay=' rightHemiFile ':overlay_threshold=' threshold ' --cam Elevation 100 --viewport 3d --colorscale --screenshot ' rightHemiFlattened]);
    leftHemiInflated = fullfile(inflatedOutput, [label{ii} '_left_inflated.png']);
    rightHemiInflated = fullfile(inflatedOutput,  [label{ii} '_right_inflated.png']);
    system(['freeview --surface ' leftSurface ':curvature_method=binary:overlay=' leftHemiFile ':overlay_threshold=' threshold ' --cam Azimuth 180 --viewport 3d --colorscale --screenshot ' leftHemiInflated]);
    system(['freeview --surface ' rightSurface ':curvature_method=binary:overlay=' rightHemiFile ':overlay_threshold=' threshold ' --viewport 3d --colorscale --screenshot ' rightHemiInflated]);
    erodedResample = fullfile(tempdir, ['eroded_resampled_' label{ii} '.nii.gz']);
    binaryForLGN = MRIread(erodedBinaryForLGN);
    binaryForLGN = binaryForLGN.vol;
    resampledImageLoaded.vol(find(binaryForLGN == 0)) = 0;
    MRIwrite(resampledImageLoaded, erodedResample);
    lgnVolume = fullfile(lgnOutput,  [label{ii} '_LGN.png']);
    system(['freeview --volume ' invivoTemplate ' --volume ' erodedResample ':colormap=heat:heatscale=' threshold ' --slice 154 124 43 --viewport y --colorscale --screenshot ' lgnVolume])
end

% Plot left and right eye for V1 and 
for ii = 1:length(project.files)
    if strcmp(project.files{ii}.name, 'canineV1all.nii.gz')
        V1mask = project.files{ii};
        V1saveMask = fullfile(tempdir, 'V1mask.nii.gz');
        V1mask.download(V1saveMask);       
    end
    if strcmp(project.files{ii}.name, 'LGN_ROI.nii.gz')
        LGNmask = project.files{ii};
        LGNsaveMask = fullfile(tempdir, 'LGNmask.nii.gz');
        LGNmask.download(LGNsaveMask)   
    end
end
V1 = MRIread(V1saveMask);
V1 = V1.vol;
LGN = MRIread(LGNsaveMask);
LGN = LGN.vol;
averagefullDataV1 = {};
averagefullDataV1CI = {};
averagefullDataLGN = {};
averagefullDataLGNCI = {};
for ii = 1:length(fulldata)
    averagefullDataV1{ii} = mean(fulldata{ii}(find(V1)));
    averagefullDataV1CI{ii} = std(fulldata{ii}(find(V1)))/sqrt(length(fulldata{ii}(find(V1))));
    averagefullDataLGN{ii} = mean(fulldata{ii}(find(LGN)));
    averagefullDataLGNCI{ii} = std(fulldata{ii}(find(LGN)))/sqrt(length(fulldata{ii}(find(LGN))));
end

figure
jitterLeft = 0.9;
jitterRight = 1.9;
groupColors = {[1 0 0],[1 0 0],[0 1 0],[0 1 0],[0 0 1],[0 0 1]};
for ii = 1:length(averagefullDataV1)
    hold on 
    if mod(ii,2) 
        plot([jitterLeft jitterLeft],[averagefullDataV1{ii}-averagefullDataV1CI{ii} averagefullDataV1{ii}+averagefullDataV1CI{ii}], '-', 'LineWidth',2, 'Color', groupColors{ii})
        plt{ii} = plot(jitterLeft, averagefullDataV1{ii}, 'o', 'MarkerFaceColor', groupColors{ii}, 'MarkerEdgeColor', groupColors{ii});
        jitterLeft = jitterLeft + 0.1;
    elseif ~mod(ii,2) 
        plot([jitterRight jitterRight],[averagefullDataV1{ii}-averagefullDataV1CI{ii} averagefullDataV1{ii}+averagefullDataV1CI{ii}], '-', 'LineWidth',2, 'Color', groupColors{ii})
        plt{ii} = plot(jitterRight, averagefullDataV1{ii}, 'o', 'MarkerFaceColor', groupColors{ii}, 'MarkerEdgeColor', groupColors{ii});
        jitterRight = jitterRight + 0.1;  
    end
end
ylim([-0.1 0.5])
xticks([1:2]);
legend([plt{[1,4,6]}], {'LightFLux','LplusS','LminusS'}, 'location', 'best')
xticklabels({'right eye','left eye'});
title('V1')

figure
jitterLeft = 0.9;
jitterRight = 1.9;
groupColors = {[1 0 0],[1 0 0],[0 1 0],[0 1 0],[0 0 1],[0 0 1]};
for ii = 1:length(averagefullDataV1)
    hold on 
    if mod(ii,2) 
        plot([jitterLeft jitterLeft],[averagefullDataLGN{ii}-averagefullDataLGNCI{ii} averagefullDataLGN{ii}+averagefullDataLGNCI{ii}], '-', 'LineWidth',2, 'Color', groupColors{ii})
        plt{ii} = plot(jitterLeft, averagefullDataLGN{ii}, 'o', 'MarkerFaceColor', groupColors{ii}, 'MarkerEdgeColor', groupColors{ii});
        jitterLeft = jitterLeft + 0.1;
    elseif ~mod(ii,2) 
        plot([jitterRight jitterRight],[averagefullDataLGN{ii}-averagefullDataLGNCI{ii} averagefullDataLGN{ii}+averagefullDataLGNCI{ii}], '-', 'LineWidth',2, 'Color', groupColors{ii})
        plt{ii} = plot(jitterRight, averagefullDataLGN{ii}, 'o', 'MarkerFaceColor', groupColors{ii}, 'MarkerEdgeColor', groupColors{ii});
        jitterRight = jitterRight + 0.1;  
    end
end
ylim([-0.1 0.5])
xticks([1:2]);
xticklabels({'right eye','left eye'});
legend([plt{[1,4,6]}], {'LightFLux','LplusS','LminusS'}, 'location', 'best')
title('LGN')

% Plot z values
V1path = '/home/ozzy/Aguirre-Brainard\ Lab\ Dropbox/Ozenc\ Taskin/Taskin_2022_CaninePostRetinalFunction/FSL_runs/V1avg_left-right.gfeat/cope1.feat/stats/';
LGNpath = '/home/ozzy/Aguirre-Brainard\ Lab\ Dropbox/Ozenc\ Taskin/Taskin_2022_CaninePostRetinalFunction/FSL_runs/LGNavg_left-right.gfeat/cope1.feat/stats';

modulations = {'Light Flux', 'L-S', 'L+S'};
for ii = 1:length(modulations)
    V1 = fullfile(V1path,['zstat' num2str(ii) '.nii.gz']);
    V1 = MRIread(V1);
    V1 = V1.vol(find(V1.vol));
    V1 = V1(1);
    LGN = fullfile(LGNpath,['zstat' num2str(ii) '.nii.gz']);
    LGN = MRIread(LGN);
    LGN = LGN.vol(find(LGN.vol));
    LGN = LGN(1);
    fprintf(['V1 z value for ' modulations{ii} ' :' num2str(V1) '\n'])
    fprintf(['LGN z value for ' modulations{ii} ' :' num2str(LGN) '\n'])
end
    




