function [Y, Ypeaks, nfft] = do_binaural_fft(x)
%DO_FFT returns real, 0-nyquist fft of x

%% error checking
if max(size(x)) < 2             % make sure input is more than 2 samples long
    error('fft input is too small');
elseif min(size(x)) ~= 1        % make sure input has only one channel
    error('fft input must be mono');
end

%% get info about input
L = length(x);                  % get number of samples in input
nfft = 2^nextpow2(L);           % get number of samples in fft        

%% do the fft
Y = fft(x, nfft);               % get fft
Ypeaks = abs(Y(1:end/2));       % get all real frequencies below nyquist
Ypeaks = gain_to_dB(Ypeaks);	% convert gain to dB

end
