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
% % matches = zeros(length(features1) , 2);
% % confidences = zeros(length(features1),1);
% % 
% % threshold = 0.875;
% % for i = 1:length(features1)
% %     distances = sqrt(sum((repmat(features1(i,:),length(features2),1)-features2).^2,2));
% %     [dists,indices] = sort(distances,'ascend');
% %     ratio = dists(1)/dists(2);
% %     if ratio < threshold
% %         matches(i,:) = [i indices(1)];
% %         confidences(i) = 1-ratio;
% %     end
% % end
% % 
% % matches(all(matches==0,2),:)=[];
% % confidences(all(matches==0,2),:)=[];
% Sort the matches so that the most confident onces are at the top of the
% list. You should probably not delete this, so that the evaluation
% functions can be run on the top matches easily.
% [confidences, ind] = sort(confidences, 'descend');
% matches = matches(ind,:);
% #################################################################################################################
	f1 = length(features1);
	f2 = length(features2);
	matches = zeros(f1, 2);
	confidences = zeros(f1, 1);
    distances = zeros(f2, f1);
    threshold = 0.865;
	% find the euclidian distance between each pair of descriptors in feature
	% space

	for i = 1:f1
	    for j = 1:f2
	        distances(j, i) = norm(features1(i, :) - features2(j, :));
            [sorted_distances, inds] = sort(distances);
            ratio = sorted_distances(1, i) / sorted_distances(2, i);
            if ratio < threshold
                matches(i, :) = [i, inds(1, i)];
                confidences(i) = 1 - ratio;
            end
	    end
	end


% 	[sorted_distances, inds] = sort(distances); % sort distances in ascending order
% 
% 	% calculate ratio of nearest neighbor to second nearest neighbor
% 	% if above threshold, add to matches list and save ratio as confidence value
% 	for i = 1 : f1
% 	    ratio = sorted_distances(1, i) / sorted_distances(2, i);
% 	    if ratio < threshold
% 	        matches(i, :) = [i, inds(1, i)];
% 	        confidences(i) = 1 - ratio;
% 	    end
% 	end

	% keep only those that matched
	match_inds = find(confidences > 0);
	matches = matches(match_inds, :);
	confidences = confidences(match_inds);

	% Sort the matches so that the most confident onces are at the top of the list
	[confidences, ind] = sort(confidences, 'descend');
	matches = matches(ind, :);

end