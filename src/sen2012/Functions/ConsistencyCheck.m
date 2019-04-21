function H = ConsistencyCheck(Href, H, Hplus, Hminus, vMaxImg, vMinImg, curRefExpoTime)

vMaxRadiance = LDRtoHDR(vMaxImg, curRefExpoTime);
vMinRadiance = LDRtoHDR(vMinImg, curRefExpoTime);

%%% Consistency check --------------------------------------
H(Href > vMaxRadiance & Hminus < vMaxRadiance) = Href(Href > vMaxRadiance & Hminus < vMaxRadiance);
H(Href < vMinRadiance & Hplus > vMinRadiance) = Href(Href < vMinRadiance & Hplus > vMinRadiance);
%%% --------------------------------------------------------
