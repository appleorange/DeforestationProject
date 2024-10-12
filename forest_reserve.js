// var forestCover = ee.Image('UMD/hansen/global_forest_change_2019_v1_7').select('treecover2000');

// // Load the Brazil forest reserve areas dataset.


// // Filter the forest reserves dataset to include only protected areas.
// var protectedAreas = forestReserves.filterMetadata('type', 'equals', 'Protected Areas');

// // Mask the forest cover data with the protected areas.
// var protectedForest = forestCover.mask(protectedAreas);

// // Create a binary mask to identify areas where logging is forbidden.
// var loggingForbidden = protectedForest.eq(100);

// // Display the logging forbidden areas on the map.
// Map.addLayer(loggingForbidden, {palette: 'green'}, 'Logging Forbidden Areas');


var geometry = 
    /* color: #98ff00 */
    /* displayProperties: [
      {
        "type": "rectangle"
      }
    ] */
    ee.Geometry.Polygon(
        [[[-53.590258343318474, -10.056229945836618],
          [-53.590258343318474, -10.072371345793437],
          [-53.54433892498351, -10.072371345793437],
          [-53.54433892498351, -10.056229945836618]]], null, false);
          
          
// Create a feature from the geometry.
var feature = ee.Feature(geometry, {});

// Create a feature collection from the feature.
var featureCollection = ee.FeatureCollection([feature]);

// Add the feature collection to the map as a layer.
Map.addLayer(featureCollection, {}, 'Geometry Layer');

var dataset = ee.FeatureCollection('WCMC/WDPA/current/polygons');
var visParams = {
  palette: ['2ed033', '5aff05', '67b9ff', '5844ff', '0a7618', '2c05ff'],
  min: 0.0,
  max: 1550000.0,
  opacity: 0.8,
};
var image = ee.Image().float().paint(dataset, 'REP_AREA');
Map.centerObject(geometry, 9);
Map.addLayer(image, visParams, 'WCMC/WDPA/current/polygons');
Map.addLayer(dataset, null, 'for Inspector', false);
