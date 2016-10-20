function data1 = offlinFormantPerturbation (dataFile,Pert,genderSubject)
%% CONFIG
audioInterfaceName = 'ASIO4ALL';%'MOTU MicroBook';%

sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3;
frameLen = 96;  % Before downsampling
noiseWavFN = 'mtbabble48k.wav';
% Audapter('deviceName', audioInterfaceName);
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
% Audapter('setParam', 'datapb', w, 1);
params.fb3Gain = 0.1;
params.fb = 1;
params.pertAmp = Pert * ones(1, 257);
params.pertPhi = 0.0 * pi * ones(1, 257);
params.fb = 1;
% AudapterIO('init', params);




params.bDetect = 1;
params.rmsThresh = 0.01;
params.bShift = 1;
params.bRatioShift = 1;
params.bBypassFmt = 0;           % === Important === %

% if isequal(pertMode, 'pitch') || isequal(pertMode, 'timeWarp') ...
%         || isequal(pertMode, 'debug')
%     params.bPitchShift = 1;          % === Important === %
% else
params.bPitchShift = 0;          % === Important === %
% end


fs = 16000;

sigIn = dataFile;

% sigIn = resample(sigIn, data.params.sr * data.params.downFact, fs);
sigIn = resample(sigIn, fs * downFact, fs);
% sigInCell = makecell(sigIn, data.params.frameLen * data.params.downFact);
sigInCell = makecell(sigIn, frameLen);

params.rmsClipThresh=0.01;
params.bRMSClip=1;

% if ~isempty(fsic(varargin, '--nLPC'))
%     params.nLPC = varargin{fsic(varargin, '--nLPC') + 1};
% end

AudapterIO('init', params);

Audapter('setParam', 'rmsthr', 5e-3, 0);

Audapter('reset');

for n = 1 : length(sigInCell)
    Audapter('runFrame', sigInCell{n});
end

data1 = AudapterIO('getData');
audioSignal = data1.signalOut;
% winTime = ones(1,160);
% InFile = conv(winTime,dataFile.^2);
% OutFile = conv(winTime,audioSignal.^2);
% % InFile = dataFile(find(InFile>10,1,'first'):InFile>10,1,'first'))
% 
% RMS_Source = rms(dataFile(find(InFile>.1,1,'first'):find(InFile>.1,1,'last')));
% RMS_Target = rms(audioSignal(find(OutFile>.1,1,'first'):find(OutFile>.1,1,'last')));
RMS_Source = rms(dataFile);
RMS_Target = rms(audioSignal);
audioSignal = audioSignal * (RMS_Source/RMS_Target);
% sortedSignal = sort(abs(audioSignal));
% aMax = mean (sortedSignal(end-16:end));
% audioSignal = audioSignal - mean(audioSignal);
% audioSignal = .75 * (audioSignal ./ aMax);%this is normalizing the amplitude
% playerObj = audioplayer(audioSignal, fs);
% playblocking(playerObj);

sound(audioSignal, fs);
pause(length(audioSignal)/fs+.2);
pause(.01);

