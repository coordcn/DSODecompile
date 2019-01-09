loadDir("core");
function prepareDbIDRanges()
{
    U32CmDbTableIDRangeInit(U32UnmovObjDbIDRange, "p_issueIdRange_unmovable_objects", "p_occupyId_unmovable_objects");
    U32CmDbTableIDRangeInit(U32MovObjDbIDRange, "p_issueIdRange_movable_objects", "p_occupyId_movable_objects");
    U32CmDbTableIDRangeInit(U32HorseIDRange, "p_issueIdRange_horses", "p_occupyId_horses");
}
function prepareManagers()
{
    prepareDbIDRanges();
    CmCalendarInit($myServerId);
    CmWeatherInit();
    if (!initInventoryManager())
    {
        error("Fatal: Can\'t load object types. Terminating.");
        return 0;
    }
    echo("Loading substances");
    SubstanceManager_init();
    exec("scripts/server/cm_substances.cs");
    echo("Init of cmPatch");
    initCmPatch();
    exec("./server/cm_skill_config.cs");
    reloadGatheringInfo();
    if (!initSkillsManager())
    {
        error("Fatal: Can\'t load skills/abilities. Terminating.");
        return 0;
    }
    if (!initTitlesManager())
    {
        error("Fatal: Can\'t load titles. Terminating.");
        return 0;
    }
    initEquipmentManager();
    initCreationManager();
    loadRecipes();
    loadQuests();
    loadTriggersManager();
    initBuildingManager();
    initDurabilityManager();
    initSoundsManager();
    initGatherManager();
    initBreedingManager();
    initChatServer();
    initJudgementHourServerManager();
    initCustomisationManager();
    initCharCreateConfig();
    initUnitManager();
    initPlayerRandomEvents();
    initBarterManager();
    loadComplexObjectTypes();
    initServerComplexObjectManager();
    initMixingManager();
    initMentoringManager();
    initBomberman();
    initCraftworkManager();
    initOutpostsManager();
    initOutpostBunnyManager();
    CmSnowdriftInit();
    loadXmlDataForSpecialAttacks();
    parseForestMaintenanceXmlSettings();
    loadAttackAnimationsXml();
    initAdminLandsAbilities();
    return 1;
}
function onPostInit()
{
    exec("scripts/CombatConstants.cs");
    exec("scripts/wounds.cs");
    exec("scripts/cm_water.cs");
    exec("scripts/client/connection.cs");
    if (!initNetwork())
    {
        return;
    }
    if (!prepareManagers())
    {
        quit();
        return;
    }
    createWorld();
    updatePlayerCountDisplay();
}
function checkServerIdLockFile()
{
    new FileObject(foLock)
    {
    };
    if (!foLock.openForWrite("data/server_" @ $cm_config::worldID @ ".lock"))
    {
        foLock.delete();
        return 0;
    }
    if (!renameLogFileByServerId($cm_config::worldID))
    {
        error("Can\'t rename log file with our world id == " @ $cm_config::worldID @ "!!! Shutting down!");
        return 0;
    }
    return 1;
}
function initNetwork()
{
    if (!isFunction(portInit))
    {
        assert(0, "Oops! No function portInit()!!!");
    }
    $net::Port = portInit($defaultPort);
    $Con::WindowTitle = $Con::WindowTitle SPC "(port" SPC $net::Port @ ")";
    updateWinConsoleTitle();
    if (!$net::Port)
    {
        return 0;
    }
    $net::TCPPort = $net::Port;
    initTCPServer($net::TCPPort);
    return $net::Port;
}
function onStart()
{
    new SimGroup(systemCleanupGroup)
    {
    };
    $instantGroup = systemCleanupGroup;
    setRandomSeed();
    exec("./server/defaults.cs");
    initCmLangManager();
    initCmMessages();
    $isFirstPersonVar = 1;
    exec("core/scripts/server/server.cs");
    echo("\n--------- Initializing Directory: scripts ---------");
    exec("./server/init.cs");
    physicsInit();
    if (!initServer())
    {
        return;
    }
    createServer();
    schedule(0, RootGroup, onPostInit);
}
function onExit()
{
    destroyServer();
    if (isObject(systemCleanupGroup))
    {
        systemCleanupGroup.delete();
    }
    else
    {
        error("Can\'t find SimGroup(systemCleanupGroup)!!!");
    }
    physicsDestroy();
    if (isFunction(shutdownCore))
    {
        shutdownCore();
    }
    hack("The server has been shut down!");
}
