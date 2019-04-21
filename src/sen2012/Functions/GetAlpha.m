function a = GetAlpha(x, status, Max, Min)

global vMax;
global vMin;

if (~exist('status', 'var'))
    status = 'both';
end

if(~exist('Max', 'var'))
    Max = vMax;
end
if(~exist('Min', 'var'))
    Min = vMin;
end

a = ones(size(x));

if (strcmp(status, 'low') || strcmp(status, 'both'))
    Ind = x > Max;
    a(Ind) = 1 - (x(Ind) - Max) / (1 - Max);
end

if (strcmp(status, 'high') || strcmp(status, 'both'))
    Ind = x < Min;
    a(Ind) =  x(Ind) / Min;
end
