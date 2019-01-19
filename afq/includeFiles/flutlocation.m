function [flutlocationPath] = flutlocation()
%FLUTLOCATION Summary of this function goes here
%   Detailed explanation goes here
flutlocationPath =  fullfile(fileparts(which('flutlocation')), 'FreeSurferColorLUT.txt');

end

