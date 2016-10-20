function data = PitchShift_Preparation(Pert,Delay,b)
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

bVis = 0;
bVisFmts = 0;
bVisOST = 0;
visName = '';

if b == 0
    ostFN = '../example_data/one_state_tracking.ost';
    pcfFN = '../example_data/persistent_pitch_pert.pcf';
    
elseif b == 1
    
    ostFN = '../example_data/compensationPitchShift.ost';
    pcfFN = '../example_data/compensationPitchShift_1.pcf';
    
end
write2pcf_Comp(pcfFN , Pert)

write2ost_Comp(ostFN, Delay)


check_file(ostFN);
check_file(pcfFN);
Audapter('ost', ostFN, 0);
Audapter('pcf', pcfFN, 0);

params = getAudapterDefaultParams(defaultGender);
params.bPitchShift = 1;
% params.pitchShiftRatio = a;

AudapterIO('init', params);

% Audapter('reset');
% Audapter('start');
% pause(b);
% Audapter('stop');
%
% data = AudapterIO('getData');





