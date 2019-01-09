//-----------------------------------------------------------------------------
// By ruipgpinheiro, March 2016
//
// Based on T3D code by GarageGames
// Many functions written from scratch, or modified.
// Almost all dependencies on T3D were removed, and is now compatible with
// ThinkTanks' DSO format
//-----------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>

#include "codeBlock.h"
#include "consoleDump.h"

using namespace std;

void usage(int argc, char *argv[]) {
	cerr << "Usage: " << argv[0] << " <DSO filename> [options]" << endl;
	cerr << "Valid options:\n";
	cerr << "\t--strings : Dump strings\n";
	cerr << "\t--hexdump : Dump code block in hexadecimal format\n";
	cerr << "\t\tNote: --strings --hexdump replaces string references in the hexdump with identifiers\n";
	cerr << "\t--disassemble : Dump disassembled instructions\n";
	cerr << "\t--decompile : Decompile script\n";
	cerr << "\t--wait : Wait for key press after conclusion\n";
	cerr << "All commands output to stdout. To write to a file, redirect it to a file, i.e.\n";
	cerr << argv[0] << " <DSO filename> [options] > [output_filename]\n";
}

int main(int argc, char *argv[])
{
	if (argc < 3) {
		usage(argc, argv);
		exit(EXIT_FAILURE);
	}

	//std::string fileName = "tests/append_char.cs.dso";

	std::string fileName = argv[1];
	std::string outputFileName = fileName.substr(0, fileName.length() - 4);
	bool strings = false;
	bool hexdump = false;
	bool disassemble = false;
	bool decompile = false;
	bool wait = false;

	for (int i = 2; i < argc; i++) {
		char *curArg = argv[i];

		if (strcmp(curArg, "--strings") == 0)
			strings = true;
		else if (strcmp(curArg, "--hexdump") == 0)
			hexdump = true;
		else if (strcmp(curArg, "--disassemble") == 0 || strcmp(curArg, "--da") == 0)
			disassemble = true;
		else if (strcmp(curArg, "--decompile") == 0 || strcmp(curArg, "--dc") == 0)
			decompile = true;
		else if (strcmp(curArg, "--wait") == 0)
			wait = true;
		else {
			cerr << "Invalid argument " << curArg << endl;
			usage(argc, argv);
			exit(EXIT_FAILURE);
		}
	}
	

	cerr << "Started" << endl;

	CodeBlock cb;

	if (!cb.read(fileName)) {
		exit(EXIT_FAILURE);
	}
	
	if (hexdump)
		cb.dumpCode(strings);

	if (strings && !hexdump)
		cb.dumpAllStrings();

	if (disassemble)
		cb.dumpInstructions(0, 0, false);

	if (decompile) {
		cerr << "Decompiling..." << endl;
		cout << DecompileWrite(outputFileName, cb);
	}

	//std::string fileName_out = "tests/append_char.cs";
	//DecompileWrite(fileName_out, cb);

	cerr << "Done.";

	if (wait) {
		cerr << " Press any key to exit.";
		getchar();
	}
	else {
		cerr << endl;
	}

	exit(EXIT_SUCCESS);
}