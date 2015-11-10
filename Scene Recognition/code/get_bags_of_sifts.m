% Code by siddharth
%reference: Szeliski chapter 14.

function image_feats = get_bags_of_sifts(image_paths)
% image_paths is an N x 1 cell array of strings where each string is an
% image path on the file system.

% This function assumes that 'vocab.mat' exists and contains an N x 128
% matrix 'vocab' where each row is a kmeans centroid or visual word. This
% matrix is saved to disk rather than passed in a parameter to avoid
% recomputing the vocabulary every time at significant expense.

% image_feats is an N x d matrix, where d is the dimensionality of the
% feature representation. In this case, d will equal the number of clusters
% or equivalently the number of entries in each image's histogram
% ('vocab_size') below.


load('vocab.mat') % assumes vocab.mat exists
vocab_size = size(vocab, 2);

image_feats = [];%zeros(size(image_paths,1), vocab_size);
for i=1:size(image_paths, 1)
    
    img = single(imread(num2str(cell2mat(image_paths(i)))));
    %img = vl_imsmooth(img,2);
    % step of 4 is fairly dense
    [locations, SIFT_features] = vl_dsift(img,'fast','STEP',4);
%     disp(size(img));
%     disp(size(locations));
%     disp(size(SIFT_features));
%     disp(locations);
    D = vl_alldist2(single(SIFT_features), vocab);
    [X,I] = min(D,[],2);
    histogram = histcounts(I,1:vocab_size+1);   
    normalized_hist=histogram/norm(histogram);
    
    % spatial matching level 1
%     sub_img1 = I(1:size(I,1)/2, 1:size(I,2)/2);
%     sub_img2 = I(1:size(I,1)/2, size(I,2)/2+1:size(I,2));
%     sub_img3 = I(size(I,1)/2+1:size(I,1), 1:size(I,2)/2);
%     sub_img4 = I(size(I,1)/2+1:size(I,1), size(I,2)/2+1:size(I,2));

%     level = 1;
%     normalized_hist = 0.5 * normalized_hist;
%     for k = 1:4     %2^(level+1)
%         den = 2;    %2^1;
%         switch(k)
%             case 1
%                 r1 = 1; c1 = 1; r2 = floor(size(I,1)/den); c2 = floor(size(I,2)/den);
%             case 2
%                 r1 = 1; c1 = 1+floor(size(I,2)/den); r2 = floor(size(I,1)/den); c2 = size(I,2);
%             case 3
%                 r1 = 1+floor(size(I,1)/den); c1 = 1; r2 = size(I,1); c2 = floor(size(I,2)/den);
%             case 4
%                 r1 = 1+floor(size(I,1)/den); c1 = 1+floor(size(I,2)/den); r2 = size(I,1); c2 = size(I,2);
%         end
%         sub_col = locations(2,:);
%         cols = sub_col(find(locations(1,:)>=r1 & locations(1,:)<=r2));
% 
%         disp(size(cols));
%         sub_indexes = find(cols>=c1 & cols<=c2);
%         sub_SIFT = SIFT_features(:,sub_indexes);
%         sub_D = vl_alldist2(single(sub_SIFT), vocab);
%         [sub_X,sub_I] = min(sub_D,[],2);
%         sub_hist = histcounts(sub_I,1:vocab_size+1);   
%         sub_hist_normalized=sub_hist/norm(sub_hist);
%         weight = 1;
%         normalized_hist=[normalized_hist sub_hist_normalized];
%     end

    
    % end spatial matching code
    image_feats(i,:)=normalized_hist;

end
fprintf('done with bag of sifts\n');