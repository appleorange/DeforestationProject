// Load a high-resolution image
var image = ee.Image('USGS/SRTMGL1_003');
var imageVisParam = {min: 0, max: 4000};

// Define the region of interest
var roi = ee.Geometry.Rectangle(-122.45, 37.74, -122.4, 37.8);

// Load a pre-trained TensorFlow model
var model = ee.Model.fromSavedModel({
  model: 'TensorFlow/models/object_detection/faster_rcnn_resnet101_coco_2018_01_28',
  })
  .select(['detection_scores', 'detection_classes', 'detection_boxes']);

// Define the parameters for the object detection algorithm
var objectDetectionParameters = {
  scoreThreshold: 0.5,
  iouThreshold: 0.5,
  maxBoxes: 100,
  classFilter: [24] // class id for 'person'
};

// Run the object detection algorithm
var objectDetections = model.detect(image, roi, objectDetectionParameters);

// Draw the detected objects on the image
var objectDetectionsVis = {
  min: 0,
  max: 1,
  palette: ['red']
};

// Display the image with the detected roads
Map.centerObject(roi, 13);
Map.addLayer(image, imageVisParam, 'Image');
Map.addLayer(objectDetections, objectDetectionsVis, 'Detected Roads');
