% Automated Panorama Stitching stencil code

function [ h ] = show_correspondence2(imgA, imgB, X1, Y1, X2, Y2)

h = figure(3);
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
    plot([X1(i) shiftX+X2(i)],[Y1(i) Y2(i)],'*-','Color', cur_color, 'LineWidth',2)
end
hold off

fprintf('Saving visualization to vis.jpg\n')
visualization_image = frame2im(getframe(h));
imwrite(visualization_image, 'vis_arrows.jpg', 'quality', 100)