//-----------------------------------------------------------------------------
// Torque
// Copyright GarageGames, LLC 2011
//-----------------------------------------------------------------------------

// Constants for referencing video resolution preferences
$WORD::RES_X = 0;
$WORD::RES_Y = 1;
$WORD::FULLSCREEN = 2;
$WORD::BITDEPTH = 3;
$WORD::REFRESH = 4;
$WORD::AA = 5;
$WORD::BORDERLESS = 6;

//---------------------------------------------------------------------------------------------
// CorePackage
// Adds functionality for this mod to some standard functions.
//---------------------------------------------------------------------------------------------
package CorePackage
{
//---------------------------------------------------------------------------------------------
// onStart
// Called when the engine is starting up. Initializes this mod.
//---------------------------------------------------------------------------------------------
function onStart()
{
   // Here is where we will do the video device stuff, so it overwrites the defaults
   // First set the PCI device variables (yes AGP/PCI-E works too)
   $isFirstPersonVar = 1;

   // Uncomment to enable AdvancedLighting on the Mac (T3D 2009 Beta 3)
   //$pref::machax::enableAdvancedLighting = true;

   // Uncomment to disable ShaderGen, useful when debugging
   //$ShaderGen::GenNewShaders = false;

   // Uncomment to dump disassembly for any shader that is compiled to disk.
   // These will appear as shadername_dis.txt in the same path as the
   // hlsl or glsl shader.
   //$gfx::disassembleAllShaders = true;

   // Uncomment useNVPerfHud to allow you to start up correctly
   // when you drop your executable onto NVPerfHud
   //$Video::useNVPerfHud = true;

   // Uncomment these to allow you to force your app into using
   // a specific pixel shader version (0 is for fixed function)
   //$pref::Video::forcePixVersion = true;
   //$pref::Video::forcedPixVersion = 0;

   if ($platform $= "macos")
      $pref::Video::displayDevice = "OpenGL";
   else
      $pref::Video::displayDevice = "D3D11";

   // language manager and messages are initialized as soon as possible
   // because they are used in other script modules (i.e. GUI)
   initCmLangManager();
   initCmMessages();

   // Initialise stuff.
   exec("./scripts/client/core.cs");
   initializeCore();


   exec("./scripts/client/client.cs");
   //exec("./scripts/server/server.cs");

   exec("./scripts/gui/guiTreeViewCtrl.cs");
   exec("scripts/gui/players.cs");
   exec("art/gui/players.gui");
   exec("gui/forms/loadingGui.gui");

   echo(" % - Initialized Core");
}

//---------------------------------------------------------------------------------------------
// onExit
// Called when the engine is shutting down. Shutdowns this mod.
//---------------------------------------------------------------------------------------------
function onExit()
{
   // Shutdown stuff.
   shutdownCore();
}

function loadKeybindings()
{
   $keybindCount = 0;
   // Load up the active projects keybinds.
   if(isFunction("setupKeybinds"))
      setupKeybinds();
}

//---------------------------------------------------------------------------------------------
// parseArgs
// Parses the command line arguments and processes those valid for this mod.
//---------------------------------------------------------------------------------------------
function parseArgs()
{
   // Loop through the arguments.
   for (%i = 1; %i < $Game::argc; %i++)
   {
      %arg = $Game::argv[%i];
      %nextArg = $Game::argv[%i+1];
      %hasNextArg = $Game::argc - %i > 1;

      switch$ (%arg)
      {
         case "-fullscreen":
            //setFullScreen(true);
            $argUsed[%i]++;

         case "-windowed":
            //setFullScreen(false);
            $argUsed[%i]++;
      }
   }
}

};

activatePackage(CorePackage);
