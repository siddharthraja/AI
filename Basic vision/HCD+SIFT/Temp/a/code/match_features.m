% Local Feature Stencil Code
% CS 4495 / 6476: Computer Vision, Georgia Tech
% Written by James Hays

% 'features1' and 'features2' are the n x feature dimensionality features
%   from the two images.
% If you want to include geometric verification in this stage, you can add
% the x and y locations of the features as additional inputs.
%
% 'matches' is a k x 2 matrix, where k is the number of matches. The first
%   column is an index in features 1, the second column is an index
%   in features2. 
% 'Confidences' is a k x 1 matrix with a real valued confidence for every
%   match.
% 'matches' and 'confidences' can empty, e.g. 0x2 and 0x1.
function [matches, confidences] = match_features(features1, features2)

    % This function does not need to be symmetric (e.g. it can produce
    % different numbers of matches depending on the order of the arguments).

    % To start with, simply implement the "ratio test", equation 4.18 in
    % section 4.1.3 of Szeliski. For extra credit you can implement various
    % forms of spatial verification of matches.


    %Initialize
    f1 = length(features1);
    f2 = length(features2);
    matches = zeros(f1, 2);
    confidences = zeros(f1, 1);
    fprintf('starting match features...');
    threshold = 0.85;
    for i = 1:f1
        temp_mat = repmat(features1(i,:), f2, 1);   
        distances = sqrt(sum((temp_mat - features2).^2, 2));
        [sortdist, indices] = sort(distances, 'ascend');
        ratio = sortdist(1) / sortdist(2);
        if ratio < threshold
            matches(i,:) = [i,indices(1)];
            confidences(i) = 1 - ratio;
        end
    end

    matched = find(confidences > 0);
    matches = matches(matched, :);
    confidences = confidences(matched);

    % Sort the matches so that the most confident onces are at the top of the
    % list. You should probably not delete this, so that the evaluation
    % functions can be run on the top matches easily.
    [confidences, ind] = sort(confidences, 'descend');
    matches = matches(ind,:);
end