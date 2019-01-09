function initTCPServer(%port)
{
    echo("initTCPServer(" SPC %port SPC ")");
    if (!isClass(TCPServer))
    {
        error("Can not initialize TCP server, and the current build doesn\'t support it!");
        return;
    }
    singleton TCPServer(tcpServerRS)
    {
        .initedOK = 0;
        .className = "clTCPServer";
        .clientsClassName = "prcClient";
        .authInfoIn = "CLIENT-CS";
        .authInfoOut = "CS-CLIENT";
    };
    tcpServerRS.schedule(32, startListening, %port);
}
function initDebugTCPServer()
{
    if (!$Player::debugTCPServerPort)
    {
        $Player::debugTCPServerPort = $net::Port + 1000;
    }
    %port = $Player::debugTCPServerPort;
    echo("initTCPServer(" SPC %port SPC ")");
    if (!isClass(TCPServer))
    {
        error("Can not initialize TCP server, and the current build doesn\'t support it!");
        return 0;
    }
    if (!isObject(tcpServerDebug))
    {
        singleton TCPServer(tcpServerDebug)
        {
            .initedOK = 0;
            .className = "cltcpServerDebug";
            .clientsClassName = "prcCli";
            .authInfoIn = "CLIENT-CS";
            .authInfoOut = "CS-CLIENT";
            .pendingPort = %port;
        };
        tcpServerDebug.schedule(32, startListening, %port);
    }
    return %port;
}
function serverCmdInitDebugTCPServer(%peer)
{
    if (!isDebugTcpEnabled())
    {
        return 0;
    }
    if (!%peer.isGM())
    {
        return 0;
    }
    %port = initDebugTCPServer();
    if (%port == 0)
    {
        return 0;
    }
    commandToClient(%peer, 'debugTCPServerIsOn', %port);
}
function prcCli::onConnected(%this)
{
}
function serverRpcAuthMe(%peer, %chid)
{
    %peer.charId = %chid;
    attachTCP(%peer, %chid);
}
function onTCPError(%tcpServer, %errorCode, %errorMessage)
{
    %tcpServer.onError(%errorCode, %errorMessage);
}
function onTCPInitOK(%tcpServer)
{
    %tcpServer.initedOK = 1;
}
function onTCPInitError(%tcpServer, %error)
{
    %tcpServer.onInitError(%error);
}
function TCPServer::onError(%this, %errorCode, %errorMessage)
{
    error(%this, %errorCode, %errorMessage);
}
function prcRS::onConnected(%this)
{
    Parent::onConnected(%this);
}
function TCPConnection::onConnected(%this)
{
    hack("Incoming TCP connected (simID=" @ %this @ ")");
    %this.schDelete = %this.schedule(2000, sAuthTimedout);
}
function tcpServerRS::onInitError(%this, %error)
{
    error("Error initializing TCP server, trying next port", %this, $net::TCPPort, %error);
    %this.schedule(0, delete);
    $net::TCPPort = $net::TCPPort + 1;
    schedule(32, RootGroup, initTCPServer, $net::TCPPort);
}
function TCPConnection::drop(%this)
{
    error("Dropping TCPConnection:" SPC %this SPC %this.getRemoteAddress());
    backtrace();
    %this.delete("DENIED");
}
function TCPConnection::sAuthTimedout(%this)
{
    warn("TCP connection (simID=" @ %this @ ") auth timed out. Drop connection");
    %this.schDelete = %this.schedule(0, delete);
}
function TCPConnection::cAuth(%this, %var)
{
    error("TCPConnection::cAuth() called");
    %this.drop();
}
function serverRpcCAUTH(%peer, %clientKey)
{
    %peer.cAuth(%clientKey);
}
