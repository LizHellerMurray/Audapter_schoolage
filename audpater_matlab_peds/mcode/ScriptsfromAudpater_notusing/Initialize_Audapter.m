function Initialize_Audapter

addpath c:/speechres/commonmcode;
cds('audapter_matlab');
which Audapter;
Audapter info;

audioInterfaceName = 'ASIO4ALL v2';%'MOTU Audio ASIO';% 'MOTU MicroBook';

sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3;
frameLen = 96;  % Before downsampling

defaultGender = 'female';

%% Visualization configuration
gray = [0.5, 0.5, 0.5];
ostMult = 250;
legendFontSize = 8;

noiseWavFN = 'mtbabble48k.wav';

%%
Audapter('deviceName', audioInterfaceName);
Audapter('setParam', 'downFact', downFact, 0);
Audapter('setParam', 'sRate', sRate / downFact, 0);
Audapter('setParam', 'frameLen', frameLen / downFact, 0);


