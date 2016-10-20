%% notes on space
% x is frequency (bins)
% y is weight (0-1)
% z is magnitude (dB.)
%
% we're trying to solve for z.
clear all;

%% line
% x = 2;
y = 0.5;
z = 0; % ???
% P = [x, y];

%% quadrilateral
A = [1, 0, 0];
B = [3, 0, 0];
C = [1, 1, 0];
D = [3, 1, 1];

%% intersection between triangles (ABC or BCD)
% find the vectors connecting the point (P) to each of the triangles three
% vertices and sum the angles between those vectors. if the sum of the
% angles is 2*pi, then the point is inside the triangle.

domain = [-1, 5];
for x = linspace(domain(1), domain(2), 1000)
    
P = [x, y]; 

% intersect triangle 1 (ABC)?
isInTriangle1 = P_in_triangle(P, A(1:2), B(1:2), C(1:2));
isInTriangle2 = P_in_triangle(P, B(1:2), C(1:2), D(1:2));

Pindicator = 'k*';
if isInTriangle1
    Pindicator = 'r*';
elseif isInTriangle2
    Pindicator = 'g*';
end

plot([A(1), B(1), C(1), A(1)], [A(2), B(2), C(2), A(2)]); hold on;
plot([B(1), C(1), D(1), B(1)], [B(2), C(2), D(2), B(2)]); 
plot(P(1), P(2), Pindicator);
axis([domain(1), domain(2), -1, 2]);
hold off;
drawnow;
pause(0.005);

end

%% solve for z
% v1 = A - B;
% v2 = A - C;
% cp = cross(v1, v2);
% k = cp(1)*D(1) + cp(2)*D(2) + cp(3)*D(3);
% z = (1/cp(3))*(k - cp(1)*x - cp(2)*y);