function bin = freq_to_bin(freq, fs, nfft)
%FREQ_TO_BIN Converts frequency to fft bin

bin = freq * nfft / fs;

end

