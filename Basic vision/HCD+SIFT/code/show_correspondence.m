% Visualizes corresponding points between two images. Corresponding points
% will have the same random color.

function [ h ] = show_correspondence(imgA, imgB, X1, Y1, X2, Y2)

h = figure(2);
Height = max(size(imgA,1),size(imgB,1));
Width = size(imgA,2)+size(imgB,2);
numColors = size(imgA, 3);
newImg = zeros(Height, Width,numColors);
newImg(1:size(imgA,1),1:size(imgA,2),:) = imgA;
newImg(1:size(imgB,1),1+size(imgA,2):end,:) = imgB;
imshow(newImg, 'Border', 'tight')
shiftX = size(imgA,2);
hold on
for i = 1:size(X1,1)
    cur_color = rand(3,1);

    plot(X1(i),Y1(i), 'o', 'LineWidth',2, 'MarkerEdgeColor','k',...
                       'MarkerFaceColor', cur_color, 'MarkerSize',10)

    plot(X2(i)+shiftX,Y2(i), 'o', 'LineWidth',2, 'MarkerEdgeColor','k',...
                       'MarkerFaceColor', cur_color, 'MarkerSize',10)

end
hold off;

fprintf('Saving visualization to vis.jpg\n')
visualization_image = frame2im(getframe(h));

imwrite(visualization_image, 'vis_dots.jpg', 'quality', 100)