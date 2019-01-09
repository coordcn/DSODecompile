//-----------------------------------------------------------------------------
// By ruipgpinheiro, March 2016
//
// Based on T3D code by GarageGames
// Many functions written from scratch, or modified.
// Almost all dependencies on T3D were removed, and is now compatible with
// ThinkTanks' DSO format
//-----------------------------------------------------------------------------

#ifndef _CONSOLEDUMP_H_
#define _CONSOLEDUMP_H_

// Note: These are not the "real" T3D headers, type definitions may be very different
#include "platform/platform.h"
#include "compiler.h"
#include "codeBlock.h"

extern String Decompile(CodeBlock& cb);
extern bool DecompileWrite(String fileName_out, CodeBlock& cb);

#endif