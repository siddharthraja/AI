% Local Feature Stencil Code
% CS 4495 / 6476: Computer Vision, Georgia Tech
% Written by James Hays

% Returns a set of feature descriptors for a given set of interest points. 

% 'image' can be grayscale or color, your choice.
% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
%   The local features should be centered at x and y.
% 'feature_width', in pixels, is the local feature width. You can assume
%   that feature_width will be a multiple of 4 (i.e. every cell of your
%   local SIFT-like feature will have an integer width and height).
% If you want to detect and describe features at multiple scales or
% particular orientations you can add input arguments.

% 'features' is the array of computed features. It should have the
%   following size: [f_number x feature dimensionality] (e.g. 128 for
%   standard SIFT)

function [features] = get_features(image, x, y, feature_width)

% To start with, you might want to simply use normalized patches as your
% local feature. This is very simple to code and works OK. However, to get
% full credit you will need to implement the more effective SIFT descriptor
% (See Szeliski 4.1.2 or the original publications at
% http://www.cs.ubc.ca/~lowe/keypoints/)

% Your implementation does not need to exactly match the SIFT reference.
% Here are the key properties your (baseline) descriptor should have:
%  (1) a 4x4 grid of cells, each feature_width/4.
%  (2) each cell should have a histogram of the local distribution of
%    gradients in 8 orientations. Appending these histograms together will
%    give you 4x4 x 8 = 128 dimensions.
%  (3) Each feature should be normalized to unit length
%
% You do not need to perform the interpolation in which each gradient
% measurement contributes to multiple orientation bins in multiple cells
% As described in Szeliski, a single gradient measurement creates a
% weighted contribution to the 4 nearest cells and the 2 nearest
% orientation bins within each cell, for 8 total contributions. This type
% of interpolation probably will help, though.

% You do not have to explicitly compute the gradient orientation at each
% pixel (although you are free to do so). You can instead filter with
% oriented filters (e.g. a filter that responds to edges with a specific
% orientation). All of your SIFT-like feature can be constructed entirely
% from filtering fairly quickly in this way.

% You do not need to do the normalize -> threshold -> normalize again
% operation as detailed in Szeliski and the SIFT paper. It can help, though.

% Another simple trick which can help is to raise each element of the final
% feature vector to some power that is less than one.

% Placeholder that you can delete. Empty features.

    f_number = length(x);
    g = fspecial('Gaussian', feature_width , feature_width/2);
    gw = fspecial('Gaussian', feature_width/2 , 2); % window weights
    features = zeros(f_number, 128);
    win_step = 16;
    subwin_step = 4;
    bins = [0:45:360] * pi/180; % buckets
    % angle_bins = [-180:45:180];
    % [Ix , Iy] = gradient(image); 
    [magnitudes, angles] = imgradient(image);
    angles = angles + 180;
    angles = angles .* pi/180;
    magnitudes = imfilter(magnitudes, gw);
    
    for i=1:f_number
        descriptors = zeros(1,128); 
        step = 1;
        iterator = 1:subwin_step:win_step;
        
        win = angles(y(i)-feature_width/2+1 : y(i)+feature_width/2, x(i)-feature_width/2+1 : x(i)+feature_width/2);

%         disp(size(image))
%         disp('winwinwinwin\n')
%         disp((win))
%         disp('magnitudesmagnitudes\n')
%         disp((magnitudes))
%         disp('anglesanglesangles\n')
%         disp((angles))
        
        
        for I = iterator
            for J = iterator
                subwin_ang = win(I:I + subwin_step - 1, J:J + subwin_step - 1);
                % subwin_mag = magnitudes(I:I + subwin_step - 1, J:J + subwin_step - 1);
                orientations = subwin_ang(:);
                % ang = zeros(length(orientations), 1);               
                hist = histcounts(orientations', bins);  
                % Normalize, threshold and renormalize
                hist = hist / norm(hist);
                hist(hist > 0.2) = 0.2;
                hist = hist / norm(hist);
                descriptors(step:step+7) = hist;
                step = step + 8;
                
            end
        end

        features(i, :) = descriptors;
    end    
end








