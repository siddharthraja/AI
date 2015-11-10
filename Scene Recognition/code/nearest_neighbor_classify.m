% by siddharth

%This function will predict the category for every test image by finding
%the training image with most similar features. Instead of 1 nearest
%neighbor, you can vote based on k nearest neighbors which will increase
%performance (although you need to pick a reasonable value for k).

function predicted_categories = nearest_neighbor_classify(train_image_feats, train_labels, test_image_feats)
% image_feats is an N x d matrix, where d is the dimensionality of the
%  feature representation.
% train_labels is an N x 1 cell array, where each entry is a string
%  indicating the ground truth category for each training image.
% test_image_feats is an M x d matrix, where d is the dimensionality of the
%  feature representation. You can assume M = N unless you've modified the



M = size(test_image_feats,1);
predicted_categories = cell(M,1);
D = vl_alldist2(test_image_feats', train_image_feats');
% 1 nearest neighbor
[Y,I] = min(D);    
    
for i=1:M
    predicted_categories(i) = train_labels(I(i));
end
fprintf('done with nearest neighbor\n');






