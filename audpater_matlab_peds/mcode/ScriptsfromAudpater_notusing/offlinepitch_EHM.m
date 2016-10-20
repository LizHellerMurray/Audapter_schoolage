function offlinepitch_EHM
prompt={'Subject ID:',...
    'Session ID (add _pos, _neg, or _ctl):',...
    'Group:',...
    'Gender ("male" or "female")'};
name='Subject Information';
numlines=1;
defaultanswer={'PedCT','Pitch_Adaptation','Control','female'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
subjectID = answer{1};
session   = answer{2};
group     = answer{3};
Gender    = answer{4};
% create the folder path to save the data files
baseFilename = ['data\' group, '\', subjectID, '\', session, '\'];

if (exist(baseFilename,'dir')) %if the folder exists, will close entire program and and tell you directory exists
    h = errordlg('THE DIRECTORY EXISTS!');
    return;
else
    mkdir(baseFilename);
end

s = RandStream.create('mt19937ar','seed',sum(100*clock)); %make it so randperm doesn't call the same thing everytime when matlab is opened
RandStream.setGlobalStream(s);
prompt={'Record Time (s) :',... %duration of vowel plus one second
    'Number of trial in Baseline :',...
    'Number of trial in Ramp :',...
    'Number of trial in Hold :',...
    'Number of trial in Aftereffect :'...
    'Max Perturbation (cent) :'};
name='Experimental parameters';
numlines=1;
defaultanswer={'3','3','3','3', '0', '100'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

Record_Time = str2num(answer{1});
baselineTrials = str2num(answer{2});
rampTrials =str2num(answer{3});
holdTrials = str2num(answer{4});
aftereffectTrials = str2num(answer{5});
maxGain = str2num(answer{6});

gainTrials = [zeros(1,baselineTrials), linspace(0,maxGain,rampTrials), maxGain*ones(1,holdTrials), zeros(1,aftereffectTrials)];
%% Initialize Audapter
clc;
addpath c:\speechres\commonmcode;
cds('audapter_matlab');
%add everything to path
which Audapter; %makes sure audapter is mapped
%Audapter info; %lets you know which sound card is being used

pause(5)
%% set up audapter for calibration
audioInterfaceName = 'ASIO4ALL v2';%'MOTU Audio ASIO';% 'MOTU MicroBook';
sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3; %downsamping factor, default is 3, reduces the computational load on CPU for ensuring  a real-time preocessing
frameLen = 96;  % Before downsampling, number of samples
defaultGender = 'female';


Audapter('deviceName', audioInterfaceName);
Audapter('setParam', 'downFact', downFact, 0); %factor to downsample by
Audapter('setParam', 'sRate', sRate / downFact, 0); %sampling rate/ downfactor sample
Audapter('setParam', 'frameLen', frameLen / downFact, 0); %frame length/downfactor sample

Audapter info; %lets you know which sound card is being used to make sure you have set the correct one

params = getAudapterDefaultParams(defaultGender); %set the default parameters for the default gender
params.dScale = 0;

%dScale = 0;

params.rmsClipThresh=0.01;
params.bRMSClip=1;
params.rmsThr = 5e-3;
    [w, fs] = audioread('rvoice2.wav'); %make sure this file is in the same folder
    w = w(:,1);
    w=w/2;
    w =resample(w, 16000,fs); %resample at sampleing rate before downsample
for TR_n = 1 :length(gainTrials) %For all files
    % read in offline wave files and resample
%     
%     [w, fs] = audioread('95.96.wav'); %make sure this file is in the same folder
%     w = w(:,1);
%     %w=resample(w,48000,fs); %change sampling rate to match audapter rate
%     
%     
%     %check length of the file to make sure it isn't too big
%     maxPBSize = Audapter('getMaxPBLen');
%     
%     if length(w) > maxPBSize
%         w = w(1 : maxPBSize);
%     end
%     %fs= 16000;
%     Signal = w; %
%     
%     Signal =resample(Signal, 48000, 16000); %resample at sampleing rate before downsample
%     
%     if length(Signal) > maxPBSize
%         Signal = Signal(1 : maxPBSize);
%     end
%     
%     sigInCell = makecell(Signal, frameLen); %make individuals cells with 96 frames in them
%     lengthsig = length(sigInCell);
%     
%     AudapterIO('init', params); %needed to save the data
    %% start trial
     if (gainTrials(TR_n)) > 0 %for a gain of greater than zero, scale the headphones 1.2X
        dScale = 1.12;
     %  dScale = 1;
    elseif (gainTrials(TR_n)) < 0 % for a gain less than zero, don't scale the headphones
        dScale = 0.96;
    else
       % dScale = 1;
         dScale = .8; %for a gain equal to zero, scale the headphones .8X times, Audapter
    end
    
    fprintf('Trial number: %d \n', TR_n) %print the trial number and gain number
    
    %      online_PitchShift_adaptation(gainTrials(TR_n)/100,Record_Time,Gender,dScale); %function called later
    data1 = offline_pitch_JND_passive (w,gainTrials(TR_n)/100,'female',1,dScale);
    
    
%     Audapter('reset'); %resests the status of temporary fields
%     Audapter('start'); % starts audadapter
%     pause(3)
%     
%     for n = 1 :lengthsig
%         Audapter('runFrame', sigInCell{n}); %does 'runframe' on each cell until completed all of them
%     end
%     
%     Audapter('stop'); % stop audapter
%     
    Out{TR_n} = AudapterIO('getData');
%     
    FileName= [baseFilename 'trial_' num2str(TR_n) '_' num2str(gainTrials(TR_n)) '.wav']; %save the wavefile with the trial number and gain
    Y_Out = [Out{TR_n}.signalIn Out{TR_n}.signalOut];
    audiowrite(FileName,Y_Out,Out{TR_n}.params.sRate); %write the audiofile 
%     % saving the data and wav files
%     Out{TR_n} = AudapterIO('getData');
%     
%     FileName= [baseFilename 'trial_' num2str(TR_n) '_' num2str(gainTrials(TR_n)) '.wav']; %save the wavefile with the trial number and gain
%     Y_Out = [Out{TR_n}.signalIn Out{TR_n}.signalOut];
%     audiowrite(FileName,Y_Out,Out{TR_n}.params.sRate); %write the audiofile
%     
end
close all;
FileName= [baseFilename 'DataFile.mat']; %saves the datafile in the correct folder
Experiment.gainTrials = gainTrials; %saves the list of gains


save(FileName,'Out','Experiment');

clc;
end

function online_PitchShift_adaptation(Pert,Rec_Time,Gender,dScale)
audioInterfaceName = 'ASIO4ALL v2';%'MOTU Audio ASIO';% 'MOTU MicroBook';
sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3; %downsamping factor, default is 3, reduces the computational load on CPU for ensuring  a real-time preocessing
frameLen = 96;  % Before downsampling, number of samples
defaultGender = lower(Gender);%puts the gender into lower case


%%
Audapter('deviceName', audioInterfaceName); %audiodevice name
Audapter('setParam', 'downFact', downFact, 0); %factor to downsample by
Audapter('setParam', 'sRate', sRate / downFact, 0); %sampling rate/downsampling rate
Audapter('setParam', 'frameLen', frameLen / downFact, 0); %frame rate/ downsampling rate

%%
ostFN = 'c:\speechres\audapter_matlab\example_data\online_pitch_adaptation.ost'; %opens up a file in "example data" saying there will be one rule
pcfFN = 'c:\speechres\audapter_matlab\example_data\online_pitch_adaptation.pcf';

write2pcf(pcfFN , Pert) %write over the pcfFN file with the current Pert
check_file(ostFN); %check the ostFN for the number of rules
check_file(pcfFN); %check the PcfFN for the amount of perturbation
Audapter('ost', ostFN, 0); % input your updated ost (online status tracking) heuristics into Audapter (second intput is boolean for verbose mode, keep at 0)
Audapter('pcf', pcfFN, 0); %input your updated pcfFN perturbation configuration into Audapter
%%
params = getAudapterDefaultParams(defaultGender); %set the default parameters for the default gender
params.bPitchShift = 1; %activation flag for phase vocoder, set to 1 because pitch shifting is invovled
AudapterIO('init', params); %needed to save the data
end






function data1 = offline_pitch_JND_passive (dataFile,Pert,genderSubject,basetime,dScale)
%% CONFIG
% addpath c:/speechres/commonmcode;
% cds('audapter_matlab');
audioInterfaceName = 'ASIO4ALL';%'MOTU MicroBook';%

sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3;
frameLen = 96;  % Before downsampling
noiseWavFN = 'mtbabble48k.wav';
% Audapter('deviceName', audioInterfaceName);
Audapter('setParam', 'downFact', downFact, 0);
Audapter('setParam', 'sRate', sRate / downFact, 0);
Audapter('setParam', 'frameLen', frameLen / downFact, 0);

%%
ostFN = '../example_data/offline_pitch_JND_passive.ost';
pcfFN = '../example_data/offline_pitch_JND_passive.pcf';

write2pcf(pcfFN , Pert)

check_file(ostFN);
check_file(pcfFN);
Audapter('ost', ostFN, 0);
Audapter('pcf', pcfFN, 0);

%%
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
params.bBypassFmt = 0;

params.bPitchShift = 1;
params.dScale = dScale; %set the headphone scaling
params.pvocFrameLen = 1024; %increased phase vocoder window lenght to accomplidate low frequencie
params.pvocHop = 256; %increased phase vocoder overlap of windows
fs = 16000;

sigIn = dataFile;
sigIn = resample(sigIn, fs * downFact, fs);
sigInCell = makecell(sigIn, frameLen);

params.rmsClipThresh=0.01;
params.bRMSClip=1;
AudapterIO('init', params);
Audapter('setParam', 'rmsthr', 5e-3, 0);
Audapter('reset');
for n = 1 : length(sigInCell)
    Audapter('runFrame', sigInCell{n});
end
data1 = AudapterIO('getData');
%% save data

    
%% play sound
audioSignal = data1.signalOut;
audioSignal = audioSignal(:);
sound(audioSignal, fs)
pause(basetime+length(audioSignal)/fs+.01)

%% normalize
% RMS_Source = sqrt(mean(dataFile.^2));
% RMS_Target = sqrt(mean(audioSignal.^2));
% audioSignal = audioSignal * (RMS_Source/RMS_Target);%this is normalizing the amplitude
% %Window = [sin(2*pi*linspace(0,riseTime,riseTime*fs)*((4*riseTime)^-1)).^2  ones(1,(StimulusDur - riseTime - fallTime) * fs) cos(2*pi*linspace(0,fallTime,fallTime*fs)*((4*fallTime)^-1)).^2];
% Window = [sin(2*pi*linspace(0,riseTime,floor(riseTime*fs))*((4*riseTime)^-1)).^2  ones(1,floor((StimulusDur - riseTime - fallTime) * fs)) cos(2*pi*linspace(0,fallTime,floor(fallTime*fs))*((4*fallTime)^-1)).^2];
% Window = Window(:);%this is a cosine square
% audioSignal = audioSignal(:);
% if length(Window) > length(audioSignal)
%     audioSignal = audioSignal(:) .* Window(1:length(audioSignal));
% elseif  length(Window) < length(audioSignal)
%     audioSignal = audioSignal(1:length(Window)) .* Window(:);
% else
%     audioSignal = audioSignal(:) .* Window(:);
% end



%audioSignal = audioSignal(:);%.*Window(:)

% playerObj = audioplayer(audioSignal, fs);
% playblocking(playerObj);


end

