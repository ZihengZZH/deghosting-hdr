function H = AlphaBlend(Href, Htilde, alpha)

%%% Use Eq. 6 to form final H ------------------------------
H = (1-alpha) .* Htilde + alpha .* Href;
%%% --------------------------------------------------------
