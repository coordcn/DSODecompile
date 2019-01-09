$Game::DefaultPlayerClass = "Player";
$Game::DefaultPlayerDataBlock = "DefaultPlayerData";
$Game::DefaultPlayerSpawnGroups = "PlayerSpawnPoints PlayerDropPoints";
singleton SimSet(PlayerList)
{
};
function spawnPlayer(%client)
{
    if (isObject(%client.Player))
    {
        error("Attempting to create a player for a client that already has one!");
    }
    %datablock = %client.getPlayerDatablock();
    %player = spawnObject($Game::DefaultPlayerClass, %datablock);
    MissionCleanup.add(%player);
    PlayerList.add(%player);
    %player.client = %client;
    %player.scopeToClient(%client);
    %client.Player = %player;
    %client.setControlObject(%player);
    if (isMethod(Player, setReferencedClient))
    {
        %player.setReferencedClient(%client);
    }
    hack("Spawned player", %player, %player.getClassName(), "at", %player.getPosition());
    $pl = %player;
}
