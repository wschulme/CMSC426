%% Pin Detection Experiment
%  Author: Chahat Deep Singh

clear
clc
close all
%% 1.2.1: Denoise Images

% Reading the image:
I = imread('TestImgResized.jpg');
subplot(3,3,1), imshow(I);
title('Input Image');

% Converting RGB to Gray:
gr = rgb2gray(I);
% figure, imshow(gr);
% title('Grayscale');

% Median Filter:
m = medfilt2(gr);
% figure, imshow(m);
% title('Median Filter');

%% Gaussian Filter:

% Read an Image and converting it to Grayscale:
% Ctrl+D
Im2 = imadjust(rgb2gray(I));
I = double(Im2);

% Defining Sigma:
s = .5; 

% Defining Window size
wz = 2;
[x,y] = meshgrid(-wz:wz,-wz:wz);

%% You can replace Line 39-56 with a simple Gaussian Filter:
% Gaussian function:
X = size(x,1)-1;
Y = size(y,1)-1;
exponential_component = -(x.^2+y.^2)/(2*s*s);
g_kernel= exp(exponential_component)/(2*pi*s*s);

g_image = zeros(size(I));

% Padding the vector with 255 (in order to get white boundries):
zI = padarray(I,[wz wz],255);

% Convolving the image with the gaussian kernel:
for i = 1:size(I,1)-X
    for j =1:size(I,2)-Y
        temp = I(i:i+X,j:j+Y).*g_kernel;
        g_image(i,j)=sum(temp(:));
    end
end

%Image after Gaussian blur
g_image = uint8(g_image);
% figure,imshow(g_image);
% title('Gaussian Filtered Image');

%% 1.2.2: Find Total number of Colored Objects:

BW = im2bw(g_image,graythresh(g_image));

% Seperating Red Green Blue Channels:
I = imread('TestImgResized.jpg');
I = medfilt3(I);

r = I(:,:,1);   %% Red Channel
g = I(:,:,2);   %% Green Channel
b = I(:,:,3);   %% Blue Channel

% Defining Thresholds for each Channel:
rlow   = 95;
rhigh  = 255;
glow   = 0;
ghigh  = 255;
blow   = 98;
bhigh  = 255;

%3 different Channels
redMask     = (r > rlow & r < rhigh);
greenMask   = (g > glow & g < ghigh);
blueMask    = (b > blow & r < bhigh);

% ALL Pins Mask
WT_Mask = uint8(redMask & greenMask & blueMask);

% Counting total number of pins:
N = bwconncomp(BW);
number_of_colored_pins = N.NumObjects;
str = sprintf('Total number of colored objects = %d',N.NumObjects);
disp(str);
subplot(3,3,2), imshow(WT_Mask,[]);

% figure, imshow(BW);
title(str);

%% 1.2.3: Find Red, Green, Yellow and Blue Pins:

GreenPins = r > 0 & r < 15 & g > 55 & g < 255 & b > 0 & b < 85;
BluePins = r > 0 & r <45 & g > 0 & g < 65 & b > 84 & b < 255;
YellowPins = r > 55 & r < 255 & g > 125 & g < 255 & b > 0 & b < 70;
RedPins = r > 80 & r < 255 & g > 0 & g < 70 & b > 0 & b < 120;

% Morphing:
GreenPins = bwmorph(GreenPins, 'dilate', 4);
BluePins = bwmorph(BluePins, 'dilate', 4);
YellowPins = bwmorph(YellowPins, 'dilate', 4);
RedPins = bwmorph(RedPins, 'dilate', 2);

subplot(3,3,3), imshow(GreenPins), title('Green Pins');
subplot(3,3,4), imshow(BluePins), title('Blue Pins');
subplot(3,3,5), imshow(YellowPins), title('Yellow Pins');
subplot(3,3,6), imshow(RedPins), title('Red Pins');

AllPins = uint8(YellowPins | GreenPins | BluePins | RedPins);

maskedI = uint8(zeros(size(AllPins))); % Initialize
maskedI(:,:,1) = I(:,:,1) .* AllPins;
maskedI(:,:,2) = I(:,:,2) .* AllPins;
maskedI(:,:,3) = I(:,:,3) .* AllPins;
subplot(3, 3, 7);
imshow(maskedI);
title('Masked Colored Pins');

%% 1.2.4: Find Transparent and White Pins:

% Using Sobel Operator to detect all the pin edges:
Z = edge(gr, 'Prewitt', 0.034);
Z = bwmorph(Z, 'dilate', 14);
Z = bwmorph(Z, 'erode', 18);
Z = bwmorph(Z, 'dilate', 3);

% Subtracting Colored Pins (binary version) from All pins found by Sobel:
WT_Pins = logical(WT_Mask) - (1 - Z);
WT_Pins = medfilt2(medfilt2(medfilt2(medfilt2(medfilt2(medfilt2...
          (WT_Pins))))));  % Applying Multiple Median filters

subplot(3,3,8), imshow(WT_Pins), title('White and Transparent Pins');

WT = uint8(WT_Pins);

% Display White and Transparent Pins in the original image:
maskedI = uint8(zeros(size(WT))); % Initialize
maskedI(:,:,1) = I(:,:,1) .* WT;
maskedI(:,:,2) = I(:,:,2) .* WT;
maskedI(:,:,3) = I(:,:,3) .* WT;
subplot(3, 3, 9);
imshow(maskedI);
title('Masked White and Tran. Pins');
