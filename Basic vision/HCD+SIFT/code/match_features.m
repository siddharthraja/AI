% author Siddharth Raja
function [matches, confidences] = match_features(features1, features2)

    %Initialize
    f1 = length(features1);
    f2 = length(features2);
    matches = zeros(f1, 2);
    confidences = zeros(f1, 1);
    fprintf('starting match_features...');
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

    % Sort the matches so that the most confident onces are at the top of the list. 
    [confidences, ind] = sort(confidences, 'descend');
    matches = matches(ind,:);
end