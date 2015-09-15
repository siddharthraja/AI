close all; % closes all figures


image1 = im2single(imread('../data/m1.png'));
middle = im2single(imread('../data/m2.png'));
image2 = im2single(imread('../data/m3.png'));

% Low Freq Image
cutoff_frequency = 3.5;
filter = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency);
low_frequencies = my_imfilter(image1, filter);%my_imfilter(image1, filter);

% Middle Freq Image
cutoff_frequency = 7.5;
filter = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency);
mid1 = my_imfilter(middle, filter);%my_imfilter(middle, filter);
% ----
cutoff_frequency = 3.5;
filter = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency);
mid2 = mid1 - my_imfilter(mid1, filter);
middle_frequencies = mid1 + mid2;


% High Freq Image
cutoff_frequency = 7;
filter = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency);
high_frequencies = my_imfilter(image2, filter);%my_imfilter(image2, filter);
high_frequencies = image2 - high_frequencies;

hybrid_image = low_frequencies + middle_frequencies + high_frequencies;

%% Visualize and save outputs
figure(1); imshow(low_frequencies)
figure(2); imshow(middle_frequencies + 0.1)
figure(3); imshow(high_frequencies + 0.5);

imwrite(low_frequencies, 'low_frequencies.jpg', 'quality', 95);
imwrite(middle_frequencies, 'middle_frequencies.jpg', 'quality', 95);
imwrite(high_frequencies + 0.5, 'high_frequencies.jpg', 'quality', 95);
imwrite(hybrid_image, 'hybrid_image.jpg', 'quality', 95);
