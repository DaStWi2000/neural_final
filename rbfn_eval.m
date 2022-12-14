close; clear; clc; path(pathdef);

%% Process the Data
source = "data";

% Concatenates all samples into one database
directory = strtrim(string(ls(source)));
files = directory(contains(directory,".mat"));
load("num_cells.mat");
[all_features, all_labels] = convert2input(source, files, num_cells);

% Converts the labels into 1vMany Form
num_features = size(all_features{1},2);
all_labels = str2double(all_labels);
label_list = unique(all_labels);
all_labels_sm = zeros(length(label_list),length(all_labels));
for count = 1:length(label_list)
    all_labels_sm(count,:) = all_labels == label_list(count);
end

% Chooses the training and testing samples
train_p = 0.7;
test_p = 0.3;
num_k_samples = 10000;
[train_ind, ~, test_ind] = dividerand(length(all_labels),train_p,0,test_p);
train_k = train_p * num_k_samples;
test_k = test_p * num_k_samples;
train_ind = train_ind(randperm(length(train_ind),train_k));
test_ind = test_ind(randperm(length(test_ind),test_k));
train_features = zeros(length(train_ind),num_features);
train_labels = all_labels_sm(:,train_ind);
test_features = zeros(length(test_ind),num_features);
test_labels = all_labels_sm(:,test_ind);
for count = 1:length(train_ind)
    train_features(count,:) = all_features{train_ind(count)};
end
for count = 1:length(test_ind)
    test_features(count,:) = all_features{test_ind(count)};
end
train_features = train_features.';
test_features = test_features.';

% Find 6000 Neuron RBFN with spread between 10^[-1:0.5:1]
N = 9;
net_mat = cell(N,1);
conf_mat_cells = cell(N,1);
accuracy = 0;
spread = 0;
index = 0;
spreads = 10^(((1:N)-(N+1)/2)/floor(N/2));
for count = 1:N
    net_mat{count} = newrbe(train_features,train_labels,spreads(count));
    conf_mat_cells{count} = conf_matrix(net_mat{count},test_features,test_labels);
    conf_results = trace(conf_mat_cells{count})/sum(conf_mat_cells{count},'all')*100;
    if accuracy < conf_results
        index = count;
        accuracy = conf_results;
    end
    % Displays Accuracy of Classification
    disp(strcat("Spread: ", num2str(spreads(count))));
    disp(strcat("Accuracy: ",num2str(conf_results),"%"));
end
net = net_mat{index};
save('overall_model.mat','net','conf_mat_cells','spreads');

% Plots MSE for RBFN being built based on training data with constant
% spread as neurons increase
net_neurons_var = newrb(train_features,train_labels,0,spreads(count),num_features,25);
% Displays Accuracy of resulting trained network
conf_mat_neurons = conf_mat(net_neurons_var, test_features, test_labels);
disp(strcat("Accuracy: ",num2str(trace(conf_mat_neurons)/sum(conf_mat_neurons,'all')*100),"%"));
save('overall_model.mat','net_neurons_var');

close; clear; clc; path(pathdef);