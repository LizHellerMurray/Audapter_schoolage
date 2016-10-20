 prompt={'Subject ID:',...
    'Session ID:',...
    'Group:',...
    'Gender ("male" or "female")'};
name='Subject Information';
numlines=1;
defaultanswer={'APYC','Intensity Calibration','Control','female'};
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
    pause(10); %pause with Audapter on for the length of time the vowel is on the screen (it is recorded for 1 extra second)
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

FileName= [baseFilename 'DataFile.mat'];
Experiment.calibration = calvalue; %saves the calibration value

save(FileName,'Out_cal','Experiment'); 