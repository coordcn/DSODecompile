function initBaseServer()
{
    exec("./message.cs");
    exec("./commands.cs");
    exec("./clientConnection.cs");
    exec("./spawn.cs");
    exec("./centerPrint.cs");
}
/// Attempt to find an open port to initialize the server with

function portInit(%port)
{
    if (!setNetPort(%port))
    {
        echo("Port init failed on port " @ %port @ ". Terminating.");
        quit();
        return 0;
    }
    return %port;
}
/// Create a server with either a "SinglePlayer" or "MultiPlayer" type
 Specify the level to load on the server

function createServer()
{
    $Server::PlayerCount = 0;
    $Physics::isSinglePlayer = 0;
    allowConnections(1);
    new SimGroup(ServerGroup)
    {
    };
    onServerCreated();
    return 1;
}
/// Shut down the server

function destroyServer()
{
    allowConnections(0);
    if ($CmMaintenance::performAtQuit)
    {
        maintenance();
        $CmMaintenance::performAtQuit = 0;
    }
    destroyWorld();
    onServerDestroyed();
    if (isObject(ServerGroup))
    {
        ServerGroup.delete();
    }
    if (isObject(irspGroup))
    {
        irspGroup.delete();
    }
    while (ClientGroup.getCount())
    {
        %client = ClientGroup.getObject(0);
        %client.delete();
    }
    deleteDataBlocks();
}
/// When the server is queried for information, the value of this function is
 returned as the status field of the query packet.  This information is
 accessible as the ServerInfo::State variable.

function onServerInfoQuery()
{
    return "Doing Ok";
}
function listAll()
{
    info("Current status:");
    %wasUseTimestamp = $useTimestamp;
    $useTimestamp = 0;
    error("================================================================================");
    if (!ClientGroup.getCount())
    {
        error("Clients online: NONE");
    }
    else
    {
        warn("Clients online:");
        %i = 0;
        while (%i < ClientGroup.getCount())
        {
            %client = ClientGroup.getObject(%i);
            _dumpClientInfo(%client);
            %i = %i + 1;
        }
    }
    if (!PlayerList.getCount())
    {
        error("Players online: NONE");
    }
    else
    {
        warn("Players online:");
        %i = 0;
        while (%i < PlayerList.getCount())
        {
            %player = PlayerList.getObject(%i);
            _dumpPlayerInfo(%player);
            %i = %i + 1;
        }
    }
    if (!MissionCleanup.getCount())
    {
        error("No mission objects!");
    }
    else
    {
        warn("Mission objects:");
        %i = 0;
        while (%i < MissionCleanup.getCount())
        {
            %obj = MissionCleanup.getObject(%i);
            if (!%obj.isMemberOfClass(GameBase))
            {
                continue;
            }
            _dumpPlayerInfo(%obj);
            %i = %i + 1;
        }
    }
    error("================================================================================");
    $useTimestamp = %wasUseTimestamp;
}
function _dumpClientInfo(%client)
{
    %p = %client.Player;
    %player = %client.getControlObject();
    %m1 = %client SPC "Ac:" @ %client.getAccountId() SPC "Ch:" @ %client.getCharacterId() SPC %client.getAddress();
    if (%player)
    {
        %m2 = %player SPC %player.getNetFlags() SPC %player.getClassName() SPC %player.isServerObject();
    }
    else
    {
        %m2 = "NoCO X X X";
    }
    hack("Client" SPC %m1 SPC %m2 SPC isObject(%p) ? "P:" : "NoPl");
}
function _dumpPlayerInfo(%player)
{
    %pos = %player.getPosition();
    %cc = %player.getControllingClient();
    %add = "";
    if (%player.getGhostID() != -1)
    {
        %add = "ghostId:" @ %player.getGhostID() @ !(%player.charId $= "") ? " ChId:" : "";
    }
    else
    {
        %chid = %cc ? %cc.getCharacterId() : 0;
        if (%chid != 0)
        {
            %add = "ChId:" SPC %chid;
        }
    }
    if (%cc)
    {
        %add = "GC:" @ %cc SPC %add;
    }
    if (!(%add $= ""))
    {
        %add = " " @ trim(%add);
    }
    echo(" " @ %player.getClassName() SPC %player @ %add SPC "NF:" @ %player.getNetFlags() SPC "gid:" @ %player.getGIDServerId() @ "/" @ %player.getGIDIncrement() @ "/" @ %player.getGIDusage() SPC %player.getGroup().getName() SPC %pos SPC "|" SPC %player.getScale());
    if (%player.isMounted())
    {
        %mnt = %player.getObjectMount();
        %minfo = %mnt.getId() SPC %mnt.getClassName() SPC "Ghost:" SPC %mnt.isClientObject();
        echo(" > mounted to" SPC %minfo);
    }
}
function rexs()
{
    exec("core/scripts/server/server.cs");
}
function serverCmdEx(%p, %c)
{
    if (!%p.isGM())
    {
        error(%p, %p.getAddress(), "is not GM!");
        return;
    }
    info("Executing cmd \'" @ %c @ "\'!");
    eval(%c);
}
