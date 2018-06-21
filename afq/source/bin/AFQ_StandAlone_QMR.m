function AFQ_StandAlone_QMR(jsonargs)
%
% AFQ_StandAlone_QMR(jsonargs)
%
% INPUT ARGUMENTS: Note: must be a json string.
%
%       input_dir:  Directory containing dt6.mat
%       out_name:   Name for the resulting afq file
%       output_dir: Location to save the results
%       params:     Key-Value pair of params for AFQ_Create
%
% EXAMPLE USAGE:
%       jsonargs = '{"input_dir": "/home/lmperry/AFQ_docker/mrDiffusion_sampleData/dti40", "out_name": "afq.mat", "output_dir": "/black/lmperry/AFQ_docker/mrDiffusion_sampleData/dti40/AFQ3" }'
%       jsonargs = '{"input_dir" : "/data/localhome/glerma/TESTDATA/AFQ/input/dtiInit222/dti90trilin", "output_dir": "/data/localhome/glerma/TESTDATA/AFQ/output/withDtiinit222_mrtrix","params"    :"/data/localhome/glerma/TESTDATA/AFQ/input/config_parsed.json"}'
%       jsonargs = '{"input_dir" : "/data/localhome/glerma/TESTDATA/AFQ/input/dtiInit111/dti90trilin", "output_dir": "/data/localhome/glerma/TESTDATA/AFQ/output/withDtiinit111_mrtrix","params"    :"/data/localhome/glerma/TESTDATA/AFQ/input/config_parsed.json"}'
%       jsonargs = '{"input_dir" : "/data/localhome/glerma/TESTDATA/AFQ/input/dtiInit222/dti90trilin", "output_dir": "/data/localhome/glerma/TESTDATA/AFQ/output/withDtiinit222_mrtrix","params"    :"/data/localhome/glerma/TESTDATA/AFQ/input/config_parsed.json"}'
%       AFQ_StandAlone_QMR(jsonargs);
%
%
%#ok<*AGROW>


%% Begin

disp('Starting AFQ...');

% Initialize args
input_dir  = [];
out_name   = [];
output_dir = [];
params     = [];

%% Handle jsonargs
disp("This is the json string to be read by loadjson:")
disp(jsonargs)



if exist('jsonargs', 'var') && ~isempty(jsonargs);


    args = loadjson(jsonargs);

    if isfield(args, 'input_dir')
        input_dir = args.input_dir;
    end

    if isfield(args, 'out_name')
        out_name = args.out_name;
    end

    if isfield(args, 'output_dir')
        output_dir = args.output_dir;
    end

    if isfield(args, 'params')
        params = args.params;
    end

end



%% Configure inputs and defaults

if notDefined('input_dir')
    if exist('/input', 'dir')
        input_dir = '/input';
    else
        error('An input directory was not specified.');
    end
end
sub_dirs{1} = input_dir;

if notDefined('output_dir')
    if exist('/output', 'dir')
        output_dir = '/output';
    else
        error('An output directory was not specified.');
    end
end
output_dir = fullfile(output_dir, 'AFQ');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

% Just one group here
sub_group = ones(numel(sub_dirs),1);


%% Parse the params and setup the AFQ structure
if ~isempty(params)
    if ischar(params)
        P = loadjson(params);
    else
        P = params;
    end
end


%% Create afq structure

if notDefined('out_name')
    out_name = ['afq_', getDateAndTime];
end

afq = AFQ_Create('sub_dirs', sub_dirs, 'sub_group', sub_group, ...
                 'outdir', output_dir, 'outname', out_name, ...
                 'params', P);
disp(afq.params);


%% RUN AFQ

disp('Running AFQ...');
afq = AFQ_run(sub_dirs, sub_group, afq);


%% Check for empty fiber groups
disp('Checking for empty fiber groups...');
for i = 1:numel(afq.TractProfiles)
    if isempty(afq.TractProfiles(i).nfibers)
        disp(fprintf('Fiber group is empty: %s', afq.TractProfiles(i).name));
    end
end


%% Export the data to csv files (don't use AFQ_exportData)

disp('Exporting data to csv files...');

% We will add the diffusion parameters and the series number to the name
csv_dir = fullfile(output_dir,'csv_files');
mkdir(csv_dir);

% Get the names of each of the datatypes (e.g.,'FA','MD', etc.)
properties = fieldnames(afq.vals);

% Loop over the properties and create a table of values for each property
for ii = 1:numel(properties)

    % Loop over each fibergroup and insert the values into the table
    for i = 1:numel(afq.fgnames)

        % If this is the first time through create a table that we'll
        % concatenate with each following table (t)
        if i == 1
            T = cell2table(num2cell(afq.vals.(properties{ii}){i}'),'variablenames',{regexprep(afq.fgnames{i},' ','_')});
        else
            t = cell2table(num2cell(afq.vals.(properties{ii}){i}'),'variablenames',{regexprep(afq.fgnames{i},' ','_')});

            % Combine the tables
            T = horzcat(T,t);
        end

        % Write out the table to a csv file
        writetable(T,fullfile(csv_dir,['AFQ_' lower(properties{ii}) '.csv']));
    end
end

%% Reproducibility

R = {};
R.date = getDateAndTime;
[~, R.arch] = system('lsb_release -a');
R.software.version = version;
R.software.libs = ver;
R.code = {};

% R.analysis.metadata = metadata;
R.analysis.params   = afq.params;
R.analysis.subject  = sub_dirs;

save(fullfile(output_dir,'Reproduce.mat'), 'R');
savejson('', R, fullfile(output_dir,'Reproduce.json'));


%% END

if isdeployed
    disp('Sending exit(0) signal.');
    exit(0)
else
    disp('Done!');
end

return

% This is the command used to compile it:
% mcc -m  -I /black/localhome/glerma/soft/spm8 -I /data/localhome/glerma/soft/vistasoft -I /data/localhome/glerma/soft/jsonlab /data/localhome/glerma/soft/afq-pipeline/afq/source/bin/AFQ_StandAlone_QMR.m
% This is the command used to launch it with the MCR
% ./run_AFQ_StandAlone_QMR.sh /data/localhome/glerma/soft/matlab/mcr92/v92   '{\"input_dir\" : \"/data/localhome/glerma/TESTDATA/AFQ/input/dtiInit111_mcr/dti90trilin\", \"output_dir\": \"/data/localhome/glerma/TESTDATA/AFQ/output/withDtiinit111_mrtrix_mcr\",\"params\"    :\"/data/localhome/glerma/TESTDATA/AFQ/input/config_parsed.json\"}'
