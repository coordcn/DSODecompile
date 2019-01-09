function onServerCreated()
{
    physicsInitWorld("server");
    if (isScriptFile("art/datablocks/managedDatablocks.cs"))
    {
        exec("art/datablocks/managedDatablocks.cs");
    }
    if (isScriptFile("art/forest/managedItemData.cs"))
    {
        exec("art/forest/managedItemData.cs");
    }
    initBehaviorsManager();
    exec("art/datablocks/datablockExec.cs");
    exec("./scriptExec.cs");
}
function onServerDestroyed()
{
    physicsDestroyWorld("server");
}
function cmChatSendLocalMessageToClient(%client, %fromName, %position, %message)
{
    commandToClient(%client, 'LocalChatMessage', %fromName, %position, %message);
}
function cmClientConnection::calcCsHash(%this)
{
    %salt = %this.getId() @ getRandom() @ %this.getAddress();
    return calcSha1(%this.charId @ %salt);
}
function cmClientConnection::informAboutLocalCS(%this)
{
    if (!%this.charId)
    {
        error("Not Calling informAboutLocalCS (client) on" SPC %this SPC "as no char is selected yet!");
        return;
    }
    if (%this.wasInformedCS)
    {
        warn("Char" SPC %this.charId SPC "is already informed about this CS");
    }
    echo("Calling informAboutLocalCS (client) on" SPC %this);
    %this.csHash = %this.calcCsHash();
    commandToPeer(%this, 'CS', $net::TCPPort, %this.csHash);
    %this.wasInformedCS = 1;
}
function cmClientConnection::joinToServer(%this)
{
    %this.informAboutLocalCS();
}
function onMaintenanceFinished(%status)
{
    if (%status && $map::generation::enabled)
    {
        SaveMapFiles();
    }
}
