
clc;
clear all;
close all;
m = 6;
IM = {};
% 循环语句 进行图像的读取
for i = 1:m
   IM{i} = imread(strcat(num2str(i),'.jpg')); 
end

i = 1;
input_A = IM{i};
% 循环语句 进行图像的拼接
while i<m
    input_B = IM{i+1};
    [input_A] = image_stitching(input_A, input_B);
    i = i+1
    imwrite(input_A,'666.jpg')
end

%图像拼接函数
function [output_image] = image_stitching(input_A, input_B)

I1 = input_A;
I2 = input_B;
%imgs=[I1,I2];

img1=rgb2gray(I1);%图像灰度化
img2=rgb2gray(I2);%图像灰度化
imageSize=size(img1);
 
p1=detectSURFFeatures(img1);%检测SURF特征点
p2=detectSURFFeatures(img2);%检测SURF特征点
[img1Features, p1] = extractFeatures(img1, p1);%使用64维向量表示特征描述子,
%第一个返回的参数即为每个特征点对应的特征描述子，第二个参数是特征点
[img2Features, p2] = extractFeatures(img2, p2);
boxPairs = matchFeatures(img1Features, img2Features);%特征描述子匹配
 
matchedimg1Points = p1(boxPairs(:, 1));%第二个参数:可以不加，因为其为n行1列的结构体数组
matchedimg2Points = p2(boxPairs(:, 2));
[tform, ~, inlierimg1Points] = ...
estimateGeometricTransform(matchedimg2Points, matchedimg1Points, 'projective');%射影变换，tfrom映射点对1内点到点对2内点

 
[xlim, ylim] = outputLimits(tform, [1 imageSize(2)], [1 imageSize(1)]);%输出坐标范围 x:23.8~4334 y:-1844~1447
% 找到输出空间限制的最大最小值
xMin = min([1; xlim(:)]);%x方向的最小值
xMax = max([imageSize(2); xlim(:)]);%x方向的最大值
 
yMin = min([1; ylim(:)]);%y方向的最小值
yMax = max([imageSize(1); ylim(:)]);%y方向的最大值
 
% 全景图的宽高
width  = round(xMax - xMin);%利用最大值和最小值得到x的范围
height = round(yMax - yMin);%利用最大值和最小值得到y的范围
 
 
 
%创建2D空间参考对象定义全景图尺寸
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width ], xLimits, yLimits);%全景图的大小
 
% 变换图片到全景图.
unwarpedImage = imwarp(I1,projective2d(eye(3)), 'OutputView', panoramaView);
warpedImage = imwarp(I2, tform, 'OutputView', panoramaView);

newImage=unwarpedImage;
newImage=double(newImage);%把图像数据转变为double类型
 

 
maskA = (warpedImage(:,:,1)>0 |warpedImage(:,:,2)>0 | warpedImage(:,:,3)>0);%变换图像掩膜
mask1 = (newImage(:,:,1)>0 | newImage(:,:,2)>0 | newImage(:,:,3)>0);%非变换图像掩膜
mask1 = and(maskA, mask1);%重叠区掩膜

[row,col] = find(mask1==1);

up=min(row);
down=max(row);
mask = ones(size(mask1));%获得重叠区域重叠范围

mask(up:down,:) = repmat(linspace(1,0,down-up+1)',1,size(mask,2));%复制平铺矩阵

warpedImage=double(warpedImage);%把图像数据转变为double类型

warpedImage(:,:,1) = warpedImage(:,:,1).*mask;%变换图像的第一通道数据
warpedImage(:,:,2) = warpedImage(:,:,2).*mask;%变换图像的第二通道数据
warpedImage(:,:,3) = warpedImage(:,:,3).*mask;%变换图像的第三通道数据
 
mask(up:down,:) = repmat(linspace(0,1,down-up+1)',1,size(mask,2));%复制平铺矩阵
newImage(:,:,1) = newImage(:,:,1).*mask;%非变换图像的第一通道数据
newImage(:,:,2) = newImage(:,:,2).*mask;%非变换图像的第一通道数据
newImage(:,:,3) = newImage(:,:,3).*mask;%非变换图像的第一通道数据
 
newImage(:,:,1) = warpedImage(:,:,1) + newImage(:,:,1);%两种图像的第一通到叠加
newImage(:,:,2) = warpedImage(:,:,2) + newImage(:,:,2);%两种图像的第二通到叠加
newImage(:,:,3) = warpedImage(:,:,3) + newImage(:,:,3);%两种图像的第三通到叠加
 

newImage=uint8(newImage);%图像数据转变我uint8类型
figure()
imshow(newImage);%显示图像
title('拼接图像');
output_image = newImage;%输出图像
end
