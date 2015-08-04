.. _Classification:

*****************************
Classification of DICOM Files
*****************************

  This module is specific to DICOM file import via storescp. It is not available if DICOM files are send using mb.

The DICOM import is build to support high-volume DICOM ingestion with advanced DICOM series classification. 
As DICOM files arrive they are copied to a /data/scratch/archive/<Study Instance UID>/ directory for permanent storage.

Views/raw
=========

Views are alternative directory structures that contain 
versions of the input data suitable for particular purposes such as quality control and processing. Such directory structures
(/data/scratch/views/raw) provide sub-directory structures on the series level and extract DICOM tags from the data. Views are
created in parallel with the data import using a daemon process  (processSingleFile.py). This allows for accelerated processing
buckets with access to series level information before a secondary DICOM parse operation.

The views/raw structure contains a folder named after the StudyInstanceUID which is unique for each study. Inside this folder are
folders for each series named using the SeriesInstanceUID. Together with the series directory a <SeriesInstanceUID>.json contains
the following DICOM tags derived from the imported series (series level json)::

  {
    "ClassifyType": [
	"GE",
        "sag",
	"T1"
    ],
    "EchoTime": "2.984",
    "InstanceNumber": "3",
    "Manufacturer": "GE MEDICAL SYSTEMS",
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
    "SeriesNumber": "3",
    "SliceSpacing": "1.2",
    "SliceThickness": "1.2",
    "StudyDate": "20140711",
    "StudyDescription": "PLING",
    "StudyInstanceUID": "1.2.840.113619.6.283.4.679947340.3258.1405103835.996"
  }

The content of this structure is likely to change in the future. Most of the entries reflect
DICOM tags on the series level. The "NumFiles" tag is added to reflect the current number of files in the
series directory. The series level directories contain symbolic links to the data stored in the archive folder
to limit the number of copy operations and file duplications.

ClassifyType
=============

The tag called "ClassifyType" is derived from rules that specify how a particular class of scans
can be detected from the availble DICOM tags. The test is executed for each incoming DICOM file in the series.

The rule file classifyRules.json stores the control structure for classification and has the following structure::

  [
    { "type" : "GE",
      "id" : "GEBYMANUFACTURER",
      "description" : "Scanner is GE",
      "rules" : [
        {
	   "tag" : [ "0x08", "0x70"],
	   "value": "^GE MEDICAL SYSTEMS" 
        } 
      ]
    },{ "type" : "axial",
      "description": "An axial scan",
      "rules" : [
        {
	   "tag" : [ "0x20","0x37" ],
	   "value" : [1,0,0,0,1,0],
	   "operator": "approx",
	   "approxLevel": "0.0004"
	}
      ]
    },{ "type" : "axial",
      "description": "An axial scan",
      "rules" : [
         { "tag" : [ "0x20","0x37" ],
           "value" : [1,0,0,0,1,0], 
           "operator": "approx",
           "approxLevel": "0.0004"
         }
      ]
    },{ "type" : "coronal",
      "description": "A coronal scan",
      "rules" : [
         { "tag" : [ "0x20","0x37" ],
           "value" : [1,0,0,0,0,-1],
           "operator": "approx"
         }
      ]
    },{ "type" : "T1",
      "description" : "A T1 weighted image is classified if its from GE and is EFGRE3D",
      "rules" : [
        {
          "rule" : "GEBYMANUFACTURER"
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
          "rule" : "GEBYMANUFACTURER"
        },{
          "tag": [ "0x19", "0x109c" ],
          "operator": "regexp",
          "value": "Cube"
        }
      ]
    },
    { "type" : "fMRI",
      "description" : "fMRI detected by used b-value",
      "rules" : [
        { 
          "rule": "GEBYMANUFACTURER"
        },{
          "tag": [ "0x43", "0x1039", "0" ],
          "operator": "==",
          "value": "4000"
        }
      ]
    }  
  ]
  
  
Each series type has a name "type" and a short description which is usually ignored and only used as a means to document what the classification tries to implement.
The rules for each type are a collection of statements that all have to be true for a scan to be classified as "type".
The order of the rules is not important. Every successful classification will add its type to the returned array.

Each rule can contain a reference to another rule (key "rule" with value "id"). This allows for an hierarchical classification of rules. In the example above the rule for
detecting if a scan was done on a scanner from GE is referenced in types "T2", "T1", and "fMRI". For debugging a call to "processSingleFile.py test" will list the resolved rules on the command line.

Non-referencing rules contain at least the tags "tag" and "value". If only these two tags are supplied the operation that compares
each incoming DICOM files tag value to the one supplied in the "value" field of the rule is assumed to be a regular expression
match (python search). The "tag" value can have the following structure:

"tag" : [ <key from series level json> ]
  The tag can describe the number of DICOM slices in this series as "tag": [ "NumFiles" ].
    
"tag" : [ <dicom group hex code>, <dicom tag hex code> ]
  The Manufacturer tag can be addressed as "tag" : [ "0x08", "0x70" ]
    
"tag" : [ <dicom group hex code>, <dicom tag hex code>, <vector index> ]
  If a third argument is supplied the returned tag is assumed to have a vector value and the specific index from that array is used. 
  The b-value for GE diffusion weighted images can be addressed this way as "tag" : [ "0x43", "0x1039", "0" ].
 
Instead of just using regular expressions tag values can also be interpreted as floating point values. This is forced
by the optional tag "operator". The following operators are available:

"operator" : "=="
  Tests for equal value of the tag of the current DICOM file in the series and the value in the rule.
    
"operator" : "!="
  True of the values are not the same (convertes values to floating point first).
    
"operator" : "<"
  True if value in the DICOM file is smaller.
    
"operator" : ">"
  True if value in the DICOM file is greater.

"operator" : "exist"
  True if the tag exists (can be empty).

"operator" : "notexist"
  True if the tag does not exist.

"operator" : "approx"
  True if the numerical values of the tag are sufficiently close to the target values. How close can be controlled by an "approxLevel" variable in the rule. The above example uses this to test if the Image Orientation Patient tag that contains the direction cosines for the positive row axis are close enough to be called either axial, sagittal or coronal. A series might contain more than one orientation (like a localizer scan). In this case all three rules might apply as images for that series are classified.

"operator" : "regexp"
  Default (non-numeric) regular expression match.
    
Note: These tests are executed for each file that arrives for a series. If the tags addressed are not series level tags (the same for all files in the series) the outcome of the classification will depend on the order in which files are received.
