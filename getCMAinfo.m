%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getCMAinfo.m: Caculates the parameters for CMA burst detection
% authors: Inkeri A. Välkki, Kerstin Lenk, Jarno E. Mikkonen, Fikret E. Kapucu, Jari A. K. Hyttinen
% date: 2016 - 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [CMAinfo, ISIinfo] = getCMAinfo(CMAType, SpikeTimes, IDs)
% [CMAinfo] = getCMAinfo(CMAType, ISIinfo)
% in:
%   CMAtype: 'original', 'net' or 'net_alpha'
%   SpikeTimes: SpikeTimes in ms in a cell
%   IDs: IDs for the spike sequences
% out:
%   CMAinfo: CMA parameters
%   ISIinfo: ISI statistics

CMAinfo.type = CMAType;
CMAinfo.ID = IDs;

% Emre's original CMA
if strcmp(CMAType, 'original')
    
    % Calculate ISIs & ISIinfo for all the SpikeTimes
    ISIs = cellfun(@diff, SpikeTimes, 'UniformOutput', false);
    ISIinfo = getISIinfo(ISIs, IDs);
    
    % Calculate the alphas
    [CMAinfo.BurstAlpha, CMAinfo.TailAlpha] = skw2alpha(ISIinfo.skewISI);
    
    CMAinfo.BurstThreshold = nan(size(SpikeTimes));
    CMAinfo.TailThreshold = nan(size(SpikeTimes));
    % Calculate CMA thresholds
    for n = 1:length(SpikeTimes)
        [CMAinfo.BurstThreshold(n), CMAinfo.TailThreshold(n)] = alphas2ths(ISIinfo.CMAcurve{n}, CMAinfo.BurstAlpha(n), CMAinfo.TailAlpha(n));
    end
    
% Common alpha value for all the neurons !! Is not such a good idea to use
elseif strcmp(CMAType, 'net_alpha')
    
    % Calculate ISIs and ISIinfo
    ISIs = cellfun(@diff, SpikeTimes, 'UniformOutput', false);
    ISIinfo = getISIinfo(ISIs, IDs);
    
    % Combined ISI histogram
    ISIdataAll = horzcat(ISIs{:});
    ISIinfoAll = getISIinfo({ISIdataAll}, {'all'});
    ISIinfo = [ISIinfo;ISIinfoAll];
    
    % Calculate the alphas
    [CMAinfo.BurstAlpha, CMAinfo.TailAlpha] = skw2alpha(ISIinfoAll.skewISI);
    
    CMAinfo.BurstThreshold = nan(size(SpikeTimes));
    CMAinfo.TailThreshold = nan(size(SpikeTimes));
    % Calculate CMA thresholds
    for n = 1:length(SpikeTimes)
        [CMAinfo.BurstThreshold(n), CMAinfo.TailThreshold(n)] = alphas2ths(ISIinfo.CMAcurve{n}, CMAinfo.BurstAlpha, CMAinfo.TailAlpha);
    end
    
% Common thresholds for burst detection
elseif strcmp(CMAType, 'net')
    
    % Calculate ISIs and ISIinfo
    ISIs = cellfun(@diff, SpikeTimes, 'UniformOutput', false);
    
    % Combined ISI histogram
    ISIdataAll = horzcat(ISIs{:});
    ISIinfoAll = getISIinfo({ISIdataAll}, {'all'});
    ISIinfo = ISIinfoAll;
    
    % Calculate the burst alphas
    [CMAinfo.BurstAlpha, CMAinfo.TailAlpha] = skw2alpha(ISIinfoAll.skewISI);
    
    % Calculate CMA thresholds
    [CMAinfo.BurstThreshold, CMAinfo.TailThreshold] = alphas2ths(ISIinfoAll.CMAcurve{1}, CMAinfo.BurstAlpha, CMAinfo.TailAlpha);
    
    
end


end



