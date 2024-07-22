function convert(infile, outfile)
    v = VideoReader(infile);
    vidFrame = readFrame(v);
    out = zeros(size(vidFrame,1), size(vidFrame,2), 1);
    mcframe = double(rgb2gray(vidFrame))/255;
    out(:,:,1) = mcframe;
    counter = 1;
    while hasFrame(v)
        counter = counter + 1;
        vidFrame = readFrame(v);
        mcframe = double(rgb2gray(vidFrame))/255;
        out(:,:,counter) = mcframe;
    end
    save(outfile, 'out');
end