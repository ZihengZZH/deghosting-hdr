function str = Sec2Str(sec)

secVec =[rem(floor(sec/3600),24) rem(floor(sec/60),60) rem(sec,60)];
secVec = round(secVec);

str = sprintf('%d:%02d:%02d',secVec);