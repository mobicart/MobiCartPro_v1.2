//
//  ConstantLogLevel.h
//  MobicartApp
//
//  Created by tuyenntm on 12/5/14.
//  Copyright (c) 2014 Net Solutions. All rights reserved.
//

//#ifdef DEBUG
//#define k_Log_Level     LOG_LEVEL_VERBOSE
//#else
//#define k_Log_Level     LOG_LEVEL_VERBOSE//LOG_LEVEL_INFO
//#endif

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_VERBOSE;//LOG_LEVEL_INFO;
#endif
