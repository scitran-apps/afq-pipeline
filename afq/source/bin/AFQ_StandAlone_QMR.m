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
%       metadata:   Key_Value pairs for analysis.
%                   Defaults are:
%                           age = '';
%                           sex = '';
%                           ndirs = 30;
%                           bvalue = 1000;
%                           age_comp = false;
%
% EXAMPLE USAGE:
%       jsonargs = '{"input_dir": "/home/lmperry/AFQ_docker/mrDiffusion_sampleData/dti40", "out_name": "afq.mat", "output_dir": "/black/lmperry/AFQ_docker/mrDiffusion_sampleData/dti40/AFQ3" }'
%       jsonargs = '{"input_dir" : "/data/localhome/glerma/TESTDATA/AFQ/input/dtiInit222/dti90trilin", "output_dir": "/data/localhome/glerma/TESTDATA/AFQ/output/withDtiinit222_mrtrix","params"    :"/data/localhome/glerma/TESTDATA/AFQ/input/config_parsed.json"}'
%       jsonargs = '{"input_dir" : "/data/localhome/glerma/TESTDATA/AFQ/input/dtiInit111/dti90trilin", "output_dir": "/data/localhome/glerma/TESTDATA/AFQ/output/withDtiinit111_mrtrix","params"    :"/data/localhome/glerma/TESTDATA/AFQ/input/config_parsed.json"}'
%       jsonargs = '{"input_dir" : "/data/localhome/glerma/TESTDATA/AFQ/input/dtiInit222/dti90trilin", "output_dir": "/data/localhome/glerma/TESTDATA/AFQ/output/withDtiinit222_mrtrix","params"    :"/data/localhome/glerma/TESTDATA/AFQ/input/config_parsed.json"}'
%       jsonargs = '{"input_dir" : "/data/localhome/glerma/TESTDATA/AFQ/input/MareikeS13/dti96trilin", "output_dir": "/data/localhome/glerma/TESTDATA/AFQ/output/MareikeS13","params"    :"/data/localhome/glerma/TESTDATA/AFQ/input/config_parsed.json"}'
%       
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
% metadata   = [];

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

%     if isfield(args, 'metadata')
%         metadata = args.metadata;
%     end

end

% Run control comparison by default
% if ~isfield(params, 'runcontrolcomp');
%     params.runcontrolcomp = true;
% end


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

% Set defaults for metadata
% if notDefined('metadata') % TODO: These should be checked individually
%     metadata.age = '';
%     metadata.sex = '';
%     metadata.ndirs = 30;
%     metadata.bvalue = 1000;
%     metadata.age_comp = false;
% end

% Set the age range for group comparisson
% if isnumeric(metadata.age) && metadata.age > 1
%     if metadata.age <= 11
%         metadata.age_range = [ 5 11 ];
%     elseif metadata.age >= 12 && metadata.age <= 18
%         metadata.age_range = [ 12 18 ];
%     elseif metadata.age >= 19 && metadata.age <= 50
%         metadata.age_range = [ 19 50 ];
%     elseif metadata.age >= 51 && metadata.age <= 65
%         metadata.age_range = [ 51 65 ];
%     elseif metadata.age > 65
%         metadata.age_range = [ 65 100 ];
%     end
% else
%     metadata.age_comp = false;
% end


%% Load the control data

% control_data = load('/opt/qmr_control_data.mat');

%% Parse the params and setup the AFQ structure
if ~isempty(params)
    if ischar(params)
        P = loadjson(params);
    else
        P = params;
    end
%    fNames = fieldnames(P);
%    for f = 1:numel(fNames)
%       afq.params.(fNames{f}) =  P.(fNames{f});
%    end
%    disp(afq.params);
end


%% Create afq structure

if notDefined('out_name')
    out_name = ['afq_', getDateAndTime];
end

afq = AFQ_Create('sub_dirs', sub_dirs, 'sub_group', sub_group, ...
                 'outdir', output_dir, 'outname', out_name, ...
                 'params', P);  

% disp(afq.params);

% Run control comparison by default
% if ~isfield(params, 'runcontrolcomp');a
%     afq.params.runcontrolcomp = false;
% end





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


%% Create Plots and save out the images
%{
if afq.params.runcontrolcomp

    disp('Running comparison to control population!')

    % Setup the valnames.
    valnames = fieldnames(afq.vals);

    % Remove those values we're not interested in currently
    %TODO: Remove this - generate them all.
    remlist = {'cl','curvature','torsion','volume','WF_map_2DTI','cT1SIR_map_2DTI'};
    for r = 1:numel(remlist)
        ind = cellfind(valnames,remlist{r});
        if ~isempty(ind)
            valnames(ind) = [];
        end
    end

    % Load up saved controls data based on the parameters for the data.
    % Handle the case where ndirs is not 96 or 30.
    a = abs(metadata.ndirs - 96);
    b = abs(metadata.ndirs - 30);

    % If the diffusion values are not exact then we have to warn that there was
    % no exact match! || OR do we just not perform the plotting aginst the
    % control data.
    if metadata.ndirs ~= 96 && metadata.ndirs ~= 30
        warning('Number of diffusion directions does not match control data!');
    end

    if metadata.bvalue ~= 2000 && metadata.bvalue ~= 1000
        warning('B-VALUE does not match control data!');
    end

    if metadata.ndirs == 96 || a < b
        disp('Loading 96-direction control data');
        afq_controls = control_data.afq96;

    elseif metadata.ndirs == 30 || b < a
        disp('Loading 30-direction control data');
        afq_controls = control_data.afq30;
    end

    % This might be where we write out the figures in two seperate directories.
    fig_out_dir = fullfile(output_dir, 'figures');
    if ~exist(fig_out_dir,'dir'); mkdir(fig_out_dir); end

    disp('Running AFQ Plot: Generating figures...');
    try
        if metadata.age_comp && isnumeric(metadata.age)
            disp('Constraining norms based on age!');

            AFQ_PlotPatientMeans(afq, afq_controls, valnames, 21:80, fig_out_dir,'Age', metadata.age_range);
        else
            AFQ_PlotPatientMeans(afq, afq_controls, valnames, 21:80, fig_out_dir);
        end
    catch ME
        disp(ME.message);
    end
end
%}

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

% Use compile.sh to compile this file 
% This is the command used to launch it with the MCR
% ./run_AFQ_StandAlone_QMR.sh /data/localhome/glerma/soft/matlab/mcr92/v92   '{\"input_dir\" : \"/data/localhome/glerma/TESTDATA/AFQ/input/dtiInit111_mcr/dti90trilin\", \"output_dir\": \"/data/localhome/glerma/TESTDATA/AFQ/output/withDtiinit111_mrtrix_mcr\",\"params\"    :\"/data/localhome/glerma/TESTDATA/AFQ/input/config_parsed.json\"}'

% After adding LiFE, add this packages too:
%       addpath(genpath('/data/localhome/glerma/soft/encode'));
%       addpath(genpath('/data/localhome/glerma/soft/app-life'));
% So the new mcc command is as follows:
% mcc -m -I /data/localhome/glerma/soft/encode -I /data/localhome/glerma/soft/app-life -I /black/localhome/glerma/soft/spm8 -I /data/localhome/glerma/soft/vistasoft -I /data/localhome/glerma/soft/jsonlab /data/localhome/glerma/soft/afq-pipeline/afq/source/bin/AFQ_StandAlone_QMR.m  

