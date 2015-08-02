.. _Classification:

*****************************
Classification of DICOM Files
*****************************

This module is specific to DICOM file import via storescp. It is not available if DICOM files are send using mb.

The DICOM import is build to support high-volume DICOM ingestion with advanced classification and post-processing steps. 
As DICOM files arrive they are copied to the /data/scratch/archive/<study instance UID>/ directory. This directory
structure is the only place that incoming files are stored. 

Views are alternative directory structures that contain 
versions of the input data suitable for particular purposes such as Quality Control and processing. Such directory structures
(/data/scratch/views/raw) provide sub-directory structures on the series level and extract DICOM tags from the data. Views are
created in parallel with the data import. This allows for accelerated processing buckets with series level access.

The views/raw structure contains a folder named after the StudyInstanceUID which is unique for each study. Inside this folder are
folders for each series as SeriesInstanceUID. Together with the series directory a <SeriesInstanceUID>.json contains the following
DICOM tags derived from the imported series::

  {
    "ClassifyType": "T1", 
    "EchoTime": "2.984", 
    "NumFiles": "166", 
    "PatientID": "P0979_03_001", 
    "PatientName": "P0979_03_001", 
    "Private0019_10BB": "1.000000", 
    "Private0043_1039": [
      400, 
      0, 
      0, 
      0
    ], 
    "RepetitionTime": "7.38", 
    "SeriesDescription": "IRSPGR_PROMO", 
    "SeriesInstanceUID": "1.2.840.113619.2.283.6945.3146400.18515.1404745836.841", 
    "StudyDate": "20140711", 
    "StudyDescription": "PLING",   
    "StudyInstanceUID": "1.2.840.113619.6.283.4.679947340.3258.1405103835.996"  
  }

The content of this structure is likely to change in the future. Most of the entries reflect directly 
DICOM tags on the series level. The "NumFiles" tag is added to reflect the current number of files in the
series directory (stored as SOPInstanceUID).

ClassifyType
=============

The tag called "ClassifyType" is derived from rules that specify how to detect a particular class of scan
from the availble DICOM tags in each file. The rule file classifyRules.json has the following structure::

  [
    { "type" : "T1", 
      "description" : "A T1 weighted image is classified if its from GE and is EFGRE3D",
      "rules" : [
        { 
          "tag": [ "0x08", "0x70"],
	  	    "value": "^GE MEDICAL SYSTEMS" 
        },{ 
          "tag": [ "0x19", "0x109e"],
	  	    "value": "EFGRE3D"
        },{ 
          "tag": [ "NumFiles" ],
          "operator": ">",
	  	    "value": "100"
        }
      ]  
    },
    { "type" : "T2",
      "description" : "A T2 weighted image",
      "rules" : [
       { 
          "tag": [ "0x08", "0x70"],
  		    "value": "^GE MEDICAL SYSTEMS" 
        },{
          "tag": [ "0x19", "0x109c" ],
          "operator": "regexp",
          "value": "Cube"
        }
      ]
    },
    { "type" : "fMRI",
      "description" : "fMRI",
      "rules" : [
        { 
          "tag": [ "0x08", "0x70"]  ,
		      "value": "^GE MEDICAL SYSTEMS" 
        },{
          "tag": [ "0x43", "0x1039", "0" ],
          "operator": "==",
          "value": "4000"
        }
      ]
    }  
  ]
  
  
Each series type has a name "type" and a short description which is usually ignored and only used as a means to document.
The rules for each type are a collection of statements that all have to be try for a scan to be classified as the "type".
The order of the rules is importants as a successful classification will stop all further attempts of validating that
particular series. 

Each rule contains at least the tags "tag" and "value". If only these two tags are supplied the operation that compares
each files tag value to the one supplied in "value" is assumed to be a regular expression match (python search). The "tag"
value can have the following form::

   * "tag" : [ <key from series level json> ]
     For example the tag can describe the number of DICOM slices in this series as "tag": [ "NumFiles" ].
   * "tag" : [ <dicom group hex code>, <dicom tag hex code> ]
     This way the Manufacturer can be addressed as "tag" : [ "0x08", "0x70" ]
   * "tag" : [ <dicom group hex code>, <dicom tag hex code>, <vector index> ]
     If a third argument is supplied the returned tag is assumed to be a vector and the specific index from that array is used. The b-value for GE diffusion weighted images can be addressed by this as "tag" : [ "0x43", "0x1039", 1 ].
 
 Instead of just using regular expressions tag values can also be interpreted as floating point values. This is forced
 by the optional tag "operator". The following tests are available::
 
    * "operator" : "regexp"
    Default regular expression match (does not have to be supplied).
    * "operator" : "=="
    Tests for equal value of the tag of the current DICOM file in the series and the value in the rule.
    * "operator" : "!="
    True of the values are not the same (convertes values to floating point first).
    * "operator" : "<"
    True if value in the DICOM file is smaller.
    * "operator" : ">"
    True if value in the DICOM file is greater.
    
    
Note: These tests are executed for each file that arrives for a series. If the tags addressed are not series level tags (the same for all files in the series)
the outcome of the classification will depend on the order in which files are received.