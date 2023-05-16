function cornIrradianceWattsPerArea = calculateIrradiance(luminance, calibration, calibrationDate)

% Define wavelength spacing.  Use 1 nm spacing
% so that values per nm.
S = [380 1 401];

% Load BoxD calibration result
load(calibration)

% Get the raw SPD for the full-on background
whichCal = length(cals);
theRawSpd = SplineSpd(cals{whichCal}.describe.S,cals{whichCal}.raw.fullOn,S);

% Load CIE 1931 CMFs
%
% 683 is a magic constant that brings luminance into cd/m2
% when SPD is in Watts/sr-m2-nm
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);

% Desired lum and scale so that we have spectrum in
% of desired luminance in Watts/sr-m2-nm.
desiredLum = luminance;
theSpd = desiredLum*theRawSpd/(T_xyz(2,:)*theRawSpd);

% Compute effective luminous efficiency
theSpd_1 = theRawSpd/sum(theRawSpd);
theLuminance_1 = T_xyz(2,:)*theSpd_1;
fprintf('Luminous efficiency is %d Lumens/Watt\n',theLuminance_1);

% Stimulus size deg
theDegs = 30;
theDegs2 = pi*((theDegs/2)^2);

% Compute corneal irradiance
cornealIrradiance_PowerPerAreaNm = RadianceAndDegrees2ToCornIrradiance(theSpd,theDegs2);

% Total corneal irradiance
cornIrradianceWattsPerArea = sum(cornealIrradiance_PowerPerAreaNm);
fprintf('Corneal irradiance corresponding to %d deg diameter, %d cd/m2 Box D: %0.2g Watts/m2\n', ...
        theDegs,desiredLum,cornIrradianceWattsPerArea);
    
% Check by going the other way
checkRadiance = CornIrradianceAndDegrees2ToRadiance(cornealIrradiance_PowerPerAreaNm,theDegs2);
checkLum = T_xyz(2,:)*checkRadiance;
if (abs(desiredLum-checkLum) > 1e-5)
    error('Calculation does not invert as expected');
end
