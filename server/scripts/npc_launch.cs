registerBehavior("npc1behavior", "data/ai/cmAINPCWaitWalk.xml");
registerBehavior("npc2behavior", "data/ai/cmAINPCWalkComplex.xml");
function serverCmdSpawnNPC(%client, %data, %bh)
{
    %transform = %client.getControlObject().getTransform();
    echo(%transform);
    makeNPC(%transform, %data, %bh);
}
function serverCmdSaveNPCs(%client, %filename)
{
    %ret = NPCGroup.save(%filename);
    echo(%ret, %filename);
}
function serverCmdLoadNPCs(%client, %filename)
{
    if (isObject(NPCGroup))
    {
        NPCGroup.delete();
    }
    exec(%filename);
    resetNPCs();
}
singleton SimGroup(NPCGroup)
{
};
function makeNPC(%transform, %data, %bh)
{
    if (%data $= "")
    {
        %data = NPC1Data;
    }
    if (%bh $= "")
    {
        %bh = "npc1behavior";
    }
    %obj = new NPCDecorative("")
    {
        .dataBlock = %data;
        .originPos = %transform;
        .behavior = %bh;
    };
    %obj.setToOrigin();
    NPCGroup.add(%obj);
}
function serverCmdActivateNPCs(%client)
{
    %i = 0;
    while (%i < NPCGroup.getCount())
    {
        %npc = NPCGroup.getObject(%i);
        %npc.setActive(1);
        %i = %i + 1;
    }
}
function serverCmdResetNPCs(%client)
{
    %i = 0;
    while (%i < NPCGroup.getCount())
    {
        %npc = NPCGroup.getObject(%i);
        %npc.setToOrigin();
        %npc.setActive(0);
        %i = %i + 1;
    }
}
function serverCmdDeleteNPCs(%client)
{
    NPCGroup.clear();
}
function serverCmdRegisterBehavior(%client, %name, %filename)
{
    registerBehavior(%name, %filename);
    %file = new FileObject("")
    {
    };
    %file.openForAppend("scripts/npc_launch.cs");
    %file.writeLine("registerBehavior(\"" @ %name @ "\", \"" @ %filename @ "\");");
    %file.close();
}
$file::net::operation::newFile = 1;
$file::net::operation::line = 2;
$file::net::operation::fileDone = 3;
function serverCmdRawFile(%client, %cmd, %a1)
{
    %file = $file::net::lastFile;
    if (%cmd == $file::net::operation::newFile)
    {
        if (isObject(%file))
        {
            error("Closing/deleting last file:", %file, $file::net::lastFileName);
            %file.delete();
        }
        %file = new FileObject("")
        {
        };
        $file::net::lastFile = %file;
        $file::net::lastFileName = %a1;
        %file.openForWrite(%a1);
        $file::net::lineCount = 0;
    }
    else
    {
        if (%cmd == $file::net::operation::line)
        {
            %file.writeLine(%a1);
            $file::net::lineCount = $file::net::lineCount + 1;
        }
        else
        {
            if (%cmd == $file::net::operation::fileDone)
            {
                %file.close();
                %file.delete();
                info("Done saving file", $file::net::lastFileName, "with", $file::net::lineCount, "lines.");
            }
        }
    }
}
registerBehavior("rabbitBehavior", "data/ai/rabbitAI.xml");

