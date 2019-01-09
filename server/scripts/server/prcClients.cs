function getClientConnectionByCsHash(%accoundHash)
{
    %i = 0;
    while (%i < ClientGroup.getCount())
    {
        %client = ClientGroup.getObject(%i);
        if (%client.csHash $= %accoundHash)
        {
            return %client;
        }
        %i = %i + 1;
    }
    return 0;
}
function prcClient::cAuth(%this, %accoundHash)
{
    %plaCon = getClientConnectionByCsHash(%accoundHash);
    if (!%plaCon)
    {
        %tcp_addr = %this.getRemoteAddress() @ ":" @ %this.getRemotePort();
        error("prcClient::cAuth() - bad hash received:" SPC %this SPC %tcp_addr SPC %accoundHash);
        %this.delete("DENIED");
        return;
    }
    cancel(%this.schDelete);
    %this.charId = %plaCon.charId;
    %name = "char_" @ %this.charId;
    if (isObject(%name))
    {
        %name.delete("Double connections not allowed!");
    }
    %this.setInternalName(%name);
    %this.setName("ch_" @ %this.charId);
    if (!yoCsAttachClient(%this, %this.charId))
    {
        return;
    }
    %this.requestPatchVersions();
}
function prcClient::requestPatchVersions(%this)
{
    %this.sendCommand('GetPVer');
}
function prcClient::onDisconnected(%this, %errCode, %err)
{
    hack(%this, %this.charId, %errCode, %err);
}
function prcClient::onDrop(%this, %reason)
{
    hack(%this, %this.charId, %reason);
}
function prcClient::onRemove(%this, %reason)
{
    hack(%this, %this.charId, %reason);
}
