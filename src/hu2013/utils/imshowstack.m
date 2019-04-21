function imshowstack(varargin)

if length(varargin) > 1
    im = varargin;
else
    im = varargin{1};
end

h.numImgs = length(im);
h.im = im;
h.currImg = 1;

h.figHan = figure('KeyPressFcn',@UpdatePlots,'Name','Image 1','NumberTitle','off');
w = warning('off');
h.imData = imshow(im{1});
warning(w);
guidata(gcf,h);

function UpdatePlots(ig1,keyStroke)

        h = guidata(gcf);

        switch keyStroke.Key
            case 'leftarrow'
                
                if h.currImg == 1
                    return
                end
                h.currImg = h.currImg-1;

            case 'rightarrow'
                if h.currImg == h.numImgs;
                    return
                end
                h.currImg = h.currImg+1;

            otherwise
                return
        end

        set(h.imData,'CData',h.im{h.currImg})
        tlt = ['Image ' num2str(h.currImg)];
        set(gcf,'name',tlt)
        guidata(gcf,h)