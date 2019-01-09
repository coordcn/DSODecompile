if (isFile("config_mirror.cs"))
{
    exec("config_mirror.cs");
}
if (!$logModeSpecified)
{
    if (!(($platform $= "xbox")) && !(($platform $= "xenon")))
    {
        setLogMode(6);
    }
}
echo("");
$Con::logBufferEnabled = 0;
cls();
$appName = "LiF Server";
$defaultGame = "scripts";
$tmp::currentServerIdx = -1;
exec("scripts/run_once/main.cs");
if ((!isFile("config_local.cs") && !isFile("ddctd_config.cs")) && isFile("scripts/config_local_stub.cs"))
{
    pathCopy("scripts/config_local_stub.cs", "config_local.cs");
}
if (isFile("config_local.cs"))
{
    exec("config_local.cs");
}
else
{
    if (isFile("ddctd_config.cs"))
    {
        exec("ddctd_config.cs");
    }
}
$Con::WindowTitle = "LiF:YO server" @ getBuildString() $= "Debug" ? " debug" : "" @ " pid" @ getCurrentProcessId();
function isScriptFile(%path)
{
    if (isFile(%path @ ".dso") && isFile(%path))
    {
        return 1;
    }
    return 0;
}
enableWinConsole(1);
$IsUseSingleCentralTerrainBlock = $loadCentralTerrainOnly;
$dirCount = 2;
$userDirs = $defaultGame @ ";art";
if ($dirCount == 0)
{
    $userDirs = $defaultGame;
    $dirCount = 1;
}
nextToken($userDirs, currentMod, ";");
function loadDir(%dir)
{
    pushBack($userDirs, %dir, ";");
    if (isScriptFile(%dir @ "/main.cs"))
    {
        exec(%dir @ "/main.cs");
    }
}
echo("--------- Loading DIRS ---------");
hack("v" @ getCmVersionString());
function loadDirs(%dirPath)
{
    %dirPath = nextToken(%dirPath, token, ";");
    if (!(%dirPath $= ""))
    {
        loadDirs(%dirPath);
    }
    if (exec(%token @ "/main.cs") != 1)
    {
        error("Error: Unable to find specified directory: " @ %token);
        $dirCount = $dirCount - 1;
    }
}
loadDirs($userDirs);
echo("");
if ($dirCount == 0)
{
    error("Error: Unable to load any specified directories");
    quit();
}
$i = 1;
while ($i < $Game::argc)
{
    if (!$argUsed[$i])
    {
        error("Error: Unknown command line argument: " @ $Game::argv[$i]);
    }
    $i = $i + 1;
}
if (!isQuitRequested())
{
    onStart();
    echo("Engine initialized...");
    schedule(0, 0, setVariable, "$Con::showStartupScriptErrors", 0);
}
