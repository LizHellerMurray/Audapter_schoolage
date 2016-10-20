clear all;
close all;
clc


fs = 44100;
tt = linspace(0,2,2*fs);

fOut = [100 200 400 800 1600 3200 6400 12800];
pause(10)
for i =1:length(fOut)
    y = .75*sin(2*pi*tt*fOut(i));
    disp(rms(y))
    sound(y,fs);
%     player = audioplayer(y, fs,16,3);
%     play(player);
    pause(4);
end 
