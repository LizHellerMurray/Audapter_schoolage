addpath c:/speechres/commonmcode; %make sure to change this if common code is in a different place
cds('audapter_matlab'); %if code is moved, find this file and update all the paths as well
which Audapter; %makes sure audapter is mapped
Audapter info; %lets you know which sound card is being used

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
AudapterIO('init', params);


for cal = 1:1
Audapter('reset'); %resests the status of temporary fields
    Audapter('start'); % starts audadapter
    pause(5); %pause with Audapter on for the length of time the vowel is on the screen (it is recorded for 1 extra second)
   
    Audapter('stop'); % stop audapter
    Out{cal} = AudapterIO('getData'); %output data includes both input and output signals and the derived dtata, see seciton 6 of manual for detailed description of the fiels in output "data"

    
    
    FileName= ['calibration.wav']; %save the wavefile with the trial number and gain
    Y_Out = [Out{cal}.signalIn Out{cal}.signalOut]; 
    audiowrite(FileName,Y_Out,Out{cal}.params.sRate);
end

prompt={'calibration value'};
name='Calibration';
numlines=1;
defaultanswer={'00'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

calvalue = str2num(answer{1});

