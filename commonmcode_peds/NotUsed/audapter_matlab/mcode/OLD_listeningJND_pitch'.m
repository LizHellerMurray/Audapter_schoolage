function pitch_test( varargin )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  edited for amplitude Cara Stepp 08-15-2013

%JND finder - edited for pitch by Stephanie Lien

%edited by Liz Heller Murray 6/3/2014

%edited by Defne Abur 4/7/2015 to normalize sound, 65dB on MOTU line 179
%edited by Defne Abur 4/9/2015 to add in 'order' and 'ordersave' variables to
%randomize presentation order - see lines 93 - 99


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% GAME INITIALIZATION

%generates the GUI that pops up at the beginning of the game
prompt={'Subject:'};
name='Hearing JND';
numlines=1;
defaultanswer={'PDT'};

answer=inputdlg(prompt,name,numlines,defaultanswer);

% subject = ['C3_hearing'];
trial = ['t001'];

s = RandStream.create('mt19937ar','seed',sum(100*clock)); %make it so randperm doesn't call the same thing everytime when matlab is opened
RandStream.setGlobalStream(s);

if isempty( answer )
    return
end

if ~exist( answer{ 1 } , 'dir' )
    mkdir( answer{ 1 } ) ;
else
    overwrite = inputdlg({'File already exists! Do you want to overwrite?'},'Overwrite',1,{'no'})
    if ~strcmp(overwrite,'yes') & ~strcmp(overwrite,'YES') & ~strcmp(overwrite,'Yes')
        return;
    end
end

% if ~exist( subject, 'dir' )
%     mkdir( subject ) ;
% end
outfile = fullfile( answer{ 1 }, trial ) ;%creates file 't001'

% Values to be input by user
%Amp = .5; %amplitude in volts of the reference tone
MaxReversals = 16;                         %number of answer switches the user must make before the game ends

% Standardized values
fs = 44100;
timeT = [0:1/fs:2];
soundwav = cos(timeT*2*pi*440); %69 MIDI = 440 Hz


%[voice,fs,NBITS]=wavread('N08AH.wav');
%fs should equal 44100;

%Initializing
reversals = 0;
Trial = 0;
dist = .4; %sets initial distortion value.
upstep = .2; %initial setting that dist will go up by if user answers 'same'. These values change later based on trial number
downstep = upstep / 2.4483; %initial setting that dist will go down by if user answers 'different'. These values change later based on trial number .71/(1-.71)
revValues = [];
dist_values = [];
revTrials = [];
Rating = [];
Correctsave = [];
Modulator = [];
successkeeper = 1;
ordersave = []; %changed from typesave to ordersave
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUNNING THE GAME

ResultMatrixTitle = {'Dist Values' ,'Correct =1, Incorrect = 2' ,'Incorrect = 0, Correct for different=1, Correct for same =2', 'Order, different with phase 1 baseline =1, different with phase 2 baseline = 2, catchtrial =3' };
% Runs the Trial in 2 phases (standard/modified) for each trial
%for Trial = 1 : Nconditions
while reversals < MaxReversals
    
    Trial = Trial + 1;
    Rating(Trial) = 0 ;
    Correctsave(Trial) = 0;
    
    %order 1 is baseline first, higher one second
    
    %order 2 is higher one first, baseline second
    
    %order 3 is catchtrial, both are baseline
    
    %order 3 is 1/6 chance and ELSE choose between order 1 and order 2 with 50/50 chance
    
    n=8;
    is_catchtrial = randperm(n,1); %catchtrial will be selected 1/6 chance
    
    if is_catchtrial == 1
        order = 3; 
        dist2=9999 ;
        dist_values = [dist_values dist2];
    else
        n = 2;
        order = randperm(n,1); %different trials, order 1 baseline is first, order 2 baseline is second
        
    end
    
    ordersave =  [ordersave order];
      
      
      
    for Phase = 1 : 2 %phase 1 plays first then phase 2
        if (order ==3) || (order ==1 && Phase == 1) || (order ==2 && Phase == 2)
            
           %if catchtrial, both phases play baseline
           %OR if different trial order 1 AND first phase play baseline
           %OR if different trial order 2 AND second phase play baseline
           
           soundwav = cos(timeT*2*pi*440); %plays the baseline - doesn't change
           
        else %if none of the above, then play the increasing one and save dist
            
            dist ;
            dist_values = [dist_values dist]; %saves all the dist values BEFORE the person hears them/makes a decisions
            newf = 440*2^(dist/12);
            soundwav = cos(timeT*2*pi*newf);
            if dist > 10
                disp('End Program and start again with higher preamp settings.')
            end
                
        end
        
       

        
         % Window the beginning and end of the stimuli slightly to avoid clicks
    taper = tukeywin(length(timeT),0.05);
    soundwav = soundwav .* taper';
 
    
    
            if Trial==1 && Phase==1

                disp('Hit return when ready to start')
                pause
            end

        if Trial~=1 && Phase==1
            disp(['Hit return to begin next trial'])
            pause
        end
        
        % t = [1/fs:1/fs:1.5];
        %y=Modulator(Trial, Phase)*Amp*sin(2*pi*1000*t);
        %y = Modulator(Trial, Phase)*voice;
        
        sound(.05*soundwav*10^(-6/20),fs); %65 dB on MOTU equipment
       % disp('Hit return when ready')
        if Phase == 1
            pause(2)
           
        end
        
        
        
        %         % Ask user for feedback on activation level required
        %         % if the user completed the task successfully
        if Phase == 2
            
            fprintf('Same (0) or Different (1)?');
            YourAnswer=getkey; %getkey is a function that finds the value of the next keypress
            fprintf('%c\n',YourAnswer) %displays the key that was entered
            if order == 1 || order == 2 % if it is a different trial
                if YourAnswer==49 %keypress=1
                    Ratingq=1; %they correctly said different
                    Correct =1; %correct
                   
                else
                    Ratingq=5; %So it will return false in the while loop
                end
                if YourAnswer==48 %keypress=0
                    Ratingq=0; %they incorrectly said same
                    Correct=2;%incorrect
                     
                end
            else %if it is a same trial (order ==3)
                if YourAnswer==49 %keypress=1
                    Ratingq=0; %they incorrectly said different
                    Correct=2; %incorrect
                   
                else
                    Ratingq=5; %So it will return false in the while loop
                end
                if YourAnswer==48 %keypress=0
                    Ratingq=2;%they correctly said same
                    Correct =1;%correct
                   
                end
            end
            
            while YourAnswer ~= 48 && YourAnswer ~= 49 % While the key that was entered is not 0 or 1
                fprintf('Try Again!! Same (0) or Different (1)?');
                YourAnswer=getkey;
                fprintf('%c\n',YourAnswer) ;
                if order == 1 || order == 2 % if it is a different trial
                    if YourAnswer==49 %keypress=1
                        Ratingq=1; %they correctly said different
                        Correct=1; %correct
                        
                    else
                        Ratingq=5; %So it will return false in the while loop
                    end
                    if YourAnswer==48 %keypress=0
                        Ratingq=0;%they incorrect said same
                        Correct=2; %incorrect
                        
                    end
                else %if it is a same trial, order == 3
                    if YourAnswer==49 %keypress=1
                        Ratingq=0; %draw a incorrect
                        Correct=2;%incorrect
                        
                    else
                        Ratingq=5; %So it will return false in the while loop
                    end
                    if YourAnswer==48 %keypress=0
                        Ratingq=2;% they correctly said same
                        Correct =1;%correct
                        
                    end
                end
            end
            
            
            
            
           Rating( Trial ) = Ratingq;
           Correctsave(Trial) = Correct;
            %Rating = 1 is success
           if dist < 0
                 dist = .02;
                 %disp('it was negative!') - D.A. took this out confuses
                 %subjects
                 upstep = 0.01;
                 downstep = upstep / 2.4483; 
           else
            if Trial > 10 %reduce step size
                %upstep = 3;
                upstep = 0.1;
                downstep = upstep / 2.4483; 
                if Trial > 20 %reduce step size again (last time)
                    upstep = 0.05;
                    downstep = upstep / 2.4483;
                end
            end %set at ratio of .71/(1-.71)
           end
            if Correctsave(Trial) == 1 %Success this turn
                if successkeeper == 1 %they got it right the last time too
                    if Trial > 3
                        if laststep == 1
                            reversals = reversals + 1;
                            revValues = [revValues dist];                        
                        end
                    end
                    dist = dist - downstep;
                    laststep = 0; %defining for next time
                end %if successkeeper was 0, they got it wrong last time, so no change in dist
                successkeeper = 1; %now defined for next time
            elseif Correctsave(Trial) == 2 %Failure this turn
                if Trial > 3
                    if laststep == 0
                        reversals = reversals + 1;
                        revValues = [revValues dist];
                    end
                end
                dist = dist + upstep;
                laststep = 1; %defining for next time
                successkeeper = 0;
       
                
            end
             if dist < 0
                 dist = .02;
                 %disp('it was negative!') 
             end
            if Trial > 74
                reversals = MaxReversals+1;
            end
            
        end
        
        TrialAnswer=Rating(end);
        
        % creates and saves data in folder
        outfile2=fullfile( answer{ 1 } ,['Trial_',num2str(Trial)]);
        save( outfile2, 'TrialAnswer')
    end
    
    
    
    % Saves in .mat format all the relevant RMS, y-axis, and time data along with the
    % ResultMatrix defined above.
%     ones(Trial,1) 
   
%     Rating

  % ResultMatrix = [ones(Trial,1) ,  dist_values', Rating'] ;
 
    ResultMatrix = [ dist_values', Correctsave', Rating', ordersave'] ;
    save( outfile , 'ResultMatrix' , 'revValues', 'ResultMatrixTitle'  ) ; 
end
ans=mean(revValues(end-5:end))
FullFile =  [ResultMatrixTitle; num2cell(ResultMatrix)];
save( outfile , 'ResultMatrix' , 'revValues', 'ResultMatrixTitle', 'FullFile'  ) ; 
%dist=(100*(ResultMatrix(:, 3)-1)); plot(dist);xlabel('Number of Trials'); ylabel('Percent Error (%)');title(['Hearing JND: ',answer{ 1 }]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANALYSIS OF GAME RESULTS
% Gives ResultMatrix, which holds target location, actual difficulty, and
% user-feedback on difficulty
% COLUMNS:
% [1] dist value
% [2] rating 0 = incorrect, 1 = correct on a different trial, 2 = correct on a same trial
% [3] order of trial, 1 = different with baseline first, 2 = different with baseline second, 3 = same
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








