function [VarName1,rate1,dur1,durHold,rate2] = importfile(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [VARNAME1,RATE1,DUR1,DURHOLD,RATE2] = IMPORTFILE(FILENAME) Reads data
%   from text file FILENAME for the default selection.
%
%   [VARNAME1,RATE1,DUR1,DURHOLD,RATE2] = IMPORTFILE(FILENAME, STARTROW,
%   ENDROW) Reads data from rows STARTROW through ENDROW of text file
%   FILENAME.
%
% Example:
%   [VarName1,rate1,dur1,durHold,rate2] =
%   importfile('persistent_pitch_pert.pcf',5, 5);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2015/03/08 18:53:59

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 5;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: double (%f)
%	column2: text (%s)
%   column3: text (%s)
%	column4: text (%s)
%   column5: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
VarName1 = dataArray{:, 1};
rate1 = dataArray{:, 2};
dur1 = dataArray{:, 3};
durHold = dataArray{:, 4};
rate2 = dataArray{:, 5};

