clc;
clear;
close;
L = im2double(imread('�ǿ�ͼ.png'));
im = rgb2gray(L);%��ɫͼת�Ҷ�ͼ
L_denoise=wiener2(im,[3 3]); %�Լ���ͼ����ж�ά����Ӧά���˲�
%%
thresh = graythresh(L_denoise)*1.6;     %�Զ�ȷ����ֵ����ֵ��
I1 =  im2bw(L_denoise,thresh);       %��ͼ���ֵ��
%%
im2 =im - bwmorph(L_denoise,'bothat',2); %ͼ����̬ѧ����
thresh2 = graythresh(im)*1.55;     %�Զ�ȷ����ֵ����ֵ��
I2 =  im2bw(im2,thresh2);       %��ͼ���ֵ��
%%
subplot(131),imshow(im),title('ԭͼ');
subplot(132),imshow(I1),title('ֱ�Ӷ�ֵ��ͼ��');
subplot(133),imshow(I2),title('��̬ѧ������ٶ�ֵ������ͼ��');
