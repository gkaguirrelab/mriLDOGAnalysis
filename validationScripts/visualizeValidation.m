function summary = visualizeValidation(pathParams, varargin)
% Summarizes and plots the contents of a OneLight validation file
%
% Syntax:
%   summaryTable = visualizeValidation(pathParams, whatToPlot)
%
% Description:
%   Creates a table showing the luminance and contrast values of the
%   validations. SPD plots showing measured and predicted background and
%   mirror on/off conditions can also be created with this function.
%
% Inputs:
%   pathParams            - String. Path to the directionObject.mat or a 
%                           path params struct.
%
% Optional key/value pairs:
%  'whatToPlot'           - String. Plot SPD on demand. Options are
%                           .bgOnOff: compares background and mirror on and
%                           off. 
%                           .measuredVsPredictedBG: Compares measured
%                           and predicted background.
%                           .measuredVsPredictedPositiveArm: Compares
%                           measured and predicred mirrors on cond.
%                           .measuredVsPredictedNegativeArm: Compares
%                           measured and predicted mirrors off cond. 
%                           .noSPD: Does not plot SPDs (Default)
%
%  'savePath'             - String. Save the figures and tables to
%                           this location. If 'NA', do not save. Default:
%                           'NA'
%
% Outputs:
%   summary               - Structure. A structure with fields for each
%                           modulation direction. Each sub-field then
%                           contains information regarding the luminance of
%                           the modulation background, and contast upon
%                           targeted and silenced photoreceptors.
%


% Parse input
p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('pathParams');

% Optional params
p.addParameter('whatToPlot', 'noSPD', @isstr);
p.addParameter('savePath', 'NA', @isstr);

% parse
p.parse(pathParams, varargin{:})

% Load the directionObject if pathParams is specified, construct the paths
if isstruct(pathParams)
    % set common path params
    dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');
    pathParams.dataSourceDirRoot = fullfile(dropboxBaseDir,'LDOG_data');
    pathParams.dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');
    
    % Input path
    inputBaseDir = fullfile(pathParams.dataSourceDirRoot, ...
        'Experiments',...
        pathParams.Approach,...
        pathParams.Protocol,...
        'DirectionObjects',...
        pathParams.Subject,...
        pathParams.Session,...
        pathParams.Date,...
        'directionObject.mat');
    
    % Output path
    outputBaseDir = fullfile(pathParams.dataOutputDirRoot, ...
        'Experiments',...
        pathParams.Approach,...
        pathParams.Protocol,...
        'ValidationSummary',...
        pathParams.Subject,...
        pathParams.Date,...
        pathParams.Session);
    
    % If the outputBaseDir does not exist, make it
    if ~exist(outputBaseDir)
        mkdir(outputBaseDir)
    end
    
    % load the input and create the final save path variable
    load(inputBaseDir)
    if strcmp(p.Results.savePath, 'NA')
        saveHere = outputBaseDir;
    else
        saveHere = p.Results.savePath;
    end
    
else
    % This is used if direct paths are specified instead of pathParams
    load(pathParams)
    saveHere = p.Results.savePath;
end

% Putting all values in a table for better indexing
AllDirections = [];

% Check if we are dealing with the maxFlash protocol which includes a var
% named modDirection
if exist('modDirection','var')
    AllDirections.modDirection = modDirection;
else
    AllDirections.LightFluxDirection = LightFluxDirection;
    AllDirections.LminusSDirection = LminusSDirection;
    AllDirections.LplusSDirection = LplusSDirection;
    AllDirections.RodMelDirection = RodMelDirection;
    
    % Get the labels
    fn = fieldnames(AllDirections)';
    fieldlength = length(fn);
    
    % Initialize figures the figures
    if ~strcmp(p.Results.whatToPlot, 'noSPD')
        prevalfig = figure;
        postvalfig = figure;
    elseif strcmp(p.Results.whatToPlot, 'noSPD')
        fprintf('Not plotting any SPDs')
    else
        error("Unknown plotting method passed")
    end
    
    % Initialize the summary struct, and save metadata.
    summary = [];
    summary.meta = p.Results;
    
    % Loop through directions and save the validation summary for each
    % condition
    for ii = 1:fieldlength
        
        % Get the number of validations
        validationNum = size(LightFluxDirection.describe.validation,2);

        % Get the pre and post val cells
        precellGotValidation = {AllDirections.(fn{1,ii}).describe.validation(1:(validationNum/2)).luminanceActual};
        postcellGotValidation = {AllDirections.(fn{1,ii}).describe.validation((validationNum/2+1):validationNum).luminanceActual};

        % Get the same thing for the contrasts if not maxFlash
        if ~exist('modDirection','var')
            precellGotContrast = {AllDirections.(fn{1,ii}).describe.validation(1:(validationNum/2)).contrastActual};
            postcellGotContrast = {AllDirections.(fn{1,ii}).describe.validation((validationNum/2+1):validationNum).contrastActual};
            precellDesiredContrast = {AllDirections.(fn{1,ii}).describe.validation(1:(validationNum/2)).contrastDesired};
            postcellDesiredContrast = {AllDirections.(fn{1,ii}).describe.validation((validationNum/2+1):validationNum).contrastDesired};
        end

        % Create luminance table values and the luminance table
        Vals = ["medianLuminance"]; 
        PreValidation = [median(cellfun(@(v)v(1),precellGotValidation))];
        PostValidation = [median(cellfun(@(v)v(1),postcellGotValidation))];        
        baseNameVals = "Luminance";
        for v = 1:validationNum
            nameToAddToType = strcat('Validation_', num2str(v), '_', baseNameVals);
            Vals = [Vals; nameToAddToType];
            if v <= 5
                PreValidation = [PreValidation; AllDirections.(fn{1,ii}).describe.validation(v).luminanceActual(1)];
            else 
                PreValidation = [PreValidation; 0];
            end
            
            if v >= 6
                PostValidation = [PostValidation; AllDirections.(fn{1,ii}).describe.validation(v).luminanceActual(1)];
            else
                PostValidation = [PostValidation; 0];
            end
        end    
        summary.(fn{1,ii}).BackgroundLuminanceSummary = table(Vals, PreValidation, PostValidation);
        % Create contrast table values and the contrast table
        photoReceptor = [strcat('PosArm_', convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{1}));...
            strcat('NegArm_', convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{1}));...
            strcat('PosArm_', convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{2}));...
            strcat('NegArm_', convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{2}));...
            strcat('PosArm_', convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{3}));...
            strcat('NegArm_', convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{3}));...
            strcat('PosArm_', convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{4}));...
            strcat('NegArm_', convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{4}))];
        contrastPreVal_actual_vs_desired = [median(cellfun(@(v)v(1,1),precellGotContrast)) median(cellfun(@(v)v(1,1),precellDesiredContrast));...
            median(cellfun(@(v)v(1,2),precellGotContrast)) median(cellfun(@(v)v(1,2),precellDesiredContrast));...
            median(cellfun(@(v)v(2,1),precellGotContrast)) median(cellfun(@(v)v(2,1),precellDesiredContrast));...
            median(cellfun(@(v)v(2,2),precellGotContrast)) median(cellfun(@(v)v(2,2),precellDesiredContrast));...
            median(cellfun(@(v)v(3,1),precellGotContrast)) median(cellfun(@(v)v(3,1),precellDesiredContrast));...
            median(cellfun(@(v)v(3,2),precellGotContrast)) median(cellfun(@(v)v(3,2),precellDesiredContrast));...
            median(cellfun(@(v)v(4,1),precellGotContrast)) median(cellfun(@(v)v(4,1),precellDesiredContrast));...
            median(cellfun(@(v)v(4,2),precellGotContrast)) median(cellfun(@(v)v(4,2),precellDesiredContrast))];
        contrastPostVal_actual_vs_desired = [median(cellfun(@(v)v(1,1),postcellGotContrast)) median(cellfun(@(v)v(1,1),postcellDesiredContrast));...
            median(cellfun(@(v)v(1,2),postcellGotContrast)) median(cellfun(@(v)v(1,2),postcellDesiredContrast));...
            median(cellfun(@(v)v(2,1),postcellGotContrast)) median(cellfun(@(v)v(2,1),postcellDesiredContrast));...
            median(cellfun(@(v)v(2,2),postcellGotContrast)) median(cellfun(@(v)v(2,2),postcellDesiredContrast));...
            median(cellfun(@(v)v(3,1),postcellGotContrast)) median(cellfun(@(v)v(3,1),postcellDesiredContrast));...
            median(cellfun(@(v)v(3,2),postcellGotContrast)) median(cellfun(@(v)v(3,2),postcellDesiredContrast));...
            median(cellfun(@(v)v(4,1),postcellGotContrast)) median(cellfun(@(v)v(4,1),postcellDesiredContrast));...
            median(cellfun(@(v)v(4,2),postcellGotContrast)) median(cellfun(@(v)v(4,2),postcellDesiredContrast))];
        summary.(fn{1,ii}).contrastSummaryTable = table(photoReceptor, contrastPreVal_actual_vs_desired, contrastPostVal_actual_vs_desired);

        % Mesured Background SPD values
        valBackgroundSPDAll = [AllDirections.(fn{1,ii}).describe.validation.SPDbackground];
        preValBackgroundSPDMeasuredAveraged = (valBackgroundSPDAll(1).measuredSPD + valBackgroundSPDAll(2).measuredSPD +valBackgroundSPDAll(3).measuredSPD +valBackgroundSPDAll(4).measuredSPD +valBackgroundSPDAll(5).measuredSPD) / 5;
        postValBackgroundSPDMeasuredAveraged = (valBackgroundSPDAll(6).measuredSPD + valBackgroundSPDAll(7).measuredSPD +valBackgroundSPDAll(8).measuredSPD +valBackgroundSPDAll(9).measuredSPD +valBackgroundSPDAll(10).measuredSPD) / 5;
        
        % Predicted Background SPD values
        preValBackgroundSPDPredictedAveraged = (valBackgroundSPDAll(1).predictedSPD + valBackgroundSPDAll(2).predictedSPD +valBackgroundSPDAll(3).predictedSPD +valBackgroundSPDAll(4).predictedSPD +valBackgroundSPDAll(5).measuredSPD) / 5;
        postValBackgroundSPDPredictedAveraged = (valBackgroundSPDAll(6).predictedSPD + valBackgroundSPDAll(7).predictedSPD +valBackgroundSPDAll(8).predictedSPD +valBackgroundSPDAll(9).predictedSPD +valBackgroundSPDAll(10).measuredSPD) / 5;
        
        % Mesured Mirror on/off SPD conditions
        valArmSPDAll = [AllDirections.(fn{1,ii}).describe.validation.SPDcombined];
        preValPositiveArmSPDMeasuredAveraged = (valArmSPDAll(1).measuredSPD + valArmSPDAll(3).measuredSPD +valArmSPDAll(5).measuredSPD +valArmSPDAll(7).measuredSPD +valArmSPDAll(9).measuredSPD) / 5;
        postValPositiveArmSPDMeasuredAveraged = (valArmSPDAll(11).measuredSPD + valArmSPDAll(13).measuredSPD +valArmSPDAll(15).measuredSPD +valArmSPDAll(17).measuredSPD +valArmSPDAll(19).measuredSPD) / 5;
        preValNegativeArmSPDMeasuredAveraged = (valArmSPDAll(2).measuredSPD + valArmSPDAll(4).measuredSPD +valArmSPDAll(6).measuredSPD +valArmSPDAll(8).measuredSPD +valArmSPDAll(10).measuredSPD) / 5;
        postValNegativeArmSPDMeasuredAveraged = (valArmSPDAll(12).measuredSPD + valArmSPDAll(14).measuredSPD +valArmSPDAll(16).measuredSPD +valArmSPDAll(18).measuredSPD +valArmSPDAll(20).measuredSPD) / 5;
        
        % Predicted Mirror on/off SPD conditions
        preValPositiveArmSPDPredictedAveraged = (valArmSPDAll(1).predictedSPD + valArmSPDAll(3).predictedSPD +valArmSPDAll(5).predictedSPD +valArmSPDAll(7).predictedSPD +valArmSPDAll(9).predictedSPD) / 5;
        postValPositiveArmSPDPredictedAveraged = (valArmSPDAll(11).predictedSPD + valArmSPDAll(13).predictedSPD +valArmSPDAll(15).predictedSPD +valArmSPDAll(17).predictedSPD +valArmSPDAll(19).predictedSPD) / 5;
        preValNegativeArmSPDPredictedAveraged = (valArmSPDAll(2).predictedSPD + valArmSPDAll(4).predictedSPD +valArmSPDAll(6).predictedSPD +valArmSPDAll(8).predictedSPD +valArmSPDAll(10).predictedSPD) / 5;
        postValNegativeArmSPDPredictedAveraged = (valArmSPDAll(12).predictedSPD + valArmSPDAll(14).predictedSPD +valArmSPDAll(16).predictedSPD +valArmSPDAll(18).predictedSPD +valArmSPDAll(20).predictedSPD) / 5;
        
        % Get the wavelengths;
        wavelengths = AllDirections.(fn{1,ii}).calibration.describe.S(1):AllDirections.(fn{1,ii}).calibration.describe.S(2): AllDirections.(fn{1,ii}).calibration.describe.S(1) + AllDirections.(fn{1,ii}).calibration.describe.S(2)*AllDirections.(fn{1,ii}).calibration.describe.S(3) - AllDirections.(fn{1,ii}).calibration.describe.S(2);
        
        % Find the maximum value in all SPDs to set the max X value
        allvals = [preValBackgroundSPDMeasuredAveraged postValBackgroundSPDMeasuredAveraged preValBackgroundSPDPredictedAveraged postValBackgroundSPDPredictedAveraged preValPositiveArmSPDMeasuredAveraged postValPositiveArmSPDMeasuredAveraged preValNegativeArmSPDMeasuredAveraged postValNegativeArmSPDMeasuredAveraged preValPositiveArmSPDPredictedAveraged postValPositiveArmSPDPredictedAveraged preValNegativeArmSPDPredictedAveraged postValNegativeArmSPDPredictedAveraged];
        maximum = max(max(allvals));
        
        % Plot stuff for each direction
        if strcmp(p.Results.whatToPlot, 'bgOnOff')
            set(0,'CurrentFigure',prevalfig)
            subplot(2,2,ii);
            suptitle('Pre-validation Measured BG/on/off')
            hold on;
            plot(wavelengths, preValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, preValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, preValNegativeArmSPDMeasuredAveraged);
            legend('BG', 'AllOn', 'AllOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            ylim([0 maximum])
            title(fn{1,ii})
            
            % visualize SPDs;
            set(0,'CurrentFigure',postvalfig)
            subplot(2,2,ii);
            suptitle('Post-validation Measured BG/on/off')
            hold on;
            plot(wavelengths, postValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, postValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, postValNegativeArmSPDMeasuredAveraged);
            legend('BG', 'AllOn', 'AllOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            ylim([0 maximum])            
            title(fn{1,ii})
        elseif strcmp(p.Results.whatToPlot, 'measuredVsPredictedBG')
            set(0,'CurrentFigure',prevalfig)
            subplot(2,2,ii);
            suptitle('Pre-validation MesuredVsPredicted BG')
            hold on;
            plot(wavelengths, preValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, preValBackgroundSPDPredictedAveraged);
            legend('MeasuredBG', 'PredictedBG', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            ylim([0 maximum])            
            title(fn{1,ii})
            
            set(0,'CurrentFigure',postvalfig)
            subplot(2,2,ii);
            suptitle('Post-validation MesuredVsPredicted BG')
            hold on;
            plot(wavelengths, postValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, postValBackgroundSPDPredictedAveraged);
            legend('MeasuredBG', 'PredictedBG', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            ylim([0 maximum])            
            title(fn{1,ii})
        elseif strcmp(p.Results.whatToPlot, 'measuredVsPredictedPositiveArm')
            set(0,'CurrentFigure',prevalfig)
            subplot(2,2,ii);
            suptitle('Pre-validation MesuredVsPredicted Positive Arm')
            hold on;
            plot(wavelengths, preValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, preValPositiveArmSPDPredictedAveraged);
            legend('MeasuredOn', 'PredictedOn', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            ylim([0 maximum])            
            title(fn{1,ii})
            
            set(0,'CurrentFigure',postvalfig)
            subplot(2,2,ii);
            suptitle('Post-validation MesuredVsPredicted PositiveArm')
            hold on;
            plot(wavelengths, postValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, postValPositiveArmSPDPredictedAveraged);
            legend('MeasuredOn', 'PredictedOn', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            ylim([0 maximum])            
            title(fn{1,ii})
        elseif strcmp(p.Results.whatToPlot, 'measuredVsPredictedNegativeArm')
            set(0,'CurrentFigure',prevalfig)
            subplot(2,2,ii);
            suptitle('Pre-validation MesuredVsPredicted Negative Arm')
            hold on;
            plot(wavelengths, preValNegativeArmSPDMeasuredAveraged);
            plot(wavelengths, preValNegativeArmSPDPredictedAveraged);
            legend('MeasuredOff', 'PredictedOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            ylim([0 maximum])            
            title(fn{1,ii})
            
            set(0,'CurrentFigure',postvalfig)
            subplot(2,2,ii);
            suptitle('Post-validation MesuredVsPredicted Negative Arm')
            hold on;
            plot(wavelengths, postValNegativeArmSPDMeasuredAveraged);
            plot(wavelengths, postValNegativeArmSPDPredictedAveraged);
            legend('MeasuredOff', 'PredictedOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            ylim([0 maximum])            
            title(fn{1,ii})
        end
        
        % Save some stuff if a path is specified
        if ~strcmp(p.Results.whatToPlot, 'noSPD') && ~strcmp(saveHere, 'NA')
            savefig(prevalfig, fullfile(saveHere, strcat(p.Results.whatToPlot, 'preVal', '.fig')))
            savefig(postvalfig, fullfile(saveHere, strcat(p.Results.whatToPlot, 'postVal', '.fig')))
        end    
        
        if ~strcmp(saveHere, 'NA')
            save(fullfile(saveHere, 'summaryTable.mat'), 'summary')
        end
    end
end