//-----------------------------------------------------------------------------
// Copyright (c) 2012 GarageGames, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// By ruipgpinheiro, March 2016
//
// Based on T3D code by GarageGames
// Many functions written from scratch, or modified.
// Almost all dependencies on T3D were removed, and is now compatible with
// ThinkTanks' DSO format
//-----------------------------------------------------------------------------

#ifndef _CODEBLOCK_H_
#define _CODEBLOCK_H_

// Note: These are not the "real" T3D headers, type definitions may be very different
#include "platform/platform.h"
#include "compiler.h"

// Verbose CodeBlock::read
//#define VERBOSE_CODEBLOCK_READ

/// Core TorqueScript code management class.
///
/// This class represents a block of code
class CodeBlock
{
private:
	void calcBreakList();
	char* CodeBlock::findStringInfoFromPointer(char * ptr);
public:
	CodeBlock();
	~CodeBlock();

	bool m_loaded = false;

	StringTableEntry name;
	StringTableEntry fullPath;
	StringTableEntry modPath;

	char *globalStrings;
	char *functionStrings;

	U32 functionStringsMaxLen;
	U32 globalStringsMaxLen;

	F64 *globalFloats;
	F64 *functionFloats;

	U32 codeSize;
	U64 *code;

	U32 refCount;
	U32 lineBreakPairCount;
	U64 *lineBreakPairs;
	U32 breakListSize;
	U64 *breakList;

	U32 version;

	///
	bool read(String &fileName);
	bool read(Stream &st);

	inline StringTableEntry CodeBlock::CodeToSTE(U64 *code, U32 ip);
	void CodeBlock::dumpInstructions1(U32 startIp, U32 number, bool upToReturn);
	void CodeBlock::dumpInstructions(U32 startIp, U32 number, bool upToReturn);
	void CodeBlock::dumpCode(bool strings = true);
	void CodeBlock::dumpStrings(char * stringBuffer);
	void CodeBlock::dumpAllStrings();
	void CodeBlock::printInstructionHex(U32 ip, U32 size);
};

#endif