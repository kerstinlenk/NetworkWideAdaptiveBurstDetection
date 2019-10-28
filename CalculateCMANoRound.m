%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CalculateCMANoRound.m: Runs the CMA burst detection
% authors: Inkeri A. Välkki, Kerstin Lenk, Jarno E. Mikkonen, Fikret E. Kapucu, Jari A. K. Hyttinen
% date: 2016 - 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [BurstInfo,CMAinfo, ISIinfo] = CalculateCMANoRound(CMAtype, SpikeTimes, IDs, ST_Duration_ms)
% [BurstInfo, CMAinfo, ISIinfo] = CalculateCMANoRound( CMAtype, SpikeTrains, IDs, ST_Duration_ms)
% in:
%   CMAtype: 'original', 'net_alpha' or 'net'
%   SpikeTimes: spike times in ms, a cell with individual spike sequences as
%   vectors.
%   IDs: some IDs for the spike trains (numbers, channels...)
%   ST_Duration_ms: Length of the spike sequences in ms, one per spike
%   sequence or one common for all
% out:
%   BurstInfo: bursting statistics as a table
%   CMAinfo: the parameters that were used in burst detection as table
%   ISIinfo: statistics of the ISIs

%%

% ST length in min
ST_Duration_min = ST_Duration_ms / 1000 / 60;

% Get ISI and CMA infos needed
[CMAinfo, ISIinfo] = getCMAinfo(CMAtype, SpikeTimes, IDs);

% Go through all spike sequences
for s = 1:length(SpikeTimes)
    
    % Spike Sequence to analyze
    Spikes = SpikeTimes{s};
    
    if length(ST_Duration_min) > 1
        simtime = ST_Duration_min(s);
    else
        simtime = ST_Duration_min;
    end
    
    % Detect Bursts
    if length(CMAinfo.BurstThreshold) > 1
        [BurstNumber,BurstStarts,BurstEnds,BurstDurations,NumSpikesInBursts] = ...
            DetectBurstNoRound(Spikes, CMAinfo.BurstThreshold(s), CMAinfo.TailThreshold(s));
    else
        [BurstNumber,BurstStarts,BurstEnds,BurstDurations,NumSpikesInBursts] = ...
            DetectBurstNoRound(Spikes, CMAinfo.BurstThreshold, CMAinfo.TailThreshold);
    end
    
    SpikesIncludedBursts = Spikes(BurstNumber > 0) ; %Index of the all spikes included to bursts
%     SpikesExcludedBursts = Spikes(BurstNumber == 0) ; %Index of the all spikes excluded from bursts
    
    % ISI in burst
    ISIinBurst = BurstDurations ./ (NumSpikesInBursts -1); 
    
    % Calculate & Collect statistics
    BI.ID = IDs(s);
    BI.SpikeCount = length(Spikes);
    BI.SpikeRate = BI.SpikeCount / simtime;
    BI.BurstCount = length(BurstStarts);
    BI.BurstRate = BI.BurstCount / simtime;
    BI.BurstDuration = mean(BurstDurations);
    BI.SpikesInBurst = mean(NumSpikesInBursts);
    BI.BurstSpikeRatio = sum(NumSpikesInBursts) / BI.SpikeCount; %%% can be 0 / nan
    BI.BurstSpikes = {SpikesIncludedBursts};
    BI.BurstStarts = {BurstStarts};
    BI.BurstEnds = {BurstEnds};
    BI.ISIinBurst = mean(ISIinBurst); 
    BI.TypeOfSpike = {BurstNumber};
    
    if s == 1
        BurstInfo = BI;
    else
        BurstInfo = [BurstInfo;BI];
    end
    
end
BurstInfo = struct2table(BurstInfo);
end

