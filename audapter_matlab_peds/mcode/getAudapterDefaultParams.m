function p = getAudapterDefaultParams(sex,varargin)
%EHM commented scripts 10/20/2016 to provide descriptions of all items
%based on audapter manual and audapter c++ code

%%
%sex only used for formant tracking, however, still need to 
switch sex
    case 'male'       
        p.nLPC          = 17;
        p.fn1           = 591; %numbers set based on aprior expectation
        p.fn2           = 1314;
    case 'female'
        p.nLPC          = 15;	%SC-Mod(2008/02/08) Used to be 9
        p.fn1           = 675;
        p.fn2           = 1392;
    otherwise,
        error('specify sex (male / female');
end

p.nFB           = 1; % no feedback voices used in this protocol, if multivoice would be >1

p.aFact         = 1; %? factor of the penalty function used in formant tracking. It is the weight on the bandwidth criterion. The formant tracking algorithm is based on Xia and Espy-Wilson (2000).
p.bFact         = 0.8; %? factor of the penalty function used in formant tracking. It is the weight on the a priori knowledge of the formant frequencies.
p.gFact         = 1; %? factor of the penalty function used in formant tracking. It is the weight on the temporal smoothness criterion.

p.downFact      = 3; %downsampling factor
p.frameLen      = 96 / p.downFact;% i.e., framelength is  32. Value must be a valid DMA Buffer size (64 128 256 ..)

if ~isempty(fsic(varargin,'downFact'))
    p.downfact=varargin{fsic(varargin,'downFact')+1};
end

p.closedLoopGain= 15;    % dB

if ~isempty(findStringInCell(varargin,'closedLoopGain'))
    p.closedLoopGain=varargin{findStringInCell(varargin,'closedLoopGain')+1};
end

p.dScale        = 10 ^ ((p.closedLoopGain - calcClosedLoopGain) / 20); %output scaling when upsampling, headphone amplitude: This is written over in the adaptation and perturbation codes
p.preempFact    = 0.98;% preemp factor

p.sr            = 48000 / p.downFact; % sampling rate after downsampling (16000)
if ~isempty(fsic(varargin,'sr'))
    p.sr=varargin{fsic(varargin,'sr')+1};
end

p.nLPC = round((p.nLPC / 16e3 * p.sr / 2 - 0.5)) * 2 + 1; 

% Frame structure
p.nWin          = 1;% 1 2 4  8 16 32 64 (max=p.framLen) Number of windows per frame  !! Number of processes per frame


if ~isempty(fsic(varargin,'frameLen'))
    p.frameLen=varargin{fsic(varargin,'frameLen')+1};
end


p.nDelay        = 5;% the total process delay is: p.frameLen*p.nDelay/p.sr This is the overall process latency without the soudncard
p.frameShift    = p.frameLen/p.nWin;% number of samples shift between two processes ( = size of processed samples in 1 process)
p.bufLen        = (2*p.nDelay-1)*p.frameLen; %main buffer length : buflen stores (2*nDelay -1)*frameLen samples
p.anaLen        = p.frameShift+2*(p.nDelay-1)*p.frameLen; %size of lpc analysis (symmetric around window to be processed)
p.avgLen      = 8;    %ceil(p.sr/(f0*p.frameShift));length of smoothing ( should be approx one pitch period, can be greater /shorter if you want more / lesss smoothing) 

p.bCepsLift     = 0; % so cepstral liftering in this code

p.minVowelLen   = 60; %Minimum allowed vowel duration (in number of frames). This is a somewhat obsolete parameter. It was used during prior single CVC syllable vowel formant perturbation experiments for preventing premature termination of perturbations. This capacity should have largely been superseded by OST

%If the cepstral liftering was being done, this would set the window width.
%However, p.bCepsLift = 0
if (isequal(sex,'male'))
    p.cepsWinWidth  = 50;
elseif (isequal(sex,'female'))
    p.cepsWinWidth  = 30;    
end

% Formant tracking 
p.nFmts         = 2; %originally the number of formants you want shift 
p.nTracks       = 4; %Number of formants to be tracked 
p.bTrack        = 1; % flag indicating that formants are being tracked (may not need to be on for pitch detection, not sure? EHM)
p.bWeight       = 1; % weigthing (short time rms) of moving average formant estimate o

% RMS calculation
if ~isempty(findStringInCell(varargin,'closedLoopGain'))
    p.mouthMicDist=varargin{findStringInCell(varargin,'closedLoopGain')+1};
else
    p.mouthMicDist=10;
end

p.rmsThresh     = 0.032*10^((getSPLTarg(p.mouthMicDist)-85)/20); % Before: 0.04*10^((getSPLTarg('prod')-85)/20); % 2009/11/27, changed from 0.04* to 0.032*
p.rmsRatioThresh= 0.1;% threshold for sibilant / vowel detection
p.rmsMeanPeak   = 6*p.rmsThresh;
p.rmsForgFact   = 0.95;% Forgetting factor (FF) for smoothing of shorttime RMS intensity (rms_o) to obtain the smoothed intensity (rms_s)

% Vowel detection
p.bDetect       = 1; %A flag indicating whether Audapter is to detect the time interval of a vowel. (%may be unnessary because bshift is set to 0)
%p.fmtsForgFact  = 0.97;% formants forgetting factor [1 2 .. nFmts]
p.dFmtsForgFact = 0.93;% formants forgetting factor for derivate calculation, Forgetting factor for formant smoothing (in status tracking) 

% Shifting
p.bShift        = 0; %Formant perturbation switch, set to off (0)
p.bRatioShift   = 1; %switch for ratio based fromant shifting A flag indicating whether the data in pertAmp are absolute (0) or relative (1) amount of formant shifting.
p.bMelShift     = 0;    % Use Hz as the unit b/c melshift=0, if =1, then use mel

p.gainAdapt     =0; %Formant perturbation gain adaptation switch, 0 = not using gain adaption

% Trial-related
p.fb=1; % Voice only;

p.trialLen = 0; %SC(2008/06/22) % 0 corresponds to no length limit (circular)

if ~isempty(findStringInCell(varargin,'trialLen'))
    p.trialLen=varargin{findStringInCell(varargin,'trialLen')+1};
end

p.rampLen = 0; %SC(2008/06/22) % 0 corresponds to no ramp

% SC(2009/02/06) RMS clipping protection
p.bRMSClip = 0; %switch for rms intensity clipping, loudness protection
% p.rmsClipThresh=1.0;

load('micRMS_100dBA.mat');
p.rmsClipThresh=micRMS_100dBA / (10^((100-100)/20));	% 100 dB maximum input level

p.bPitchShift = 0; % should be set to 1 when pitch shifting or time shifting are involved, overwrittenin code
if ~isempty(fsic(varargin, 'bPitchShift'))
    p.bPitchShift = varargin{fsic(varargin, 'bPitchShift') + 1};
end

p.bBypassFmt = 0; %if want to bypass pitch shifting, can set to 1

%% 
p.fb3Gain = dBSPL2WaveAmp(-Inf);

p.fb4GainDB = 10;
p.rmsFF_fb = [0.8, 0.99, 0.1, 0.1]; %p.rmsFF_fb = [0.8, 0.99, 0, 0]; are values written in manual

%% Perturbation-related variables: these are for the mel (bMelShift=1) or Hz (bMelShift=0) frequency space
p.F2Min=0;
p.F2Max=5000;
p.F1Min=0;
p.F1Max=5000;
p.LBb=0;
p.LBk=0;

p.pertFieldN=257;
p.pertF2=zeros(1,p.pertFieldN);
p.pertAmp=zeros(1,p.pertFieldN);
p.pertPhi=zeros(1,p.pertFieldN);

%% Pitch shift and delay related
p.delayFrames = 0;
p.bPitchShift = 0;
p.pitchShiftRatio = 1;

%using this frame length runs the risk of amplitude modulation below 130Hz,
%however this is a low enough frame rate so keep the delay beteween the
%microphone and headphones under 30 ms (about 25)
p.pvocFrameLen = 256;
p.pvocHop = 64;

%this framelength would get rid of the amplitude at low frequencies,
%however, it increases the delay to 70 ms, changing this to 512, 128 would
%still increase the delay to 40 ms. Which is too long (has to be under 30
%to be usable)
%p.pvocFrameLen = 1024;
%p.pvocHop = 256;

p.bDownSampFilt = 1;

if ~isempty(fsic(varargin, 'pvocFrameLen'))
    p.pvocFrameLen = varargin{fsic(varargin, 'pvocFrameLen') + 1};
end

if ~isempty(fsic(varargin, 'pvocHop'))
    p.pvocHop = varargin{fsic(varargin, 'pvocHop') + 1};
end

%%
p.bPitchShift = 0;

%%
p.stereoMode = 1; % Left-right audio identical

return
