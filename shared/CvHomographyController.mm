//
//  CVFindHomography.m
//  FindHomography
//
//  Created by Eduard Feicho on 26.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "CvHomographyController.h"
#import "UIImageCVMatConverter.h"



@interface CvHomographyController(PrivateMethods)
- (id)init;
@end



@implementation CvHomographyController



@synthesize thresh_min;
@synthesize thresh_max;
@synthesize adaptive;
@synthesize object_loaded;


#pragma mark - Singleton

+ (CvHomographyController*)sharedInstance;
{
	static CvHomographyController *singleton;
	
	@synchronized(self)
	{
		if (!singleton) {
			singleton = [[CvHomographyController alloc] init];
		}
		return singleton;
	}
}



- (id)init;
{
	self = [super init];
	if (self) {
		
		detector = NULL;
		descriptor = NULL;
		matcher = NULL;
		
		max_dist = 0;
		min_dist = 100;
		
		FASTthreshold = 70;
		ORBnfeatures = 500;
		GFTTmaxCorners = 1000;
		STARresponseThreshold = 30;
		SIFTnfeatures = 0;
		SURFhessianThreshold = 400;
		MSERarea_threshold = 1.01;
		
		adaptive = true;
		
		limit_features = NO;
		numFeaturesObjective = 50;
		numFeaturesVariance = 15;
		
		/*
		multiscale = true;
		[self setDetector:CV_FEATUREDETECTOR_FAST];
		[self setDescriptor:CV_FEATUREDESCRIPTOR_SURF];
		//		matcher = new BFMatcher( NORM_L2 );
		matcher = new FlannBasedMatcher();
		*/
		
		[self useSURF];
	}
	return self;
}



- (void)dealloc;
{
	delete detector;
	delete descriptor;
	delete matcher;
}



- (void)setDetector:(enum CVFeatureDetectorType)type;
{
	FeatureDetector* newDetector = NULL;
	
	switch (type) {
			
		case CV_FEATUREDETECTOR_FAST:
		{
			int threshold = FASTthreshold;
			bool nonMaxSuppression=true;
			newDetector = new FastFeatureDetector(threshold, nonMaxSuppression);
			thresh_min = 0;
			thresh_max = 255;
			thresh_delta = 1;
			break;
		}
			
		case CV_FEATUREDETECTOR_ORB:
		{
			int nfeatures = ORBnfeatures;
			float scaleFactor = 1.2f;
			int nlevels = multiscale ? 8 : 1;
			int edgeThreshold = 31;
			int firstLevel = 0;
			int WTA_K = 2;
			int scoreType = ORB::HARRIS_SCORE;
			int patchSize = 31;
			
			newDetector = new OrbFeatureDetector(nfeatures,
												 scaleFactor,
												 nlevels,
												 edgeThreshold,
												 firstLevel,
												 WTA_K,
												 scoreType,
												 patchSize
												 );
			thresh_min = numFeaturesObjective-numFeaturesVariance;
			thresh_max = numFeaturesObjective+numFeaturesVariance;
			thresh_min = (thresh_min < 0) ? 0 : thresh_min;
			thresh_delta = -1;
			break;
		}
		
		case CV_FEATUREDETECTOR_GOODTOTRACK:
		{
			int maxCorners = GFTTmaxCorners;
			double qualityLevel = 0.01;
			double minDistance = 1;
			int blockSize = 3;
			bool useHarrisDetector = false;
			double k = 0.04;
			newDetector = new GFTTDetector(maxCorners,
										   qualityLevel,
										   minDistance,
										   blockSize,
										   useHarrisDetector,
										   k
										   );
			
			thresh_min = numFeaturesObjective-numFeaturesVariance;
			thresh_max = numFeaturesObjective+numFeaturesVariance;
			thresh_min = (thresh_min < 0) ? 0 : thresh_min;
			thresh_delta = -1;
			break;
		}
			
		case CV_FEATUREDETECTOR_MSER:
		{
			int delta=5;
			int min_area=60;
			int max_area=14400;
			double max_variation=0.25;
			double min_diversity=.2;
			int max_evolution=200;
			double area_threshold=MSERarea_threshold;
			double min_margin=0.003;
			int edge_blur_size=5;
			
			newDetector = new MserFeatureDetector(delta,
												  min_area,
												  max_area,
												  max_variation,
												  min_diversity,
												  max_evolution,
												  area_threshold,
												  min_margin,
												  edge_blur_size
												  );
			thresh_min = 0.01;
			thresh_max = 3.00;
			thresh_delta = 0.01;
			break;
		}
			
		case CV_FEATUREDETECTOR_STAR:
		{
			int maxSize=45;
			int responseThreshold=STARresponseThreshold;
			int lineThresholdProjected=10;
			int lineThresholdBinarized=8;
			int suppressNonmaxSize=5;
			
			newDetector = new StarFeatureDetector(maxSize,
												  responseThreshold,
												  lineThresholdProjected,
												  lineThresholdBinarized,
												  suppressNonmaxSize
												  );
			thresh_min = 0;
			thresh_max = 255;
			thresh_delta = 1;
			break;
		}
			
		case CV_FEATUREDETECTOR_SIFT:
		{
			int nfeatures=SIFTnfeatures;
			int nOctaveLayers = multiscale ? 3 : 1;
			double contrastThreshold=0.04;
			double edgeThreshold=10;
			double sigma=1.6;
			newDetector = new SiftFeatureDetector(nfeatures,
												  nOctaveLayers,
												  contrastThreshold,
												  edgeThreshold,
												  sigma
												  );
			
			thresh_min = numFeaturesObjective-numFeaturesVariance;
			thresh_max = numFeaturesObjective+numFeaturesVariance;
			thresh_min = (thresh_min < 0) ? 0 : thresh_min;
			thresh_delta = -1;
			
			break;
		}
			
		case CV_FEATUREDETECTOR_SURF:
		{
			double hessianThreshold=SURFhessianThreshold;
			int nOctaves = multiscale ? 4 : 1;
			int nOctaveLayers = multiscale ? 2 : 1;
			bool extended=true;
			bool upright=false;
			newDetector = new SurfFeatureDetector(hessianThreshold,
												  nOctaves,
												  nOctaveLayers,
												  extended,
												  upright
												  );
			thresh_min = 0;
			thresh_max = 30000;
			thresh_delta = 10;
			
			break;
		}
			
		default:
			cout << " Error: Unsupported detector chosen" << endl;
			break;
	}
	
	if (newDetector != NULL) {
		if (detector != NULL) {
			delete detector;
		}
		detector = newDetector;
		currentDetectorType = type;
	}
}



- (void)setDescriptor:(enum CVFeatureDescriptorType)type;
{
	DescriptorExtractor* newDescriptor = NULL;
	
	switch (type) {
		case CV_FEATUREDESCRIPTOR_SIFT:
		{
			int nfeatures=SIFTnfeatures;
			int nOctaveLayers=3;
			double contrastThreshold=0.04;
			double edgeThreshold=10;
			double sigma=1.6;
			newDescriptor = new SiftDescriptorExtractor(nfeatures,
														nOctaveLayers,
														contrastThreshold,
														edgeThreshold,
														sigma
														);
			break;
		}
			
		case CV_FEATUREDESCRIPTOR_SURF:
		{
			double hessianThreshold=SURFhessianThreshold;
			int nOctaves=4;
			int nOctaveLayers=2;
			bool extended=true;
			bool upright=false;
			newDescriptor = new SurfDescriptorExtractor(hessianThreshold,
														nOctaves,
														nOctaveLayers,
														extended,
														upright
														);
			break;
		}
			
		case CV_FEATUREDESCRIPTOR_ORB:
		{
			int nfeatures = ORBnfeatures;
			float scaleFactor = 1.2f;
			int nlevels = 8;
			int edgeThreshold = 31;
			int firstLevel = 0;
			int WTA_K = 2;
			int scoreType = ORB::HARRIS_SCORE;
			int patchSize = 31;
			
			newDescriptor = new OrbDescriptorExtractor(nfeatures,
													   scaleFactor,
													   nlevels,
													   edgeThreshold,
													   firstLevel,
													   WTA_K,
													   scoreType,
													   patchSize
													   );
			break;
		}
			
			
		default:
			cout << " Error: Unsupported descriptor chosen" << endl;
			break;
	}
	
	if (newDescriptor != NULL) {
		if (descriptor != NULL) {
			delete descriptor;
		}
		descriptor = newDescriptor;
		currentDescriptorType = type;
	}
}


- (void)useORB;
{
	multiscale = true;
	[self setDetector:CV_FEATUREDETECTOR_ORB];
	[self setDescriptor:CV_FEATUREDESCRIPTOR_ORB];
	matcher = new FlannBasedMatcher();
}


- (void)useSIFT;
{
	multiscale = true;
	[self setDetector:CV_FEATUREDETECTOR_SIFT];
	[self setDescriptor:CV_FEATUREDESCRIPTOR_SIFT];
	matcher = new FlannBasedMatcher();
}



- (void)useSURF;
{
	multiscale = true;
	[self setDetector:CV_FEATUREDETECTOR_SURF];
	[self setDescriptor:CV_FEATUREDESCRIPTOR_SURF];
	matcher = new FlannBasedMatcher();
}



- (void)reset;
{
	Mat emptyMat;
	descriptors_object = emptyMat;
	descriptors_scene = emptyMat;
	
	img_object = emptyMat;
	img_scene = emptyMat;
	
	keypoints_object.clear();
	keypoints_scene.clear();
	matches.clear();
}



- (void)setObjectImage:(UIImage*)image;
{
	//	img_object = Mat(image.height, image.width, CV_8UC1, image.data, image.rowBytes);
	img_object = [UIImageCVMatConverter cvMatGrayFromUIImage:image];
	NSLog(@"set object image [w,h] = [%d,%d]", img_object.cols, img_object.rows);
	
	keypoints_object.clear();
	
	// enable multiscale only for reference image
	detector->detect( img_object, keypoints_object );
	
	if (limit_features && keypoints_object.size() > numFeaturesObjective + numFeaturesVariance) {
		keypoints_object.resize(numFeaturesObjective + numFeaturesVariance);
	}
	
	NSLog(@"%ld keypoints detected for reference object", keypoints_object.size());
	
	descriptor->compute( img_object, keypoints_object, descriptors_object );
	NSLog(@"%d descriptors generated for reference object", descriptors_object.rows);
	
	
	// disable multiscale for faster online processing
	// (multiscale features in the reference image are still matched)
	multiscale = false;
	[self setDetector:currentDetectorType];
	[self setDescriptor:currentDescriptorType];
	
	self.object_loaded = YES;
}



- (void)setSceneImage:(Mat*)image;
{
	//	img_scene = Mat(image.height, image.width, CV_8UC1, image.data, image.rowBytes);
	img_scene = *image;
	NSLog(@"set scene image [w,h] = [%d,%d]", img_scene.cols, img_scene.rows);
}



- (void)adaptThreshold:(int)numFeatures;
{
	const int& n = numFeatures;
	
	if (!adaptive)
		return;
	
	if (abs(numFeaturesObjective - n) < numFeaturesVariance)
		return;
	
	float threshold = [self getDetectorThreshold];
	
	if (numFeaturesObjective - n < 0) {
		// too many features
		threshold += thresh_delta;
	} else {
		// too few features
		threshold -= thresh_delta;
	}
	
	threshold = (threshold < thresh_min) ? thresh_min : threshold;
	threshold = (threshold > thresh_max) ? thresh_max : threshold;
	
	[self setDetectorThreshold:threshold];
}



- (float)getDetectorThreshold;
{
	switch (currentDetectorType) {
		case CV_FEATUREDETECTOR_FAST:
			return FASTthreshold;
			break;
			
		case CV_FEATUREDETECTOR_ORB:
			return ORBnfeatures;
			break;
			
		case CV_FEATUREDETECTOR_GOODTOTRACK:
			return GFTTmaxCorners;
			break;
			
		case CV_FEATUREDETECTOR_MSER:
			return MSERarea_threshold;
			break;
			
		case CV_FEATUREDETECTOR_STAR:
			return STARresponseThreshold;
			break;
			
		case CV_FEATUREDETECTOR_SIFT:
			return SIFTnfeatures;
			break;
			
		case CV_FEATUREDETECTOR_SURF:
			return SURFhessianThreshold;
			break;
			
		default:
			return 0;
			break;
	}
}



- (NSString*)getDetectorThresholdName;
{
	switch (currentDetectorType) {
		case CV_FEATUREDETECTOR_FAST:
			return @"FAST Threshold";
			break;
			
		case CV_FEATUREDETECTOR_ORB:
			return @"ORB # Features";
			break;
			
		case CV_FEATUREDETECTOR_GOODTOTRACK:
			return @"GFTT Max Corners";
			break;
			
		case CV_FEATUREDETECTOR_MSER:
			return @"MSER Area Threshold";
			break;
			
		case CV_FEATUREDETECTOR_STAR:
			return @"STAR Response Threshold";
			break;
			
		case CV_FEATUREDETECTOR_SIFT:
			return @"SIFT # Features";
			break;
			
		case CV_FEATUREDETECTOR_SURF:
			return @"SURF Hessian Threshold";
			break;
			
		default:
			return @"undefined";
			break;
	}
}



- (void)setDetectorThreshold:(int)threshold;
{
	bool update = true;
	
	switch (currentDetectorType) {
		case CV_FEATUREDETECTOR_FAST:
			FASTthreshold = threshold;
			break;
			
		case CV_FEATUREDETECTOR_ORB:
			ORBnfeatures = threshold;
			break;
			
		case CV_FEATUREDETECTOR_GOODTOTRACK:
			GFTTmaxCorners = threshold;
			break;
			
		case CV_FEATUREDETECTOR_MSER:
			MSERarea_threshold = threshold;
			break;
			
		case CV_FEATUREDETECTOR_STAR:
			STARresponseThreshold = threshold;
			break;
			
		case CV_FEATUREDETECTOR_SIFT:
			SIFTnfeatures = threshold;
			break;
			
		case CV_FEATUREDETECTOR_SURF:
			SURFhessianThreshold = threshold;
			break;
			
		default:
			update = false;
			break;
	}
	
	if (update) {
		[self setDetector:currentDetectorType];
	}
}



- (void)detect;
{
	keypoints_scene.clear();
	detector->detect( img_scene, keypoints_scene );
	NSLog(@"%ld keypoints detected for scene image", keypoints_scene.size());
	
	if (limit_features && keypoints_scene.size() > numFeaturesObjective + numFeaturesVariance) {
		keypoints_scene.resize(numFeaturesObjective + numFeaturesVariance);
	}
	
	[self adaptThreshold:keypoints_scene.size()];
}



- (void)descript;
{
	descriptor->compute( img_scene, keypoints_scene, descriptors_scene );
	NSLog(@"%d descriptors generated for scene image", descriptors_scene.rows );
}



- (void)match;
{
	matches.clear();
	
	if (descriptors_object.rows == 0 || descriptors_scene.rows == 0) {
		return;
	}
	
	matcher->match( descriptors_object, descriptors_scene, matches );
	NSLog(@"%ld keypoint matches", matches.size());
	
	//-- Quick calculation of max and min distances between keypoints
	max_dist = 0;
	min_dist = 100;
	for( int i = 0; i < descriptors_object.rows; i++ ) {
		double dist = matches[i].distance;
		if( dist < min_dist ) min_dist = dist;
		if( dist > max_dist ) max_dist = dist;
	}
	
	printf("-- Max dist : %f \n", max_dist );
	printf("-- Min dist : %f \n", min_dist );
}



- (void)drawMatches;
{
	//-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
	vector< DMatch > good_matches;
		
	if (matches.size() == descriptors_object.rows) {
		for( int i = 0; i < descriptors_object.rows; i++ ) {
			if( matches[i].distance < 3*min_dist ) {
				good_matches.push_back( matches[i]);
			}
		}
	}
	NSLog(@"%ld good matches", good_matches.size());
	
	if (img_matches == NULL) {
		delete img_matches;
	}
	img_matches = new Mat();
	
	
	drawMatches( img_object, keypoints_object, img_scene, keypoints_scene,
				good_matches, *img_matches, Scalar::all(-1), Scalar::all(-1),
				vector<char>(), DrawMatchesFlags::DEFAULT );
	NSLog(@"draw matches image [w,h] = [%d,%d]", img_matches->cols, img_matches->rows);
	
	//-- Localize the object
	vector<Point2f> obj;
	vector<Point2f> scene;
	
	for( int i = 0; i < good_matches.size(); i++ ) {
		//-- Get the keypoints from the good matches
		obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
		scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
	}
	
	try {
		Mat H = findHomography( obj, scene, CV_RANSAC );
		
		//-- Get the corners from the image_1 ( the object to be "detected" )
		vector<Point2f> obj_corners( 4 );
		obj_corners[0] = cvPoint( 0, 0 );
		obj_corners[1] = cvPoint( img_object.cols, 0 );
		obj_corners[2] = cvPoint( img_object.cols, img_object.rows );
		obj_corners[3] = cvPoint( 0, img_object.rows );
		vector<Point2f> scene_corners( 4 );
		
		perspectiveTransform( cv::Mat(obj_corners), cv::Mat(scene_corners), H);
		
		//-- Draw lines between the corners (the mapped object in the scene - image_2 )
		line( *img_matches, scene_corners[0] + Point2f( img_object.cols, 0), scene_corners[1] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
		line( *img_matches, scene_corners[1] + Point2f( img_object.cols, 0), scene_corners[2] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
		line( *img_matches, scene_corners[2] + Point2f( img_object.cols, 0), scene_corners[3] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
		line( *img_matches, scene_corners[3] + Point2f( img_object.cols, 0), scene_corners[0] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
	} catch (exception& e) {
		cout << "Exception in findHomography() and/or perspectiveTransform()" << endl;
		cout << e.what();
	}
	
}


- (void)drawObject;
{
	//-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
	vector< DMatch > good_matches;
	
	if (matches.size() == descriptors_object.rows) {
		for( int i = 0; i < descriptors_object.rows; i++ ) {
			if( matches[i].distance < 3*min_dist ) {
				good_matches.push_back( matches[i]);
			}
		}
	}
	NSLog(@"%ld good matches", good_matches.size());
	
	if (img_matches == NULL) {
		delete img_matches;
	}
	img_matches = new Mat();
	drawKeypoints( img_object, keypoints_object, *img_matches, Scalar::all(-1), DrawMatchesFlags::DEFAULT );
	
	//-- Localize the object
	vector<Point2f> obj;
	
	for( int i = 0; i < good_matches.size(); i++ ) {
		//-- Get the keypoints from the good matches
		obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
	}
}


- (void)drawScene;
{
	//-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
	vector< DMatch > good_matches;
	
	if (matches.size() == descriptors_object.rows) {
		for( int i = 0; i < descriptors_object.rows; i++ ) {
			if( matches[i].distance < 3*min_dist ) {
				good_matches.push_back( matches[i]);
			}
		}
	}
	NSLog(@"%ld good matches", good_matches.size());
	
	drawKeypoints( img_scene, keypoints_scene, img_scene, Scalar::all(-1), DrawMatchesFlags::DRAW_OVER_OUTIMG );
	
	//-- Localize the object
	vector<Point2f> obj;
	vector<Point2f> scene;
	
	for( int i = 0; i < good_matches.size(); i++ ) {
		//-- Get the keypoints from the good matches
		obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
		scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
	}
	
	try {
		Mat H = findHomography( obj, scene, CV_RANSAC );
		
		//-- Get the corners from the image_1 ( the object to be "detected" )
		vector<Point2f> obj_corners( 4 );
		obj_corners[0] = cvPoint( 0, 0 );
		obj_corners[1] = cvPoint( img_object.cols, 0 );
		obj_corners[2] = cvPoint( img_object.cols, img_object.rows );
		obj_corners[3] = cvPoint( 0, img_object.rows );
		vector<Point2f> scene_corners( 4 );
		
		perspectiveTransform( cv::Mat(obj_corners), cv::Mat(scene_corners), H);
		
		//-- Draw lines between the corners (the mapped object in the scene - image_2 )
		line( *img_matches, scene_corners[0], scene_corners[1], Scalar( 0, 255, 0), 4 );
		line( *img_matches, scene_corners[1], scene_corners[2], Scalar( 0, 255, 0), 4 );
		line( *img_matches, scene_corners[2], scene_corners[3], Scalar( 0, 255, 0), 4 );
		line( *img_matches, scene_corners[3], scene_corners[0], Scalar( 0, 255, 0), 4 );
	} catch (exception& e) {
		cout << "Exception in findHomography() and/or perspectiveTransform()" << endl;
		cout << e.what();
	}
	
}


- (UIImage*)getObjectImage;
{
	return [UIImageCVMatConverter UIImageFromCVMat:img_object];
}



- (Mat*)getSceneImage;
{
	return &img_scene;
}



- (Mat*)getMatchImage;
{
	return img_matches;
}



- (void)drawKeypoints;
{
	for (vector<KeyPoint>::iterator it = keypoints_object.begin(); it != keypoints_object.end(); it++) {
		KeyPoint k = *it;
		cout << "object k@(" << k.pt.x << "," << k.pt.y << "), || " << k.size << endl;
		circle(img_object, k.pt, k.size, Scalar(255,255,0));
	}
	
	for (int i=0; i < keypoints_scene.size(); i++) {
		KeyPoint k = keypoints_scene[i];
		cout << "scene k@(" << k.pt.x << "," << k.pt.y << "), || " << k.size << endl;
		circle(img_scene, k.pt, k.size, Scalar(255,255,0));
	}
}



@end
