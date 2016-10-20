
audioInterfaceName = 'ASIO4ALL v2';%'MOTU Audio ASIO';% 'MOTU MicroBook';

sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3;
frameLen = 96;  % Before downsampling

defaultGender = 'male';

%% Visualization configuration
gray = [0.5, 0.5, 0.5];
ostMult = 250;
legendFontSize = 8;


%% 
Audapter('deviceName', audioInterfaceName);
Audapter('setParam', 'downFact', downFact, 0);
Audapter('setParam', 'sRate', sRate / downFact, 0);
Audapter('setParam', 'frameLen', frameLen / downFact, 0);

bVis = 0;
bVisFmts = 0;
bVisOST = 0;
visName = '';

ostFN = '../example_data/one_state_tracking.ost';
    pcfFN = '../example_data/persistent_pitch_pert.pcf';
    
    check_file(ostFN);
    check_file(pcfFN);
    Audapter('ost', ostFN, 0);
    Audapter('pcf', pcfFN, 0);
    
    params = getAudapterDefaultParams(defaultGender);
    params.bPitchShift = 0;
    params.dScale = 2
    AudapterIO('init', params);
    
    Audapter('reset');
    Audapter('start');
    fprintf(1, 'Please say something...');
    pause(4);

    fprintf(1, '\n');
    Audapter('stop');
    
    bVis = 1;
    visName = 'Persistent pitch shift (up 2 semitones)';