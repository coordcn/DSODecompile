function createWorld()
{
    if ($Game::Running)
    {
        error("createWorld() has already been called! Not doing it again!");
        return;
    }
    $instantGroup = ServerGroup;
    new SimGroup(MissionGroup)
    {
        .canSave = 1;
        .canSaveDynamicFields = 1;
        .enabled = 1;
    };
    new SimGroup(MissionCleanup)
    {
    };
    $instantGroup = MissionCleanup;
    createLandsManager();
    echo("Loading terrain list");
    if (!InitTerrainList($dataMirrorPath))
    {
        error("Fatal: Can\'t init terrain list (mirror path=\"" @ $dataMirrorPath @ "\"). Terminating.");
        quit();
        return;
    }
    %obj = new Player("")
    {
        .dataBlock = PlayerMaleData;
    };
    %obj.delete();
    %obj = new Player("")
    {
        .dataBlock = PlayerFemaleData;
    };
    %obj.delete();
    %obj = "";
    echo("*** Mission loaded");
    initAnimalsSpawnControl();
    initLoadGuilds();
    initLoadLands();
    initLoadClaimRules();
    initGuildActionsManager();
    recalcLands();
    physicsStartSimulation("server");
    initHorsesManager();
    initBeehiveManager();
    $Game::Running = 1;
    schedule(256, 0, tryToRegisterOnSteam);
    schedule(32, 0, hack, "Server is up and ready to accept connections");
}
function tryToRegisterOnSteam()
{
    if ($shuttingDown)
    {
        error("Not registering on Steam, as server requested shutdown!");
        return;
    }
    registerSteamServer($net::Port);
}
function destroyWorld()
{
    if (!isObject(MissionGroup))
    {
        return;
    }
    echo("*** ENDING MISSION");
    physicsStopSimulation("server");
    if (!$Game::Running)
    {
        error("endGame: No game running!");
        return;
    }
    %clientIndex = 0;
    while (%clientIndex < ClientGroup.getCount())
    {
        %cl = ClientGroup.getObject(%clientIndex);
        commandToClient(%cl, 'GameEnd');
        %clientIndex = %clientIndex + 1;
    }
    $Game::Running = 0;
    echo("Saving terrains on endGame()");
    detachTerrains();
    %clientIndex = 0;
    while (%clientIndex < ClientGroup.getCount())
    {
        %cl = ClientGroup.getObject(%clientIndex);
        %cl.resetGhosting();
        %clientIndex = %clientIndex + 1;
    }
    MissionGroup.delete();
    MissionCleanup.delete();
    $instantGroup = ServerGroup;
}
function onSteamServerRegistered()
{
    if (isObject($sharedLoadingStatus))
    {
        $sharedLoadingStatus.setServerLoaded();
    }
}
