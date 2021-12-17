clc;
clear;
close all;

% load acquired image data
back = open('Data/rowDataVoltsBscanBackground.mat').sigATS';
back_len = size(back, 1);

a = open('Data/rowDataVoltsBscan.mat');
a_reshaped = reshape(a.sigATS',back_len,[]);

signal = a_reshaped - back;
im = abs(fft(signal));

figure(1)
imshow(im);

% dispersion compensation variables
c =  299792458;         %Speed of light
laserCenterWavelength = 1060E-9;    %Laser centre wavelength
w0 = 2*pi*c/laserCenterWavelength*1E-15;
Lf=1110E-9;
wi=2*pi*c/Lf*1E-15;
Li=1010E-9;
wf=2*pi*c/Li*1E-15;
w=(linspace(wi,wf,size(im,1)))';

% %Phase information extraction
% hilIm = hilbert(im);
% phase = atan2((imag(hilIm)),real(hilIm));

% coefficients - tuned through app
cvals = [500 650 0 0 0 0 0 0 0 0];
a2 = cvals(2);
a3 = cvals(3);
a4 = cvals(4);
a5 = cvals(5);
a6 = cvals(6);
a7 = cvals(7);
a8 = cvals(8);
a9 = cvals(9);

% dispersion transformation
dQ =  (a9*(w-w0).^9 + a8*(w-w0).^8 + a7*(w-w0).^7 + a6*(w-w0).^6 + a5*(w-w0).^5 + a4*(w-w0).^4 +a3*(w-w0).^3 + a2*(w-w0).^2  ) ;

% apply dQ to image data, column by column
for k=1:size(im,2)
   im(:,k) = im(:,k) .* dQ;
end

figure(2)
imshow(im);

% transform to Fourier domain for viewing
shifted_img = fftshift(im);

img_y_len = size(im, 1);
cropped_img = shifted_img(1:img_y_len/2, :);

% imitate range selectors
l = min(min(cropped_img));
u = max(max(cropped_img));
gray = mat2gray(cropped_img, [l,u]);
figure(3)
imshow(gray, [l, u]);

% display final transformed image
figure(4)
transformed_img = ifft(ifftshift(im));
imshow(transformed_img(1:img_y_len/2, :))