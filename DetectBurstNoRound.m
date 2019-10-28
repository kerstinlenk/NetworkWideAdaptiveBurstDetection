%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DetectBurstNoRound.m: Detects the bursts using CMA-algorithm
% authors: Inkeri A. Välkki, Kerstin Lenk, Jarno E. Mikkonen, Fikret E. Kapucu, Jari A. K. Hyttinen
% date: 2016 - 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [BurstNumbers, BurstStarts, BurstEnds, BurstDurations, NumSpikesInBursts] = DetectBurstNoRound(SpikeTimes, BurstThreshold, TailThreshold)
% [BurstNumbers, BurstStarts, BurstEnds, BurstDurations, NumSpikesInBursts] = DetectBurstNoRound(SpikeTimes, BurstThreshold, TailThreshold)
% in:
%   SpikeTimes: spiketimes in ms, sorted, vector
%   BurstThreshold, TailThreshold: thresholds for burst detection, scalars
% out:
%   BurstNumbers: burst number to which the spike belongs to, 0 for
%   non-burst spikes
%   BurstStarts: start times of bursts (ms)
%   BurstEnds: end times of bursts (ms)
%   BurstDurations: burst durations (ms)
%   NumSpikesInBursts: number of spikes in each burst

% Number of spikes
nspikes = length(SpikeTimes);

% For keeping track of spike types
TypeOfSpike = zeros(1,nspikes); % 1 for bursts, 2 for tails , 0 for individuals

% Determine burst spikes
isis = find(diff(SpikeTimes) < BurstThreshold);
bspikes = false(size(SpikeTimes));
bspikes(isis) = 1;
bspikes(isis+1) = 1;
TypeOfSpike(bspikes) = 1;

%% omitting bursts having fewer spikes then desired (in this case 2 spikes)

%+++comment out if two spike bursts are wanted
minNOspikes = 3; % specify the min number of spikes in a burst to be
BreakPointAfter=[];
BreakPointBefore=[];
burstspikes = find(TypeOfSpike==1);
if ~isempty(burstspikes)
    BreakPoints = find(diff(SpikeTimes(burstspikes)) > BurstThreshold);
    BreakPointBefore = [burstspikes(1) burstspikes(BreakPoints+1)];
    BreakPointAfter = [burstspikes(BreakPoints) burstspikes(end)];
end

ZeroIndexes = find(BreakPointAfter-BreakPointBefore+ 1<minNOspikes); % spike indexes to be nullified
for l=1:length(ZeroIndexes)
    TypeOfSpike(BreakPointBefore(ZeroIndexes(l)):BreakPointAfter(ZeroIndexes(l))) = 0;
end
%+++make comment out till here++++

%% TAIL CALCULATION

% Find tail spikes
isis = find(diff(SpikeTimes) < TailThreshold);
tspikes = false(size(SpikeTimes));
tspikes(isis) = 1;
tspikes(isis+1) = 1;
tspikes(bspikes) = 0;
TypeOfSpike(tspikes) = 2;

%% omitting tails away from bursts and merging rest with the bursts

tailspikes = find(TypeOfSpike==2);
controlForLoop = TypeOfSpike;
resultOfmerging=zeros(1,nspikes);
%/loop till all the burst related tails merged and counted as bursts
while ~isequal(controlForLoop,resultOfmerging)
    controlForLoop = TypeOfSpike;
    for t = tailspikes
        if t== 1
            if (SpikeTimes(t + 1) - SpikeTimes(t) <= TailThreshold...
                    && TypeOfSpike(t + 1) == 1)
                TypeOfSpike(t) = 1;
            end
        elseif t == nspikes
            if(SpikeTimes(t) - SpikeTimes(t-1) <= TailThreshold...
                    && TypeOfSpike(t - 1) == 1)
                TypeOfSpike(t) = 1;
            end
        else
            if (TypeOfSpike(t + 1) == 1 && SpikeTimes(t + 1) - SpikeTimes(t) <= TailThreshold) ...
                    || (TypeOfSpike(t - 1) == 1 && SpikeTimes(t) - SpikeTimes(t-1) <= TailThreshold)
                TypeOfSpike(t) = 1;
            end
        end
    end
    resultOfmerging = TypeOfSpike;
    tailspikes = find(TypeOfSpike==2);
end

nonbursts = TypeOfSpike ~= 1;
TypeOfSpike(nonbursts) = 0;

%%Burst Starts  and Burst Ends
burstspikes = find(TypeOfSpike==1);
if ~isempty(burstspikes)
    BreakPoints = find(diff(SpikeTimes(burstspikes)) > TailThreshold);
    BreakPointStarts = [burstspikes(1) burstspikes(BreakPoints+1)];
    BreakPointEnds = [burstspikes(BreakPoints) burstspikes(end)];
    
    BurstStarts = SpikeTimes(BreakPointStarts);
    BurstEnds = SpikeTimes(BreakPointEnds);
    
    NumSpikesInBursts = BreakPointEnds - BreakPointStarts+1;
    BurstDurations = BurstEnds - BurstStarts;
    %     IBI = BurstStarts - BurstEnds;
    %     ISIinBurst
    BurstNumbers = zeros(size(TypeOfSpike));
    for b = 1:length(BreakPointStarts)
        BurstNumbers(BreakPointStarts(b):BreakPointEnds(b)) = b;
    end
else
    BurstStarts = [];
    BurstEnds= [];
    BurstDurations= [];
    NumSpikesInBursts= [];
    BurstNumbers = TypeOfSpike;
end
