close; clear; clc; path(pathdef);

%% Read in the Data
% Directory of Downloaded Database
raw_dir = "sleep-edf-database-expanded-1.0.0";
addpath("sleep-edfx-toolbox-master")
cd("sleep-edfx-toolbox-master")
biosig_installer
cd("..")
sorted_edf_data = "edf_data";
initialSetupEDFx(sorted_edf_data, raw_dir);
raw_mat = "raw_mat";
mkdir(raw_mat);
raw_dir_files = ls(sorted_edf_data);
raw_dir_files = string(raw_dir_files(~contains(string(raw_dir_files),"."),:));
raw_dir_files = strtrim(raw_dir_files);
max_eeg_1 = -Inf;
max_eeg_2 = -Inf;
min_eeg_1 = Inf;
min_eeg_2 = Inf;
num_cells = 0;
for count = 1:length(raw_dir_files)
    subject = raw_dir_files(count)
    sel_dir = strcat(sorted_edf_data,"\",subject);
    try
        [data, f_samp, ~, hypnogram, ~] = loadEDFx(strcat(pwd,"\",sel_dir), 'RK');
    catch
        hypnogram = null(1);
    end
    if (~isempty(hypnogram))
        eeg1 = data('eeg_fpz');
        eeg2 = data('eeg_pz');
        max_eeg_1 = max(max_eeg_1,max(eeg1));
        max_eeg_2 = max(max_eeg_2,max(eeg2));
        min_eeg_1 = min(min_eeg_1,min(eeg1));
        min_eeg_2 = min(min_eeg_2,min(eeg2));
        XTrain = cell(length(hypnogram),1);
        YTrain = cellstr(hypnogram);
        for div = 1:length(hypnogram)
            XTrain(div) = {[eeg1(((div-1)*30*f_samp+1):div*30*f_samp),eeg2(((div-1)*30*f_samp+1):div*30*f_samp)]};
        end
        save(strcat(pwd,"\",raw_mat,"\",subject,".mat"),"XTrain","YTrain");
        num_cells = num_cells + length(hypnogram);
    end
end
save(strcat(pwd,"\scaling.mat"),"min_eeg_1","min_eeg_2","max_eeg_1","max_eeg_2");
save(strcat(pwd,"\num_cells.mat"),"num_cells");
rmdir(sorted_edf_data,'s'); clear; path(pathdef);

%% Preprocess the Data
raw_mat = "raw_mat";
scaled_mat = "data";
mat_files = ls(raw_mat);
mat_files = string(mat_files(contains(string(mat_files),".mat"),:));
mat_files = strtrim(mat_files);
load("scaling.mat");
mat_files = erase(mat_files,".mat");
for count = 1:length(mat_files)
    subject = mat_files(count)
    file_struct = load(strcat(raw_mat,"\",subject));
    XTrain = file_struct.XTrain;
    YTrain = file_struct.YTrain;
    for cells = 1:length(XTrain)
        tmp = XTrain{cells};
        XTrain(cells) = {[(tmp(:,1)-min_eeg_1)/(max_eeg_1-min_eeg_1),(tmp(:,2)-min_eeg_2)/(max_eeg_2-min_eeg_2)]};
    end
    save(strcat(scaled_mat,"\",subject,"_scaled.mat"),"XTrain","YTrain");
end
rmdir(raw_mat, 's'); clear;