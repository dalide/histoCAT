function save_each_file

% sessionData = retr('sessionData');
gates = retr('gates');
global Fcs_Interest_all
global Mask_all

custom_gatesfolder = retr('custom_gatesfolder');

ImageId = {};
SampleId = {};
TotalArea = {};

fcs_folder = fullfile(custom_gatesfolder, 'fcs');
if ~exist(fcs_folder,'dir')
    mkdir(fcs_folder)
end

% create folder to put single cell information csv if not exist yet
singlecell_folder = fullfile(custom_gatesfolder, 'single_cell');
if ~exist(singlecell_folder, 'dir')
    mkdir(singlecell_folder)
end

% create folder to put neighbor cell information if not exist yet
neighbor_folder = fullfile(custom_gatesfolder, 'neighbor_cell');
if ~exist(neighbor_folder, 'dir')
    mkdir(neighbor_folder)
end

ImageId = cell(1,size(gates,1));
SampleId = cell(1,size(gates,1));
TotalArea = cell(1, size(gates,1));
for i=1:size(gates,1)
   
   disp(gates{i,1});
   T = Fcs_Interest_all{i,1};
   % get neighbor cells columns
   getNtneigh = cell2mat(cellfun(@(x) ~strncmp('neighbour',x,9), T.Properties.VariableNames, 'UniformOutput',false));
   getneigh = cell2mat(cellfun(@(x) strncmp('neighbour',x,9), T.Properties.VariableNames, 'UniformOutput',false));
   
   % column names exclude neighbor cells columns
   channels = T.Properties.VariableNames(getNtneigh);
   neighbor = T.Properties.VariableNames(getneigh);
   
   % save single cell infomation as fcs
   fcs_filename = strcat(char(gates{i,1}), '_singlecell.fcs');
   fcs_output = fullfile(fcs_folder, fcs_filename);
   fca_writefcs(fcs_output, table2array(T(:,channels)), channels, channels);
   
   
   % save single cell information as csv
   sc_filename = strcat(char(gates{i,1}), '_singlecell.csv');
   sc_output = fullfile(singlecell_folder, sc_filename);
   % save as csv
   writetable(T(:,channels), sc_output, 'WriteRowNames', true);
   
   % save neigbor cells information as csv
   neighbor_filename = strcat(char(gates{i,1}), '_neighbor.csv');
   neighbor_output = fullfile(neighbor_folder, neighbor_filename);
   % save as csv
   writetable(T(:,['ImageId', 'CellId', neighbor]), neighbor_output, 'WriteRowNames', true);
   
   
   % save metadata 
   ImageId{1,i} = T{1,1};
   SampleId{1,i} = gates{i,1};
   TotalArea{1,i} = size(Mask_all(i).Image,1)*size(Mask_all(i).Image,2)/1e6;

end

metadata_table = table(ImageId', SampleId', TotalArea', 'VariableName', {'ImageId','SampleId', 'TotalArea'});
metadata_filename = 'metadata.csv';
metadata_output = fullfile(custom_gatesfolder, metadata_filename);
writetable(metadata_table, metadata_output, 'WriteRowNames', true);

end