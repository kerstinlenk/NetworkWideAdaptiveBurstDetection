%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getISIinfo.m: Calculates the ISI statistics
% authors: Inkeri A. Välkki, Kerstin Lenk, Jarno E. Mikkonen, Fikret E. Kapucu, Jari A. K. Hyttinen
% date: 2016 - 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ISIinfo] = getISIinfo(ISIs, IDs)
% getISIinfo calculates ISI statistics
% function [ISIinfo] = getISIinfo(ISIs, IDs)
% in:
%   ISIs: cell of ISI sequences in ms
%   ID: IDs for the ISI sequences
% out:
%   ISIinfo: table of ISI statistics

% Calculate ISI statistics for all ISIs
ISIinfo = cellfun(@calc_stats, ISIs, IDs);

% Convert to table
ISIinfo = struct2table(ISIinfo);

end

function [info] = calc_stats(ISI, ID)
% calc_stats calculates II statistics of one ISI squence
info.ID = ID;
info.ISIs = ISI;

if isempty(ISI)
    info.maxISI = nan;
    info.minISI = nan;
    info.meanISI = nan;
    info.stdISI = nan;
    info.medianISI = nan;
    info.histISI = [];
    info.cumhistISI = [];
    info.CMAcurve = [];
    info.skewCMA = nan;
    info.skewISI = nan;
else
    info.maxISI = max(ISI);
    info.minISI = min(ISI);
    info.meanISI = mean(ISI);
    info.stdISI = std(ISI);
    info.medianISI = median(ISI);
    info.histISI = histc(ISI , (0:1:20000));
    info.cumhistISI = cumsum(info.histISI);
    info.CMAcurve = info.cumhistISI ./ (1:1:20001);
    %SkewnessCMA
    if  info.maxISI > 20000 || isnan(info.maxISI)
        info.skewCMA =  skewness(info.CMAcurve);
    else
        info.skewCMA = skewness(info.CMAcurve(1:ceil(info.maxISI)));
    end
    info.skewISI = skewness(ISI);
end
    info.histISI = {info.histISI};
    info.cumhistISI = {info.cumhistISI};
    info.CMAcurve = {info.CMAcurve};
end
