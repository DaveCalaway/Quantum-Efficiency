%% Import data from text file.
% Script for importing data from the following text file.
% Spectrum: https://goo.gl/Zaojol
%
% clc
% clear all
% close all
function data =read_txt(NDF)
vettore=[400:5:800];
Wave = [];
Ampl = [];
nWave = [];
for i=1:80
%% Initialize variables.
if NDF == 0.6
    filename = strcat('/Users/Dave/Desktop/tesi/A_NDF06/',num2str(vettore(i)),'.txt');
else
    filename = strcat('/Users/Dave/Desktop/tesi/A_NDF12/',num2str(vettore(i)),'.txt');
end
delimiter = '\t';
%% Format string for each line of text:
formatSpec = '%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
 W = dataArray{:, 1};
 A = dataArray{:, 2};

    if i==1 %at first iteration saves the data in an array
        Wave=W;
        Ampl=A;
    else    %for the following iterations builds the data matrixes
        Wave=[Wave, W];
        Ampl=[Ampl, A];
    end

%% Close the text file.
fclose(fileID);
clearvars filename delimiter formatSpec fileID dataArray ans;
end
%% Allocate imported array to column variable names
%  figure()
%   grid on
%   hold on
% Apmlitude normalized respect max
 nAmpl = Ampl/max(abs(Ampl(:)));
 for i=1:80
     data(i,1) = max(nAmpl(:,i));
     %plot(vettore(1,i),data(i,1),'r--o');
 end
% for i=1:80
%   plot(Wave(:,i),nAmpl(:,i))
% end
%Plot limits
% xlim([350 850])