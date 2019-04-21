function [Htilde Hplus Hminus] = HDRmerge(input, alphaPlus, alphaMinus, expoTimes, curRefImgNum)

triFunc = @(x) 2 * (0.5 - abs(0.5 - x));
numInputs = size(input, 2);
[h w c] = size(input{1});
H_LDRs = cell(1, numInputs);
lambda = cell(1, numInputs);

% A large value. Infinity cannot be used.
largeVal = 99999999;

for i = 1 : numInputs
    H_LDRs{i} = LDRtoHDR(input{i}, expoTimes(i));
    lambda{i} = triFunc(input{i});
end

%%% Compute H+ and H- using Eq. 5 ---------------------------
if (curRefImgNum < numInputs)
    Hplus = 0;
    totWplus = 0;
    for i = curRefImgNum+1 : numInputs
        Hplus = Hplus + lambda{i} .* H_LDRs{i};
        totWplus = totWplus + lambda{i};
    end
    Hplus = Hplus ./ totWplus;
    Hplus(totWplus == 0) = H_LDRs{numInputs}(totWplus == 0);
    
    HplusContribution = 1;
else
    Hplus = -largeVal * ones(h, w, c);
    HplusContribution = 0;
end

if (curRefImgNum > 1)
    Hminus = 0;
    totWminus = 0;
    for i = 1 : curRefImgNum-1
        Hminus = Hminus + lambda{i} .* H_LDRs{i};
        totWminus = totWminus + lambda{i};
    end
    Hminus = Hminus ./ totWminus;
    Hminus(totWminus == 0) = H_LDRs{1}(totWminus == 0);
    
    HminusContribution = 1;
else
    Hminus = largeVal * ones(h, w, c);
    HminusContribution = 0;
end
%%% --------------------------------------------------------

%%% Combine H+ and H - to form Htilde ----------------------
Htilde = (alphaPlus.*Hplus*HplusContribution+alphaMinus.*Hminus*HminusContribution)./(alphaPlus*HplusContribution+alphaMinus*HminusContribution);
Htilde((alphaPlus*HplusContribution+alphaMinus*HminusContribution) == 0) = 0;
%%% --------------------------------------------------------