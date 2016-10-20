%edited to reduce default number of trials
%commented based on audapter manual 
%calibration section added, do EL calibration before each run
%added line of code so randperm doesn't enter the same thign each time Liz Heller Murray 06022016

%as the pitch shifted, the intensity shifted (by chuck larson), so tha that
%is okay since that is what chuck is doing, so we aren't scaling it either


function Pediatric_Final_Pitch_Reflex_DelayPeriod()
% clear all;
close all;
clc;
tstart = tic;
%% define experimental parameters
prompt={'Subject ID:',...
    'Session ID, add _pos, _neg, _ctl:',...
    'group:',...
    'Gender ("male" or "female")'};
name='Subject Information';
numlines=1;
defaultanswer={'PedCT#','Pitch_Reflex_','PedControl','male'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
subjectID = answer{1};
session   = answer{2};
group     = answer{3};
Gender    = answer{4};

% create the folder path to save the data files
baseFilename = ['data\' group, '\', subjectID, '\', session, '\'];
% check if the foler exists (to avoid overwrite)
if (exist(baseFilename,'dir'))
    h = errordlg('THE DIRECTORY EXISTS!');
    return;
else
    mkdir(baseFilename);
end

s = RandStream.create('mt19937ar','seed',sum(100*clock)); %make it so randperm doesn't call the same thing everytime when matlab is opened
RandStream.setGlobalStream(s);
%% initialization of the parameters
prompt={'Record Time (s) :',... %duration of vowel plus one second
    'Number of trials in a Block :',...
    'Number of Blocks :',...
    'Number of Perturbed trials in a Block :',...
    'Max Perturbation (cent) :',...
    };
name='Experimental parameters';
numlines=1;
defaultanswer={'4','6','10','2','100'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

Record_Time = str2num(answer{1}); %vowel + 1 second
numTrialBlock = str2num(answer{2}); % number trials in a block
numBlocks =str2num(answer{3}); %number of total blocks
numPert = str2num(answer{4}); %number of perturbation trials in a block
maxGain = str2num(answer{5}); %maximum perturbation
% DurationPert = str2num(answer{6});
Fs = 44100;


delayPeriod = linspace(.5, 1, numTrialBlock); %delay period is between is a vector of .5 to 1, equally spaced for the number of trials (i.e., .5, .6, .7, .8 .9, 1)
delayPeriodTrial = [];
for i = 1: numBlocks %perturbation is not applied to first or last trials in a block to give time for 'washout', it is randomly applied to two of the middle trials
    tempRandInd = randperm(numTrialBlock); %randomize the number of trials in a block (i.e., 6 trials, randomize the numbers 1 to 6)
    delayPeriodTrial = [delayPeriod(tempRandInd) delayPeriodTrial]; %randomize the potential delay periods for this block
    gainTrials((i-1)*numTrialBlock+1) = 0; %makes a vector of zeros
    % this section decides what to make tirlas 2,3,4,5 within each block.
    % Note, this will be the same for each participant, since the "mod" is
    % based on the block number
    if mod(i,3) == 1
        gainTrials((i-1)*numTrialBlock+[2 3 4 5]) = [maxGain 0 maxGain 0]; %will always keep trials 1 and 6 within a block 0, for trials 2-5, will over-write teh zeros with the given random display below based on trial number
        
    elseif mod(i,3) == 2
        gainTrials((i-1)*numTrialBlock+[2 3 4 5]) = [0 maxGain 0 maxGain];
    else
        gainTrials((i-1)*numTrialBlock+[2 3 4 5]) = [maxGain 0  0 maxGain];
    end
    gainTrials((i-1)*numTrialBlock+6) = 0;
    
end
rng('shuffle'); %seeds the randperm so is different everytime
tempVar1 =  reshape(gainTrials',numTrialBlock,numBlocks)'; %reshape the vectors so they go up and down, instead of side to side
indRand = randperm(numBlocks); 
for i = 1:numBlocks
    tempVar2(i,:) = tempVar1(indRand(i),:);
end
tempVar2 = tempVar2';
gainTrials = tempVar2(:);


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

%%
addpath c:/speechres/commonmcode; %make sure to change this if common code is in a different place
cds('audapter_matlab'); %if code is moved, find this file and update all the paths as well
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
AudapterIO('init', params);

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
    audiowrite(FileName,Y_Out_cal,Out_cal{cal}.params.sRate);
end

prompt={'calibration value'};
name='Calibration';
numlines=1;
defaultanswer={'00'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

calvalue = str2num(answer{1});

%% start experiment

msg = helpdlg( ...
                    sprintf( 'click "OK" to begin Experiment' ) , ...
                    '' ...
                    ) ;
                uiwait( msg ) ;
 pause(3)               
for TR_n = 1 : length(gainTrials)
    fprintf('Trial number: %d, Pert (cent): %1.2f, Delay (s): %1.2f \n', TR_n, gainTrials(TR_n),delayPeriodTrial(TR_n))
    
    set(H2,'Color',[1 1 1]);
    set (H2,'Visible','on');
    
    %no d-scale values here??
    
    
    online_pitch_reflex(gainTrials(TR_n)/100,delayPeriodTrial(TR_n),Gender);%function which will be called later, see below, gaintrials (number calculate previously)/100 gives the perturbation value between 0 (baseline and after effects), trial#/100 for ramp, 100/100 for hold =1
   
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
FileName= [baseFilename 'DataFile.mat'];
Experiment.gainTrials = gainTrials;
Experiment.delayPeriodTrial = delayPeriodTrial;
Experiment.calibration = calvalue;

save(FileName,'Out','Out_cal','Experiment');

elapsed_time = toc(tstart);
clc;
disp (sprintf('Total time: %f (min)',elapsed_time/60));
end



function online_pitch_reflex(Pert,Delay,Gender)
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
ostFN = '../example_data/online_pitch_reflexPED.ost'; %opens up a file in "example data" saying there will be fives rule - detect the voicing onset, wait, pitch shift after .35 ms, wait, and end
pcfFN = '../example_data/online_pitch_reflexPED.pcf'; %sets perturbation to zero, will be written over each trial
write2pcf_Comp(pcfFN , Pert) %write over the pcfFN file with the current Pert
write2ost_Comp(ostFN, Delay) %write over the pcfFN file with the current delay
check_file(ostFN); %check the ostFN for the number of rules
check_file(pcfFN); %check the PcfFN for the amount of perturbation
Audapter('ost', ostFN, 0); % input your updated ost (online status tracking) heuristics into Audapter (second intput is boolean for verbose mode, keep at 0)
Audapter('pcf', pcfFN, 0); %input your updated pcfFN perturbation configuration into Audapter 


%%
params = getAudapterDefaultParams(defaultGender); %set the default parameters for the default gender
params.bPitchShift = 1; %activation flag for phase vocoder, set to 1 because pitch shifting is invovled
AudapterIO('init', params); %needed to save the data
%params.dScale = dScale; %set the headphone scaling
%no dscale here??


% Audapter('reset');
% Audapter('start');
% pause(b);
% Audapter('stop');
% data = AudapterIO('getData');

end






