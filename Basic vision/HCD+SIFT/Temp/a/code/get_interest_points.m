% Local Feature Stencil Code
% CS 4495 / 6476: Computer Vision, Georgia Tech
% Written by James Hays

% Returns a set of interest points for the input image

% 'image' can be grayscale or color, your choice.
% 'feature_width', in pixels, is the local feature width. It might be
%   useful in this function in order to (a) suppress boundary interest
%   points (where a feature wouldn't fit entirely in the image, anyway)
%   or(b) scale the image filters being used. Or you can ignore it.

% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
% 'confidence' is an nx1 vector indicating the strength of the interest
%   point. You might use this later or not.
% 'scale' and 'orientation' are nx1 vectors indicating the scale and
%   orientation of each interest point. These are OPTIONAL. By default you
%   do not need to make scale and orientation invariant local features.
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

% Implement the Harris corner detector (See Szeliski 4.1.1) to start with.
% You can create additional interest point detector functions (e.g. MSER)
% for extra credit.

% If you're finding spurious interest point detections near the boundaries,
% it is safe to simply suppress the gradients / corners near the edges of
% the image.

% The lecture slides and textbook are a bit vague on how to do the
% non-maximum suppression once you've thresholded the cornerness score.
% You are free to experiment. Here are some helpful functions:
%  BWLABEL and the newer BWCONNCOMP will find connected components in 
% thresholded binary image. You could, for instance, take the maximum value
% within each component.
%  COLFILT can be used to run a max() operator on each sliding window. You
% could use this to ensure that every interest point is at a local maximum
% of cornerness.

% Get Required image derivatives
gauss = fspecial('Gaussian', feature_width, 2);
image = imfilter(image, fspecial('Gaussian',5, 1));
gy = fspecial('sobel');
gx = gy';
Ix = imfilter(image, gx); Iy = imfilter(image, gy);
Ix2 = imfilter(Ix.^2, gauss);Iy2 = imfilter(Iy.^2, gauss);Ixy=imfilter(Ix.*Iy, gauss);

% Get pixel response
R = (Ix2.*Iy2 - Ixy.^2) - 0.045*(Ix2 + Iy2).^2;

% Threshold the response
R(R < 0.0005) = 0;
[height, width] = size(R);

%Supress edges
R(:, 1:feature_width) = 0;
R(:, width - feature_width:width) = 0;
R(1: feature_width, :) = 0;
R(height - feature_width: height, :) = 0;



%Local Non-maximal Supression
offset = floor(feature_width/2);
for row=1+offset:height-offset
    for col=1+offset:width-offset
        window = R(row-offset:row+offset, col-offset:col+offset);
        if R(row,col) ~=  max(max(window))
            R(row,col) = 0;
        end 
    end
end

[y, x] = find(R>0);

%Vis Corners
figure(3);imshow(image);
viscircles([x, y], ones(size([x, y],1),1));


end


function radius = getMaxRadius(image, x, y, width, height)

radius = 0;
window = image(x-radius:x+radius, y-radius:y+radius);
    while max(window(:)) <= image(x,y)
        radius = radius + 1;
        if (x-radius < 1) || (x+radius)> height || (y-radius < 1) || (y+radius)> width
            break
        end
        window = image(x-radius:x+radius, y-radius:y+radius);
    end
end

