function initializeAudapter (genderSubject)
%% Initialize Audapter
addpath c:/speechres/commonmcode;
cds('audapter_matlab');
audioInterfaceName = 'ASIO4ALL';%'MOTU MicroBook';%

sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3;
frameLen = 96;  % Before downsampling
noiseWavFN = 'mtbabble48k.wav';
Audapter('deviceName', audioInterfaceName);
Audapter('setParam', 'downFact', downFact, 0);
Audapter('setParam', 'sRate', sRate / downFact, 0);
Audapter('setParam', 'frameLen', frameLen / downFact, 0);

bVis = 0;
bVisFmts = 0;
bVisOST = 0;
visName = '';
Audapter('ost', '', 0);
Audapter('pcf', '', 0);

% I may need change this line and replace it with a new version of my own
% function that is taking into account individual-based basline formants
params = getAudapterDefaultParams(lower(genderSubject));

params.f1Min = 0;
params.f2Max = 5000;
params.f2Min = 0;
params.f2Max = 5000;
params.pertF2 = linspace(0, 5000, 257);
params.pertAmp = 0.0 * ones(1, 257);
params.pertPhi = 0.0 * pi * ones(1, 257);
params.bTrack = 1;
params.bShift = 1;
params.bRatioShift = 1;
params.bMelShift = 0;
maxPBSize = Audapter('getMaxPBLen');
check_file(noiseWavFN);
[w, fs] = audioread(noiseWavFN);
if fs ~= params.sr * params.downFact
    w = resample(w, params.sr * params.downFact, fs);
end
if length(w) > maxPBSize
    w = w(1 : maxPBSize);
end
Audapter('setParam', 'datapb', w, 1);
params.fb3Gain = 0.1;
params.fb = 1;
params.pertAmp = 0.0 * ones(1, 257);
params.pertPhi = 0.0 * pi * ones(1, 257);
params.fb = 1;
AudapterIO('init', params);

