//
//  ConstantLogLevel.h
//  library
//
//  Created by tuyenntm on 12/12/14.
//
//

//#ifndef library_ConstantLogLevel_h
//#define library_ConstantLogLevel_h
//
//
//#endif

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_VERBOSE; //LOG_LEVEL_INFO;
#endif
