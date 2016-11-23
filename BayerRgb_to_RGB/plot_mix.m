%% The script read npy's array ( with Bayer format ) and extract RGB's array in specific area of image.
%  In final it plot the QE.
% Verions 0.3 - 23-11-2016 Davide Gariselli Git: https://goo.gl/pFs9TY
%% What did you have crop?
    %  im = readNPY('/Users/Dave/Desktop/tesi/test.npy');
    %  J = demosaic(im,'grbg');
    %  figure, imshow(J);
    %  [I2, rect] = imcrop(J);
    %  Copy position of area selected, paste it in 'Crop' value.
clc
clear all
close all
Height = 5;
Width = 5;
Crop = [1380.5 1098.5 24 22];
lol = 0;
%% Numbers of captures. 
% If you have more then one, keep in mind to start with NDF lower to NDF highter.
n = 1;

for a=1:n
    %% Search .npy files
    [FileName,PathName]= uigetfile('*.npy','Select source directory:');
    % Asks the user to select the folder where the software should look for npy log files

    %Samples= input('How many samples per each flow? ')

    txt_files = dir([PathName, '*.npy']);   % Search for npy files in the selected path
    files_name = {txt_files.name};         % Name of the npy files in the folder
    N=length (files_name);                  % How many npy files in the folder? N!
    %% What to plot in X axis
    vettore = strrep(files_name,'.npy','');
    vettore = str2double(vettore);
    %% Preallocate Memory matrix
    color = zeros(Height*Width, 1);
    RGB_images = zeros(3,Height*Width);

    %% scroll all images
    for i=1:N
        %% Initialize variables.
        filename = [PathName,txt_files(i).name];
        %filename = strcat('/Users/Dave/Desktop/tesi/myfile/',N2str(vettore(i)),'.jpg');
        delimiter = '\t';
        %% Function to read NPY files,BayerRgb, into matlab.
        BayerRgb= readNPY(filename);
        %% BayerRgb to Bilinear Demosaicing
        %  3 x Width-by-Height colors
        Demo = demosaic(BayerRgb,'grbg');

        %% What did you have crop?
        I2 = imcrop(Demo, Crop);
        imshow(I2)

        %% Color extraction
        for z=1:3
            pos=1;
            for x=1:Width
                for y=1:Height
                    color(pos) = I2(x,y,z);
                    pos=pos+1;
                end
            end
            %% Normalized and Mean
            if z==1
                a_B_n = color/255;
                a_B_m = mean(a_B_n);
                RGB_images(3,i) = a_B_m;
            elseif z==2
                a_G_n = color/255;
                a_G_m = mean(a_G_n);
                RGB_images(2,i) = a_G_m;
            else
                a_R_n = color/255;
                a_R_m = mean(a_R_n);
                RGB_images(1,i) = a_R_m;
            end
        end
    end


    %% Multi plot with NDF's mean

    %% Start before first time
    if lol == 1
        for i=1:N
            p = find(h_vect == vettore(i));
            % Existing value
            if p~=0
                for x=1:3
                    media = RGB_images(x,i) - h_RGB(x,p);
                    if i == 1
                        media_RGB(x,1) = media;
                    else
                        media_RGB(x,2) = media;
                    end
                end
                % it is a column vector containing the mean of each row.
                media_RGB = mean(media_RGB,2);
            % New elements
            else
                q = length(h_RGB)+1;
                for x=1:3
                    RGB_images(x,i) = RGB_images(x,i) - media_RGB(x,1);
                    h_RGB(x,q) = RGB_images(x,i);
                end
            end
        end
        % combine data from A and B with no repetitions. 
        h_vect = union(h_vect,vettore);
    end
    
    %% Print quantum efficiency
    if lol == 1 || n == 1
        if n == 1
            h_vect = vettore;
            h_RGB = RGB_images;
            q=N;
        end
        figure()
        grid on
        hold on
        for i=1:q
            plot(h_vect(1,i),h_RGB(1,i),'r--o');
            plot(h_vect(1,i),h_RGB(2,i),'g--o');
            plot(h_vect(1,i),h_RGB(3,i),'b--o');
        end
    end
    % Run only  the first time
    if lol == 0 
        h_vect = vettore;
        h_RGB = RGB_images;
        lol = 1;
    end 
end