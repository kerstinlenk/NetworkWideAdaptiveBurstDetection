%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main.m: Main function of the modified CMA algorithm 
% relevant publications: doi:10.3389/fncom.2017.00040, 10.3389/fncom.2012.00038
% authors: Inkeri A. Välkki, Kerstin Lenk, Jarno E. Mikkonen, Fikret E. Kapucu, Jari A. K. Hyttinen
% date: 2016 - 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clearvars -except SR BR BD SB col run lengthST
    
% load sample data
% DataCell from Emre Kapucu's code

TargetDir = 'C:\Users\lenk\MyData\5_SoftwareTools\'; %Path where DataCells are stored
list = dir([TargetDir '*.mat']);
lenLIST = length(list);     %number of *.mcd/*.mat files 

for k = 1 : lenLIST
	TargetFile = list(k).name;
	filename = [TargetDir TargetFile];
	load(filename);
    
    lengthST = DataCell{1,4}/60; % 60 = number of electrodes
    
    SpikeTrains = DataCell(:,3);
    IDs = DataCell(:,1);

    testEmpty = cellfun('isempty',SpikeTrains);
    
    if sum(testEmpty) ~= length(SpikeTrains) && max(cell2mat(DataCell(:,2))) > 2
        % Do Burst Detection
        % original CMA
        [BurstInfoO, CMAinfoO, ISIinfoO] = CalculateCMANoRound('original', SpikeTrains, IDs, lengthST*60*1000+1);

        %network CMA
        [BurstInfoN, CMAinfoN, ISIinfoN] = CalculateCMANoRound('net', SpikeTrains, IDs, lengthST*60*1000+1);

        TimeDuration = DataCell{1,4}; % duration of the data in sec.CHANGE!!according. 
        TimeDuration_ms = TimeDuration*1000;
        SpikesFigure = zeros(1,TimeDuration_ms);

        if sum(BurstInfoN.BurstRate) > 0
            [M,row] = max(BurstInfoN.BurstRate);
            temp = round(DataCell{row,3}(1,:));

            if ~isnan(temp)
                for j = 1: length(temp)
                    SpikesFigure(temp(j)) = 1;
                end
            end
        end     
    end
end



