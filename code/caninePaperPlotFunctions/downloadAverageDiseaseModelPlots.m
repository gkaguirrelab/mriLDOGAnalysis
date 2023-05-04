% Housekeeping
clear all
clc

% Set threshold and output dir
thresholdV1 = '0.2,0.5'; % Lower and higher threshold for V1
thresholdLGN = '0.1,0.5'; % Threshold for LGN
outputDir = '/home/ozzy/Desktop/averagePlots';
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

% tempdir 
tempdir = fullfile(tempdir, 'averagePlotTempDir');
if ~isdir(tempdir)
    mkdir(tempdir)
end

% Set libraries for freesurfer plotting
setenv('LD_LIBRARY_PATH', ['/usr/lib/x86_64-linux-gnu:',getenv('LD_LIBRARY_PATH')]);

% Get Flywheel project 
fw = flywheel.Flywheel(getpref('flywheelMRSupport','flywheelAPIKey'));
project = fw.projects.findFirst('label=canineFovea');
resampledTempPath = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/2x2x2resampled_invivoTemplate.nii.gz';
template = MRIread(resampledTempPath);

% Get all analyses 
modelNames = {'WT', 'WT', 'WT', ...
              'RCD1', 'RCD1', 'RCD1', ...  
              'XLPRA2', 'XLPRA2', 'XLPRA2', ...
              'CRD2', 'CRD2', 'CRD2'};

modulationNames = {'LF', 'LplusS', 'LminusS', ...
                   'LF', 'LplusS', 'LminusS', ...
                   'LF', 'LplusS', 'LminusS', ...
                   'LF', 'LplusS', 'LminusS'};

analysesIDs = {...
    '63d167f19aed8e37fb4dd25d','63d16805c4f734f85b9758c5','63d1681972abf3a066ca4e04',...
    '63d16750893c027db074da71','63d16762fc9bfe6dc779e323','63d167defcfd7742b3c57cdf',...
    '63d16834e68b5169c59758cb','63d168513051b546a2ca4c74','63d1686d8251a670a44dd260', ...
    '6449bacf2c358a2836db1b3a','6449bae4a8f559f0913009a4','6449baf8c2a62b3c63af5d92'};


for ii = 1:length(analysesIDs)
    analysis = fw.getAnalysis(analysesIDs{ii});
    files = analysis.files();
    for ff = 1:length(files)
        if contains(files{ff}.name, 'eventGain_results')
            fileSaveName = fullfile(tempdir, [modelNames{ii} '_' modulationNames{ii} '_' files{ff}.name]);
            files{ff}.download(fileSaveName)
            
            load(fileSaveName)
            beta = results.beta01;
            beta(isnan(beta)) = 0;
            template.vol = reshape(beta, [53 53 54]);
            imageSaveName = fullfile(tempdir, [modelNames{ii} '_' modulationNames{ii} '.nii.gz']);
            MRIwrite(template, imageSaveName)
            resampledImage = fullfile(tempdir, ['resampled_' modelNames{ii} '_' modulationNames{ii} '.nii.gz']);
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
            leftHemiFlattened = fullfile(flattenedOutput, [modelNames{ii} '_' modulationNames{ii} '_left_flattened.png']);
            rightHemiFlattened = fullfile(flattenedOutput,  [modelNames{ii} '_' modulationNames{ii} '_right_flattened.png']);
            system(['freeview --surface ' leftSurface ':patch=' leftPatch ':curvature_method=binary:overlay=' leftHemiFile ':overlay_threshold=' thresholdV1 ' --cam Elevation 100 --viewport 3d --colorscale --screenshot ' leftHemiFlattened]);
            system(['freeview --surface ' rightSurface ':patch=' rightPatch ':curvature_method=binary:overlay=' rightHemiFile ':overlay_threshold=' thresholdV1 ' --cam Elevation 100 --viewport 3d --colorscale --screenshot ' rightHemiFlattened]);
            leftHemiInflated = fullfile(inflatedOutput, [modelNames{ii} '_' modulationNames{ii} '_left_inflated.png']);
            rightHemiInflated = fullfile(inflatedOutput,  [modelNames{ii} '_' modulationNames{ii} '_right_inflated.png']);
            system(['freeview --surface ' leftSurface ':curvature_method=binary:overlay=' leftHemiFile ':overlay_threshold=' thresholdV1 ' --cam Azimuth 180 --viewport 3d --colorscale --screenshot ' leftHemiInflated]);
            system(['freeview --surface ' rightSurface ':curvature_method=binary:overlay=' rightHemiFile ':overlay_threshold=' thresholdV1 ' --viewport 3d --colorscale --screenshot ' rightHemiInflated]); 
            erodedResample = fullfile(tempdir, ['eroded_resampled_' modelNames{ii} '_' modulationNames{ii} '.nii.gz']);
            binaryForLGN = MRIread(erodedBinaryForLGN);
            binaryForLGN = binaryForLGN.vol;
            resampledImageLoaded.vol(find(binaryForLGN == 0)) = 0;
            MRIwrite(resampledImageLoaded, erodedResample);
            lgnVolume = fullfile(lgnOutput,  [modelNames{ii} '_' modulationNames{ii} '_LGN.png']);
            system(['freeview --volume ' invivoTemplate ':grayscale=70,310' ' --volume ' erodedResample ':colormap=heat:opacity=1:heatscale=' thresholdLGN ' --slice 154 124 43 --viewport y --colorscale --screenshot ' lgnVolume])
        end
    end
end