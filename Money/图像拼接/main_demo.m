clear all
clc
file1='1.jpg';
file2='2.jpg';
I1=imread(file1);%��ȡͼƬ
I2=imread(file2);
 
imgs=[I1,I2];

img1=rgb2gray(I1);
img2=rgb2gray(I2);
imageSize=size(img1);
 
p1=detectSURFFeatures(img1);
p2=detectSURFFeatures(img2);%���SURF������
[img1Features, p1] = extractFeatures(img1, p1);%ʹ��64ά������ʾ����������,
%��һ�����صĲ�����Ϊÿ���������Ӧ�����������ӣ��ڶ���������������
[img2Features, p2] = extractFeatures(img2, p2);
boxPairs = matchFeatures(img1Features, img2Features);%����������ƥ��
 
matchedimg1Points = p1(boxPairs(:, 1));%�ڶ�������:���Բ��ӣ���Ϊ��Ϊn��1�еĽṹ������
matchedimg2Points = p2(boxPairs(:, 2));
[tform, inlierimg2Points, inlierimg1Points] = ...
estimateGeometricTransform(matchedimg2Points, matchedimg1Points, 'projective');%��Ӱ�任��tfromӳ����1�ڵ㵽���2�ڵ�
%�ú���ʹ���������һ���ԣ�RANSAC���㷨�ı���MSAC�㷨ʵ�֣�ȥ����ƥ���
%The returned geometric transformation matrix maps the inliers in matchedPoints1
%to the inliers in matchedPoints2.���صļ���ӳ�����ӳ���һ�����ڵ㵽�ڶ������ڵ�
 
showMatchedFeatures(I1, I2, inlierimg1Points, ...
    inlierimg2Points, 'montage');
title('Matched Points (Inliers Only)');



Rfixed = imref2d(size(I1));
[registered2, Rregistered] = imwarp(I2, tform);
%[registered1, Rregistered1] = imwarp(I1, tform);
figure()
imshowpair(I1,Rfixed,registered2,Rregistered,'blend');
title('ͼ�����');

[xlim, ylim] = outputLimits(tform, [1 imageSize(2)], [1 imageSize(1)]);%������귶Χ x:23.8~4334 y:-1844~1447
% �ҵ�����ռ����Ƶ������Сֵ
xMin = min([1; xlim(:)]);%1
xMax = max([imageSize(2); xlim(:)]);%4334
 
yMin = min([1; ylim(:)]);%-1844
yMax = max([imageSize(1); ylim(:)]);%3000
 
% ȫ��ͼ�Ŀ��
width  = round(xMax - xMin);
height = round(yMax - yMin);
 
 
 
%����2D�ռ�ο�������ȫ��ͼ�ߴ�
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width ], xLimits, yLimits);
 
% �任ͼƬ��ȫ��ͼ.
unwarpedImage = imwarp(I1,projective2d(eye(3)), 'OutputView', panoramaView);
warpedImage = imwarp(I2, tform, 'OutputView', panoramaView);

newImage=unwarpedImage;
newImage=double(newImage);
 
balck1=(warpedImage(:,:,1)==0 & warpedImage(:,:,2)==0 & warpedImage(:,:,3)==0);
balck2=(newImage(:,:,1)==0 & newImage(:,:,2)==0 & newImage(:,:,3)==0);
black=and(balck1,balck2);
black=~black;
 
maskA = (warpedImage(:,:,1)>0 |warpedImage(:,:,2)>0 | warpedImage(:,:,3)>0);%�任ͼ����Ĥ
mask1 = (newImage(:,:,1)>0 | newImage(:,:,2)>0 | newImage(:,:,3)>0);%�Ǳ任ͼ����Ĥ
mask1 = and(maskA, mask1);%�ص�����Ĥ

[row,col] = find(mask1==1);
left = min(col);
right = max(col);%����ص������ҷ�Χ
up=min(row);
down=max(row);
mask = ones(size(mask1));
% figure()
% imshow(mask)
%mask(:,left:right) = repmat(linspace(0,1,right-left+1),size(mask,1),1);%����ƽ�̾���
mask(up:down,:) = repmat(linspace(1,0,down-up+1)',1,size(mask,2));%����ƽ�̾���
% BLEND EACH CHANNEL
warpedImage=double(warpedImage);
% figure()
% warpedImage=uint8(warpedImage);
% imshow(warpedImage)
% figure()
% imshow(mask)
warpedImage(:,:,1) = warpedImage(:,:,1).*mask;
warpedImage(:,:,2) = warpedImage(:,:,2).*mask;
warpedImage(:,:,3) = warpedImage(:,:,3).*mask;
 
% REVERSE THE ALPHA VALUE
%mask(:,left:right) = repmat(linspace(1,0,right-left+1),size(mask,1),1);
mask(up:down,:) = repmat(linspace(0,1,down-up+1)',1,size(mask,2));%����ƽ�̾���
newImage(:,:,1) = newImage(:,:,1).*mask;
newImage(:,:,2) = newImage(:,:,2).*mask;
newImage(:,:,3) = newImage(:,:,3).*mask;
 
newImage(:,:,1) = warpedImage(:,:,1) + newImage(:,:,1);
newImage(:,:,2) = warpedImage(:,:,2) + newImage(:,:,2);
newImage(:,:,3) = warpedImage(:,:,3) + newImage(:,:,3);
 
% newImage(:,:,1) = newImage(:,:,1).*black;
% newImage(:,:,2) = newImage(:,:,2).*black;
% newImage(:,:,3) = newImage(:,:,3).*black;
newImage=uint8(newImage);
figure()
imshow(newImage);
title('ƴ��ͼ��');
