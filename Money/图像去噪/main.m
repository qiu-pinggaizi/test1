clc;
clear;
close;
Im_ori = imread('lena.jpg'); 

%%

sigma = (20*20)/(255*255); 
Im_noisy = imnoise(Im_ori, 'gaussian', 0, sigma); 
Im = double(Im_noisy);

%%

N = 16;
I = ones(N);
D = zeros(N);
for i = 1:N
    for j = 2:N
       if i==j
           D(i,j)=1;
           D(i,j-1)=-1;
       end
    end
end
D(1,1) = 0;
B = [kron(I,D)
    kron(D,I)];
B_T = B';
%%
y0 = B*Im;
%y0 = zeros(size(y0));
I_2d = ones(2*N*N);
k = 0.16;
u = 0.07; 
p = u/k;
y_k = y0;
for i = 1:50
    y1 = (y0+(I_2d-k*B*B_T)*y_k);
    y2 = y1;  
    [a,b] = size(y2);
    for jj = 1:a
        for pp = 1:b
            if y2(jj,pp)>p
               y2(jj,pp) = y2(jj,pp)-p;
            end
            if y2(jj,pp)<-p
               y2(jj,pp) = p+y2(jj,pp);
            end
            if -p<=y2(jj,pp)<=p
               y2(jj,pp) = 0;
            end          
        end
        y = y1-y2;
    end
    y_k = y;  
end
F_im = Im - k*B_T*y;

fprintf('End');
imshow(uint8(F_im));

