// // Define an area of interest geometry with a global non-polar extent.
// // var aoi = ee.Geometry.Polygon(
// //   [[[-179.0, 78.0], [-179.0, -58.0], [179.0, -58.0], [179.0, 78.0]]], null,
// //   false);
  
// var aoi = ee.Geometry.Polygon( [-50.4658, -2.4241, -58.7541, -2.4241, -58.7541, -10.8444, -50.4658, -10.8444]);



// var ndviCol = ee.ImageCollection('MODIS/006/MOD13A2')
//   .filterBounds(aoi)
//   .filterDate('2018-06-01', '2020-10-01')
//   .select('NDVI');
  

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
var aoi = ee.Geometry.Polygon( [-55.4658, -1.4241, -54.7541, -1.4241, -54.7541, -1.8444, -55.4658, -1.8444]);

var l8_2018 = l8.filterBounds(aoi).filterDate('2018-08-01', '2018-12-31').map(maskL8sr);

var ndviCol = l8_2018.map(addNDVI);

// Define RGB visualization parameters.
var visParams = {
  min: 0.0,
  max: 9000.0,
  palette: [
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  ],
};

var sorted = ndviCol.sort('system:time_start');

// // Create RGB visualization images for use as animation frames.
// var rgbVis = sorted.map(function(img) {
//   return img.visualize(visParams);
// });

var gifParams = {
  'region': aoi,
  'dimensions': 600,
  'crs': 'EPSG:3857',
  'framesPerSecond': 1
};

var text = require('users/gena/packages:text'); // Import gena's package which allows text overlay on image

var annotations = [
  {position: 'left', offset: '1%', margin: '1%', property: 'label', scale: 5} //large scale because image if of the whole world. Use smaller scale otherwise
  ]

// Create RGB visualization images for use as animation frames.
var rgbVis = sorted.map(function(img) {

  // get the time stamp of each frame. This can be any string. Date, Years, Hours, etc.  
  var timeStamp = ee.Date(img.get('system:time_start')).format().slice(0,10); 
  // get the time stamp of each frame. This can be any string. Date, Years, Hours, etc.
  timeStamp = ee.String('Date: ').cat(timeStamp); 
  
  
  var image = img.visualize(visParams).set({'label': timeStamp})
  
  // create a new image with the label overlayed using gena's package
  var annotated = text.annotateImage(image, {}, aoi, annotations); 

  return annotated;
});

print(rgbVis);
print(ui.Thumbnail(rgbVis, gifParams));


// // Import hourly predicted temperature image collection for northern winter
// // solstice. Note that predictions extend for 384 hours; limit the collection
// // to the first 24 hours.
// var tempCol = ee.ImageCollection('NOAA/GFS0P25')
//   .filterDate('2018-12-22', '2018-12-23')
//   .limit(24)
//   .select('temperature_2m_above_ground');
  
// // Define arguments for animation function parameters.
// var videoArgs = {
//   dimensions: 768,
//   region: aoi,
//   framesPerSecond: 7,
//   crs: 'EPSG:3857',
//   min: -40.0,
//   max: 35.0,
//   palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red']
// };

// // Print the animation to the console as a ui.Thumbnail using the above defined
// // arguments. Note that ui.Thumbnail produces an animation when the first input
// // is an ee.ImageCollection instead of an ee.Image.
// print(ui.Thumbnail(tempCol, videoArgs));

// // Alternatively, print a URL that will produce the animation when accessed.
// print(tempCol.getVideoThumbURL(videoArgs));