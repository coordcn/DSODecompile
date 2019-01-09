/// Determine the IP address we can use locally

function determineNetwork()
{
    %ipLine = getIPLocal();
    if (getWordCount(%ipLine) <= 0)
    {
        error("Can\'t get IP address");
        return;
    }
    $cm_config::localIpAddress = getWord(%ipLine, 0);
}
function initServer()
{
    echo("\n--------- Initializing " @ $appName @ ": Server Scripts ---------");
    initBaseServer();
    exec("./commands.cs");
    exec("./game.cs");
    exec("art/terrains/materials.cs");
    echo("Loading CmConfiguration");
    exec("scripts/server/cm_config.cs");
    CmConfiguration_init();
    echo("Init of DB interface");
    CmDatabase_init();
    if (!CmServerInfoManager::setLocalWorldIDToLoad($cm_config::worldID))
    {
        error("Fatal: Can\'t set world to load (id=" @ $cm_config::worldID @ "). Terminating.");
        quit();
        return 0;
    }
    $cm_config::worldID = CmServerInfoManager::getWorldIdToLoad();
    if (!checkServerIdLockFile())
    {
        error("Can\'t init server... looks like another instance is already started! (id=" @ $cm_config::worldID @ "). Terminating.");
        quit();
        return;
    }
    if (!CmServerInfoManager::initLocalWorld())
    {
        error("Fatal: Can\'t init local world (id=" @ $cm_config::worldID @ "). Terminating.");
        quit();
        return 0;
    }
    $Con::WindowTitle = $Con::WindowTitle @ "," SPC "world ID" SPC $cm_config::worldID;
    updateWinConsoleTitle();
    if (!CmServerInfoManager::isDedicatedServer())
    {
        startSharingServerLoadingStatus();
    }
    singleton DatabaseInterface(dbi)
    {
    };
    dbi.initialize(DBIPrimary);
    singleton DatabaseInterface(dbiInventory)
    {
    };
    dbiInventory.initialize(DBIInvLoad);
    singleton DatabaseInterface(dbiInvHelper)
    {
    };
    dbiInvHelper.initialize(dbiInvHelper);
    singleton DatabaseInterface(dbiGuilds)
    {
    };
    dbiGuilds.initialize(DBIGuildsProcess);
    U32CmDbTableIDRangeInit(U32CharacterDbIDRange, "p_issueIdRange_character", "p_occupyId_character");
    initPlayerSpawnPoints();
    exec("art/forest/treeDatablocks.cs");
    exec("scripts/navmesh.cs");
    initNavMeshUpdates();
    determineNetwork();
    return 1;
}
function startSharingServerLoadingStatus()
{
    if (!isObject($sharedLoadingStatus))
    {
        $sharedLoadingStatus = new CmServerSharedLoadingStatus("")
        {
        };
        MissionCleanup.add($sharedLoadingStatus);
    }
}
