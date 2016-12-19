%% Import data from text file.
% Script for importing data from the following text file.
% Spectrum: https://goo.gl/Zaojol
%
% clc
% clear all
% close all
function [data,transmission] =read_txt(PathName)
vettore=[400:5:810];
Wave = [];
Ampl = [];
nWave = [];

% How many txt files in the folder?
my_dir = fullfile(PathName,'NDF');
num = length(dir([my_dir, '/*.TXT']));

for i=1:num
%% Initialize variables.
    filename = strcat(PathName,'/NDF/',num2str(vettore(i)),'.txt');
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
 for i=1:num
     data(i,1) = max(nAmpl(:,i));
     %plot(vettore(1,i),data(i,1),'r--o');
 end
 transmission = Transmission(PathName);
end
 
%% Import Transmission Data ( optical density ) from xlsx file
    % example: OD=log10(1/Transmission)
function transmission = Transmission(PathName)
% How many xlsx files in the folder?
    num = length(dir([PathName, '/*.xlsx']));
    if(num == 1 )
        fprintf('You have used only one NDF');
        filename = strcat(PathName,'OP.xlsx');
        [~, ~, raw] = xlsread(filename,'%Transmission');
        raw = raw(3:end,3:4);

        %% Create output variable
        transmission = reshape([raw{:}],size(raw));

        %% Clear temporary variables
        clearvars raw; 
    else
        fprintf('You have used a combination of %d NDF',num);
        
    end
end
% for i=1:80
%   plot(Wave(:,i),nAmpl(:,i))
% end
%Plot limits
% xlim([350 850])