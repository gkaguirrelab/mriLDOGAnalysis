function correctedFuncPath = regressMotion(epiPath, motionParamsPath, outputFolder, varargin)
% Pre-process the ldog func data to regress out the effects of motion
%
% Syntax:
%  correctedFuncPath = regressMotion(funcZipPath, motionParamsPath)
%
% Description
%   Loads a volumetric, 4D fMRI dataset and the motion parameter vectors
%   generated by the XXX routine. These vectors are treated as a regression
%   matrix and the effect of motion is removed from the data (preserving
%   signal mean). The motion-cleaned data is written back to disk.
%
%   Requires the Freesurfer MATLAB library to handle read/write operations.
%
% Inputs:
%   epiPath               - String. Path to .nii file that contains the
%                           fMRI data to be analyzed. This is the unzipped
%                           output of the ldogFunc.
%   motionParamsPath      - String. Path to a .txt file that contains the
%                           motion covariates.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   correctedFuncPath     - String. Full path to the uncompressed
%                           functional MRI data file that has undergone
%                           regression to remove the effects of motion.
%
% Examples:
%{
    epiPath = 'N292_N292_final_preprocessed_N292_N292_corrected_1.3.12.2.1107.5.2.32.35335.201912051319034549056903.0.0.0.nii';
    motionParamsPath = 'N292_N292_motion_params.txt';
    stimFile = 'lightFluxFlicker_1x112_On=0.mat';
    correctedFuncPath = regressMotion(epiPath, motionParamsPath,'','stimFile',stimFile);
%}

%% Parse inputs
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('epiPath',@isstr);
p.addRequired('motionParamsPath',@isstr);
p.addRequired('outputFolder',@isstr);

% Optional
p.addParameter('convertToPercentChangeSignal', "false",@isstr)
p.addParameter('stimFile', "Na" ,@isstr)

% Parse
p.parse(epiPath, motionParamsPath, outputFolder, varargin{:})

% Extract the file name and extension from the full path 
[~,name,ext] = fileparts(epiPath);
acqusitionName = strcat(name, ext);

% Load the data
thisAcqData = MRIread(epiPath);

% Get the original shape of the data for later reshaping
originalShape = size(thisAcqData.vol);

% Reshape into a matrix
data = thisAcqData.vol;
data = single(data);
data = reshape(data, [size(data,1)*size(data,2)*size(data,3), size(data,4)]);
data(isnan(data)) = 0;

% Load and format the motion covariates
X = readmatrix(motionParamsPath);

% Check that the motion covariates and data match
if size(X,1) ~= size(data,2)
    error('regressMotion:mismatchRegressors','The data and motion parameters have different temporal lengths');
end

% If a stimulusVector has been supplied, load this and partial this effect
% out of the X matrix
if ~strcmp(p.Results.stimFile,'Na')
    % Load the stimulus
    load(p.Results.stimFile,'stimulus');
    % We want a vector, not a cell
    if iscell(stimulus)
        stimulus = stimulus{1};
    end
    % Check that we were passed a vector
    if size(stimulus,1) ~= 1
        error('regressMotion:multiDimensionalStimulus','The stimulus must be a one dimensional vector');
    end
    % Check that the stiumulus matches the data
    if size(data,2) ~= length(stimulus)
        error('regressMotion:mismatchStimulus','The data and the stimulus vector have different temporal lengths');
    end
    % Prepare the stimulus vector for regression
    stimulus = (stimulus - mean(stimulus))';
    % Regress the stimulus out of each element of the X matrix
    for ii = 1:size(X,2)
        b=stimulus\X(:,ii);
        X(:,ii) = X(:,ii) - b*stimulus;
    end
end

% Store the warning state
warningState = warning;

% Silence warnings.
warning('off','MATLAB:rankDeficientMatrix');

% Loop through the voxels and regress out the motion component
for vv = 1:size(data,1)
    datats = data(vv,:)';
    if all(datats==0)
        continue
    end
    meants = mean(datats);
    beta = X\datats;
    cleants = datats - X*beta + meants;

    % If asked to do so, convert the data to % change units
    if strcmp(p.Results.convertToPercentChangeSignal,"true")
        cleants = 100.* ((cleants - meants)./meants)+100;
    end
    
    % Store the cleaned vector
    data(vv,:) = cleants';
    
end

% Restore the warning state.
warning(warningState);

% Put the cleaned data back into the acquisition and reshape to 4D
thisAcqData.vol = data;
thisAcqData.vol = reshape(thisAcqData.vol, originalShape);

% Set the save name
newName = strrep(acqusitionName, '_preprocessed_','_preprocessedMoReg_');

% Save the motion corrected fMRI data
correctedFuncPath = fullfile(outputFolder,newName);
MRIwrite(thisAcqData,correctedFuncPath);

end % Main function
