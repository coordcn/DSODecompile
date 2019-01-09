//-----------------------------------------------------------------------------
// By ruipgpinheiro, March 2016
//
// Based on T3D code by GarageGames
// Many functions written from scratch, or modified.
// Almost all dependencies on T3D were removed, and is now compatible with
// ThinkTanks' DSO format
//-----------------------------------------------------------------------------

#pragma once

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>

/// Import the platform type definitions from T3D
/// These were barely touched
#include "platform/types.h"

/// Avoid dependencies from Torque Streams and Strings
/// by using with the C++ stdlib instead
typedef std::ifstream Stream;
typedef std::string String;