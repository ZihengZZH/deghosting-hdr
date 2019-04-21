function [ check ] = isimg( x )

if ndims(x) > 3 || size(x,3) == 2 || size(x,3) > 3 
    check = false; 
    return;
end

if isa(x, 'uint8') || isa(x, 'uint16')
    check = true;
elseif isa(x, 'double')    
    check = (max(x(:)) <= 1) && (min(x(:)) >= 0);
else
    check = false;
end 

end

