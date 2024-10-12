// Define a region of interest
var roi = ee.Geometry.Rectangle([-122.4, 37.7, -122.3, 37.8]);

// Load a Sentinel-2 image
var image = ee.ImageCollection('COPERNICUS/S2_SR')
  .filterBounds(roi)
  .filterDate('2019-01-01', '2019-12-31')
  .sort('CLOUDY_PIXEL_PERCENTAGE', true)
  .first()
  .clip(roi);

// Select the bands to use for classification
var bands = ['B2', 'B3', 'B4', 'B8', 'B11', 'B12'];

// Define the training data
var roads = ee.FeatureCollection('TIGER/2016/Roads')
  .filterBounds(roi)
  .filter(ee.Filter.eq('RTTYP', 'M'));

var background = image.reduceRegion({
  reducer: ee.Reducer.sampleStdDev(),
  geometry: roi,
  scale: 10,
  maxPixels: 1e9
});

var keys = background.keys();
var values = keys.map(function(key) {
  return ee.Dictionary.fromLists(['band', 'stdDev'], [key, background.get(key)]);
});

var samples = ee.FeatureCollection(roads.merge(ee.FeatureCollection(values.map(function(feature) {
  return ee.Feature(null, feature);
}))));

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
Map.addLayer(image, {bands: ['B4', 'B3', 'B2'], max: 3000}, 'Image');
Map.addLayer(classified, {min: 0, max: 1, palette: ['black', 'yellow']}, 'Roads');
