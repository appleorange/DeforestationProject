/**
 * Function to mask clouds based on the pixel_qa band of Landsat 8 SR data.
 * @param {ee.Image} image input Landsat 8 SR image
 * @return {ee.Image} cloudmasked Landsat 8 image
 */
function maskL8sr(image) {
  // Bits 3 and 5 are cloud shadow and cloud, respectively.
  var cloudShadowBitMask = (1 << 3);
  var cloudsBitMask = (1 << 5);
  // Get the pixel QA band.
  var qa = image.select('pixel_qa');
  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudShadowBitMask).eq(0)
                 .and(qa.bitwiseAnd(cloudsBitMask).eq(0));
  return image.updateMask(mask);
}


var addNDVI = function(image) {
  var ndvi = image.normalizedDifference(['B5', 'B4']).rename('NDVI');
  return image.addBands(ndvi);
};


var l8 = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR'); 

// var visParams = {bands: ['B4', 'B3', 'B2'], min:0,max: 1000};

//var l8 = ee.ImageCollection('LANDSAT/LC08/C02/T1_TOA');
var roi = ee.Geometry.Polygon( [-55.4658, -1.4241, -54.7541, -1.4241, -54.7541, -1.8444, -55.4658, -1.8444]);

var l8_2018 = l8.filterBounds(roi).filterDate('2018-08-01', '2018-12-31').map(maskL8sr);

var L8_2018_ndvi = l8_2018.map(addNDVI);



var visParams = {
  bands: ['B4', 'B3', 'B2'],
  min: 0,
  max: 3000,
  gamma: 1.4,
};


Map.centerObject(scene, 9);

Map.addLayer(scene, visParams, 'true-color composite');

// Zoom to a location.
//Map.setCenter(-55, -1.6, 9); 

//var visParams = {bands: ['B4', 'B3', 'B2'], max: 0.3};

// This will sort from least to most cloudy.
var sorted = l8_2018.sort('system:time_start'); //CLOUD_COVER');

var sorted = l8_2018.sort('CLOUD_COVER');

// Get the first (least cloudy) image.
var scene = sorted.first();

//print(scene);

Map.centerObject(scene, 9);
//Map.addLayer(scene, {}, 'default RGB');

Map.addLayer(scene, visParams, 'true-color composite');

// // Display the image on the map.
// Map.addLayer(l8_2018, visParams, 'l8 collection');



// // #### Greenest Pixel Composite
// // create normalized difference vegetation index
// var addNDVI = function(image) {
//   var ndvi = image.normalizedDifference(['B5', 'B4']).rename('NDVI');
//   return image.addBands(ndvi);
// };

// // add NDVI to collection
// var withNDVI = l8_2018.map(addNDVI);

// // make greenest pixel composite
// var greenest = withNDVI.qualityMosaic('NDVI');

// // #### Simple Composite
// // import raw landsat imagery
// var l8_t1_raw = ee.ImageCollection('LANDSAT/LC08/C01/T1');
// var l8_t1_raw_2018 = l8_t1_raw.filterBounds(roi).filterDate('2018-01-01', '2018-12-31');

// // create simple composite
// var simpleComposite = ee.Algorithms.Landsat.simpleComposite({
//   collection : l8_t1_raw_2018,
//   asFloat: true,
//   percentile : 50,
//   cloudScoreRange : 10,
// });