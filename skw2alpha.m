%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% skw2alpha.m: Sets the thresholds for burst identification 
% authors: Inkeri A. Välkki, Kerstin Lenk, Jarno E. Mikkonen, Fikret E. Kapucu, Jari A. K. Hyttinen
% date: 2016 - 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ BurstAlpha, TailAlpha ] = skw2alpha( Skw )
% skw2alpha( Skw ) returns the alphas for the skewnesses
% [ BurstAlpha, TailAlpha ] = skw2alpha( Skw )
% in:
%   Skw: vector (or scalar) of skewness values
% out:
%   BurstAlpha, TailAlpha: vectors of size of Skw

BurstAlpha = zeros(size(Skw));
TailAlpha = zeros(size(Skw));
for i = 1:length(Skw)
    if isnan(Skw(i))
        BurstAlpha(i) = nan;
        TailAlpha(i) = nan;
    elseif Skw(i) < 1
        BurstAlpha(i) = 1;
        TailAlpha(i) = 0.7;
    elseif Skw < 3%4
        BurstAlpha(i) = 0.7;
        TailAlpha(i) = 0.5;
    elseif Skw < 9
        BurstAlpha(i) = 0.5;
        TailAlpha(i) = 0.3;
    else
        BurstAlpha(i) = 0.3;
        TailAlpha(i) = 0.1;
    end
end
