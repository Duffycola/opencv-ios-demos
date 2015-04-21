//
//  CVFindHomography.h
//  FindHomography
//
//  Created by Eduard Feicho on 26.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Accelerate/Accelerate.h>

#include "opencv2/core/core.hpp"



#ifdef __cplusplus

#include "opencv2/features2d/features2d.hpp"
#include "opencv2/nonfree/features2d.hpp"
#include "opencv2/calib3d/calib3d.hpp"
using namespace cv;

#include <list>
using namespace std;

#endif




enum CVFeatureDetectorType {
	CV_FEATUREDETECTOR_FAST,
	CV_FEATUREDETECTOR_GOODTOTRACK,
	CV_FEATUREDETECTOR_MSER,
	CV_FEATUREDETECTOR_ORB,
	CV_FEATUREDETECTOR_STAR,
	CV_FEATUREDETECTOR_SIFT,
	CV_FEATUREDETECTOR_SURF,
};



enum CVFeatureDescriptorType {
	CV_FEATUREDESCRIPTOR_SIFT,
	CV_FEATUREDESCRIPTOR_SURF,
	CV_FEATUREDESCRIPTOR_ORB
};



@interface CvHomographyController : NSObject
{
	double max_dist;
	double min_dist;
	
	int minHessian;
	
	int FASTthreshold;
	int ORBnfeatures;
	int GFTTmaxCorners;
	int STARresponseThreshold;
	int SIFTnfeatures;
	double SURFhessianThreshold;
	double MSERarea_threshold;
	
	bool adaptive;
	bool limit_features;
	bool object_loaded;
	
	int numFeaturesObjective;
	int numFeaturesVariance;
	
	enum CVFeatureDetectorType currentDetectorType;
	enum CVFeatureDescriptorType currentDescriptorType;
	
	float thresh_min;
	float thresh_max;
	float thresh_delta;
	
	bool multiscale;
	
#ifdef __cplusplus
	
	DescriptorExtractor* descriptor;
	FeatureDetector* detector;
	DescriptorMatcher* matcher;
	
	Mat descriptors_object;
	Mat descriptors_scene;
	
	Mat img_object;
	Mat img_scene;
	Mat* img_matches;
	
	vector<KeyPoint> keypoints_object;
	vector<KeyPoint> keypoints_scene;
	vector<DMatch> matches;
	
#else
	
	void* extractor;
	void* detector;
	void* matcher;
	
#endif
	
};

@property (nonatomic,readonly) float thresh_min;
@property (nonatomic,readonly) float thresh_max;
@property (nonatomic,assign) bool adaptive;
@property (nonatomic,assign) bool object_loaded;

- (void)setDetector:(enum CVFeatureDetectorType)type;
- (void)setDescriptor:(enum CVFeatureDescriptorType)type;
- (float)getDetectorThreshold;

- (void)adaptThreshold:(int)numFeatures;


- (void)setDetectorThreshold:(int)threshold;
- (NSString*)getDetectorThresholdName;


- (void)useORB;
- (void)useSIFT;
- (void)useSURF;

- (void)reset;
- (void)setObjectImage:(UIImage*)image;
#ifdef __cplusplus
- (void)setSceneImage:(Mat*)image;
#endif
- (void)detect;
- (void)descript;
- (void)match;
- (void)drawMatches;
- (void)drawObject;
- (void)drawScene;

- (void)drawKeypoints;


- (UIImage*)getObjectImage;

#ifdef __cplusplus
- (Mat*)getSceneImage;
- (Mat*)getMatchImage;
#endif

+ (id)sharedInstance;

@end
