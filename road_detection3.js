// Define a region of interest
var roi = ee.Geometry.Rectangle([-85.04, 33.74, -84.96, 33.78]);

// Load a DigitalGlobe image
var image = ee.Image('DigitalGlobe:Imagery:Atlanta').clip(roi);

// Select the bands to use for classification
var bands = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10'];

// Define the training data
var roads = ee.FeatureCollection('TIGER/2016/Roads')
  .filterBounds(roi)
  .filter(ee.Filter.eq('RTTYP', 'M'));

var background = image.reduceRegion({
  reducer: ee.Reducer.sampleStdDev(),
  geometry: roi,
  scale: 5,
  maxPixels: 1e9
});

var samples = ee.FeatureCollection(roads.merge(ee.FeatureCollection(background
  .toList(background.size())
  .map(function(image) {
    return ee.Feature(null, ee.Dictionary(image).toDictionary().rename(bands));
  })
)));

// Split the data into training and testing sets
var split = 0.7;
var training = samples.filter(ee.Filter.lt('random', split));
var testing = samples.filter(ee.Filter.gte('random', split));

// Train a random forest classifier
var classifier = ee.Classifier.randomForest(10).train({
  features: training,
  classProperty: 'class'
});

// Classify the image
var classified = image.select(bands).classify(classifier);

// Display the result
Map.centerObject(roi, 15);
Map.addLayer(image, {bands: ['B4', 'B3', 'B2'], max: 4000}, 'Image');
Map.addLayer(classified, {min: 0, max: 1, palette: ['black', 'yellow']}, 'Roads');
