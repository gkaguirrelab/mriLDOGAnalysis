function summary = ldogVisulizeValidation(pathToLDOGDirectionObject, validationNumber, whatToPlot)

%%%%% 
% pathToLDOGDirectionObject = str, path to the directionObject mat file
% validationNumber = num or str, Either use a number for individual vals or 'median'
% whatToPlot = str, Decides what to plot. The options are below: 
  % bgOnOff-compares background/mirrorOn/mirrorOff creates pre and post val
  % measuredVsPredictedBG - measured vs predicted background. Pre and post
  % measuredVsPredictedMirrorsOn - measured vs predicted On. Pre and post
  % measuredVsPredictedMirrorsOff - measured vs predicted Off. Pre and post


load(pathToLDOGDirectionObject)

% Get all values in a cell for better indexing and get the labels 
AllDirections = [];
AllDirections.LightFluxDirection = LightFluxDirection;
AllDirections.LminusSDirection = LminusSDirection;
AllDirections.LplusSDirection = LplusSDirection;
AllDirections.RodMelDirection = RodMelDirection;
fn = fieldnames(AllDirections)';
fieldlength = length(fn);

%Loop through directions and save the validation summary for each
%condition
summary = [];
if strcmp(whatToPlot, 'bgOnOff')
    prefigureBgOnOff = figure;
    postfigureBgOnOff = figure;
elseif strcmp(whatToPlot, 'measuredVsPredictedBG')
    prefigureMeasuredVsPredictedBG = figure;   
    postfigureMeasuredVsPredictedBG = figure;    
elseif strcmp(whatToPlot, 'measuredVsPredictedMirrorsOn')
    prefigureMeasuredVsPredictedOn = figure;
    postfigureMeasuredVsPredictedOn = figure;
elseif strcmp(whatToPlot, 'measuredVsPredictedMirrorsOff')
    prefigureMeasuredVsPredictedOff = figure;
    postfigureMeasuredVsPredictedOff = figure;    
end
for ii = 1:fieldlength
    if isnumeric(validationNumber)
        % Specify table values
        Type = ["BackgroundLuminance";"PositiveArmLuminance";"NegativeArmLuminance";"BackgroundMinusPositiveArmLuminance";"BackgroundMinusNegativeArmLuminance"];
        Value = [AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceActual(1) AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceDesired(1);...
            AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceActual(2) AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceDesired(2);...
            AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceActual(3) AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceDesired(3);...
            AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceActual(4) AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceDesired(4);...
            AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceActual(5) AllDirections.(fn{1,ii}).describe.validation(validationNumber).luminanceDesired(5)];  
        % Create a table
        summary.(fn{1,ii}).summaryTable = table(Type, Value);
        
    elseif strcmp(validationNumber, 'median')
        % Get the pre and post val cells 
        precellGot = {AllDirections.(fn{1,ii}).describe.validation(1:5).luminanceActual};
        postcellGot = {AllDirections.(fn{1,ii}).describe.validation(6:10).luminanceActual};
        precellDesired = {AllDirections.(fn{1,ii}).describe.validation(1:5).luminanceDesired};
        postcellDesired = {AllDirections.(fn{1,ii}).describe.validation(6:10).luminanceDesired};   
        % Create table values and the table
        Type = ["medianBackgroundLuminance";"medianPositiveArmLuminance";"medianNegativeArmLuminance";"medianBackgroundMinusPositiveArmLuminance";"medianBackgroundMinusNegativeArmLuminance"];
        PreValidation = [median(cellfun(@(v)v(1),precellGot)) median(cellfun(@(v)v(1),precellDesired));median(cellfun(@(v)v(2),precellGot)) median(cellfun(@(v)v(2),precellDesired));median(cellfun(@(v)v(3),precellGot)) median(cellfun(@(v)v(3),precellDesired));median(cellfun(@(v)v(4),precellGot)) median(cellfun(@(v)v(4),precellDesired));median(cellfun(@(v)v(5),precellGot)) median(cellfun(@(v)v(5),precellDesired))];
        PostValidation = [median(cellfun(@(v)v(1),postcellGot)) median(cellfun(@(v)v(1),postcellDesired));median(cellfun(@(v)v(2),postcellGot)) median(cellfun(@(v)v(2),postcellDesired));median(cellfun(@(v)v(3),postcellGot)) median(cellfun(@(v)v(3),postcellDesired));median(cellfun(@(v)v(4),postcellGot)) median(cellfun(@(v)v(4),postcellDesired));median(cellfun(@(v)v(5),postcellGot)) median(cellfun(@(v)v(5),postcellDesired))];
        summary.(fn{1,ii}).summaryTable = table(Type, PreValidation, PostValidation);
    end
   
        % Mesured Backgrounds
        valBackgroundSPDAll = [AllDirections.(fn{1,ii}).describe.validation.SPDbackground];
        preValBackgroundSPDMeasuredAveraged = (valBackgroundSPDAll(1).measuredSPD + valBackgroundSPDAll(2).measuredSPD +valBackgroundSPDAll(3).measuredSPD +valBackgroundSPDAll(4).measuredSPD +valBackgroundSPDAll(5).measuredSPD) / 5;
        postValBackgroundSPDMeasuredAveraged = (valBackgroundSPDAll(6).measuredSPD + valBackgroundSPDAll(7).measuredSPD +valBackgroundSPDAll(8).measuredSPD +valBackgroundSPDAll(9).measuredSPD +valBackgroundSPDAll(10).measuredSPD) / 5;

        % Predicted Backgrounds 
        preValBackgroundSPDPredictedAveraged = (valBackgroundSPDAll(1).predictedSPD + valBackgroundSPDAll(2).predictedSPD +valBackgroundSPDAll(3).predictedSPD +valBackgroundSPDAll(4).predictedSPD +valBackgroundSPDAll(5).measuredSPD) / 5;
        postValBackgroundSPDPredictedAveraged = (valBackgroundSPDAll(6).predictedSPD + valBackgroundSPDAll(7).predictedSPD +valBackgroundSPDAll(8).predictedSPD +valBackgroundSPDAll(9).predictedSPD +valBackgroundSPDAll(10).measuredSPD) / 5;
        
        % Mesured Mirror on/off conditions
        valArmSPDAll = [AllDirections.(fn{1,ii}).describe.validation.SPDcombined];
        preValPositiveArmSPDMeasuredAveraged = (valArmSPDAll(1).measuredSPD + valArmSPDAll(3).measuredSPD +valArmSPDAll(5).measuredSPD +valArmSPDAll(7).measuredSPD +valArmSPDAll(9).measuredSPD) / 5;
        postValPositiveArmSPDMeasuredAveraged = (valArmSPDAll(11).measuredSPD + valArmSPDAll(13).measuredSPD +valArmSPDAll(15).measuredSPD +valArmSPDAll(17).measuredSPD +valArmSPDAll(19).measuredSPD) / 5;
        preValNegativeArmSPDMeasuredAveraged = (valArmSPDAll(2).measuredSPD + valArmSPDAll(4).measuredSPD +valArmSPDAll(6).measuredSPD +valArmSPDAll(8).measuredSPD +valArmSPDAll(10).measuredSPD) / 5;
        postValNegativeArmSPDMeasuredAveraged = (valArmSPDAll(12).measuredSPD + valArmSPDAll(14).measuredSPD +valArmSPDAll(16).measuredSPD +valArmSPDAll(18).measuredSPD +valArmSPDAll(20).measuredSPD) / 5;

        % Predicted Mirror on/off conditions
        preValPositiveArmSPDPredictedAveraged = (valArmSPDAll(1).predictedSPD + valArmSPDAll(3).predictedSPD +valArmSPDAll(5).predictedSPD +valArmSPDAll(7).predictedSPD +valArmSPDAll(9).predictedSPD) / 5;
        postValPositiveArmSPDPredictedAveraged = (valArmSPDAll(11).predictedSPD + valArmSPDAll(13).predictedSPD +valArmSPDAll(15).predictedSPD +valArmSPDAll(17).predictedSPD +valArmSPDAll(19).predictedSPD) / 5;
        preValNegativeArmSPDPredictedAveraged = (valArmSPDAll(2).predictedSPD + valArmSPDAll(4).predictedSPD +valArmSPDAll(6).predictedSPD +valArmSPDAll(8).predictedSPD +valArmSPDAll(10).predictedSPD) / 5;
        postValNegativeArmSPDPredictedAveraged = (valArmSPDAll(12).predictedSPD + valArmSPDAll(14).predictedSPD +valArmSPDAll(16).predictedSPD +valArmSPDAll(18).predictedSPD +valArmSPDAll(20).predictedSPD) / 5;
        
        % visualize SPDs;
        wavelengths = AllDirections.(fn{1,ii}).calibration.describe.S(1):AllDirections.(fn{1,ii}).calibration.describe.S(2): AllDirections.(fn{1,ii}).calibration.describe.S(1) + AllDirections.(fn{1,ii}).calibration.describe.S(2)*AllDirections.(fn{1,ii}).calibration.describe.S(3) - AllDirections.(fn{1,ii}).calibration.describe.S(2);

        if strcmp(whatToPlot, 'bgOnOff')
            set(0,'CurrentFigure',prefigureBgOnOff)
            subplot(2,2,ii);
            suptitle('Pre-validation BG/on/off')
            hold on;
            plot(wavelengths, preValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, preValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, preValNegativeArmSPDMeasuredAveraged);
            legend('BG', 'AllOn', 'AllOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})   

            % visualize SPDs;
            set(0,'CurrentFigure',postfigureBgOnOff)
            subplot(2,2,ii);
            suptitle('Post-validation BG/on/off')
            hold on;
            plot(wavelengths, postValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, postValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, postValNegativeArmSPDMeasuredAveraged);
            legend('BG', 'AllOn', 'AllOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})  
        elseif strcmp(whatToPlot, 'measuredVsPredictedBG')
            set(0,'CurrentFigure',prefigureMeasuredVsPredictedBG)
            subplot(2,2,ii);
            suptitle('Pre-validation MesuredVsPredicted BG')
            hold on;
            plot(wavelengths, preValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, preValBackgroundSPDPredictedAveraged);
            legend('MeasuredBG', 'PredictedBG', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})             

            set(0,'CurrentFigure',postfigureMeasuredVsPredictedBG)
            subplot(2,2,ii);
            suptitle('Post-validation MesuredVsPredicted BG')
            hold on;
            plot(wavelengths, postValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, postValBackgroundSPDPredictedAveraged);
            legend('MeasuredBG', 'PredictedBG', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})           
        elseif strcmp(whatToPlot, 'measuredVsPredictedMirrorsOn')
            set(0,'CurrentFigure',prefigureMeasuredVsPredictedOn)
            subplot(2,2,ii);
            suptitle('Pre-validation MesuredVsPredicted Mirrors On')
            hold on;
            plot(wavelengths, preValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, preValPositiveArmSPDPredictedAveraged);
            legend('MeasuredOn', 'PredictedOn', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})               
 
            set(0,'CurrentFigure',postfigureMeasuredVsPredictedOn)
            subplot(2,2,ii);
            suptitle('Post-validation MesuredVsPredicted MirrorsOn')
            hold on;
            plot(wavelengths, postValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, postValPositiveArmSPDPredictedAveraged);
            legend('MeasuredOn', 'PredictedOn', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})   
        elseif strcmp(whatToPlot, 'measuredVsPredictedMirrorsOff')
            set(0,'CurrentFigure',prefigureMeasuredVsPredictedOff)
            subplot(2,2,ii);
            suptitle('Pre-validation MesuredVsPredicted Mirrors Off')
            hold on;
            plot(wavelengths, preValNegativeArmSPDMeasuredAveraged);
            plot(wavelengths, preValNegativeArmSPDPredictedAveraged);
            legend('MeasuredOff', 'PredictedOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})               
 
            set(0,'CurrentFigure',postfigureMeasuredVsPredictedOff)
            subplot(2,2,ii);
            suptitle('Post-validation MesuredVsPredicted MirrorsOff')
            hold on;
            plot(wavelengths, postValNegativeArmSPDMeasuredAveraged);
            plot(wavelengths, postValNegativeArmSPDPredictedAveraged);
            legend('MeasuredOff', 'PredictedOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})              
        end
        
end
end