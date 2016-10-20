%edited to reduce default number of trials
%commented based on audapter manual 
%calibration section added, do EL calibration before each run
%added line of code so randperm doesn't enter the same thign each time Liz Heller Murray 06022016

function Pediatric_Final_Pitch_Adaptation()
% clear all;

close all;
clc;
tstart = tic; %starts the timer so know how long the entire task takes
%% define experimental parameters

prompt={'Subject ID:',...
    'Session ID (add _pos, _neg, or _ctl):',...
    'Group:',...
    'Gender ("male" or "female")'};
name='Subject Information';
numlines=1;
defaultanswer={'PedCT#','Pitch_Adaptation_','PedControl','male'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
subjectID = answer{1};
session   = answer{2};
group     = answer{3};
Gender    = answer{4};
% create the folder path to save the data files
baseFilename = ['data\' group, '\', subjectID, '\', session, '\']

% check if the foler exists (to avoid overwrite)
if (exist(baseFilename,'dir')) %if the folder exists, will close entire program and and tell you directory exists
    h = errordlg('THE DIRECTORY EXISTS!');
    return;
else
    mkdir(baseFilename);
end

s = RandStream.create('mt19937ar','seed',sum(100*clock)); %make it so randperm doesn't call the same thing everytime when matlab is opened
RandStream.setGlobalStream(s);
%% initialization of the parameters

prompt={'Record Time (s) :',... %duration of vowel plus one second 
    'Number of trial in Baseline :',...
    'Number of trial in Ramp :',...
    'Number of trial in Hold :',...
    'Number of trial in Aftereffect :'...
    'Max Perturbation (cent)CHANGE THIS :'};
name='Experimental parameters';
numlines=1;
defaultanswer={'3','5','5','5', '0', '100'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

Record_Time = str2num(answer{1});
baselineTrials = str2num(answer{2});
rampTrials =str2num(answer{3});
holdTrials = str2num(answer{4});
aftereffectTrials = str2num(answer{5});
maxGain = str2num(answer{6});

Fs = 44100;
% calculate gain value for every trial
gainTrials = [zeros(1,baselineTrials), linspace(0,maxGain,rampTrials), maxGain*ones(1,holdTrials), zeros(1,aftereffectTrials)]; %baseline is zeros, ramp goes from 0 to max gain in equal intervals depending on how many trials, max gain is 100, after is 0


%% initialize figure
figure1 = figure('NumberTitle','off','Color',[0 0 0],'Position',[-1280 1050 1281 1026],'MenuBar','none');
H1 = annotation(figure1,'textbox',[0.38 0.46 0.2 0.2],...
    'Color',[1 1 1],...
    'String','READY',...
    'LineStyle','none',...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle',...
    'FontSize',130,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none',...
    'BackgroundColor',[0 0 0],...
    'Visible','on');

H2 = annotation(figure1,'textbox',[0.38 0.46 0.2 0.2],...
    'Color',[1 1 1],...
    'String',{'aaa'},...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',160,...
    'FontName','Arial',...
    'BackgroundColor',[0 0 0],...
    'visible','off');


%% Initialize Audapter
clc;
addpath c:/speechres/commonmcode_peds; %make sure to change this if common code is in a different place
cds('audapter_matlab_peds'); %if code is moved, find this file and update all the paths as well
which Audapter; %makes sure audapter is mapped
Audapter info; %lets you know which sound card is being used

pause(5)
set (H1,'Visible','off');
%% start calibration
audioInterfaceName = 'ASIO4ALL v2';%'MOTU Audio ASIO';% 'MOTU MicroBook';
sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3; %downsamping factor, default is 3, reduces the computational load on CPU for ensuring  a real-time preocessing
frameLen = 96;  % Before downsampling, number of samples
defaultGender = 'female';


Audapter('deviceName', audioInterfaceName);
Audapter('setParam', 'downFact', downFact, 0); %factor to downsample by
Audapter('setParam', 'sRate', sRate / downFact, 0); %sampling rate 
Audapter('setParam', 'frameLen', frameLen / downFact, 0);


params = getAudapterDefaultParams(defaultGender); %set the default parameters for the default gender
params.dScale = 0; %set the headphone scaling to zero during calibration
%params.pvocFrameLen=1280;

AudapterIO('init', params); %needed to save the data

msg = helpdlg( ...
                    sprintf( 'click "OK" to begin Calibration' ) , ...
                    '' ...
                    ) ;
                uiwait( msg ) ;
for cal = 1:1
    pause(2)
Audapter('reset'); %resests the status of temporary fields
    Audapter('start'); % starts audadapter
    pause(5); %pause with Audapter on for the length of time the vowel is on the screen (it is recorded for 1 extra second)
    Audapter('stop'); % stop audapter
    Out_cal{cal} = AudapterIO('getData'); %output data includes both input and output signals and the derived dtata, see seciton 6 of manual for detailed description of the fiels in output "data"

      
    FileName= [baseFilename 'calibration.wav']; %save the wavefile with the trial number and gain
    Y_Out_cal = [Out_cal{cal}.signalIn Out_cal{cal}.signalOut]; 
    audiowrite(FileName,Y_Out_cal,Out_cal{cal}.params.sRate);%write calibration file
end

prompt={'calibration value'};
name='Calibration';
numlines=1;
defaultanswer={'00'}; %input box to save calibration value
answer=inputdlg(prompt,name,numlines,defaultanswer);

calvalue = str2num(answer{1}); %calibration value

%% start experiment
msg = helpdlg( ...
                    sprintf( 'click "OK" to begin Experiment' ) , ...
                    '' ...
                    ) ;
                uiwait( msg ) ; 
    pause(3)            
for TR_n = 1 :length(gainTrials) %For all files
    fprintf('Trial number: %d, Gain value : %1.2f \n', TR_n, gainTrials(TR_n)) %print the trial number and gain number
    
    set(H2,'Color',[1 1 1]);
    set (H2,'Visible','on');
    
    
    %in audapter, the headphone output is not the headphone output, it is
    %the mic signal pertrubed by audapter before it is scaled. there is no
    %way to save the headphone output after he has scaled it- there is no
    %way to see the true intensity  headphone output. So you won't see this
    %intensity correction factor in the heaphone out if you look in the
    %saved output. This intensity correction factor is applied because,
    %as the pitch increases, audapter decreases the intensity to compensate
    %for the natural loudness increase the happens during a pitch increase.
    %THEREFORE the code below scales the intensity back up to correct for
    %the decrease that we don't want. This doens't happen on decrease in
    %pitch, so no correction is necessary, during control and after effect
    %trials - still too loud because of somethign audapter is doing, so
    %scale it down to keep the intensity the same throughout (at least 5 db
    %in every phase) 
    if (gainTrials(TR_n)) > 0 %for a gain of greater than zero, scale the headphones 1.2X
        dScale = 1.2;
        %dScale = 1.12;
     %  dScale = 1;
    elseif (gainTrials(TR_n)) < 0 % for a gain less than zero, don't scale the headphones
      % dScale = 1;
      dScale = 0.96;
    else
       % dScale = 1;
         dScale = .8; %for a gain equal to zero, scale the headphones .8X times, Audapter
    end
    
    online_PitchShift_adaptation(gainTrials(TR_n)/100,Record_Time,Gender,dScale); %function which will be called later, see below, gaintrials (number calculate previously)/100 gives the perturbation value between 0 (baseline and after effects), trial#/100 for ramp, 100/100 for hold =1
    
    Audapter('reset'); %resests the status of temporary fields
    Audapter('start'); % starts audadapter
    pause(Record_Time-1); %pause with Audapter on for the length of time the vowel is on the screen (it is recorded for 1 extra second)
    set (H2,'Visible','off');
    pause(1);
    Audapter('stop'); % stop audapter
    Out{TR_n} = AudapterIO('getData'); %output data includes both input and output signals and the derived dtata, see seciton 6 of manual for detailed description of the fiels in output "data"

    % jitter the between trial pause
    jitterPause = [1,2,3];
    tempVarRand = randperm(3);
    pause(jitterPause(tempVarRand(2)));
    
    
    FileName= [baseFilename 'trial_' num2str(TR_n) '_' num2str(gainTrials(TR_n)) '.wav']; %save the wavefile with the trial number and gain
    Y_Out = [Out{TR_n}.signalIn Out{TR_n}.signalOut]; 
    audiowrite(FileName,Y_Out,Out{TR_n}.params.sRate); %write the audiofile
    
end
close all;
FileName= [baseFilename 'DataFile.mat']; %saves the datafile in teh correct folder
Experiment.gainTrials = gainTrials; %saves the list of gains
Experiment.calibration = calvalue; %saves the calibration value

save(FileName,'Out','Out_cal','Experiment'); 

elapsed_time = toc(tstart); %end timer of entire experiment
clc;
disp (sprintf('Total time: %f (min)',elapsed_time/60)); %prints length of experiment

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
ostFN = '../example_data_peds/online_pitch_adaptation.ost'; %opens up a file in "example data" saying there will be one rule
pcfFN = '../example_data_peds/online_pitch_adaptation.pcf'; %sets perturbation to zero, will be written over each trial

write2pcf(pcfFN , Pert) %write over the pcfFN file with the current Pert
check_file(ostFN); %check the ostFN for the number of rules
check_file(pcfFN); %check the PcfFN for the amount of perturbation
Audapter('ost', ostFN, 0); % input your updated ost (online status tracking) heuristics into Audapter (second intput is boolean for verbose mode, keep at 0)
Audapter('pcf', pcfFN, 0); %input your updated pcfFN perturbation configuration into Audapter 

%%
params = getAudapterDefaultParams(defaultGender); %set the default parameters for the default gender
params.bPitchShift = 1; %activation flag for phase vocoder, set to 1 because pitch shifting is invovled
params.dScale = dScale; %set the headphone scaling
params.bBypassFmt = 1; %bypasses the formant tracking

AudapterIO('init', params); %needed to save the data
% Audapter('reset');
% Audapter('start');
% pause(Rec_Time);
% Audapter('stop');
% data = AudapterIO('getData');
end









