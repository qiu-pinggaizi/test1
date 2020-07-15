
clc;
clear all;
close all;
m = 6;
IM = {};
% ѭ����� ����ͼ��Ķ�ȡ
for i = 1:m
   IM{i} = imread(strcat(num2str(i),'.jpg')); 
end

i = 1;
input_A = IM{i};
% ѭ����� ����ͼ���ƴ��
while i<m
    input_B = IM{i+1};
    [input_A] = image_stitching(input_A, input_B);
    i = i+1
    imwrite(input_A,'666.jpg')
end

%ͼ��ƴ�Ӻ���
function [output_image] = image_stitching(input_A, input_B)

I1 = input_A;
I2 = input_B;
%imgs=[I1,I2];

img1=rgb2gray(I1);%ͼ��ҶȻ�
img2=rgb2gray(I2);%ͼ��ҶȻ�
imageSize=size(img1);
 
p1=detectSURFFeatures(img1);%���SURF������
p2=detectSURFFeatures(img2);%���SURF������
[img1Features, p1] = extractFeatures(img1, p1);%ʹ��64ά������ʾ����������,
%��һ�����صĲ�����Ϊÿ���������Ӧ�����������ӣ��ڶ���������������
[img2Features, p2] = extractFeatures(img2, p2);
boxPairs = matchFeatures(img1Features, img2Features);%����������ƥ��
 
matchedimg1Points = p1(boxPairs(:, 1));%�ڶ�������:���Բ��ӣ���Ϊ��Ϊn��1�еĽṹ������
matchedimg2Points = p2(boxPairs(:, 2));
[tform, ~, inlierimg1Points] = ...
estimateGeometricTransform(matchedimg2Points, matchedimg1Points, 'projective');%��Ӱ�任��tfromӳ����1�ڵ㵽���2�ڵ�

 
[xlim, ylim] = outputLimits(tform, [1 imageSize(2)], [1 imageSize(1)]);%������귶Χ x:23.8~4334 y:-1844~1447
% �ҵ�����ռ����Ƶ������Сֵ
xMin = min([1; xlim(:)]);%x�������Сֵ
xMax = max([imageSize(2); xlim(:)]);%x��������ֵ
 
yMin = min([1; ylim(:)]);%y�������Сֵ
yMax = max([imageSize(1); ylim(:)]);%y��������ֵ
 
% ȫ��ͼ�Ŀ��
width  = round(xMax - xMin);%�������ֵ����Сֵ�õ�x�ķ�Χ
height = round(yMax - yMin);%�������ֵ����Сֵ�õ�y�ķ�Χ
 
 
 
%����2D�ռ�ο�������ȫ��ͼ�ߴ�
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width ], xLimits, yLimits);%ȫ��ͼ�Ĵ�С
 
% �任ͼƬ��ȫ��ͼ.
unwarpedImage = imwarp(I1,projective2d(eye(3)), 'OutputView', panoramaView);
warpedImage = imwarp(I2, tform, 'OutputView', panoramaView);

newImage=unwarpedImage;
newImage=double(newImage);%��ͼ������ת��Ϊdouble����
 

 
maskA = (warpedImage(:,:,1)>0 |warpedImage(:,:,2)>0 | warpedImage(:,:,3)>0);%�任ͼ����Ĥ
mask1 = (newImage(:,:,1)>0 | newImage(:,:,2)>0 | newImage(:,:,3)>0);%�Ǳ任ͼ����Ĥ
mask1 = and(maskA, mask1);%�ص�����Ĥ

[row,col] = find(mask1==1);

up=min(row);
down=max(row);
mask = ones(size(mask1));%����ص������ص���Χ

mask(up:down,:) = repmat(linspace(1,0,down-up+1)',1,size(mask,2));%����ƽ�̾���

warpedImage=double(warpedImage);%��ͼ������ת��Ϊdouble����

warpedImage(:,:,1) = warpedImage(:,:,1).*mask;%�任ͼ��ĵ�һͨ������
warpedImage(:,:,2) = warpedImage(:,:,2).*mask;%�任ͼ��ĵڶ�ͨ������
warpedImage(:,:,3) = warpedImage(:,:,3).*mask;%�任ͼ��ĵ���ͨ������
 
mask(up:down,:) = repmat(linspace(0,1,down-up+1)',1,size(mask,2));%����ƽ�̾���
newImage(:,:,1) = newImage(:,:,1).*mask;%�Ǳ任ͼ��ĵ�һͨ������
newImage(:,:,2) = newImage(:,:,2).*mask;%�Ǳ任ͼ��ĵ�һͨ������
newImage(:,:,3) = newImage(:,:,3).*mask;%�Ǳ任ͼ��ĵ�һͨ������
 
newImage(:,:,1) = warpedImage(:,:,1) + newImage(:,:,1);%����ͼ��ĵ�һͨ������
newImage(:,:,2) = warpedImage(:,:,2) + newImage(:,:,2);%����ͼ��ĵڶ�ͨ������
newImage(:,:,3) = warpedImage(:,:,3) + newImage(:,:,3);%����ͼ��ĵ���ͨ������
 

newImage=uint8(newImage);%ͼ������ת����uint8����
figure()
imshow(newImage);%��ʾͼ��
title('ƴ��ͼ��');
output_image = newImage;%���ͼ��
end
