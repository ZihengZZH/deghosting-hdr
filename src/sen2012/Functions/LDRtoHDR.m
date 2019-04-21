function out = LDRtoHDR(input, expo)

global gamma;

input = max(min(input,1),0);
input = single(input);
out = (input).^gamma;
out = out/expo;

