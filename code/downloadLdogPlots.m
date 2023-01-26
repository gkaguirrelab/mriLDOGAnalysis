% Ldog processing path
saveFolder = '/home/ozzy/Desktop/plots';
if ~isdir(saveFolder)
    mkdir(saveFolder)
end
tempDir = '/home/ozzy/Desktop/tmp';
if ~isdir(tempDir)
    mkdir(tempDir)
end
pythonFuncSurf = '/home/ozzy/Desktop/plot_surface.py';
ldogSurfaceCalc = '/home/ozzy/Desktop/invivo2exvivo';
threshold = '0.1';
resampledTempPath = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/2x2x2resampled_invivoTemplate.nii.gz';

% Get Flywheel project 
fw = flywheel.Flywheel(getpref('flywheelMRSupport','flywheelAPIKey'));
project = fw.projects.findFirst('label=canineFovea');

% Get all subjects
subjectNames = [...
    'N344','N347','N349',...
    '2350','2346','2356',...
    'Z663','Z665','Z666', 'Z720', 'Z710', 'Z709', ...
    'EM529','EM543',...
    'WM65','WM67', ...
    'LA7', ...
    'EM404', 'EM533', 'EM532', 'EM499', 'EM501'];

subjects = project.subjects();
for sub = 1:length(subjects)
    if contains(subjectNames, subjects{sub}.label)
        if ~isdir(fullfile(saveFolder, subjects{sub}.label))
            mkdir(fullfile(saveFolder, subjects{sub}.label))
        end
        
        sessions = subjects{sub}.sessions();
        for ses = 1:length(sessions)
            if ~isdir(fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))
                mkdir(fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))
            end
            analyses = sessions{ses}.analyses();
            for aa = 1:length(analyses)
                if contains(analyses{aa}.label, 'forwardmodel')
                    analyses{aa}.label
                    if contains(analyses{aa}.label, 'photoFlicker') && ~contains(analyses{aa}.label, 'noPseudo') && ~contains(analyses{aa}.label, 'LGN') && ~contains(analyses{aa}.label, 'allV1') && ~contains(analyses{aa}.label, 'wholeBrain')
                        matrix = fullfile(tempDir, 'mtSinai_results.mat');
                        analyses{aa}.downloadFile([subjects{sub}.label '_mtSinai_results.mat'], matrix);
                        region = 'V1';
                        hemi = 'Pseudo';
                        sessionType = 'photoFlicker';
                        process_matrices(matrix, resampledTempPath, region, hemi, tempDir, pythonFuncSurf, ldogSurfaceCalc, threshold, sessionType, fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))
                        region = 'LGN';
                        process_matrices(matrix, resampledTempPath, region, hemi, tempDir, pythonFuncSurf, ldogSurfaceCalc, threshold, sessionType, fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))                        
                    elseif contains(analyses{aa}.label, 'photoFlicker') && contains(analyses{aa}.label, 'noPseudo') && ~contains(analyses{aa}.label, 'LGN') && ~contains(analyses{aa}.label, 'allV1') && ~contains(analyses{aa}.label, 'wholeBrain')
                        matrix = fullfile(tempDir, 'mtSinai_results.mat');
                        analyses{aa}.downloadFile([subjects{sub}.label '_mtSinai_results.mat'], matrix);
                        region = 'V1';
                        hemi = 'noPseudo';
                        sessionType = 'photoFlicker';        
                        process_matrices(matrix, resampledTempPath, region, hemi, tempDir, pythonFuncSurf, ldogSurfaceCalc, threshold, sessionType, fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))
                        region = 'LGN';
                        process_matrices(matrix, resampledTempPath, region, hemi, tempDir, pythonFuncSurf, ldogSurfaceCalc, threshold, sessionType, fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))                        
                    % Max FLicker
                    elseif contains(analyses{aa}.label, 'maxFlicker') && contains(analyses{aa}.label, 'NoPseudo') && ~contains(analyses{aa}.label, 'LGN') && ~contains(analyses{aa}.label, 'allV1') && ~contains(analyses{aa}.label, 'wholeBrain')
                        matrix = fullfile(tempDir, 'maxFlicker_results.mat');
                        analyses{aa}.downloadFile([subjects{sub}.label '_mtSinai_results.mat'], matrix);
                        sessionType = 'maxFlicker';
                        hemi = 'noPseudoHemi';                      
                        region = 'V1';
                        process_matrices(matrix, resampledTempPath, region, hemi, tempDir, pythonFuncSurf, ldogSurfaceCalc, threshold, sessionType, fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))
                        region = 'LGN';
                        process_matrices(matrix, resampledTempPath, region, hemi, tempDir, pythonFuncSurf, ldogSurfaceCalc, threshold, sessionType, fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))
                    elseif contains(analyses{aa}.label, 'maxFlicker') && ~contains(analyses{aa}.label, 'NoPseudo') && ~contains(analyses{aa}.label, 'LGN') && ~contains(analyses{aa}.label, 'allV1') && ~contains(analyses{aa}.label, 'wholeBrain')
                        matrix = fullfile(tempDir, 'maxFlicker_results.mat');
                        analyses{aa}.downloadFile([subjects{sub}.label '_mtSinai_results.mat'], matrix);
                        sessionType = 'maxFlicker';
                        hemi = 'pseudoHemi';                      
                        region = 'V1';
                        process_matrices(matrix, resampledTempPath, region, hemi, tempDir, pythonFuncSurf, ldogSurfaceCalc, threshold, sessionType, fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))
                        region = 'LGN';
                        process_matrices(matrix, resampledTempPath, region, hemi, tempDir, pythonFuncSurf, ldogSurfaceCalc, threshold, sessionType, fullfile(saveFolder, subjects{sub}.label, sessions{ses}.label))
                    end
                    
                             
                end
            end
        end
    end      
end

function process_matrices(matrix, resampledTempPath, region, hemi, tempDir, pythonFuncSurf, ldogSurfaceCalc, threshold, sessionType, outputPath)
    load(matrix, 'results')
    if strcmp(sessionType, 'photoFlicker')
        params = results.params;
%         rightEye = nanmean(params(:, [1,2,3,7,8,9,13,14,15]), 2);  These do not remove L-S
%         leftEye = nanmean(params(:, [4,5,6,10,11,12,16,17,18]), 2);
        rightEye = nanmean(params(:, [1,2,3,13,14,15]), 2);  
        leftEye = nanmean(params(:, [4,5,6,16,17,18]), 2);
    elseif strcmp(sessionType, 'maxFlicker')
        params = results.params;
        leftEye = nanmean(params(:, [1,2,3,4,5,6,7,8,9]), 2);
        rightEye = nanmean(params(:, [10,11,12,13,14,15,16,17,18]), 2);
    end
    dat = MRIread(resampledTempPath);
    dat.vol = reshape(rightEye, [53 53 54]);
    MRIwrite(dat, fullfile(tempDir, 'rightEye.nii.gz'))
    system(['python3 ' pythonFuncSurf ' ' [region '_' hemi '_' 'rightEye']  ' ' resampledTempPath ' ' fullfile(tempDir, 'rightEye.nii.gz') ' ' ldogSurfaceCalc ' ' threshold ' ' outputPath]);
    dat.vol = reshape(leftEye, [53 53 54]);
    MRIwrite(dat, fullfile(tempDir, 'leftEye.nii.gz'))
    system(['python3 ' pythonFuncSurf ' ' [region '_' hemi '_' 'leftEye']  ' ' resampledTempPath ' ' fullfile(tempDir, 'leftEye.nii.gz') ' ' ldogSurfaceCalc ' ' threshold ' ' outputPath]);
    
end