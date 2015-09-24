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
    threshold = 0.001;
    g = fspecial('Gaussian', 6, 2.2); % Found best results with sigma 2.2
    image = imfilter(image, g); % Blurring the image a little with Gaussian filter to reduce noise
    gx = [-1 0 1; -1 0 1; -1 0 1]; % Prewitt mask
    gy = gx';

    Ix = imfilter(image, gx); 
    Iy = imfilter(image, gy);
    Ix2 = imfilter(Ix.^2, g);
    Iy2 = imfilter(Iy.^2, g);
    Ixy = imfilter(Ix.*Iy, g);

    R = (Ix2.*Iy2 - Ixy.^2)./(Ix2 + Iy2); % Cornerness measure - Brown, Szeliski, and Winder (2005). Szeliski (4.11)

    R(R < threshold) = 0;
    r_dim = size(R);
    R(1: feature_width, :) = 0;R(r_dim(1) - feature_width: r_dim(1), :) = 0; % suppression of outputs near edges
    R(:, 1:feature_width) = 0;R(:, r_dim(2) - feature_width:r_dim(2)) = 0; % supp continued

    r_max = colfilt(R,[3 3],'sliding',@max); % find neighborhood max
    r_suppressed = R.*(R == r_max);  % suppress non-max
    [y, x] = find(r_suppressed); 
    
    figure(1);imshow(image);
    viscircles([x, y], ones(size([x, y],1),1));

end


