clear all;
close all;
clc;
%%%edited by Defne Abur 3/16 to change default values to :defaultanswer={'3','20','60','40', '40', '100'};
%% define experimental parameters

prompt={'Subject ID:',...
    'Session ID:',...
    'group:',...
    'Gender ("male" or "female")'};
name='Subject Information';
numlines=1;
defaultanswer={'a','a','a','male'};
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

%% initialization of the parameters

prompt={'Vowel Duration (s) :',...
    'Number of trial in Basline :',...
    'Number of trial in Ramp :',...
    'Number of trial in Hold :',...
    'Number of trial in Aftereffect :'...
    'Max Perturbation (cent) :'};
name='Experimental parameters';
numlines=1;
defaultanswer={'3','20','60','40', '40', '100'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

Record_Time = str2num(answer{1});
baselineTrials = str2num(answer{2});
rampTrials =str2num(answer{3});
holdTrials = str2num(answer{4});
aftereffectTrials = str2num(answer{5});
maxGain = str2num(answer{6});

Fs = 44100;
% calculate gain value for every trial
gainTrials = [zeros(1,baselineTrials), linspace(0,maxGain,rampTrials), maxGain*ones(1,holdTrials), zeros(1,aftereffectTrials)];

figure1 = figure('NumberTitle','off','Color',[0 0 0],'Position',[-1280 1050 1281 1026],'MenuBar','none');
H1 = annotation(figure1,'textbox',[0.46 0.46 0.2 0.2],...
    'Color',[1 1 1],...
    'String',{'+'},...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',160,...
    'FontName','Arial',...
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

% LineIn = audiorecorder(Fs,24,2);
% Happy = 0;
%
%
% h1 = figure;
% while (Happy ==0)
%     clf(h1);
%     set (H1,'Visible','on');
%     pause(1);
%     set (H1,'Visible','off');
%
%     set(H2,'Color',[1 1 1]);
%     set (H2,'Visible','on');
%     recordblocking(LineIn, 5);
%         set (H2,'Visible','off');
%     Y_sample = getaudiodata(LineIn);
%     stop(LineIn);
%     plot(linspace(0,length(Y_sample)/Fs,length(Y_sample)),Y_sample(:,1));
%     hold on;
%     line([1 1],[-1 1],'LineWidth',2,'Color',[0 0 0])
%     line([4 4],[-1 1],'LineWidth',2,'Color',[0 0 0])
%     ylim([-1 1])
%     Happy = input('Are you happy with the signal (0,1):');
%     set (H2,'Visible','off');
% end
% try
%     close (h1);
% catch
%     %
% end
% FileName= [baseFilename 'Sample.wav'];
% audiowrite(FileName,Y_sample,Fs);

addpath c:/speechres/commonmcode;
cds('audapter_matlab');
which Audapter;
Audapter info;


%%
for TR_n = 1 : length(gainTrials)
    fprintf('Trial number: %d, Gain value : %1.2f \n', TR_n, gainTrials(TR_n))
    
    
    % show the +
    set (H1,'Visible','on');
    pause(2);
    %     sound (Y_sample(round(length(Y_sample)/5):round(4*length(Y_sample)/5),1),Fs);
    set (H1,'Visible','off');
    
    
    
    set(H2,'Color',[1 1 1]);
    set (H2,'Visible','on');
    pause(1);
    set(H2,'Color',[0 1 0]);
    % GO
    Ayoub_PitchShift(gainTrials(TR_n)/100,Record_Time+2);
    
    Audapter('reset');
    Audapter('start');
    pause(Record_Time);
     set(H2,'Color',[1 1 1]);
    pause(2)
    Audapter('stop');
    
    Out{TR_n} = AudapterIO('getData');
    
    
    set (H2,'Visible','off');
    
    pause(3)
    
    
    FileName= [baseFilename 'trial_' num2str(TR_n) '_' num2str(gainTrials(TR_n)) '.wav'];
    Y_Out = [Out{TR_n}.signalIn Out{TR_n}.signalOut];
    audiowrite(FileName,Y_Out,Out{TR_n}.params.sRate);
    
end
close all;
FileName= [baseFilename 'DataFile.mat'];
Experiment.gainTrials = gainTrials;

save(FileName,'Out','Experiment');
