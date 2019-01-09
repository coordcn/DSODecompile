exec("./triggers.cs");
exec("./inventory.cs");
exec("./shapeBase.cs");
exec("./projectile.cs");
exec("./radiusDamage.cs");
exec("./weapon.cs");
exec("./player.cs");
exec("./vehicle.cs");
exec("./world.cs");
exec("./horse.cs");
exec("./horsepack.cs");
exec("./tcpServer.cs");
exec("./prcClients.cs");
///Call exec() on all scripts from the %folder excluding filenames specified in %exclude.
Usage example:
reloadScriptsFromFolder("global", "init main onceOnly");
will exec all files except init.cs, main.cs and onceOnly.cs

function reloadScriptsFromFolder(%folder, %exclude, %ext)
{
    if (%ext $= "")
    {
        %ext = "cs";
    }
    %filespec = %folder @ "/*." @ %ext;
    %exCnt = getWordCount(%exclude);
    %file = findFirstFile(%filespec);
    while (!(%file $= ""))
    {
        %filename = fileBase(%file);
        if (%exCnt > 0)
        {
            %i = 0;
            while (%i < %exCnt)
            {
                if (!(%filename $= getWord(%exclude, %i)))
                {
                    exec(%file);
                }
                %i = %i + 1;
            }
        }
        else
        {
            exec(%file);
        }
        %file = findNextFile(%filespec);
    }
}
