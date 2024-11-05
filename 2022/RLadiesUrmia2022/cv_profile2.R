library(neuralnet)
library(plyr)

cv = function(data, hidden, n.folds = 2, formula, features, output)
{
  # split data into 'folds' for cross validation
  fold.size = floor(nrow(data)/n.folds)
  category = NULL
  for(k in 1:n.folds){
    category = c(category, rep(k, fold.size))
  }
  # we have rounding errors (i.e. if have 10 folds and
  # the number of rows is not divisible by 10)
  # randomly assign the leftover rows to different folds
  if(length(category) != nrow(data))
  {
    extra.length = nrow(data) - length(category)
    extra = sample(seq(1, n.folds), extra.length)
    category = c(category, extra)
  }
  data$cv.fold = sample(category)
  
  mse = rep(NA, n.folds)
  for(k in 1:n.folds)
  {
    # standard neural network model fit on this subset of data
    train.cv = data[data$cv.fold != k,]
    test.cv = data[data$cv.fold == k,]
    
    # the algorithm starts out with a random set of weights
    # occasionally it starts with suboptimal weights and does not converge
    # within the allowed time (maximum steps).
    # I increase the max steps
    model.cv = neuralnet(formula, train.cv, hidden = hidden, linear.output = FALSE, stepmax = 2e+05)
    
    # calculate Mean Squared Error
    test.predictions = max.col(compute(model.cv, test.cv[,features])$net.result)
    test.true.values = max.col(test.cv[,output])
    mse[k] = sum((test.predictions - test.true.values)^2)/nrow(test.cv)
  }
  return(mean(mse))
}

test.size = function(data, n.folds, formula, features, output)
{
  hidden.values = seq(2, length(features) - 1)
  n.values = length(hidden.values)
  mse.all = rep(NA, n.values)
  for(i in 1:n.values)
  {
    mse.all[i] = cv(data, hidden.values[i], n.folds, formula, features, output)
  }
  best = which.min(mse.all)
  return(hidden.values[best])
}

wine = read.csv('https://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data')
names(wine) = c('label', 'alcohol', 'malic_acid', 'ash', 'alcalinity_of_ash',
                'magnesium', 'total_phenols', 'flavanoids', 'nonflavanoid_phenols',
                'proanthocyanins', 'color_intensity', 'hue', 'OD280_OD315_of_diluted_wines',
                'proline')
wine$id = as.character(seq(1, nrow(wine)))

# convert 'label' factor column to separate binary columns
wine.label = mutate(wine, label1 = label == '1',
                    label2 = label == '2', label3 = label == '3', label = factor(label))
sapply(wine.label, class)

# normalize the numeric columns
numeric = sapply(wine.label, is.numeric)
wine.scaled = wine.label
wine.scaled[ ,numeric]= sapply(wine.label[,numeric], scale)

# extract just the feature names to create a formula
feature.names = colnames(wine)[!(colnames(wine) %in% c('id', 'label', 'label1', 'label2', 'label3'))]
neuralnet.formula = paste('label1 + label2 + label3 ~', paste(feature.names, collapse = ' + '))
features = which(colnames(wine.label) %in% feature.names)
output = which(colnames(wine.label) %in% c('label1', 'label2', 'label3'))

# split into training and testing
train.sample = sample(wine$id, 100)
test.sample = wine$id[!(wine$id %in% train.sample)]
wine.train = wine.scaled[train.sample, ]
wine.test = wine.scaled[test.sample, ]

hidden.nodes = test.size(wine.label, n.folds = 2, neuralnet.formula, features, output)
model = neuralnet(neuralnet.formula, data = wine.train, hidden = hidden.nodes, linear.output = FALSE)
summary(model)




