function freq = bin_to_freq(bin, fs, nfft)
%BIN_TO_FREQ Converts frequency bin to frequency in Hz.

freq = bin * fs / nfft;

end

