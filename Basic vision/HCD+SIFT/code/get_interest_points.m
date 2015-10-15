% Written by Siddharth Raja
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

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
    fprintf('finished get_interest_points\n');


end


