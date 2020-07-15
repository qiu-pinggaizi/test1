clear all
clc
file1='1.jpg';
file2='2.jpg';
I1=imread(file1);%读取图片
I2=imread(file2);
 
imgs=[I1,I2];

img1=rgb2gray(I1);
img2=rgb2gray(I2);
imageSize=size(img1);
 
p1=detectSURFFeatures(img1);
p2=detectSURFFeatures(img2);%检测SURF特征点
[img1Features, p1] = extractFeatures(img1, p1);%使用64维向量表示特征描述子,
%第一个返回的参数即为每个特征点对应的特征描述子，第二个参数是特征点
[img2Features, p2] = extractFeatures(img2, p2);
boxPairs = matchFeatures(img1Features, img2Features);%特征描述子匹配
 
matchedimg1Points = p1(boxPairs(:, 1));%第二个参数:可以不加，因为其为n行1列的结构体数组
matchedimg2Points = p2(boxPairs(:, 2));
[tform, inlierimg2Points, inlierimg1Points] = ...
estimateGeometricTransform(matchedimg2Points, matchedimg1Points, 'projective');%射影变换，tfrom映射点对1内点到点对2内点
%该函数使用随机样本一致性（RANSAC）算法的变体MSAC算法实现，去除误匹配点
%The returned geometric transformation matrix maps the inliers in matchedPoints1
%to the inliers in matchedPoints2.返回的几何映射矩阵映射第一参数内点到第二参数内点
 
showMatchedFeatures(I1, I2, inlierimg1Points, ...
    inlierimg2Points, 'montage');
title('Matched Points (Inliers Only)');



Rfixed = imref2d(size(I1));
[registered2, Rregistered] = imwarp(I2, tform);
%[registered1, Rregistered1] = imwarp(I1, tform);
figure()
imshowpair(I1,Rfixed,registered2,Rregistered,'blend');
title('图像差异');

[xlim, ylim] = outputLimits(tform, [1 imageSize(2)], [1 imageSize(1)]);%输出坐标范围 x:23.8~4334 y:-1844~1447
% 找到输出空间限制的最大最小值
xMin = min([1; xlim(:)]);%1
xMax = max([imageSize(2); xlim(:)]);%4334
 
yMin = min([1; ylim(:)]);%-1844
yMax = max([imageSize(1); ylim(:)]);%3000
 
% 全景图的宽高
width  = round(xMax - xMin);
height = round(yMax - yMin);
 
 
 
%创建2D空间参考对象定义全景图尺寸
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width ], xLimits, yLimits);
 
% 变换图片到全景图.
unwarpedImage = imwarp(I1,projective2d(eye(3)), 'OutputView', panoramaView);
warpedImage = imwarp(I2, tform, 'OutputView', panoramaView);

newImage=unwarpedImage;
newImage=double(newImage);
 
balck1=(warpedImage(:,:,1)==0 & warpedImage(:,:,2)==0 & warpedImage(:,:,3)==0);
balck2=(newImage(:,:,1)==0 & newImage(:,:,2)==0 & newImage(:,:,3)==0);
black=and(balck1,balck2);
black=~black;
 
maskA = (warpedImage(:,:,1)>0 |warpedImage(:,:,2)>0 | warpedImage(:,:,3)>0);%变换图像掩膜
mask1 = (newImage(:,:,1)>0 | newImage(:,:,2)>0 | newImage(:,:,3)>0);%非变换图像掩膜
mask1 = and(maskA, mask1);%重叠区掩膜

[row,col] = find(mask1==1);
left = min(col);
right = max(col);%获得重叠区左右范围
up=min(row);
down=max(row);
mask = ones(size(mask1));
% figure()
% imshow(mask)
%mask(:,left:right) = repmat(linspace(0,1,right-left+1),size(mask,1),1);%复制平铺矩阵
mask(up:down,:) = repmat(linspace(1,0,down-up+1)',1,size(mask,2));%复制平铺矩阵
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
mask(up:down,:) = repmat(linspace(0,1,down-up+1)',1,size(mask,2));%复制平铺矩阵
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
title('拼接图像');
