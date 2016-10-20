function data = recorStimulusWord (Words,nRep, trialDur,genderSubject)
initializeAudapter (genderSubject)
%%
close all;
% monitorSize = get(0,'Monitor');
% if size(monitorSize,1) == 1
%     figPosition = [1 200 monitorSize(3) monitorSize(4)-200];
% elseif size(monitorSize,1) == 2
%     figPosition = [monitorSize(2,1) monitorSize(2,2)+20 monitorSize(2,3) monitorSize(2,4)];
% end
figure1 = figure('Color',[0 0 0],'Menubar','none','Position',[-1280 1050 1281 1026]);%'Position',figPosition,

textBox1 = annotation(figure1,'textbox',...
    [0.25 0.65 0.5 0.25],...
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


textBox2 = annotation(figure1,'textbox',...
    [0 0 1 0.4],...
    'Color',[1 1 1],...
    'String','PLEASE SOFTER!',...
    'LineStyle','none',...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle',...
    'FontSize',90,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none',...
    'BackgroundColor',[0 0 1],...
    'Visible','off');
drawnow;
pause(5)

%% Present words and collect the results
 

for i = 1:nRep
    a = randperm(length(Words));
    wordOrder(:,i) = a';
    for j = 1:length(Words)
        outDesignMatrix{j,i} = Words{a(j)};
        
    end
end

outDesignMatrix = outDesignMatrix(:);
wordOrder = wordOrder(:);

for tr = 1:length(outDesignMatrix)
    
    
    set(textBox1,'String',outDesignMatrix{tr,1})
    
    % start Audapter
    Audapter('reset');
    Audapter('start');
    % wait and receive data
    pause(trialDur);
    fprintf(1, '\n');
    Audapter('stop');
    
    % save the data
    data1 = AudapterIO('getData');
    data{tr} = data1;
    data{tr}.trialType = wordOrder(tr);
%     fileNameData = [folderName 'Trial_' num2str(tr) '.mat'];
%     save(fileNameData,'data');
    
    % calculate RMS (SPL) based on the data and present the feedback
    set(textBox1,'String',' ')
    pause(1)
    
    
end

close all;

