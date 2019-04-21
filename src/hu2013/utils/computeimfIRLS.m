function [ ppIMF ] = computeimfIRLS( srcImg, refImg, viz )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function [ ppIMF ] = computeimfIRLS( srcImg, refImg, viz )
%  
%  computer Intensity Mapping Function by Iterativaly reweighted 
%  least square
%  
%  if viz is true, display the result
%
%  copyRight @ junhu@cs.duke.edu
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isequalsize(srcImg, refImg)
    error('computeimf: input imgs are different sizes/dims');
elseif ndims(srcImg) > 3 || ndims(srcImg) < 2 || ...
       ndims(refImg) > 3 || ndims(refImg) < 2
    error('computeimf: input imgs must be 2D or 3D');
end

if ~isa(srcImg, 'double') || ~isa(refImg, 'double') ...
        || min(srcImg(:)) < 0 || max(srcImg(:)) > 1 ...
        || min(refImg(:)) < 0 || max(refImg(:)) > 1 ...
    error('computeimf: input imgs must be double in the range[0 1]');    
end

if ~exist('viz', 'var')
    viz = false;
end


nChannel = size(srcImg,3);
edges{1} = 0:255;
edges{2} = 0:255;
    
for iCh = 1:nChannel

    srcSubCh = srcImg(:,:,iCh);
    refSubCh = refImg(:,:,iCh);

    mask = (~isnan(srcSubCh)) & (~isnan(refSubCh));
            
    XX(:,1) = 255 * srcSubCh(mask);
    XX(:,2) = 255 * refSubCh(mask);
    scloud  = hist3(XX, 'Edges', edges);            
    [y,x,w] = find(scloud);        
    
    ppIMF{iCh} = computeIRLS((double(x)-1)/255, (double(y)-1)/255, w);
    
    % Visualization
    if viz
        figure, imagesc(log(scloud+1));
        axis xy;
        hold on; plot(255*(0:.01:1), 255 * ppval(ppIMF{iCh},0:.01:1), 'g');
    end    
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  [ pp ] = computeIRLS( x, y, w )
%
%  solve the optimization 
%  using iterative reweighted least square (IRLS)
%
%  pp = argmin \sum_i weight(i)||pp(x(i)) - y(i)||_1
% 
%  where pp is modeled as nPieces piecewise Cubic Hermite  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ pp ] = computeIRLS( x, y, weight, nPieces )

if ~isequalsize(x, y) || ~isequalsize(x, weight)
    error('computeIRLS in computeimfIRLS: inputs size are different !');
end

if ~exist('nPieces', 'var')
    nPieces = 7;
end

% Removing potential outliers 
if mean(x(:)) > mean(y(:))    
    iGood = x < .98;
    x = x(iGood);
    y = y(iGood);
    weight = weight(iGood);
else
    iGood = x > .02;
    x = x(iGood);
    y = y(iGood);
    weight = weight(iGood);
end

x      = x(:);
y      = y(:);
weight = weight(:);
b      = linspace(min(x(:)) - eps, max(x(:)) + eps, nPieces + 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P is (2 * nPieces) x 1 matrix, 
% For the iPiece th piece Cubic Hermite Polynomial, its staring point value, 
% staring point tangent, ending point value and ending point tangent are 
% represented by the entries P(2 * iPiece - 1), P(2* iPiece), P(2 * iPiece + 1) 
% and P(2 * iPiece + 2) resp. 
%
% if data x(i) is in [b(iPiece), b(iPiece+1)], 
% then 
% xx(i,:) = (0 .................. 0, 2x_^3-3x_^2+1, x_^3-2x_^2+x_, -2x_^3+3x_^2, x_^3-x_^2, 0 ................... 0 ]
%           |<-   2*seg - 2     ->|                                                         |<-    2*l - 2*seg    ->|
%
% yy(i) = y(i);
% where x_ = (x - b(iPiece))/(b(iPiece+1) - b(iPiece))
%
% xx = |  * * * * 0 .....           0 |  -> normalized data in the interval [b(1), b(2)]
%      |  : : : : 0 .....           0 |  _____
%      |  0 ... 0 * * * * 0 ...     0 |  -> normalized data in the interval [b(2), b(3)]
%      |  :     : : : : : :         : |  :
%      |  0 ... 0 ....      0 * * * * |  _____
%      |  :     :           : : : : : |  -> normalized data in the interval [b(nPieces), b(nPieces+1)]
%      |  0 ... 0 ....      0 * * * * |  _____
%
% Therefore, 
% W * xx * P = W * yy or P = (W * xx) / (W * yy) is the optimal solution for 
% pp = argmin \sum_i w(i)||pp(x(i)) - y(i)||_2
% we apply a series of IRLS to approach the optimal solution for 
% pp = argmin \sum_i w(i)||pp(x(i)) - y(i)||_1
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Two extra samples (-.1,-.1) (1.1,1.1) for a better global sharpe
x      = cat(1,x,[-.1;1.1]);
y      = cat(1,y,[-.1;1.1]);
weight = cat(1,weight,[1;1]);

lengthPiece = zeros(nPieces,1);
xx          = zeros(length(x), 2 * nPieces + 2);
yy          = zeros(length(x), 1);

iStart = 1;
for iPiece = 1:nPieces

    if iPiece == 1
        iSelected = x < b(iPiece+1);
    elseif iPiece == nPieces
        iSelected = x >= b(iPiece);
    else
        iSelected = x >= b(iPiece) & x < b(iPiece + 1);
    end    
    
    x_ = x(iSelected); x_ = x_(:);
    y_ = y(iSelected); y_ = y_(:);
    
    % Normalization of data in the range [b(seg), b(seg+1)]
    x_ = x_ - b(iPiece);
    lengthPiece(iPiece) = max(eps, b(iPiece+1) - b(iPiece));
    x_  = x_ / lengthPiece(iPiece);
    x_2 = x_ .* x_;
    x_3 = x_2 .* x_;
    
    % Filling the normalized data to xx subsession
    subXX = [2 * x_3 - 3 * x_2 + 1, (x_3 - 2 * x_2  + x_) * lengthPiece(iPiece) , -2 * x_3 + 3 * x_2, (x_3 - x_2) * lengthPiece(iPiece) ];
    subXX = padarray(subXX, [0 2 * nPieces + 2 - 4], 'post');
    subXX = circshift(subXX, [0 2 * (iPiece - 1)]);
    
    iEnd              = iStart + sum(iSelected(:)) - 1;         
    xx(iStart:iEnd,:) = subXX;
    yy(iStart:iEnd,:) = y_;    
    iStart            = iEnd + 1;
end


ppOld = zeros(size(xx,2),size(yy,2));
hx    = ones(1,size(xx,2));
hy    = ones(1,size(yy,2));
wXX   = (weight * hx).* xx;
wYY   = (weight * hy).* yy;

xSample = 0:1/255:1;
iStart = 1;
for iPiece = 1:nPieces
    
    if iPiece == 1
        iSelected = xSample < b(iPiece+1);
    elseif iPiece == nPieces
        iSelected = xSample >= b(iPiece);
    else
        iSelected = xSample >= b(iPiece) & xSample < b(iPiece + 1);
    end
        
    x_  = xSample(iSelected); 
    x_  = x_(:);    
    x_  = x_ - b(iPiece);
    x_  = x_ / lengthPiece(iPiece);
    x_2 = x_ .* x_;
    x_3 = x_2 .* x_;
    
    % Filling the normalized data to xx subsession
    xSubSample = [2 * x_3 - 3 * x_2 + 1, (x_3 - 2 * x_2  + x_) * lengthPiece(iPiece) , -2 * x_3 + 3 * x_2, (x_3 - x_2) * lengthPiece(iPiece) ];
    xSubSample = padarray(xSubSample, [0 2 * nPieces + 2 - 4], 'post');
    xSubSample = circshift(xSubSample, [0 2 * (iPiece - 1)]);
    
    iEnd                    = iStart + sum(iSelected(:)) - 1;       
    xxSample(iStart:iEnd,:) = xSubSample;    
    iStart                  = iEnd + 1;
end

N  = size(xxSample,1);
B  = ones(N-1,2); B(:,1) = -1;
Dx = full(spdiags(B,[0 1], N-1, N));
C  = -Dx*xxSample;
d  = zeros(N-1,1);

C = cat(1, C, xxSample);
d = cat(1, d, ones(N,1));
C = cat(1, C, -xxSample);
d = cat(1, d, zeros(N,1));

B   = ones(N-2,2); B(:,1) = -1;
SDx = full(spdiags(B,[0 1], N-2, N-1));
SDx = SDx*Dx*xxSample;

if mean(x(:)) > mean(y(:))  
    C = cat(1, C, -SDx);
    d = cat(1, d, zeros(N-2,1));
else
    C = cat(1, C, SDx);
    d = cat(1, d, zeros(N-2,1));    
end

options = optimset('Display','none');
[ppNew, ~,~, exitflag] = lsqlin(wXX, wYY, C, d, [], [], [], [], wXX\wYY, options);

if exitflag == -2
    ppNew = lsqlin(wXX,wYY,C,d,[],[],[],[],[],options);    
elseif exitflag == 0
    while exitflag == 0                
       ppOld = ppNew;
       [ppNew, ~,~, exitflag] = lsqlin(wXX, wYY, C, d, [], [], [], [], ppOld, options); 
       if norm(ppOld(:)-ppNew(:), 2) < 1e-5
           break;
       end
    end
end

max_iteration = 1000;
iteration     = 0;
convergence   = norm(ppOld(:)-ppNew(:), 2);

while ( (convergence > 1e-5) && (iteration < max_iteration) )
    
    ppOld = ppNew;
    diffs = abs(xx*ppOld-yy);
    W     =  1./sqrt(diffs.^2 + (1e-6)^2);    
    
    W   = W.*weight;    
    wXX = (W*hx).*xx;
    wYY = (W*hy).*yy;
    
    [ppNew, ~,~, exitflag] = lsqlin(wXX, wYY, C, d, [], [], [], [], ppOld, options);
    if exitflag == -2
        ppNew = lsqlin(wXX,wYY,C,d, [], [], [], [], [], options);    
    elseif exitflag == 0
        while exitflag == 0                
           [ppNew, ~,~, exitflag] = lsqlin(wXX, wYY, C, d, [], [], [], [], ppNew, options); 
        end
    end
    
    convergence = norm(ppOld(:)-ppNew(:), 2);     
    iteration   = iteration + 1;
end

cc = zeros(nPieces,4);

for iPiece = 1:nPieces
    lengthPieceSq = lengthPiece(iPiece) * lengthPiece(iPiece);
    lengthPieceCb = lengthPiece(iPiece) * lengthPieceSq;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Computing the Cubic Hermite Polynomial Coefs for the non-normalized
    % data in the subinterval [b(iPiece)  b(iPiece+1)]
    % if, for the normalized data t \in [0 1]
    % p(t) = (2t^3-3t^2+1)P(2*iPiece-1) + (t^3-2t^2+t)P(2*iPiece) + (-2t^3+3t^2)P(2*iPiece+1) + (t^3-t^2)P(2*iPiece + 2)
    % then for the non-normalzied but shifted x \in [0  b(iPiece+1)-b(iPiece)]
    % y(x) = (x/D)^3(2*P(2*iPiece-1)+P(2*iPiece)-2P(2*iPiece+1)+P(2*iPiece+2)) +
    %        (x/D)^2(-3*P(2*iPiece-1)-2P(2*iPiece)+3P(2*iPiece+1)-P(2*iPiece+2)) +
    %        (x/D)^1P(2*iPiece) +
    %        (x/D)^0P(2*iPiece-1);
    % D = b(iPiece+1) - b(iPiece)
    % Note: non-normalized but shifted format is preferred for mkpp
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cc(iPiece,1) = ( 2 * ppNew( 2 * (iPiece - 1) + 1) + ppNew( 2 * (iPiece - 1) + 2) * lengthPiece(iPiece) - 2 * ppNew( 2 * (iPiece - 1) + 3) + ppNew( 2 * (iPiece - 1) + 4) * lengthPiece(iPiece)) / lengthPieceCb;
    cc(iPiece,2) = ( -3 * ppNew( 2 * (iPiece - 1) + 1) - 2 * ppNew( 2 * (iPiece - 1) + 2) * lengthPiece(iPiece)  + 3 * ppNew( 2 * (iPiece - 1) + 3) - ppNew( 2 * (iPiece - 1) + 4) * lengthPiece(iPiece) ) / lengthPieceSq;
    cc(iPiece,3) = ppNew( 2 * (iPiece - 1) + 2);
    cc(iPiece,4) = ppNew( 2 * (iPiece - 1) + 1);
end

pp = mkpp(b,cc);

end