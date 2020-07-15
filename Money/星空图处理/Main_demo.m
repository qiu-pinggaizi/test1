clc;
clear;
close;
L = im2double(imread('星空图.png'));
im = rgb2gray(L);%彩色图转灰度图
L_denoise=wiener2(im,[3 3]); %对加噪图像进行二维自适应维纳滤波
%%
thresh = graythresh(L_denoise)*1.6;     %自动确定二值化阈值；
I1 =  im2bw(L_denoise,thresh);       %对图像二值化
%%
im2 =im - bwmorph(L_denoise,'bothat',2); %图像形态学处理
thresh2 = graythresh(im)*1.55;     %自动确定二值化阈值；
I2 =  im2bw(im2,thresh2);       %对图像二值化
%%
subplot(131),imshow(im),title('原图');
subplot(132),imshow(I1),title('直接二值化图像');
subplot(133),imshow(I2),title('形态学处理后再二值化处理图像');
