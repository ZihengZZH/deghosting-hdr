%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function [ f ] = solvescreenedpossion(g, hx, hy, lambda)
%
%  sovle screened possion equation:
%  
%  f = argmin  (f-g)^2 - lambda * ( (fx, fy) - (hx, hy) )^2
%
%  where (fx, fy) is the gradient of f
%
%  copyRight @ junhu@cs.duke.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ f ] = solvescreenedpossion(g, hx, hy, lambda)

if ~exist('lambda', 'var')
    lambda = 1;
end

if ndims(g) > 3
    error('Current Version only supports 2d, 3d data');
end

[h,w,c] = size(g);
dx      = [1,-1];
dy      = [1;-1];
g_size  = [h,w];
otfDx   = psf2otf(dx, g_size);
otfDy   = psf2otf(dy, g_size);

Denominator = repmat( abs(otfDx).^2 + abs(otfDy ).^2, [1 1 c]);
Denominator = 1 + lambda*Denominator;

Numerator = [hx(:,end,:) - hx(:, 1,:), -diff(hx,1,2)] + ...
    [hy(end,:,:) - hy(1,:,:); -diff(hy,1,1)];

F_f = (fft2(g) + lambda*fft2(Numerator))./Denominator;
f   = real(ifft2(F_f));

end

