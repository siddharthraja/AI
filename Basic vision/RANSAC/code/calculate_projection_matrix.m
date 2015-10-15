% Projection Matrix Stencil Code
% By Siddharth

function M = calculate_projection_matrix( Points_2D, Points_3D )



u = Points_2D(:,1);
v = Points_2D(:,2);
X = Points_3D(:,1);
Y = Points_3D(:,2);
Z = Points_3D(:,3);

odd = [ X Y Z ones(size(u)) zeros(size(u)) zeros(size(u)) zeros(size(u)) zeros(size(u)) -u.*X -u.*Y -u.*Z -u ];
even = [ zeros(size(u)) zeros(size(u)) zeros(size(u)) zeros(size(u)) X Y Z ones(size(u)) -v.*X -v.*Y -v.*Z -v];
A = zeros((size(odd, 1)*2), size(odd, 2));
% Interleaving
for i = 1:1:size(u)
    A(2*i-1,:) = odd(i,:);
    A(2*i,:) = even(i,:);
end

[U, S, V] = svd(A);
M = V(:,end);
M = reshape(M,[],3)';


end

