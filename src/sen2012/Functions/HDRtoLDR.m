function out = HDRtoLDR(input, expo)

global gamma;

input = single(input)*expo;
out = (input).^(1/gamma);
out = max(min(out,1),0);