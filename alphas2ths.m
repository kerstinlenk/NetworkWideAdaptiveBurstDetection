%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% alphas2ths.m: Calculates the thresholds for burst detection
% authors: Inkeri A. Välkki, Kerstin Lenk, Jarno E. Mikkonen, Fikret E. Kapucu, Jari A. K. Hyttinen
% date: 2016 - 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [BurstThreshold, TailThreshold] = alphas2ths(CMAcurve, BurstAlpha, TailAlpha)
% [BurstThreshold, TailThreshold] = alphas2ths(CMAcurve, BurstAlpha, TailAlpha)
% in:
%   CMAcurve: of ISIinfo, vector
%   BurstAlpha, TailAlpha: scalars
% out:
%   BurstThreshold, TailThreshold: scalars

MaxCMA =  max(CMAcurve);
MaxPointCMA = find(CMAcurve==max(CMAcurve),1, 'last');

if isnan(BurstAlpha) || isempty(CMAcurve)
    BurstThreshold = nan;
else
    BurstDistants = abs(CMAcurve(MaxPointCMA:end) - (BurstAlpha * max(MaxCMA)));
    BurstThreshold = MaxPointCMA + find(BurstDistants==min(BurstDistants), 1, 'last') -1;
end

if isnan(TailAlpha) || isempty(CMAcurve)
    TailThreshold = nan;
else
    TailDistants = abs(CMAcurve(BurstThreshold:end) - (TailAlpha * max(MaxCMA)));
    TailThreshold = BurstThreshold + find(TailDistants==min(TailDistants), 1, 'last') -1;
end

end