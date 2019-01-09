function GameConnection::onPreConnectRequest(%this, %netAddress, %name)
{
    echo(%this, %netAddress, %name);
    $Server::PlayerCount = $Server::PlayerCount + 1;
    updatePlayerCountDisplay();
}
function GameConnection::onConnectRequest(%this, %netAddress, %name)
{
    echo("Connect request from:", %this, %this.getAccountId(), %netAddress @ ". Players " @ mRound($Server::PlayerCount) @ "/" @ $Server::MaxPlayers);
    if ($Server::PlayerCount > $Server::MaxPlayers)
    {
        warn("Connection from" SPC %netAddress SPC "(" @ %name @ ")" SPC "dropped due to CR_SERVERFULL");
        return "CR_SERVERFULL";
    }
    return "";
}
/// Clear data of the previous play session (char data)

function GameConnection::clearPlaySession(%this)
{
    %this.setName("");
    if (%this.charId)
    {
        %this.unregisterByCharacter();
    }
    %this.charId = "";
    %this.geoId = "";
    %this.charName = "";
    %this.charLastName = "";
}
/// This method (and a few others around) is duplicated on Dispatcher

function GameConnection::dropDuplicatedConnection(%this, %useCharId)
{
    %accountId = %this.getAccountId();
    %prevConnection = %useCharId ? NetConnection::findByCharId(%useCharId) : NetConnection::findByAccountId(%accountId);
    if (!isObject(%prevConnection) && (%prevConnection.getId() == %this.getId()))
    {
        return 1;
    }
    if (isEventPending(%prevConnection.schExit))
    {
        return getEventTimeLeft(%prevConnection.schExit) + 1;
    }
    if (%useCharId)
    {
        %msg = "Dropping previous connection for in-game character:";
        %cmd = 2;
        %id = %useCharId;
    }
    else
    {
        %msg = "Dropping previous connection for non-DbGm account:";
        %cmd = 3;
        %id = %this.getAccountId();
    }
    info(%msg, "[" @ %prevConnection.getId() @ "]", %useCharId, %this.getAccountId());
    %disconnectReason = "Duplicated connection";
    %timeout = 0;
    if (%useCharId)
    {
        %prevConnection.delete(%disconnectReason);
    }
    else
    {
        if (%prevConnection.charId == 0)
        {
            %prevConnection.delete(%disconnectReason);
        }
        else
        {
            %timeout = %prevConnection.getPingTimeout();
            %prevConnection.schExit = %prevConnection.scheduleDelete(%disconnectReason, %timeout);
            %prevConnection.sendCommand('DS', 2, %timeout);
            %i = 0;
            while (%i < ServersGroup.getCount())
            {
                ServersGroup.getObject(%i).sendCommand('Client', %cmd, %id, %disconnectReason, %timeout);
                %i = %i + 1;
            }
        }
    }
    return %timeout + 1;
}
function GameConnection::onConnect(%this)
{
    info(%this, %this.getAccountId(), %this.charId);
}
function GameConnection::onAuthorized(%this)
{
    info(%this, %this.getAccountId(), %this.charId, %this.charName);
    SendServerUUIDEvent(%this);
    %this.cameraNewtonMode = 0;
    %this.cameraNewtonRotation = 0;
    %this.cameraSpeed = 40;
    %this.allowedToGetIn = 0;
    %jumpInTimeout = %this.dropDuplicatedConnection(0) - 1;
    %this.schedule(%jumpInTimeout, postConnectRoutine);
    if (%jumpInTimeout > 1000)
    {
        commandToPeer(%this, 'DS', 1, %jumpInTimeout);
    }
    %this.registerByAccountId();
}
function GameConnection::isReadyForCharList(%this)
{
    return %this.allowedToGetIn;
}
function GameConnection::postConnectRoutine(%this)
{
    info(%this, %this.getAddress(), %this.getName(), %this.getAccountId());
    %this.allowedToGetIn = 1;
    %this.sendCharList();
}
function serverCmdReadyState(%client)
{
    commandToClient(%client, 'ReadyStateAck');
    SendGameDateTime(%client);
    SendWeather(%client);
}
function serverCmdReadyToInventory(%client)
{
    %client.insertIntoRegistry();
    %client.initPlayerManager();
}
function serverCmdReadyToPatch(%client)
{
    %client.joinToServer();
}
function serverCmdClientReadyToEnterGame(%client)
{
    messageClient(%client, 'MsgConnectionError', "", $Pref::Server::ConnectionError);
    echo("CADD: " @ %client @ " " @ %client.getAddress());
    %client.prepareClient();
}
function GameConnection::onClientEnterGame(%this)
{
    if (!%this.readyToGetIn)
    {
        commandToClient(%this, 'setCameraSpeed', $Camera::movementSpeed);
        %this.readyToGetIn = 1;
        hack(%this, "Player ready to get in, waiting for trySpawnPlayer() call...");
    }
}
function GameConnection::trySpawnPlayer(%this)
{
    if (%this.readyToGetIn && (%this.getEventQueueSize() == 0))
    {
        hack(%this, "Player ready to get in, spawning Player object...");
        %this.schDataLoaded = "";
        spawnPlayer(%this);
    }
    else
    {
        if (%this.getEventQueueSize())
        {
            warn("Client", %this, "have still", %this.getEventQueueSize(), "NetEvents pending to be sent... Already sent:", %this.getEventsSent());
        }
        %this.schDataLoaded = %this.schedule(256, trySpawnPlayer);
    }
}
function GameConnection::onClientLeaveGame(%this)
{
    echo(%this);
    if (%this.schDataLoaded)
    {
        cancel(%this.schDataLoaded);
        %this.schDataLoaded = "";
    }
    if (isObject(%this.Camera))
    {
        error("Client:" SPC %this SPC "Camera:" SPC %this.Camera SPC "isServerObject:" SPC %this.Camera.isServerObject());
        if (%this.Camera.isServerObject())
        {
            %this.Camera.delete();
        }
    }
    hack("Client disconnected:" SPC %this SPC "Player:" SPC %this.Player SPC "isServerObject:" SPC isObject(%this.Player) ? %this.Player.isServerObject() : "X");
    if (isObject(%this.Player) && %this.Player.isServerObject())
    {
        echo("Saving player position...");
        if (%this.Player.teleporting)
        {
            hack("Skipping save player as we are teleporting");
        }
        else
        {
            %this.Player.saveAndDestructPlayer();
        }
        %this.Player.delete();
    }
}
function GameConnection::onDeath(%this, %sourceObject, %sourceClient, %damageType, %damLoc)
{
    %this.Player.setShapeName("");
    %this.Player.updateHealth();
    %this.setPlayerDead();
    %this.Player = 0;
}
function GameConnection::onDrop(%this, %reason)
{
    echo("GameConnection::onDrop", %this, %reason);
    %this.onClientLeaveGame();
    removeTaggedString(%this.playerName);
    echo("CDROP: " @ %this @ " " @ %this.getAddress());
    $Server::PlayerCount = $Server::PlayerCount - 1;
    updatePlayerCountDisplay();
    if (isObject(%this.PathCamera))
    {
        %this.PathCamera.delete();
    }
    if (%this.charId)
    {
        %this.unregisterByCharacter();
    }
    %this.unregisterByAccountId();
}
function GameConnection::prepareClient(%this)
{
    warn("GC:" SPC %this SPC "CharId:" SPC %this.getCharacterId());
    %this.setName("ch_" @ %this.getCharacterId());
    %this.activateGhosting();
}
function GameConnection::onGhostAlwaysObjectsReceived(%this)
{
    commandToClient(%this, 'AllGhostAlwaysReceived');
    %this.onClientEnterGame();
}
function GameConnection::onPatched(%this)
{
    commandToClient(%this, 'PATCHOK');
}
function updatePlayerCountDisplay()
{
    %plaStr = "players" SPC getMax(0, $Server::PlayerCount) @ "/" @ $Server::MaxPlayers;
    %plaSubstrPos = strstr($Con::WindowTitle, "players");
    if (%plaSubstrPos >= 0)
    {
        $Con::WindowTitle = getSubStr($Con::WindowTitle, 0, %plaSubstrPos) @ %plaStr;
    }
    else
    {
        $Con::WindowTitle = $Con::WindowTitle SPC %plaStr;
    }
    updateWinConsoleTitle();
}
function serverCmdClientManagersInitialized(%connection)
{
    onClientManagersInitialized(%connection);
}
