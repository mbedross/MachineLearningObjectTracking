# Machine Learning Object Tracking (MLOT)

This repo contains all the functions needed for the MLOT algorithm. this algorithm is useful for identification of low SNR particles in 3D. This README file contains a general overview of the algorithm, as well as installation instructions.

## General Overview

### Fundamentals

MLOT uses a linear logistic regression in order to create a general linear model of data based on a small sample dataset. The user is presented with this small training dataset and asked to identify all in focus particles of interest. With pixel locations of known particles, this linear model is generated and stored.

The linear model is applied to unkown data in order to calculate the probability of particlse presence in the dataset. Using a threshold probablility value, unknown data is analyzed. Once all data has been analyzed and particle locations through time are known, these (x,y,z,t) points are then stitched together using a Hungarian simple tracking algorithm with gap detection.

You can read more about the fundamental mathematics behind this algorithm, as well as preliminary results and error quantification, on out AIMES Biophysics paper (link coming soon).

### Practica lImplementation

MLOT has three major steps:

1. Image pre-processing
2. Training
3. Tracking

#### Image pre-processing

Preprocessing is a very imporatant step as it de-noises the images and increases the SNR so that the algorithm can better identify particles. This routines (currently) consists of two denoising steps.

1. Mean Subtraction
2. Band-Pass Filtering

Mean subtraction calculates the mean image of a time sequence of images and subtracts that mean image from all images in that sequence. This eliminates any stationary artifacts from the image and increases contrast for objects that are moving (i.e the things that are going to be tracked).

Band-pass filtering eliminates low and high spatial frequency noise from images. For the DHM instrument used in the AIMES Biophysics Paper (link coming soon), the diffraction limited resolution of the instrument is about 800 nm. This represents a physical upper limit of spatial frequencies that can be observed, thus anything beyond this frequency is pure noise. A lower cut off frequency is used to attenuate any large scale artificats in the image (e.g lens curvature). To edit the low and high frequency cutoff values for this filter, edit the following variables in MAIN.m (located in the 'Ask user for inputs' section)

```matlab
innerRadius = 30;
outerRadius = 230;
centerX = n(1)/2;
centerY = n(2)/2;
```

#### Training



## Installation

This program is intended to be standalone. The only external dependencies are that the MATLAB Statistics and Machine Learning Toolbox must be installed. Once this toolbox is installed, clone the repository into the machine's MATLAB working directory.

## Running the Code

The majority of the user inputs for this code are provided graphically. Initially, to run the code, run 'MAIN'.

A dialog box will appear asking what you would like to do. From here, you can choose to:

* Pre-Process a dataset
* Train the tracking algorithm
* Track a dataset

