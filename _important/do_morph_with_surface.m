function newx = do_morph_with_surface(x1, x2, M, weight)

%% do fft
nfft = length(x1);
Ndb = nfft / 2 + 1;
Y1 = fft(x1, nfft);
Y2 = fft(x2, nfft);
Ydb1 = gain_to_dB(abs(Y1(1:Ndb)));
Ydb2 = gain_to_dB(abs(Y2(1:Ndb)));
Yph1 = unwrap(angle(Y1(1:Ndb)));
Yph2 = unwrap(angle(Y2(1:Ndb)));

%% make interpolated Ydb's
YM1 = linear_interpolation(Ydb1, M(:,1));
YM2 = linear_interpolation(Ydb2, M(:,2));

%% morph
newYdb = zeros(size(Ydb1));
Yindex = 2;
FREQ = 1; MAG = 2;  % helper indices
for e = 2:length(M) - 1
    b = e - 1;
    
    % this surface (corner points)
    % b === beginning (closer to bin 1)
    % e === ending (closer to bin Ndb)
    % suffix 1 is for weight = 0
    % suffix 2 is for weight = 1
    % finally, as a note, B1(1) is the frequency, B1(2) is the magnitude,
    % weight is not in here, but it should be. the problem is flattened in
    % the representation below.
    B1 = [M(b, 1), YM1(b)];
    E1 = [M(e, 1), YM1(e)];
    B2 = [M(b, 2), YM2(b)];
    E2 = [M(e, 2), YM2(e)];
    
    % points between line segments that connect Y1 to Y2
    bPoint = weighted_mean(B1, B2, weight);
    ePoint = weighted_mean(E1, E2, weight);
    
    % if the new Y index that we're looking for is between this line
    % segment, then figure out the elevation (or magnitude) at the point
    % (Yindex, weight, elevation).
    if bPoint(FREQ) <= Yindex && Yindex <= ePoint(FREQ)
        slope = (ePoint(MAG) - bPoint(MAG)) / (ePoint(FREQ) - bPoint(FREQ));
        newYdb(Yindex) = slope * (Yindex - bPoint(FREQ)) + bPoint(MAG);
        Yindex = Yindex + 1;
    end
end

newYdb(1) = weighted_mean(Ydb1(1), Ydb2(1), weight);
newYdb(end) = weighted_mean(Ydb1(end), Ydb2(end), weight);

%% return result
newMag = dB_to_gain(newYdb);
newMag = [newMag; newMag(end-1:-1:2)];
newPhase = wrapToPi(weighted_mean(Yph1, Yph2, weight));
newPhase = [newPhase; -1.*newPhase(end-1:-1:2)];

newx = fdosc_bank(newMag, newPhase);

end