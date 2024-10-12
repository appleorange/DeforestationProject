

// ============================
// Short-term Forest Change Tool
// ============================
//
// Last update: April 3, 2020
//
// Created by: NASA DEVELOP Spring 2020 Costa Rica and Panama Ecological 
// Forecasting Project Team: Teodora Mitroi, Kate Markham, Eder Hernandez, 
// Sharifa Karwandyar
//
// Long title: Identifying Current and Future Areas of Environmental Concern 
// in La Amistad International Park to Inform Resource Management
//
// Contact: Teodora Mitroi, mitteodora@gmail.com
//
// The script was developed using Google Earth Engine (GEE). It uses Landsat 8 
// OLI TOA Reflectance with maskL8sr cloud-mask, Sentinel MSI Level-1C with 
// maskS2cloud cloud-mask, and Terra Moderate Resolution Imaging 
// Spectroradiometer (MODIS). It also utilizes the Hansen Global Forest Change 
// v.16 (2000-2018)to mask non-forested areas from calculations. Vegetation 
// indices such as Enhanced Vegetation Index (EVI) and Normalized Difference 
// Vegetation Index (NDVI) were used. The main scope of the software is to 
// display changes in vegetation of forested area and identify regions of 
// possible deforestation.
//
// -----------------
// PROCEDURE:
// -----------------
// 1. Paste the code into GEE.
//
// 2. Scroll to the section “Enter Dates of Choice” and read the instructions 
// in the comments. Enter starting month, starting day, end month, end day, and 
// beginning year of the first year,and do the same for the second(later) date. 
//
// 3. To enter your own study area, you must first import it as an asset into 
// GEE. Click on the “Assets” tab in the left window on the GEE playground and 
// click “NEW.” Then, select “Shape files” and search your directory for your 
// shp, zip, dbf, prj, shx, cpg, fix, qix, sbn or shp.xml files. Next, name your 
// asset, and rewrite your path name so it directs shapefile to your asset. Use 
// lines 107 and 115 as examples.
//
// 4. Press “Run” at the top to start analyzing your input and begin processing.
//
// 5. Buttons will appear on the side where you can select what satellite and 
// vegetation index to use, as well as time interval (before, after, change).
//
// 6. Under the “Tasks” tab on the upper right, the average change in EVI and 
// NDVI by region will display as a percentage for you to export as a table. 
// Click run to download to a folder in your drive you specify in line 166.
//
// 7. To export maps, scroll in the right panel of the user interface to the 
// “Export” section. Press the button of the map you wish to download. Visit the
// “Tasks” tab once more to see your map; press “Run.”After you are finished, 
// you will be able to export the maps as GeoTIFF (.tif) in the  folder 
// you specified on line 166. 
//
// Introduction:
// Since the establishment of the Mesoamerican Biological Corridor in 1997 in 
// Central America, deforestation has continued to plague La Amistad 
// International Park due to the expansion of agriculture and the strain of 
// financial and natural resource management. The Athens Spring 2020 DEVELOP 
// team and the partners created the software to assess forest disturbances and 
// deforestation in the Corridor. The tool calculates NDVI and EVI for any two 
// time periods and maps the change in the indices. 
// 
// Application and Scope:
// Users will be able to input their choice of region and date range and identify areas within the region that have underwent changes in forest cover.
//
// Capabilities:
// The software has the capability to calculate NDVI and EVI for Landsat 8, 
// Sentinel, and MODIS, and calculate the change. It also is able to output the 
// average change of EVI and NDVI 
// for region’s date range. 
//
// Limitations: 
// Because this tool uses the Hansen Global Forest Change dataset, it has the 
// same limitations as this dataset. The Hansen dataset is current only through 
// 2018. Thus, if the user were to attempt to identify changes in EVI from 2019 
// and 2020 (or any time after 2018), the STFC tool verifies that the change 
// occurred in a forested area with 2018 forest cover.  In addition, the canopy 
// cover included in the Hansen dataset is not restricted to only natural forest 
// canopy cover but also includes agricultural areas, plantations, and other 
// vegetation types. If Hansen releases an update for 2019, that data can be 
// easily implemented in the software’s code. 


// *****For more detailed information about using the tool, please see the 
// Short-term Forest Change Tool Operating Procedures Guide. 


//-------------------------Notes about date limitations---------------------///
// Landsat 8 OLI data only goes as far back as April 11, 2013.
// Sentinel 2 data only goes as far back as June 23, 2015.
// Terra MODIS Vegetation Indices only go as far back as July 4th, 2002.


//--------------------------------------------------------------------------///
//--------------------------------USER DEFINED INPUTS-----------------------///
//--------------------------------------------------------------------------///

//----------------------------Enter Study Area------------------------------///
//Changing the study area is optional. The study area currently includes La 
//Amistad International Park in Costa Rica and Panama with additional land 
//outside of the park in Costa Rica. 

//Change path name so that it directs to a shapefile of the study area
var studyArea = ee.FeatureCollection("users/DEVELOP_Geoinformatics/NASA_DEVELOP_Codes/NASA_DEVELOP_Spring2020/GA_CostaRicaPanamaEcoII_STFC/CRP_StudyArea");


//-----------------------Enter Regions for Analysis--------------------------///
//Change path name so that it directs to a single shapefile that
//contains regions within the study area. These are the regions for
//which statistics are calculated and exported as tables. Tables will appear
//on the right under the "Tasks" bar.
var Regions = ee.FeatureCollection("users/DEVELOP_Geoinformatics/NASA_DEVELOP_Codes/NASA_DEVELOP_Spring2020/GA_CostaRicaPanamaEcoII_STFC/StudyAreaRegions");

//------------------Enter Regions for Exporting Sentinel Imagery-------------///
//Regions for Sentinel Export
//Because Sentinel imagery is at 10m resolution, exporting it for the entire study
//region is not possible in GEE at this resolution. If you want to export
//Sentinel imagery at its original resolution, you must enter regions here.
//If you need more than 4 regions, you will also need to change lines 8-91
//as well as lines 1162-1252 (user interface buttons).
//Note: If you want to export the composite Landsat-Sentinel imagery,
//this is at 30m and you do not need to export by region.

var Region1= ee.FeatureCollection('users/DEVELOP_Geoinformatics/NASA_DEVELOP_Codes/NASA_DEVELOP_Spring2020/GA_CostaRicaPanamaEcoII_STFC/LaAmistadPanama');
var Region2= ee.FeatureCollection('users/DEVELOP_Geoinformatics/NASA_DEVELOP_Codes/NASA_DEVELOP_Spring2020/GA_CostaRicaPanamaEcoII_STFC/LaAmistadCaribe');
var Region3= ee.FeatureCollection('users/DEVELOP_Geoinformatics/NASA_DEVELOP_Codes/NASA_DEVELOP_Spring2020/GA_CostaRicaPanamaEcoII_STFC/LaAmistadPacifico');
var Region4= ee.FeatureCollection('users/DEVELOP_Geoinformatics/NASA_DEVELOP_Codes/NASA_DEVELOP_Spring2020/GA_CostaRicaPanamaEcoII_STFC/Osa');

//-------------------------Enter Dates of Choice-----------------------------///
//Format must use "-" and a two digit number
//for yearList, please write year in both locations

//Define date range for earlier image collection. 
//Leave "-" in the variable name.
var startmonth = '-08';
var startday = '-01';
var endmonth = '-12';
var endday = '-31';

// List year to be analyzed for earlier image
var yearList = {
'2016': 2016
};

// Define date range for second(later) image collection
//Leave "-" in the variable name.
var Laterstartmonth = '-08';
var Laterstartday = '-01';
var Laterendmonth = '-12';
var Laterendday = '-31';

// List later year to be analyzed
var LateryearList = {
'2019': 2019
};

//-------------------------------Exporting---------------------------------///
//Specify the exact name of the folder in Google Earth Engine you 
//would like exports to go to. Exports will appear in the "Tasks" tab
//on the righthand side of the screen. You will need to click "RUN"
//for the exports you want. It may take considerable time to export these
//images and tables.
var GEE_Folder = 'GEE_Exports';

//--------------------------------------------------------------------------///
//--------------------------------------------------------------------------///
//-------------NOTHING BELOW THIS POINT NEEDS TO BE CHANGED BY USER---------///
//--------------------------------------------------------------------------///
//--------------------------------------------------------------------------///

//------------------------------------------
//-----EARTH OBSERVATIONS AND HANSEN DATA----///
//------------------------------------------

// Importing USGS Landsat 8 Surface Reflectance
var L8 = ee.ImageCollection("LANDSAT/LC08/C01/T1_SR");

//Importing Sentinel 2 TOA
var S2 = ee.ImageCollection("COPERNICUS/S2");

//Importing MODIS Products
var MODISVeg = ee.ImageCollection("MODIS/006/MOD13Q1");
//Map.addLayer(MODISVeg);

//Import Hansen Global Forest Change dataset
//and the bands we are manipulating: tree cover and loss for every year
var image = ee.Image("UMD/hansen/global_forest_change_2018_v1_6");
var TC2000 = image.select('treecover2000');
var lossyear = image.select('lossyear');

//--------------------------------------------------------------------------///
//------------------------------------DISPLAY-------------------------------///
//--------------------------------------------------------------------------///

//-------------------Palettes--------------

var visParams = {bands: ['B4', 'B3', 'B2'], min:0,max: 1000};
var EVIPalette = ['FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718',
               '74A901', '66A000', '529400', '3E8601', '207401', '056201',
               '004C00', '023B01', '012E01', '011D01', '011301'];

//Create custom palettes to place theresholds on tree cover change 
var setPalettesEVI = function(image){
  image = image;
  var image01 = image.gte(-100);//red, 80-100 loss, category 1
  var image02 = image.gte(-80);//dark orange, 60-80 loss, cat. 2
  var image03 = image.gte(-60);//orange, 40-60 loss, cat. 3
  var image04 = image.gte(-40);//yellow, 20-40 loss, cat 4
  var image05 = image.gte(-20);//pale/green yellow, 0-20 loss, cat 5 STABLE
  var image06 = image.gte(0);//light green, 0-30 gain, cat 6
  var image07 = image.gte(20); //darker green, >30 gain, cat 7
  return image01.add(image02).add(image03).add(image04).add(image05).add(image06).add(image07);
};

var setPalettesNDVI = function(image){
  image = image;
  var image01 = image.gte(-100);//red, 80-100 loss, category 1
  var image02 = image.gte(-80);//dark orange, 60-80 loss, cat. 2
  var image03 = image.gte(-60);//orange, 40-60 loss, cat. 3
  var image04 = image.gte(-40);//yellow, 20-40 loss, cat 4
  var image05 = image.gte(-20);//pale/green yellow, 0-20 loss, cat 5 STABLE
  var image06 = image.gte(0);//light green, 0-30 gain, cat 6
  var image07 = image.gte(30); //darker green, >30 gain, cat 7
  return image01.add(image02).add(image03).add(image04).add(image05).add(image06).add(image07);
};

//------------------Map display-------------
//Displaying study area, centering map, and adding border as a layer

var geometry = studyArea.geometry();
Map.centerObject(studyArea,9);
Map.addLayer(studyArea,null,"StudyArea",false);

//--------------------------------------------------------------------------///
//----------------------UPDATING HANSEN DATA--------------------------------///
//--------------------------------------------------------------------------///

//Creating updated maps for every year to include tree cover and the loss
var treeCoverThreshold = TC2000.gte(70); //at least 70% tree cover in 2000 
var lossyear12 = lossyear.eq(12); // loss from 2000-2012
var lossyear13 = lossyear.eq(13); // loss from 2000-2013
var lossyear14 = lossyear.eq(14); // loss from 2000-2014
var lossyear15 = lossyear.eq(15); // loss from 2000-2015
var lossyear16 = lossyear.eq(16); // loss from 2000-2016
var lossyear17 = lossyear.eq(17); // loss from 2000-2017
var lossyear18 = lossyear.eq(18); // loss from 2000-2017
// Inverting the colors to match the tree cover pallette
var lossyear12=lossyear12.not();
var lossyear13=lossyear13.not();
var lossyear14=lossyear14.not();
var lossyear15=lossyear15.not();
var lossyear16=lossyear16.not();
var lossyear17=lossyear17.not();
var lossyear18=lossyear18.not();
//Combining tree cover and loss
var update12 = treeCoverThreshold.and(lossyear12);
var update13 = treeCoverThreshold.and(lossyear13);
var update14 = treeCoverThreshold.and(lossyear14);
var update15 = treeCoverThreshold.and(lossyear15);
var update16 = treeCoverThreshold.and(lossyear16);
var update17 = treeCoverThreshold.and(lossyear17);
var update18 = treeCoverThreshold.and(lossyear18);

var update12=update12.clip(studyArea);
var update13=update13.clip(studyArea);
var update14=update14.clip(studyArea);
var update15=update15.clip(studyArea);
var update16=update16.clip(studyArea);
var update17=update17.clip(studyArea);
var update18=update18.clip(studyArea);


//---------------------------------------------------------------------------///
//-----------------------FUNCTIONS FOR INDICES/MASKS/ETC---------------------///
//---------------------------------------------------------------------------///

///-------------------Landsat 8 OLI CLOUDMASK----------------
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


//---------------Composite of Sentinel and Landsat Functions--------------///

function composite1 (img){
  return img.expression(                                           
    '(M1+M2) / 2', {
      'M1': img.select('L8StartEVI'),
      'M2': img.select('S2StartEVI'),})
  .select([0],['Comp']);
}
  
function composite2 (img){
  return img.expression(                                           
    '(M1+M2) / 2', {
      'M1': img.select('L8EndEVI'),
      'M2': img.select('S2EndEVI'),})
  .select([0],['Comp']);
}

function composite3 (img){
  return img.expression(                                           
    '(M1+M2) / 2', {
      'M1': img.select('L8StartNDVI'),
      'M2': img.select('S2StartNDVI'),})
  .select([0],['Comp']);
}
function composite4 (img){
  return img.expression(                                           
    '(M1+M2) / 2', {
      'M1': img.select('L8EndNDVI'),
      'M2': img.select('S2EndNDVI'),})
  .select([0],['Comp']);
}

function composite5 (img){
  return img.expression(                                           
    '(M1+M2) / 2', {
      'M1': img.select('L8EVIChange'),
      'M2': img.select('S2EVIChange'),})
  .select([0],['Comp']);
}
function composite6 (img){
  return img.expression(                                           
    '(M1+M2) / 2', {
      'M1': img.select('L8NDVIChange'),
      'M2': img.select('S2NDVIChange'),})
  .select([0],['Comp']);
}
//--------------------------------------------------------------------------///
//---------MASK CLOUDS AND SHADOWS, FILTER DATES, CALCULATE INDICES---------///
//----------------------------FOR LANDSAT 8 IMAGERY------------------------///
//--------------------------------------------------------------------------///

//Filtering Earlier imagery dates

var year, geometry;
for (var year in yearList) {
  var yr = year.toString();
  var mo1 = startmonth.toString();
  var mo2 = endmonth.toString();
  var day1 = startday.toString();
  var day2 = endday.toString();
  if (yr >= 2012) {
    var L8start = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR')
      .filterDate(yr+mo1+day1, yr+mo2+day2) 
      .filterBounds(geometry)
      .sort('CLOUD_COVER', true)
      .map(maskL8sr)
      .select(['B5','B4','B3', 'B2'])
      .map(addIndices)
      .median()
      .clip(geometry);
    // The final image collection uses a unique date range in order
    //to pull in the most up-to-date Landsat imagery possible. 
  }}
print('Landsat composite using imagery starting in the month of', startmonth, 'and the day of', startday, 
'and ending in the month of', endmonth, 'and the day of', endmonth, 'for the year', yr);

//Filtering Later imagery date

var year, geometry;
for (var Lateryear in LateryearList) {
  var Lateryr = Lateryear.toString();
  var Latermo1 = Laterstartmonth.toString();
  var Latermo2 = Laterendmonth.toString();
  var Laterday1 = Laterstartday.toString();
  var Laterday2 = Laterendday.toString();
  if (Lateryr >= 2012) {
    var L8end = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR')
      .filterDate(Lateryr+Latermo1+Laterday1, Lateryr+Latermo2+Laterday2) 
      .filterBounds(geometry)
      .sort('CLOUD_COVER', true)
      .map(maskL8sr)
      .select(['B5','B4','B3', 'B2'])
      .map(addIndices)
      .median()
      .clip(geometry);
    // The final image collection uses a unique date range 
    //in order to pull in the most up-to-date Landsat imagery possible. 
  }}
  print('Landsat composite using imagery starting in the month of', Laterstartmonth, 'and the day of', Laterstartday, 
'and ending in the month of', Laterendmonth, 'and the day of', Laterendmonth, 'for the year', Lateryr);
// Multiply by 100 to get from 0 to 100 instead of 0 to 1 for accuracy purposes
var L8start=L8start.multiply(100);
var L8end=L8end.multiply(100);




//--------------------------------------------------------------------------///
//-----------MASK CLOUDS AND SHADOWS, FILTER DATES, CALCULATE INDICES-------///
//------------------------FOR SENTINEL IMAGERY------------------------------///
//--------------------------------------------------------------------------///

//Filtering Earlier imagery date

var year, geometry;
for (var year in yearList) {
  var yr = year.toString();
  var mo1 = startmonth.toString();
  var mo2 = endmonth.toString();
  var day1 = startday.toString();
  var day2 = endday.toString();
  if (yr >= 2014) {
    var S2start = ee.ImageCollection('COPERNICUS/S2')
      .filterDate(yr+mo1+day1, yr+mo2+day2) 
      .filterBounds(geometry)
      .sort('CLOUDY_PIXEL_PERCENTAGE', true)
      .map(maskS2clouds)
      .select(['B8', 'B4', 'B3', 'B2'],['B5', 'B4', 'B3','B2'])
      .map(addIndices)
      .median()
      .clip(geometry);
    // The final image collection uses a unique date range in order
    //to pull in the most up-to-date Sentinel imagery possible. 
  }}
print('Sentinel composite using imagery starting in the month of', startmonth, 'and the day of', startday, 
'and ending in the month of', endmonth, 'and the day of', endmonth, 'for the year', yr);
//Filtering Later imagery date

var year, geometry;
for (var Lateryear in LateryearList) {
  var Lateryr = Lateryear.toString();
  var Latermo1 = Laterstartmonth.toString();
  var Latermo2 = Laterendmonth.toString();
  var Laterday1 = Laterstartday.toString();
  var Laterday2 = Laterendday.toString();
  if (Lateryr >= 2013) {
    var S2end = ee.ImageCollection('COPERNICUS/S2')
      .filterDate(Lateryr+Latermo1+Laterday1, Lateryr+Latermo2+Laterday2) 
      .filterBounds(geometry)
      .sort('CLOUDY_PIXEL_PERCENTAGE', true)
      .map(maskS2clouds)
      .select(['B8', 'B4', 'B3', 'B2'],['B5', 'B4', 'B3','B2'])
      .map(addIndices)
      .median()
      .clip(geometry);
    // The final image collection uses a unique date range in order
    //to pull in the most up-to-date Sentinel imagery possible. 
  }}
print('Sentinel composite using imagery starting in the month of', Laterstartmonth, 'and the day of', Laterstartday, 
'and ending in the month of', Laterendmonth, 'and the day of', Laterendmonth, 'for the year', Lateryr);

// Multiply by 100 to get from 0 to 100 instead of 0 to 1 for accuracy purposes
var S2start=S2start.multiply(100);
var S2end=S2end.multiply(100);

//--------------------------------------------------------------------------///
//-----------------------------FILTER DATES---------------------------------///
//---------------------------FOR MODIS VEGETATION PRODUCTS------------------///
//--------------------------------------------------------------------------///

//Filtering Earlier imagery date

var year, geometry;
for (var year in yearList) {
  var yr = year.toString();
  var mo1 = startmonth.toString();
  var mo2 = endmonth.toString();
  var day1 = startday.toString();
  var day2 = endday.toString();
  if (yr >= 2002) {
    var Mstart = ee.ImageCollection("MODIS/006/MOD13Q1")
      .filterDate(yr+mo1+day1, yr+mo2+day2) 
      .filterBounds(geometry)
      .select(['EVI', 'NDVI'])
      .median()
      .clip(geometry);
    // The final image collection uses a unique date range in order
    //to pull in the most up-to-date MODIS imagery possible. 
  }}
print('MODIS composite using imagery starting in the month of', startmonth, 'and the day of', startday, 
'and ending in the month of', endmonth, 'and the day of', endmonth, 'for the year', yr);
//Filtering Later imagery date

var year, geometry;
for (var Lateryear in LateryearList) {
  var Lateryr = Lateryear.toString();
  var Latermo1 = Laterstartmonth.toString();
  var Latermo2 = Laterendmonth.toString();
  var Laterday1 = Laterstartday.toString();
  var Laterday2 = Laterendday.toString();
  if (Lateryr >= 2002) {
    var Mend = ee.ImageCollection("MODIS/006/MOD13Q1")
      .filterDate(Lateryr+Latermo1+Laterday1, Lateryr+Latermo2+Laterday2) 
      .filterBounds(geometry)
      .select('EVI', 'NDVI')
      .median()
      .clip(geometry);
    // The final image collection uses a unique date range in order
    //to pull in the most up-to-date MODIS imagery possible. 
  }}
print('MODIS composite using imagery starting in the month of', Laterstartmonth, 'and the day of', Laterstartday, 
'and ending in the month of', Laterendmonth, 'and the day of', Laterendmonth, 'for the year', Lateryr);

// Multiply by 100 to get from 0 to 100 instead of 0 to 1 for accuracy purposes
var Mstart=Mstart.divide(100);
var Mend=Mend.divide(100);


//---------------------------------------------------------------------------///
//--------------------MASK NON-TREE COVER AREA (FROM HANSEN)-----------------///
//---------------------------------------------------------------------------///

//Creating a watermask to integrate into the first condition's false statement
var datamask=image.select('datamask');
var mask=datamask.eq(0);
var watermask = datamask.eq(1).and(mask);
var watermask=watermask.not();
//Function that compares yr(Earlier year) or Lateryr (Later year) to 2013-2020 in order to mask the appropriate tree cover update
var HansenUpdatecond= function(image){
  var cond1= ee.Algorithms.If(ee.Algorithms.IsEqual(yr,'2013'),image.updateMask(update13.eq(1)),image.updateMask(watermask));
  var cond2= ee.Algorithms.If(ee.Algorithms.IsEqual(yr,'2014'),image.updateMask(update14.eq(1)),image.updateMask(cond1));
  var cond3= ee.Algorithms.If(ee.Algorithms.IsEqual(yr,'2015'),image.updateMask(update15.eq(1)),image.updateMask(cond2));
  var cond4= ee.Algorithms.If(ee.Algorithms.IsEqual(yr,'2016'),image.updateMask(update16.eq(1)),image.updateMask(cond3));
  var cond5= ee.Algorithms.If(ee.Algorithms.IsEqual(yr,'2017'),image.updateMask(update17.eq(1)), image.updateMask(cond4));
  var cond6= ee.Algorithms.If(ee.Algorithms.IsEqual(yr,'2018'),image.updateMask(update18.eq(1)), image.updateMask(cond5));
  var cond7= ee.Algorithms.If(ee.Algorithms.IsEqual(yr,'2019'),image.updateMask(update18.eq(1)), image.updateMask(cond6));
  var cond77= ee.Algorithms.If(ee.Algorithms.IsEqual(yr,'2020'),image.updateMask(update18.eq(1)), image.updateMask(cond7));
  var cond8= ee.Algorithms.If(ee.Algorithms.IsEqual(Lateryr,'2013'),image.updateMask(update13.eq(1)), image.updateMask(cond77));
  var cond9= ee.Algorithms.If(ee.Algorithms.IsEqual(Lateryr,'2014'),image.updateMask(update14.eq(1)), image.updateMask(cond8));
  var cond10= ee.Algorithms.If(ee.Algorithms.IsEqual(Lateryr,'2015'),image.updateMask(update15.eq(1)), image.updateMask(cond9));
  var cond11= ee.Algorithms.If(ee.Algorithms.IsEqual(Lateryr,'2016'),image.updateMask(update16.eq(1)), image.updateMask(cond10));
  var cond12= ee.Algorithms.If(ee.Algorithms.IsEqual(Lateryr,'2017'),image.updateMask(update17.eq(1)), image.updateMask(cond11));
  var cond13= ee.Algorithms.If(ee.Algorithms.IsEqual(Lateryr,'2018'),image.updateMask(update18.eq(1)), image.updateMask(cond12));
  var cond14= ee.Algorithms.If(ee.Algorithms.IsEqual(Lateryr,'2019'),image.updateMask(update18.eq(1)), image.updateMask(cond13));
  var cond15= ee.Algorithms.If(ee.Algorithms.IsEqual(Lateryr,'2020'),image.updateMask(update18.eq(1)), image.updateMask(cond14));
// return cond1,cond2,cond3,cond4,cond5,cond6,cond7,cond77
  return cond1,cond2,cond3,cond4,cond5,cond6,cond7,cond8,cond9,cond10,cond11,cond12,cond13,cond77,cond14,cond15};
//Reverting variables to ImageCollection in order to use .map function
var L8start = ee.ImageCollection(L8start);
var L8end = ee.ImageCollection(L8end);
var S2start = ee.ImageCollection(S2start);
var S2end = ee.ImageCollection(S2end);
var Mstart = ee.ImageCollection(Mstart);
var Mend = ee.ImageCollection(Mend);
// //Apply function to all variables and renaming them
var L8start=L8start.map(HansenUpdatecond);
var L8end=L8end.map(HansenUpdatecond);
var S2start=S2start.map(HansenUpdatecond);
var S2end=S2end.map(HansenUpdatecond);
var Mstart=Mstart.map(HansenUpdatecond);
var Mend=Mend.map(HansenUpdatecond);


//---------------------------------------------------------------------------///
//--------------------------CALCULATING VEGETATION CHANGE--------------------///
//---------------------------------------------------------------------------///

// Covert ImageCollection to Image using the median function 
//to perform subtraction. Note: ee.Image throws an error  

var S2end=S2end.median();
var S2start=S2start.median();

var L8end=L8end.median();
var L8start=L8start.median();

var Mend=Mend.median();
var Mstart=Mstart.median();

//Calculate the change between the two images
var S2change = S2end.subtract(S2start);  
var L8change=L8end.subtract(L8start);
var Mchange=Mend.subtract(Mstart);

//---------------------------------------------------------------------------///
//-------------CREATE COMPOSITE IMAGES FOR ANALYSIS AND EXPORT---------------///
//---------------------------------------------------------------------------///

//Separate individual change, NDVI, and EVI bands and 
// create composite images for each satellite 

var L8StartEVI = L8start.select('EVI').rename('L8StartEVI');
var L8EndEVI = L8end.select('EVI').rename('L8EndEVI');
var L8StartNDVI = L8start.select('NDVI').rename('L8StartNDVI');
var L8EndNDVI = L8end.select('NDVI').rename('L8EndNDVI');
var S2StartEVI = S2start.select('EVI').rename('S2StartEVI');
var S2EndEVI = S2end.select('EVI').rename('S2EndEVI');
var S2StartNDVI = S2start.select('NDVI').rename('S2StartNDVI');
var S2EndNDVI = S2end.select('NDVI').rename('S2EndNDVI');
var MStartEVI = Mstart.select('EVI').rename('MStartEVI');
var MEndEVI = Mend.select('EVI').rename('MEndEVI');
var MStartNDVI = Mstart.select('NDVI').rename('MStartNDVI');
var MEndNDVI = Mend.select('NDVI').rename('MEndNDVI');
var L8EVIChange =  L8change.select('EVI').rename('L8EVIChange');
var L8NDVIChange =  L8change.select('NDVI').rename('L8NDVIChange');
var S2EVIChange =  S2change.select('EVI').rename('S2EVIChange');
var S2NDVIChange =  S2change.select('NDVI').rename('S2NDVIChange');
var MEVIChange =  Mchange.select('EVI').rename('MEVIChange');
var MNDVIChange =  Mchange.select('NDVI').rename('MNDVIChange');


var LandsatComposite= L8StartEVI.addBands([L8EndEVI]);
var LandsatComposite= LandsatComposite.addBands([L8StartNDVI]);
var LandsatComposite= LandsatComposite.addBands([L8EndNDVI]);
var SentinelComposite= S2StartEVI.addBands([S2EndEVI]);
var SentinelComposite= SentinelComposite.addBands([S2StartNDVI]);
var SentinelComposite= SentinelComposite.addBands([S2EndNDVI]);
var MODISComposite= MStartEVI.addBands([MEndEVI]);
var MODISComposite= MODISComposite.addBands([MStartNDVI]);
var MODISComposite= MODISComposite.addBands([MEndNDVI]);
var LandsatComposite= LandsatComposite.addBands([L8EVIChange]);
var LandsatComposite= LandsatComposite.addBands([L8NDVIChange]);
var SentinelComposite= SentinelComposite.addBands([S2EVIChange]);
var SentinelComposite= SentinelComposite.addBands([S2NDVIChange]);
var MODISComposite= MODISComposite.addBands([MEVIChange]);
var MODISComposite= MODISComposite.addBands([MNDVIChange]);

var LandsatEVIComposite= L8StartEVI.addBands([L8EndEVI]);
var LandsatEVIComposite= LandsatEVIComposite.addBands([L8EVIChange]);
var LandsatNDVIComposite= L8StartNDVI.addBands([L8EndNDVI]);
var LandsatNDVIComposite= LandsatNDVIComposite.addBands([L8NDVIChange]);
var SentinelEVIComposite= S2StartEVI.addBands([S2EndEVI]);
var SentinelEVIComposite= SentinelEVIComposite.addBands([S2EVIChange]);
var SentinelNDVIComposite= S2StartNDVI.addBands([S2EndNDVI]);
var SentinelNDVIComposite= SentinelNDVIComposite.addBands([S2NDVIChange]);
var MODISEVIComposite= MEndEVI.addBands([MStartEVI]);
var MODISEVIComposite= MODISEVIComposite.addBands([MEVIChange]);
var MODISNDVIComposite= MStartEVI.addBands([MEndEVI]);
var MODISNDVIComposite= MODISNDVIComposite.addBands([MNDVIChange]);

//-------------Combining Landsat and Sentinel imagery-------------
//Composite of Sentinel and Landsat Start and End
var L8StartEVI1 = ee.ImageCollection(L8StartEVI);
var S2StartEVI1 = ee.ImageCollection(S2StartEVI);
var comp1=L8StartEVI1.combine(S2StartEVI1);

var L8EndEVI1 = ee.ImageCollection(L8EndEVI);
var S2EndEVI1 = ee.ImageCollection(S2EndEVI);
var comp2=L8EndEVI1.combine(S2EndEVI1);

var L8StartNDVI1 = ee.ImageCollection(L8StartNDVI);
var S2StartNDVI1 = ee.ImageCollection(S2StartNDVI);
var comp3=L8StartNDVI1.combine(S2StartNDVI1);

var L8EndNDVI1 = ee.ImageCollection(L8EndNDVI);
var S2EndNDVI1 = ee.ImageCollection(S2EndNDVI);
var comp4=L8EndNDVI1.combine(S2EndNDVI1);

//Apply composite functions to combine Landsat and Sentinel imagery
var L8S2StartEVI  = comp1.map(composite1);
var L8S2EndEVI = comp2.map(composite2);
var L8S2StartNDVI = comp3.map(composite3);
var L8S2EndNDVI = comp4.map(composite4);


//--------------Create variables of results for mapping-------------------///
//Converting to Image Collection data type in order to use .map function
var L8EVIChangeCol = ee.ImageCollection(L8EVIChange);
var L8EVIChangeCol = L8EVIChangeCol.map(setPalettesEVI);
var L8NDVIChangeCol = ee.ImageCollection(L8NDVIChange);
var L8NDVIChangeCol = L8NDVIChangeCol.map(setPalettesNDVI);

var S2EVIChangeCol = ee.ImageCollection(S2EVIChange);
var S2EVIChangeCol = S2EVIChangeCol.map(setPalettesEVI);
var S2NDVIChangeCol = ee.ImageCollection(S2NDVIChange);
var S2NDVIChangeCol = S2NDVIChangeCol.map(setPalettesNDVI);

var MEVIChangeCol = ee.ImageCollection(MEVIChange);
var MEVIChangeCol = MEVIChangeCol.map(setPalettesEVI);
var MNDVIChangeCol = ee.ImageCollection(MNDVIChange);
var MNDVIChangeCol = MNDVIChangeCol.map(setPalettesNDVI);



//------Calculate changes in EVI and NDVI for Landsat-Sentinel Composite-----///
var comp5=L8EVIChangeCol.combine(S2EVIChangeCol);
var comp6=L8NDVIChangeCol.combine(S2NDVIChangeCol);

var L8S2ChangeEVI = comp5.map(composite5);
var L8S2ChangeNDVI = comp6.map(composite6);


//------------Creating Composite Images of the Landsat-Sentinel--------------///
//-------------------Composites for Analysis and Export----------------------///


//---change from image collection to images-----
var L8S2StartEVI_img  = L8S2StartEVI.min();
var L8S2EndEVI_img = L8S2EndEVI.min();
var L8S2StartNDVI_img = L8S2EndEVI.min();
var L8S2EndNDVI_img =L8S2EndNDVI.min();
var L8S2ChangeEVI_img = L8S2ChangeEVI.min();
var L8S2ChangeNDVI_img = L8S2ChangeNDVI.min();

//Separate individual change, NDVI, and EVI bands and
// create composite images for each satellite
var L8S2StartEVI_img = L8S2StartEVI_img.select('Comp').rename('StartEVI');
var L8S2EndEVI_img = L8S2EndEVI_img.select('Comp').rename('EndEVI');
var L8S2StartNDVI_img = L8S2StartNDVI_img.select('Comp').rename('StartNDVI');
var L8S2EndNDVI_img = L8S2EndNDVI_img.select('Comp').rename('EndNDVI');
var L8S2ChangeEVI_img = L8S2ChangeEVI_img.select('Comp').rename('ChangeEVI');
var L8S2ChangeNDVI_img = L8S2ChangeNDVI_img.select('Comp').rename('ChangeNDVI');


var LS_EVI= L8S2StartEVI_img.addBands([L8S2EndEVI_img]);
var LS_EVI= LS_EVI.addBands([L8S2ChangeEVI_img]);

var LS_NDVI=  L8S2StartNDVI_img.addBands([L8S2EndNDVI_img]);
var LS_NDVI= LS_NDVI.addBands([L8S2ChangeNDVI_img]);

//Change all bands to float data type for image export
LS_NDVI = LS_NDVI.float();
LS_EVI = LS_EVI.float();

 //----------------------------------------------------
 //-Quantifying imagery/change by region and exporting-
 //----------------------------------------------------

// get mean LS EVI change values by region polygon
var RegionLSChangeEVI = L8S2ChangeEVI_img.reduceRegions({
  collection: Regions,
  reducer: ee.Reducer.mean(),
  crs: 'EPSG:4326',
  scale: 30
});

// Table to Drive Export 
Export.table.toDrive({
  collection: RegionLSChangeEVI,
  description: 'LSEVIChangeByRegion',
  folder: GEE_Folder,
  fileFormat: 'CSV'
});   

// get mean LS NDVI change values by region polygon
var RegionLSChangeNDVI = L8S2ChangeNDVI_img.reduceRegions({
  collection: Regions,
  reducer: ee.Reducer.mean(),
  crs: 'EPSG:4326',
  scale: 30
});

// Table to Drive Export 
Export.table.toDrive({
  collection: RegionLSChangeNDVI,
  description: 'LSNDVIChangeByRegion',
  folder: GEE_Folder,
  fileFormat: 'CSV'
});   

// get mean L8 EVI change values by region polygon
var RegionL8ChangeEVI = L8EVIChange.reduceRegions({
  collection: Regions,
  reducer: ee.Reducer.mean(),
  crs: 'EPSG:4326',
  scale: 30
});

// Table to Drive Export 
Export.table.toDrive({
  collection: RegionL8ChangeEVI,
  description: 'LandsatEVIChangeByRegion',
  folder: GEE_Folder,
  fileFormat: 'CSV'
});   

// get mean L8 NDVI change values by region polygon
var RegionL8ChangeNDVI = L8NDVIChange.reduceRegions({
  collection: Regions,
  reducer: ee.Reducer.mean(),
  crs: 'EPSG:4326',
  scale: 30
});

// Table to Drive Export 
Export.table.toDrive({
  collection: RegionL8ChangeNDVI,
  description: 'LandsatNDVIChangeByRegion',
  folder: GEE_Folder,
  fileFormat: 'CSV'
});   

// get mean S2 EVI change values by region polygon
var RegionS2ChangeEVI = S2EVIChange.reduceRegions({
  collection: Regions,
  reducer: ee.Reducer.mean(),
  crs: 'EPSG:4326',
  scale: 10,
  tileScale: 16
});

// Table to Drive Export 
Export.table.toDrive({
  collection: RegionS2ChangeEVI,
  description: 'S2EVIChangeByRegion',
  folder: GEE_Folder,
  fileFormat: 'CSV'
});   

// get mean S2 NDVI change values by region polygon
var RegionS2ChangeNDVI = S2NDVIChange.reduceRegions({
  collection: Regions,
  reducer: ee.Reducer.mean(),
  crs: 'EPSG:4326',
  scale: 10,
  tileScale: 16
});

// Table to Drive Export 
Export.table.toDrive({
  collection: RegionS2ChangeNDVI,
  description: 'S2NDVIChangeByRegion',
  folder: GEE_Folder,
  fileFormat: 'CSV'
});   

// get mean MODIS EVI change values by region polygon
var RegionMChangeEVI = MEVIChange.reduceRegions({
  collection: Regions,
  reducer: ee.Reducer.mean(),
  crs: 'EPSG:4326',
  scale: 250
});


// Table to Drive Export 
Export.table.toDrive({
  collection: RegionMChangeEVI,
  description: 'MODISEVIChangeByRegion',
  folder: GEE_Folder,
  fileFormat: 'CSV'
});   

// get mean MODIS NDVI change values by region polygon
var RegionMChangeNDVI = MNDVIChange.reduceRegions({
  collection: Regions,
  reducer: ee.Reducer.mean(),
  crs: 'EPSG:4326',
  scale: 250
});


// Table to Drive Export 
Export.table.toDrive({
  collection: RegionMChangeNDVI,
  description: 'MODISNDVIChangeByRegion',
  folder: GEE_Folder,
  fileFormat: 'CSV'
});   
//---------------------------------------------------------------------------///
//--------------------------------USER INTERFACE-----------------------------///
//---------------------------------------------------------------------------///

//Adds right side panel
var panel = ui.Panel({
  layout: ui.Panel.Layout.flow('vertical'),
  style: {width: '300px'}
});
//Title
panel.add(
  ui.Label({
    value:'Short-term Forest Change Tool',
    style: {
            fontWeight: 'bold',
            fontSize: '22px',
            color: '#228B22'}}
            ));
ui.root.add(panel);

//Instructions text 
var instructions =  ui.Label('This interface allows users to display EVI and NDVI maps and export them. The interface is organized as follows: First are the display and export options for the Landat-Sentinel Composites, which are at 30m resolution. Following the Landsat-Sentinel Composites are the options for viewing and exporting maps from three satellite-sensors: Landsat 8 OLI, Sentinel 2, and Terra MODIS. We recommend displaying all imagery before exporting. Please note that it may take a long time to export some of the images. If there is significant cloud coverage in your region of interest, we suggest trying Terra MODIS.', {
                fontSize: '12px',
            });
panel.add(instructions);   

//Composite label 
 var co =  ui.Label('Displaying Landsat-Sentinel Composite Maps:', {
                fontWeight: 'bold',
                textAlign: 'center',
                fontSize: '20px',
            });
panel.add(co);   
  
//Composite buttons
var button19=ui.Button({label: 'Composite EVI Before' , style: {stretch: 'horizontal'}});
var button20=ui.Button({label: 'Composite  EVI After' , style: {stretch: 'horizontal'}});
var button21=ui.Button({label: 'Composite  EVI Change' , style: {stretch: 'horizontal'}});
var button22=ui.Button({label: 'Composite  NDVI Before' , style: {stretch: 'horizontal'}});
var button23=ui.Button({label: 'Composite  NDVI After' , style: {stretch: 'horizontal'}});
var button24=ui.Button({label: 'Composite  NDVI Change' , style: {stretch: 'horizontal'}});
panel.add(button19).add(button20).add(button21).add(button22).add(button23).add(button24);  

button19.onClick(function(){Map.addLayer(L8S2StartEVI,
{min: 0, max: 100, palette: EVIPalette},'Composite EVI Before');
});
button20.onClick(function(){Map.addLayer(L8S2EndEVI,
{min: 0, max: 100, palette: EVIPalette},'Composite EVI After');
});
button21.onClick(function(){Map.addLayer(L8S2ChangeEVI,
{min: 1, max: 7, palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']}, 'Composite EVI Change');
});

button22.onClick(function(){Map.addLayer(L8S2StartNDVI,
{min: 0, max: 100, palette: EVIPalette},'Composite NDVI Before');
});
button23.onClick(function(){Map.addLayer(L8S2EndNDVI,
{min: 0, max: 100, palette: EVIPalette},'Composite NDVI After');
});
button24.onClick(function(){Map.addLayer(L8S2ChangeNDVI,
{min: 1, max: 7, palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']}, 'Composite NDVI Change');
});

//Export label 
var exportingComposites =  ui.Label('Exporting Landsat-Sentinel Composites as GeoTIFF Files:', {
                fontWeight: 'bold',
                textAlign: 'center',
                fontSize: '20px',
            });
panel.add(exportingComposites);

//Creating buttons for composite exports
var button19=ui.Button({label: 'LS EVI Composite' , style: {stretch: 'horizontal'}});
var button20=ui.Button({label: 'LS NDVI Composite' , style: {stretch: 'horizontal'}});

button19.onClick(function() {
  Export.image.toDrive({
  image: LS_EVI,
  description: 'LS_EVI_Composite',
  scale: 30,
  region: studyArea.geometry().bounds(),
  maxPixels:1e11,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});
  
 
button20.onClick(function() {
  Export.image.toDrive({
  image: LS_NDVI,
  description: 'LS_NDVI_Composite',
  scale: 30,
  region: studyArea.geometry().bounds(),
  maxPixels:1e11,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});


panel.add(button19).add(button20);
 
//Displaying imagery
var displaying =  ui.Label('Displaying Individual Satellite-Sensor Maps', {
                fontWeight: 'bold',
                textAlign: 'center',
                fontSize: '20px',
            });
panel.add(displaying);

//Landsat label 
 var maps =  ui.Label('Display Landsat Maps:', {
                textAlign: 'center',
                fontSize: '18px',
            });
//Creating buttons for maps
var button1=ui.Button({label: 'Landsat EVI Before' , style: {stretch: 'horizontal'}});
var button2=ui.Button({label: 'Landsat EVI After' , style: {stretch: 'horizontal'}});
var button3=ui.Button({label: 'Landsat EVI Change' , style: {stretch: 'horizontal'}});
var button4=ui.Button({label: 'Landsat NDVI Before' , style: {stretch: 'horizontal'}});
var button5=ui.Button({label: 'Landsat NDVI After' , style: {stretch: 'horizontal'}});
var button6=ui.Button({label: 'Landsat NDVI Change' , style: {stretch: 'horizontal'}});
panel.add(maps);
panel.add(button1).add(button2).add(button3).add(button4).add(button5).add(button6);

//MODIS label 
 var maps =  ui.Label('Display MODIS Maps:', {
                textAlign: 'center',
                fontSize: '18px',
            });
     
//Creating buttons for maps            
var button13=ui.Button({label: 'MODIS EVI Before' , style: {stretch: 'horizontal'}});
var button14=ui.Button({label: 'MODIS EVI After' , style: {stretch: 'horizontal'}});
var button15=ui.Button({label: 'MODIS EVI Change' , style: {stretch: 'horizontal'}});
var button16=ui.Button({label: 'MODIS NDVI Before' , style: {stretch: 'horizontal'}});
var button17=ui.Button({label: 'MODIS NDVI After' , style: {stretch: 'horizontal'}});
var button18=ui.Button({label: 'MODIS NDVI Change' , style: {stretch: 'horizontal'}});
            
panel.add(maps);
panel.add(button13).add(button14).add(button15).add(button16).add(button17).add(button18);

//Sentinel label 
 var maps =  ui.Label('Display Sentinel Maps:', {
                textAlign: 'center',
                fontSize: '18px',
            });
     

var button7=ui.Button({label: 'Sentinel EVI Before' , style: {stretch: 'horizontal'}});
var button8=ui.Button({label: 'Sentinel EVI After' , style: {stretch: 'horizontal'}});
var button9=ui.Button({label: 'Sentinel EVI Change' , style: {stretch: 'horizontal'}});
var button10=ui.Button({label: 'Sentinel NDVI Before' , style: {stretch: 'horizontal'}});
var button11=ui.Button({label: 'Sentinel NDVI After' , style: {stretch: 'horizontal'}});
var button12=ui.Button({label: 'Sentinel NDVI Change' , style: {stretch: 'horizontal'}});

panel.add(maps);
panel.add(button7).add(button8).add(button9).add(button10).add(button11).add(button12);

//Function that tells button what to do once it is clicked
button1.onClick(function() {
  Map.addLayer(L8StartEVI,
{min: 0, max: 100, palette: EVIPalette},'Landsat EVI Before');});

button2.onClick(function() {
  Map.addLayer(L8EndEVI,
{min: 0, max: 100, palette: EVIPalette},'Landsat EVI After');});
  
button3.onClick(function(){Map.addLayer(L8EVIChangeCol, 
{min: 1, max: 7, palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']}, 'Landsat EVI Change');
});  
  
button4.onClick(function(){Map.addLayer(L8StartNDVI,
{min: 0, max: 100, palette: EVIPalette},'Landsat NDVI Before');
});
button5.onClick(function(){Map.addLayer(L8EndNDVI,
{min: 0, max: 100, palette: EVIPalette},'Landsat NDVI After');
});
button6.onClick(function(){Map.addLayer(L8NDVIChangeCol,
{min: 1, max: 7, palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']}, 'Landsat NDVI Change');
});


button7.onClick(function() {
  Map.addLayer(S2StartEVI,
{min: 0, max: 100, palette: EVIPalette},'Sentinel EVI Before');});

button8.onClick(function() {
  Map.addLayer(S2EndEVI,
{min: 0, max: 100, palette: EVIPalette},'Sentinel EVI After');});
  
button9.onClick(function(){Map.addLayer(S2EVIChangeCol, 
{min: 1, max: 7, palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']}, 'Sentinel EVI Change');
});  
  
button10.onClick(function(){Map.addLayer(S2StartNDVI,
{min: 0, max: 100, palette: EVIPalette},'Sentinel NDVI Before');
});
button11.onClick(function(){Map.addLayer(S2EndNDVI,
{min: 0, max: 100, palette: EVIPalette},'Sentinel NDVI After');
});
button12.onClick(function(){Map.addLayer(S2NDVIChangeCol,
{min: 1, max: 7, palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']}, 'Sentinel NDVI Change');
});

button13.onClick(function(){Map.addLayer(MStartEVI,
{min: 0, max: 100, palette: EVIPalette},'MODIS EVI Before');
});
button14.onClick(function(){Map.addLayer(MEndEVI,
{min: 0, max: 100, palette: EVIPalette},'MODIS EVI After');
});
button15.onClick(function(){Map.addLayer(MEVIChangeCol,
{min: 1, max: 7, palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']}, 'MODIS EVI Change');
});

button16.onClick(function(){Map.addLayer(MStartNDVI,
{min: 0, max: 100, palette: EVIPalette},'MODIS NDVI Before');
});
button17.onClick(function(){Map.addLayer(MEndNDVI,
{min: 0, max: 100, palette: EVIPalette},'MODIS NDVI After');
});
button18.onClick(function(){Map.addLayer(MNDVIChangeCol,
{min: 1, max: 7, palette: ['#ff0000','#ff7431', '#ffa500', '#ffc967','#ffff00','#4feb33','#026440']}, 'MODIS NDVI Change');
});



//Export label 
var exporting =  ui.Label('Exporting Imagery for Individual Satellite-Sensors as GeoTIFF Files', {
                fontWeight: 'bold',
                textAlign: 'center',
                fontSize: '20px',
            });
 panel.add(exporting);
 
var exporting =  ui.Label('Export Landsat:', {
                textAlign: 'center',
                fontSize: '18px',
            });

// //export Landsat buttons  
 var button1=ui.Button({label: 'Landsat EVI Composite' , style: {stretch: 'horizontal'}});
var button2=ui.Button({label: 'Landsat NDVI Composite' , style: {stretch: 'horizontal'}});



 panel.add(exporting);
 panel.add(button1).add(button2);

//export MODIS label
var exporting =  ui.Label('Export MODIS:', {
                textAlign: 'center',
                fontSize: '18px',
            });

var button13=ui.Button({label: 'MODIS EVI Composite' , style: {stretch: 'horizontal'}});
var button14=ui.Button({label: 'MODIS NDVI Composite' , style: {stretch: 'horizontal'}});

panel.add(exporting);
panel.add(button13).add(button14);

//export Sentinel label
var exporting =  ui.Label('Export Sentinel:', {
                textAlign: 'center',
                fontSize: '18px',
            });
//-------EVI Sentinel Export-----
 var button7=ui.Button({label: 'Sentinel Region 1 EVI Composite' , style: {stretch: 'horizontal'}});
 var button8=ui.Button({label: 'Sentinel Region 2 EVI Composite' , style: {stretch: 'horizontal'}});
 var button9=ui.Button({label: 'Sentinel Region 3 EVI Composite' , style: {stretch: 'horizontal'}});
 var button10=ui.Button({label: 'Sentinel Region 4 EVI Composite' , style: {stretch: 'horizontal'}});
 //-------NDVI Sentinel Export-----
 var button15=ui.Button({label: 'Sentinel Region 1 NDVI Composite' , style: {stretch: 'horizontal'}});
 var button16=ui.Button({label: 'Sentinel Region 2 NDVI Composite' , style: {stretch: 'horizontal'}});
 var button17=ui.Button({label: 'Sentinel Region 3 NDVI Composite' , style: {stretch: 'horizontal'}});
 var button18=ui.Button({label: 'Sentinel Region 4 NDVI Composite' , style: {stretch: 'horizontal'}});


 panel.add(exporting).add(button7).add(button8).add(button9).add(button10).add(button15).add(button16).add(button17).add(button18);


//Functions for buttons to export
button1.onClick(function() {
  Export.image.toDrive({
  image: LandsatEVIComposite,
  description: 'Landsat_EVI_Composite',
  scale: 30,
  region: studyArea.geometry().bounds(),
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
  })});
  
  button2.onClick(function() {
  Export.image.toDrive({
  image: LandsatNDVIComposite,
  description: 'Landsat_NDVI_Composite',
  scale: 30,
  region: studyArea.geometry().bounds(),
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
  })});

button7.onClick(function() {
  Export.image.toDrive({
  image: SentinelEVIComposite,
  description: 'Sentinel_Region1_EVI_Composite',
  scale: 10,
  region: Region1,
  maxPixels:1e12,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});
  
 
button8.onClick(function() {
  Export.image.toDrive({
  image: SentinelEVIComposite,
  description: 'Sentinel_Region2_EVI_Composite',
  scale: 10,
  region: Region2,
  maxPixels:1e12,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});
  
button9.onClick(function(){
  Export.image.toDrive({
  image: SentinelEVIComposite,
  description: 'Sentinel_Region3_EVI_Composite',
  scale: 10,
  maxPixels:1e12,
  region: Region3,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});

  
button10.onClick(function(){
  Export.image.toDrive({
  image: SentinelEVIComposite,
  description: 'Sentinel_Region4_EVI_Composite',
  scale: 10,
  region: Region4,
  fileFormat: 'GeoTIFF',
  maxPixels:1e12,
  folder: GEE_Folder
})});

button15.onClick(function() {
  Export.image.toDrive({
  image: SentinelNDVIComposite,
  description: 'Sentinel_Region1_NDVI_Composite',
  scale: 10,
  region: Region1,
  maxPixels:1e12,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});
  
 
button16.onClick(function() {
  Export.image.toDrive({
  image: SentinelNDVIComposite,
  description: 'Sentinel_Region2_NDVI_Composite',
  scale: 10,
  region: Region2,
  maxPixels:1e12,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});
  
button17.onClick(function(){
  Export.image.toDrive({
  image: SentinelNDVIComposite,
  description: 'Sentinel_Region3_NDVI_Composite',
  scale: 10,
  maxPixels:1e12,
  region: Region3,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});

  
button18.onClick(function(){
  Export.image.toDrive({
  image: SentinelNDVIComposite,
  description: 'Sentinel_Region4_NDVI_Composite',
  scale: 10,
  region: Region4,
  fileFormat: 'GeoTIFF',
  maxPixels:1e12,
  folder: GEE_Folder
})});



button13.onClick(function() {
  Export.image.toDrive({
  image: MODISEVIComposite,
  description: 'MODIS_EVI_Composite',
  scale: 250,
  region: studyArea.geometry().bounds(),
  maxPixels:1e12,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});

button14.onClick(function() {
  Export.image.toDrive({
  image: MODISNDVIComposite,
  description: 'MODIS_NDVI_Composite',
  scale: 250,
  region: studyArea.geometry().bounds(),
  maxPixels:1e12,
  fileFormat: 'GeoTIFF',
  folder: GEE_Folder
})});

// Displays legend explaining the colors of the VEGETATION CHANGE
 // set position of panel
var legend = ui.Panel({
  style: {
    position: 'bottom-left',
    padding: '8px 15px'
  }
});
 
// Create legend title
var legendTitle = ui.Label({
  value: 'Vegetation Change (%)',
  style: {
    fontWeight: 'bold',
    fontSize: '12px',
    margin: '0 0 4px 0',
    padding: '0'
    }
});
 
// Add the title to the panel
legend.add(legendTitle);
 
// Creates and styles 1 row of the legend.
var makeRow = function(color, name) {
 
      // Create the label that is actually the colored box.
      var colorBox = ui.Label({
        style: {
          backgroundColor: '#' + color,
          // Use padding to give the box height and width.
          padding: '8px',
          margin: '0 0 4px 0'
        }
      });
 
      // Create the label filled with the description text.
      var description = ui.Label({
        value: name,
        style: {margin: '0 0 4px 6px'}
      });
 
      // return the panel
      return ui.Panel({
        widgets: [colorBox, description],
        layout: ui.Panel.Layout.Flow('horizontal')
      });
};
 
//  Palette with the colors
var palette =['ff0000','ff7431', 'ffa500', 'ffc967','ffff00','4feb33','026440'];
 
// name of the legend
var names = ['80-100 loss, category 1','60-80 loss, cat. 2','40-60 loss, cat. 3','20-40 loss, cat. 4','0-20 loss, cat. 5','0-20 gain, cat. 6','>20 gain, cat. 7'];
 
// Add color and and names
for (var i = 0; i < 7; i++) {
  legend.add(makeRow(palette[i], names[i]));
  }  
 
// add legend to map 
Map.add(legend);




// Displays legend explaining the colors of the EVI
 // set position of panel
var legend = ui.Panel({
  style: {
    position: 'bottom-left',
    padding: '8px 15px'
  }
});
 
// Create legend title
var legendTitle = ui.Label({
  value: 'EVI/\nNDVI (%)',
  style: {
    whiteSpace: 'pre',
    fontWeight: 'bold',
    fontSize: '12px',
    margin: '0 0 2px 0',
    padding: '0'
    }
});
 
// Add the title to the panel
legend.add(legendTitle);
 
 
  
//  Palette with the colors
var palette ={min:0, max: 100, palette:EVIPalette};
 //Create legend image
var lon = ee.Image.pixelLonLat().select('latitude');
var gradient = lon.multiply((palette.max-palette.min)/100.0).add(palette.min);
var legendImage = gradient.visualize(palette);



// create text on top of legend
var panel = ui.Panel({
widgets: [
ui.Label(palette['max'])
],
});
 
legend.add(panel);
 
// create thumbnail from the image
var thumbnail = ui.Thumbnail({
image: legendImage,
params: {bbox:'0,0,10,100', dimensions:'10x75'},
style: {padding: '0px', position: 'bottom-center'}
});
 
// add the thumbnail to the legend
legend.add(thumbnail);
 
// create text on top of legend
var panel = ui.Panel({
widgets: [
ui.Label(palette['min'])
],
});
 
legend.add(panel);
 
Map.add(legend);
