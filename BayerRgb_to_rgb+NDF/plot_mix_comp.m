%% The script read npy's array ( with Bayer format ) and extract RGB's array in specific area of image.
%  In final it plot the QE.
% Verions 0.3 - 14-12-2016 Davide Gariselli Git: 
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
n = input('Number of NDFs filters: ');
%n = 1;
%NDF_name = input('Write NDF filter: ','s');


for a=1:n
    %% Search .npy files
    NDF = input('What NDFs filter did you used: ');
    fprintf('Please load NPY capture with NDF: %1.1f \n',NDF);
    [FileName,PathName]= uigetfile('*.npy','Select source directory:');
    % Load spectrum for specific NDF
    fprintf('Loading spectrum\n');
    data = read_txt(NDF);
    %Samples= input('How many samples per each flow? ')

    txt_files = dir([PathName, '*.npy']);   % Search for npy files in the selected path
    files_name = {txt_files.name};         % Name of the npy files in the folder
    N=length (files_name);                  % How many npy files in the folder? N!
    %% What to plot in X axis
    vettore = strrep(files_name,'.npy','');
    vettore = str2double(vettore);
    %% Preallocate Memory matrix
%     color = zeros(Height*Width, 1);
%     RGB_images = zeros(3,Height*Width);

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
                %a_B_n = color/255;
                a_B_m = mean(color);
                %a_B_m = color/max(abs(color(:)));
                RGB_images(3,i) = a_B_m;
            elseif z==2
                %a_G_n = color/255;
                a_G_m = mean(color);
                %a_G_m = color/max(abs(color(:)));
                RGB_images(2,i) = a_G_m;
            else
                %a_R_n = color/255;
                a_R_m = mean(color);
                %a_R_m = color/max(abs(color(:)));
                RGB_images(1,i) = a_R_m;
            end
        end
    end
    %% Normalized respect max
    RGB_images_n = RGB_images/max(abs(RGB_images(:)));
    
    %% Subtract RBG_images (normalized respect max) to Data monochromator
    %% txt (normalized respect max) and fill mono.
    
    for y=1:N
        for x=1:3
            mono(x,y,a) = RGB_images_n(x,y) / data(y,1);
        end
    end
    mono(4,1:N,a) = vettore;
    mono(5,1,a) = NDF;
    mono(5,2,a) = N;
    
    if (a==n)
        % put on top the vector
        %mono = circshift(mono,1);
        fprintf('salta\n');
        lol=1;
    end
    
end

%% Multi plot with NDF's mean
     %% Start before first time

if lol == 1
    % News matrix in Z with first mattrix (z=1)
    mono(:,:,n+1) = mono(:,:,1);
    % Number of NDFs filters
    for z=2:n
        % cerca ultimo valore di n+1 dentro a z+1
        last = mono(4,:,n+1);
        [rowStart,colStart] = find(mono(4,:,z) == last(end));
        % a me interessano le colonne, inzio di quello che devo copiare in
        % n+1
        % cerca ultimo vettore in z+1
        %prova = mono( 1:3,colStart:mono(5,2,z),z );
        mono(1:3,mono(5,2,n+1):( mono(5,2,n+1)+(mono(5,2,z)-colStart) ), n+1 ) = mono( 1:3,colStart:mono(5,2,z),z );
        last = union(last,mono(4,:,n));
        % delate the first zero column
        last(:,1)=[];
        % new vettore
        mono(4,:,n+1) = last;
        % new NDF
        mono(5,1,n+1) = mono(5,1,n);
        % new size
        mono(5,2,n+1) = size(last,2);
    end
end
%             p = find(h_vect == vettore(i));
%             % Existing value
%             if p~=0
%                 for x=1:3
%                     media = RGB_images(x,i) - h_RGB(x,p);
%                     if i == 1
%                         media_RGB(x,1) = media;
%                     else
%                         media_RGB(x,2) = media;
%                     end
%                 end
%                 % it is a column vector containing the mean of each row.
%                 media_RGB = mean(media_RGB,2);
%             % New elements
%             else
%                 q = length(h_RGB)+1;
%                 for x=1:3
%                     RGB_images(x,i) = RGB_images(x,i) - media_RGB(x,1);
%                     h_RGB(x,q) = RGB_images(x,i);
%                 end
%             end
%         end
%         % combine data from A and B with no repetitions. 
%         h_vect = union(h_vect,vettore);
%     end
%     
%     %% Print quantum efficiency
%     if lol == 1 || n == 1
%         if n == 1
%             h_vect = vettore;
%             %h_RGB = RGB_images;
%             h_RGB = mono;
%             q=N;
%         end
%         figure()
%         grid on
%         hold on
%         for i=1:q
%             plot(h_vect(1,i),h_RGB(1,i),'r--o');
%             plot(h_vect(1,i),h_RGB(2,i),'g--o');
%             plot(h_vect(1,i),h_RGB(3,i),'b--o');
%         end
%     end
%     % Run only  the first time
%     if lol == 0 
%         h_vect = vettore;
%         h_RGB = RGB_images;
%         lol = 1;
%     end 
