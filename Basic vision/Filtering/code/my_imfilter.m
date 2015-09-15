function output = my_imfilter(image, filter)
% This function is intended to behave like the built in function imfilter()
% See 'help imfilter' or 'help conv2'. While terms like "filtering" and
% "convolution" might be used interchangeably, and they are indeed nearly
% the same thing, there is a difference:
% from 'help filter2'
%    2-D correlation is related to 2-D convolution by a 180 degree rotation
%    of the filter matrix.

% Your function should work for color images. Simply filter each color
% channel independently.

% Your function should work for filters of any width and height
% combination, as long as the width and height are odd (e.g. 1, 7, 9). This
% restriction makes it unambigious which pixel in the filter is the center
% pixel.

% Boundary handling can be tricky. The filter can't be centered on pixels
% at the image boundary without parts of the filter being out of bounds. If
% you look at 'help conv2' and 'help imfilter' you see that they have
% several options to deal with boundaries. You should simply recreate the
% default behavior of imfilter -- pad the input image with zeros, and
% return a filtered image which matches the input resolution. A better
% approach is to mirror the image content over the boundaries for padding.

% % Uncomment if you want to simply call imfilter so you can see the desired
% % behavior. When you write your actual solution, you can't use imfilter,
% % filter2, conv2, etc. Simply loop over all the pixels and do the actual
% % computation. It might be slow.
% output = imfilter(image, filter);


%%%%%%%%%%%%%%%%
% Your code here
%%%%%%%%%%%%%%%%

% image reading section
 %----------------------------------
 clc
 %image = im2single(imread('../data/dog.bmp'));
 %filter = fspecial('Gaussian', [25 1], 10);
 %----------------------------------

 filter_dim = size(filter);
 m = floor(filter_dim(1)/2);
 n = floor(filter_dim(2)/2);
 filter_dim = int16(filter_dim);
 
 F = padarray(image, [m,n], 'symmetric'); 
 image_dim = int16(size(F));
 I = zeros(image_dim(1), image_dim(2), 3);

 for k = 1:3
    k
    for i = 1:image_dim(1) - filter_dim(1) + 1
        
        for j = 1:image_dim(2) - filter_dim(2) + 1
            %I(x, y, k) = sum(sum(filter .* F(i:i+filter_dim(1)-1, j:j+filter_dim(2)-1, k)));
            A = F(i:i+filter_dim(1)-1, j:j+filter_dim(2)-1, k);
            I(i+m, j+n, k) =  sum(sum(A.*filter));
            
        end
    end 
 end
 
 % removing extra padding
 I = I(m+1:image_dim(1)-m, n+1:image_dim(2)-n, 1:3);

 %imshow(I);
 output = I;

