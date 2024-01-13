% Housekeeping
clear all
clc

% Set threshold we will use for the plots and an output dir
thresholdV1 = '0.2,0.5'; % Lower and higher threshold for V1
thresholdLGN = '0.1,0.5'; % Threshold for LGN
outputDir = '/home/ozzy/Desktop/maxFlickerPlots';
if ~isdir(outputDir)
    mkdir(outputDir)
end

% surface calculation folder. This can be found on Flywheel under the 
% subject "atlas". Download the archive invivo2exvivo.zip. Extract the
% folder and set path to it below. 
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

% Get the list of the subjects we want to analyze
subjectNames = ['EM404', 'EM533', 'EM532', 'EM499', 'EM501', 'M662'];

% Get all subjects from Flywheel
subjects = project.subjects();
% Loop through subjets
for sub = 1:length(subjects)
    
    % If subject is in our list create a directory for it in the output dir
    if contains(subjectNames, subjects{sub}.label)
        if ~isdir(fullfile(outputDir, subjects{sub}.label))
            mkdir(fullfile(outputDir, subjects{sub}.label))
        end
        
        % Get all sessions for the subject
        sessions = subjects{sub}.sessions();
        
        % Loop through sessions and create a folder for each of them
        for ses = 1:length(sessions)
            sessionPath = fullfile(outputDir, subjects{sub}.label, sessions{ses}.label);
            if ~isdir(sessionPath)
                mkdir(sessionPath)
            end  
            % Get all analyses in the sessions
            analyses = sessions{ses}.analyses();
            % Loop through analyses. 
            for aa = 1:length(analyses)
                % Decide whether the analysis is a
                % noPseudo run or Pseudo run and based on that create a
                % savePath.
                if contains(analyses{aa}.label, 'maxFlicker') && contains(analyses{aa}.label, 'forwardmodel') && contains(analyses{aa}.label, 'NoPseudo')
                    savePath = fullfile(sessionPath, 'NoPseudo');
                elseif contains(analyses{aa}.label, 'maxFlicker') && contains(analyses{aa}.label, 'forwardmodel') && ~contains(analyses{aa}.label, 'NoPseudo')
                    savePath = fullfile(sessionPath, 'Pseudo');
                end
                % If analysis is forwardModel, we are going to do the stuff
                % below.
                if contains(analyses{aa}.label, 'maxFlicker') && contains(analyses{aa}.label, 'forwardmodel')
                    % Create a folder
                    if ~isdir(savePath)
                        mkdir(savePath)
                    end
                    % Get the files in the analysis
                    files = analyses{aa}.files();
                    % Loop through files and find mtSinai_results. Save it
                    % to tmp and load into MATLAB.
                    for ff = 1:length(files)
                        if contains(files{ff}.name, 'mtSinai_results')
                            fileSaveName = fullfile(tempdir, 'mtSinai_results.mat');
                            files{ff}.download(fileSaveName)
                            load(fileSaveName)
                            % Here we will separate eyes and get the
                            % average beta values for left and right eyes
                            % separately
                            eyes = {'leftEye','rightEye'};
                            for eye = 1:length(eyes)
                                % M662 and other maxFlicker subjects have a
                                % different number of scans. We deal with
                                % that here.
                                if ~strcmp(subjects{sub}.label, 'M662')
                                    if strcmp(eyes{eye}, 'leftEye')    
                                        beta = nanmean(results.params(:,1:9), 2);
                                    elseif strcmp(eyes{eye}, 'rightEye')
                                        beta = nanmean(results.params(:,10:18), 2);
                                    end
                                elseif strcmp(subjects{sub}.label, 'M662')
                                    % Further, different M662 sessions have
                                    % different number of acquisitions.
                                    % Deal with that here.
                                    if strcmp(sessions{ses}.label, 'foveaLocalizer_2.1')
                                        if strcmp(eyes{eye}, 'leftEye')    
                                            beta = nanmean(results.params(:,1:8), 2);
                                        elseif strcmp(eyes{eye}, 'rightEye')
                                            beta = nanmean(results.params(:,9:12), 2);
                                        end
                                    elseif strcmp(sessions{ses}.label, 'foveaLocalizer_1.1') || strcmp(sessions{ses}.label, 'foveaLocalizer_3.1')
                                        if strcmp(eyes{eye}, 'leftEye')    
                                            beta = nanmean(results.params(:,1:8), 2);
                                        elseif strcmp(eyes{eye}, 'rightEye')
                                            beta = nanmean(results.params(:,9:16), 2);
                                        end
                                    end
                                end
                                
                                % Set nans to 0, load beta values to the
                                % template image and save that template
                                beta(isnan(beta)) = 0;
                                template.vol = reshape(beta, [53 53 54]);
                                imageSaveName = fullfile(tempdir, 'beta.nii.gz');   
                                MRIwrite(template, imageSaveName)
                                % Resample to template image to hires
                                % invivoTemplate. This is to show LGN
                                % results. Mask with binary template
                                resampledImage = fullfile(tempdir, 'resampled_beta.nii.gz');
                                system(['flirt -in ' imageSaveName ' -ref ' invivoTemplate ' -interp nearestneighbour -applyxfm -init ' identityMatrix ' -o ' resampledImage])
                                resampledImageLoaded = MRIread(resampledImage);
                                binaryImage = MRIread(binaryTemplate);
                                binaryImage = binaryImage.vol; 
                                resampledImageLoaded.vol(find(binaryImage == 0)) = 0; 
                                MRIwrite(resampledImageLoaded, resampledImage);
                                % Interpolate image to canine orig.mgz.
                                % This is the volumetric base of the
                                % template surface
                                interpolatedMap = fullfile(tempdir, 'interpolatedMap.nii.gz');
                                system(['antsApplyTransforms -d 3 -i ' imageSaveName ' -r ' origImage ' -o ' interpolatedMap ' -t ' warp ' -t ' secondaryLinear ' -t ' primaryLinear])
                                % Now map to surface mgz format
                                leftHemiFile = fullfile(tempdir, 'lh.mgz');
                                rightHemiFile = fullfile(tempdir, 'rh.mgz');
                                system(['mri_vol2surf --mov ' interpolatedMap ' --ref ' interpolatedMap  ' --reg ' registerDat ' --srcsubject Woofsurfer ' '--hemi ' 'lh' ' --o ' leftHemiFile]); 
                                system(['mri_vol2surf --mov ' interpolatedMap ' --ref ' interpolatedMap  ' --reg ' registerDat ' --srcsubject Woofsurfer ' '--hemi ' 'rh' ' --o ' rightHemiFile]);
                                % Save flattened images
                                flattenedOutput = fullfile(savePath, 'flattened');
                                if ~isdir(flattenedOutput)
                                    mkdir(flattenedOutput)
                                end
                                leftHemiFlattened = fullfile(flattenedOutput, [eyes{eye} '_left_flattened.png']);
                                rightHemiFlattened = fullfile(flattenedOutput, [eyes{eye} '_right_flattened.png']);
                                system(['freeview --surface ' leftSurface ':patch=' leftPatch ':curvature_method=binary:overlay=' leftHemiFile ':overlay_threshold=' thresholdV1 ' --cam Elevation 100 --viewport 3d --colorscale --screenshot ' leftHemiFlattened]);
                                system(['freeview --surface ' rightSurface ':patch=' rightPatch ':curvature_method=binary:overlay=' rightHemiFile ':overlay_threshold=' thresholdV1 ' --cam Elevation 100 --viewport 3d --colorscale --screenshot ' rightHemiFlattened]);
                                % Save inflated images
                                inflatedOutput = fullfile(savePath, 'inflated');
                                if ~isdir(inflatedOutput)
                                    mkdir(inflatedOutput)
                                end                        
                                leftHemiInflated = fullfile(inflatedOutput, [eyes{eye} '_left_inflated.png']);
                                rightHemiInflated = fullfile(inflatedOutput, [eyes{eye} '_right_inflated.png']);
                                system(['freeview --surface ' leftSurface ':curvature_method=binary:overlay=' leftHemiFile ':overlay_threshold=' thresholdV1 ' --cam Azimuth 180 --viewport 3d --colorscale --screenshot ' leftHemiInflated]);
                                system(['freeview --surface ' rightSurface ':curvature_method=binary:overlay=' rightHemiFile ':overlay_threshold=' thresholdV1 ' --viewport 3d --colorscale --screenshot ' rightHemiInflated]); 
                                % Erode the volume so we don't show the
                                % general area of the LGN and exclude other
                                % areas. Then save LGN image
                                erodedResample = fullfile(tempdir, 'eroded_resampled.nii.gz');
                                binaryForLGN = MRIread(erodedBinaryForLGN);
                                binaryForLGN = binaryForLGN.vol;
                                resampledImageLoaded.vol(find(binaryForLGN == 0)) = 0;
                                MRIwrite(resampledImageLoaded, erodedResample);
                                lgnOutput = fullfile(savePath, 'LGN');
                                if ~isdir(lgnOutput)
                                    mkdir(lgnOutput)
                                end                     
                                lgnVolume = fullfile(lgnOutput,  [eyes{eye} '_LGN.png']);
                                system(['freeview --volume ' invivoTemplate ':grayscale=70,310' ' --volume ' erodedResample ':colormap=heat:opacity=1:heatscale=' thresholdLGN ' --slice 154 124 43 --viewport y --colorscale --screenshot ' lgnVolume])
                            end
                        end
                    end
                end
            end
        end
    end
end
