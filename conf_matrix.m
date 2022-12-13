% Takes in a net object, along with a test input and labels, and returns
% the confusion matrix for this classifier.
function y = conf_matrix(net, input, labels)
    y = zeros(net.outputs{2}.size);
    [~,results] = max(sim(net,input),[],1);
    [~,labels] = max(labels,[],1);    
    for count = 1:length(results)
        y(results(count),labels(count)) = y(results(count),labels(count)) + 1;
    end
end