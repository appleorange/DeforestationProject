var startYear = 2019;
var endYear = 2021;


          
//var l8 = ee.ImageCollection('LANDSAT/LC08/C02/T1_TOA');
var roi = tefe; //xinguArea; //ee.Geometry.Polygon( [-69, 1.232, -50, 1.243, -50, -7, -69, -7]);
//var xinguIndigenousPark = ee.Geometry.Polygon([ [-53.077, -10.132], [-53.077, -12.219], [-51.283, -12.219], [-51.283, -10.132] ]);


//var roi = xinguArea;//xinguIndigenousPark;

// Create a feature from the geometry.
// var xinguFeature = ee.Feature(xinguArea, {});

// // Create a feature collection from the feature.
// var xinguFeatureCollection = ee.FeatureCollection([xinguFeature]);

// // Add the feature collection to the map as a layer.
// Map.addLayer(xinguFeatureCollection, {}, 'Xingu Geometry Layer');

// //var ee.Feature(null, {'year'}).id());

// // Define a mask to clip the NDVI data by.
// var mask = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017')
//   //.filter(ee.Filter.eq('wld_rgn', 'South America'));
//   .filter(ee.Filter.eq('country_co', 'BR'));

//print(mask);
// Define the regional bounds of animation frames.
//var region = mask.geometry();
var region = amazon_local_with_lost;
var col;

/// ------------------ util functions for MODIS images---------
//function to create mask from SmmaryQA
var maskQA = function(image) {
  return image.updateMask(image.select("SummaryQA").lte(1));
};


///-------------------Landsat 8 util functions ----------------
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


//-----------------Sentinel CLOUDMASK------------
//Function to mask clouds using the Sentinel-2 QA band

function maskS2clouds(image) {
  var qa = image.select('QA60');

  // Bits 10 and 11 are clouds and cirrus, respectively.
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
      .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  return image.updateMask(mask);
}

//-----------------EVI Function----------------

//function to calculate EVI
function evi_calc(img){
  return img.expression(                                           
    '2.5 * ((NIR - RED) / (NIR + 6 * RED - 7.5 * BLUE + 1))', {
      'NIR': img.select('B5').multiply(0.0001),
      'RED': img.select('B4').multiply(0.0001),
      'BLUE': img.select('B2').multiply(0.0001),
  }).select([0],['EVI']);
  
}

//-----------------NDVI Function----------------///
//function to calculate NDVI
function ndvi_calc(img){
    return img.normalizedDifference(['B5','B4']).select([0],['NDVI']);
  }

//function to add EVI and NDVI bands into image 
function addIndices(in_image){
    return in_image.addBands([ndvi_calc(in_image),evi_calc(in_image)]);
}



// image_source can be 'MODIS','LANDSAT'
var image_source = 'MODIS';

if (image_source === 'MODIS') {
// We have multiple ways to choose the satellite images
/** Image source 1: MODIS 
 * we use the summaryQA to create mask
 * We use EVI band
 **/
//var newModisCol = ee.ImageCollection('MODIS/MOD09GA_006_EVI')
//.filterBounds(region)
//.select('EVI');
//col = newModisCol;
//print(newModisCol);

var modisCol = ee.ImageCollection('MODIS/006/MOD13A2')
  .filterBounds(region)
  .select('NDVI', 'SummaryQA', 'EVI');
col = modisCol.map(maskQA).select('EVI');



  
} 

if (image_source === 'LANDSAT') {

/**
 * Image source 2: LATSAT 
 **/
// var L8 = ee.ImageCollection("LANDSAT/LC08/C01/T1_SR")
//   .filterBounds(region)
//   .map(maskL8sr)
//   .select(['B5','B4','B3', 'B2']);
  
// L8 = L8.map(addIndices);
// print(L8);
// col = L8.select('EVI');


var L8 = ee.ImageCollection('LANDSAT/LC08/C01/T1_8DAY_EVI')
  .filterBounds(region)
 // .map(maskL8sr)
  .select('EVI');
  col = L8;
}
  
col = col.map(function(img) {
  var start_date = ee.Date(img.get('system:time_start'));
  var year =start_date.get('year');
  var doy = start_date.getRelative('day', 'year');
  var month = start_date.getRelative('month', 'year');
  return img.set('year', year, 'month', month, 'doy', doy);

});

//print(col);
col = col.filter(ee.Filter.rangeContains('month', 5, 10));
//print(col);
var distinctYear = col.distinct('year');

//print(distinctYear);

var filter = ee.Filter.equals({leftField: 'year', rightField: 'year'});

// Define a join.
var join = ee.Join.saveAll('year_matches');

var postJoin = join.apply(distinctYear, col, filter);
print(postJoin);

// Apply the join and convert the resulting FeatureCollection to an
// ImageCollection.
var joinCol = ee.ImageCollection(postJoin);

// Apply median reduction among matching DOY collections.
var comp = joinCol.map(function(img) {
  var yearCol = ee.ImageCollection.fromImages(
    img.get('year_matches')
  );
  var reducedImage = yearCol.reduce(ee.Reducer.mean());
  return reducedImage.set('year', img.get('year'));
  //return reducedImage;
});

print(comp);

// Define RGB visualization parameters.
var EVIPalette = ['FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718',
               '74A901', '66A000', '529400', '3E8601', '207401', '056201',
               '004C00', '023B01', '012E01', '011D01', '011301'];

var l8NDVIVisParams = {min:-1, max: 1, palette: ['blue', 'white', 'green']};
var l8EVIVisParams = {min:0.0, max: 1.0, palette: EVIPalette};
               

var modisVisParams = {
  min: 0.0,
  max: 9000.0,
  palette: EVIPalette
  // [
  //   'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
  //   '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
  //   '012E01', '011D01', '011301'
  //],
};

var visParamsMin = 0.0;
var visParamsMax = 9000.0;

if (image_source === 'MODIS') {
  visParamsMin = 0.0;
  visParamsMax = 9000.0;
}
else if (image_source === 'LANDSAT') {
  visParamsMin = 0.0;
  visParamsMax = 1.0;
} 

var visParams = {
  min: visParamsMin,
  max: visParamsMax,
  palette: EVIPalette 
}

/// show a map with two layers. The first layer is the first year. The last layer is 2020.
//Composite buttons

// get upto 100 images
var compList = comp.toList(100);
print(compList);
var EVIBefore = compList.get(-4);
print(EVIBefore);
var lastIndex = -2;//-1;
var EVIAfter = compList.get(lastIndex);
print(EVIAfter);


var EVIBeforeImage = ee.Image(EVIBefore);
var EVIAfterImage = ee.Image(EVIAfter);
var EVIBeforeImageMean = EVIBeforeImage.reduceRegion(ee.Reducer.mean(), region);
var EVIAfterImageMean = EVIAfterImage.reduceRegion(ee.Reducer.mean(), region);
//print("EVI before mean", EVIBeforeImageMean);
//print("EVI after mean", EVIAfterImageMean);

var EVIDiff = EVIAfterImage.subtract(EVIBeforeImage);

var diffMean = EVIDiff.reduceRegion(ee.Reducer.mean(), region);
//print("diff mean", diffMean);
// var EVI_mean_min = diffMinMax.get('EVI_mean_min');
// print(EVI_mean_min);
// var EVI_mean_max = diffMinMax.get('EVI_mean_max');

// var startMinMax = EVIBeforeImage.reduceRegion(ee.Reducer.minMax(), region);
// print(startMinMax);

var reservedDataset = ee.FeatureCollection('WCMC/WDPA/current/polygons');
var reservedVisParams = {
  palette: ['2ed033', '5aff05', '67b9ff', '5844ff', '0a7618', '2c05ff'],
  min: 0.0,
  max: 1550000.0,
  opacity: 0.8,
};
var reservedImage = ee.Image().float().paint(reservedDataset, 'REP_AREA');
//Map.centerObject(geometry, 9);
Map.addLayer(reservedImage, reservedVisParams, 'WCMC/WDPA/current/polygons');
Map.addLayer(reservedDataset, null, 'for Inspector', false);



Map.centerObject(roi,9);
//Adds right side panel
var panel = ui.Panel({
  layout: ui.Panel.Layout.flow('vertical'),
  style: {width: '300px'}
});
//Title
panel.add(
  ui.Label({
    value:'Forest Change Detection',
    style: {
            fontWeight: 'bold',
            fontSize: '25px',
            color: '#344ceb'}}
            ));
ui.root.add(panel);
var button1=ui.Button({label: 'EVI Before' , style: {stretch: 'horizontal'}});
var button2=ui.Button({label: 'EVI After' , style: {stretch: 'horizontal'}});
var button3=ui.Button({label: 'EVI Change' , style: {stretch: 'horizontal'}});
panel.add(button1).add(button2).add(button3);  

button1.onClick(function(){Map.addLayer(EVIBeforeImage,
{min: visParamsMin, max: visParamsMax, palette: EVIPalette},'Composite EVI Before');
});
button2.onClick(function(){Map.addLayer(EVIAfterImage,
{min: visParamsMin, max: visParamsMax, palette: EVIPalette},'Composite EVI After');
});
button3.onClick(function(){Map.addLayer(ee.Image(EVIDiff),
{min: -1000, max: 500 , palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']},'Composite EVI Diff');
//{min: 0.0, max: 0.04, palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']},'Composite EVI Diff');
});




if (1) {
// Import gena's package which allows text overlay on image
var text = require('users/gena/packages:text'); 

var annotations = [
  {position: 'left', offset: '1%', margin: '1%', property: 'label', scale: Map.getScale() * 2} ]

// Create RGB visualization images for use as animation frames.
var rgbVis = comp.map(function(img) {
  var image = img.visualize(visParams)//l8EVIVisParams)//visParams)
    .clip(mask).set({'label': img.get('year')})
  
  // create a new image with the label overlayed using gena's package
  var annotated = text.annotateImage(image, {}, region, annotations); 

  return annotated;
});

//Create RGB visualization images for use as animation frames.
// var rgbVis = comp.map(function(img) {
//   return img.visualize(visParams).clip(mask);
// });

// Define GIF visualization parameters.
var gifParams = {
  'region': region,
  'dimensions': 600,
  'crs': 'EPSG:3857',
  'framesPerSecond': 1
};

// Print the GIF URL to the console.
print(rgbVis.getVideoThumbURL(gifParams));

// Render the GIF animation in the console.
print(ui.Thumbnail(rgbVis, gifParams));
}
/*
// var region = ee.Geometry.Polygon(
//   [[[-18.698368046353494, 38.1446395611524],
//     [-18.698368046353494, -36.16300755581617],
//     [52.229366328646506, -36.16300755581617],
//     [52.229366328646506, 38.1446395611524]]],
//   null, false
// );

//var region = ee.Geometry.Polygon( [-55.4658, -1.4241, -54.7541, -1.4241, -54.7541, -1.8444, -55.4658, -1.8444]);

col = col.map(function(img) {
  var doy = ee.Date(img.get('system:time_start')).getRelative('day', 'year');
  return img.set('doy', doy);
});

var distinctDOY = col.filterDate('2013-01-01', '2014-01-01');

print(distinctDOY);

// Define a filter that identifies which images from the complete collection
// match the DOY from the distinct DOY collection.
var filter = ee.Filter.equals({leftField: 'doy', rightField: 'doy'});

// Define a join.
var join = ee.Join.saveAll('doy_matches');

var postJoin = join.apply(distinctDOY, col, filter);
print(postJoin);

// Apply the join and convert the resulting FeatureCollection to an
// ImageCollection.
var joinCol = ee.ImageCollection(postJoin);

// Apply median reduction among matching DOY collections.
var comp = joinCol.map(function(img) {
  var doyCol = ee.ImageCollection.fromImages(
    img.get('doy_matches')
  );
  return doyCol.reduce(ee.Reducer.median());
});

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

// Create RGB visualization images for use as animation frames.
var rgbVis = comp.map(function(img) {
  return img.visualize(visParams).clip(mask);
});

// Define GIF visualization parameters.
var gifParams = {
  'region': region,
  'dimensions': 600,
  'crs': 'EPSG:3857',
  'framesPerSecond': 10
};

// Print the GIF URL to the console.
print(rgbVis.getVideoThumbURL(gifParams));

// Render the GIF animation in the console.
print(ui.Thumbnail(rgbVis, gifParams));
*/