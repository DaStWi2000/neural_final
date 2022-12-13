function [features, labels] = convert2input(source_dir, files, num_cells)
    features = cell(num_cells,1);
    labels = cell(num_cells,1);
    current_index = 1;
    for count = 1:length(files)
        files(count)
        file = load(strcat(source_dir, "\", files(count)));
        x = file.XTrain;
        y = file.YTrain;
        y(y=="R") = {'5'};
        y(y=="W") = {'6'};
        y(y=="t") = {'7'};
        x = x(y=="1" | y=="2" | y=="3" | y=="4" | y=="5" | y=="6" | y=="7");
        y = y(y=="1" | y=="2" | y=="3" | y=="4" | y=="5" | y=="6" | y=="7");
        len = length(y);
        labels(current_index:current_index+len-1) = y;
        for window = 1:len
            tmp = x{window};
            features(current_index) = {reshape(tmp,1,[])};
            current_index = current_index+1;
        end
    end
    features = features(~cellfun('isempty',features));
    labels = labels(~cellfun('isempty',labels));
end