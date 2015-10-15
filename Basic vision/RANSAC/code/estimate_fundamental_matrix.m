% Fundamental Matrix Stencil Code
% By Siddharth

function [ F_matrix ] = estimate_fundamental_matrix(Points_a,Points_b)

% normalization and centering of data
Ca_uv = mean(Points_a);
ua = Points_a(:,1) - Ca_uv(1);
va = Points_a(:,2) - Ca_uv(2);

Cb_uv = mean(Points_b);
ub = Points_b(:,1) - Cb_uv(1);
vb = Points_b(:,2) - Cb_uv(2);

% Prepare Ta
Scale_a = [sqrt(2)/rms(ua) sqrt(2)/rms(va)];
ua = Scale_a(1) * ua;
va = Scale_a(2) * va;
Ta = [Scale_a(1) 0 0; 0 Scale_a(2) 0; 0 0 1] * [1 0 -Ca_uv(1); 0 1 -Ca_uv(2); 0 0 1];
% Prepare Tb
Scale_b = [sqrt(2)/rms(ub) sqrt(2)/rms(vb)];
ub = Scale_b(1) * ub;
vb = Scale_b(2) * vb;
Tb = [Scale_b(1) 0 0; 0 Scale_b(2) 0; 0 0 1] * [1 0 -Cb_uv(1); 0 1 -Cb_uv(2); 0 0 1];

% system of equations [uu' + vu' + u' + uv' + vv' + v' + u + v + 1]
A = [ua.*ub va.*ub ub ua.*vb va.*vb vb ua va ones(size(ua))];

% det(F) = 0 constraint using SVD
[U, S, V] = svd(A);
f = V(:, end);
F_matrix = reshape(f, [3 3])';

% rank 2 constraint
[U1, S1, V1] = svd(F_matrix);
S1(3,3) = 0;
F_matrix = U1*S1*V1';

% apply transformations to get F in original pixel co-ordinates
F_matrix = Tb' * F_matrix * Ta;

end

