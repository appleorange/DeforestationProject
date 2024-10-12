var aoi = ee.Geometry.Polygon([ [-53.077, -10.132], [-53.077, -12.219], [-51.283, -12.219], [-51.283, -10.132] ]);

// Load Sentinel-2 image collection
var collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
    .filterDate('2020-01-01', '2020-12-31')
    .filterBounds(aoi)
    .map(function(image) {
      return image.clip(aoi);
    });

// Define a cloud mask function
function maskClouds(image) {
  var qa = image.select('QA60');
  var cloudBitMask = ee.Number(2).pow(10).int();
  var cirrusBitMask = ee.Number(2).pow(11).int();
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
      .and(qa.bitwiseAnd(cirrusBitMask).eq(0));
  return image.updateMask(mask);
}

// Apply the cloud mask to the image collection
var filteredCollection = collection.map(maskClouds);


// Compute the NDVI and NDWI indices
var addIndices = function(image) {
  var ndvi = image.normalizedDifference(['B8', 'B4']).rename('NDVI');
  var ndwi = image.normalizedDifference(['B3', 'B8']).rename('NDWI');
  return image.addBands([ndvi, ndwi]);
};

// Add the indices to the image collection
var indexedCollection = filteredCollection.map(addIndices);

// Define the bands and the region of interest for classification
var bands = ['B4', 'B3', 'B2', 'NDVI', 'NDWI'];
//var roi = ee.Geometry.Rectangle(-122.5235, 37.6725, -122.4901, 37.6973);

// Sample the image collection to create a training dataset
var training = indexedCollection.select(bands).mean();
print(training);
training = training.sample({
  region: aoi,
  scale: 10,
  numPixels: 1000
});

// Train a Random Forest classifier using the training dataset
var classifier = ee.Classifier.randomForest().train({
  features: training,
  classProperty: 'road',
  inputProperties: bands
});

// Apply the classifier to the image collection
var classified = indexedCollection.select(bands).mean().classify(classifier);

// Mask the classified image to show only roads
var roads = classified.eq(1).selfMask();

// Display the original image and the detected roads on a map
Map.centerObject(aoi, 17);
Map.addLayer(filteredCollection.median(), {bands: ['B4', 'B3', 'B2'], min: 0, max: 3000}, 'Original Image');
Map.addLayer(roads, {palette: 'red'}, 'Detected Roads');
