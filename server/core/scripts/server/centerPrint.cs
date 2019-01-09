function centerPrintAll(%message, %time, %lines)
{
    if (((%lines $= "") || (%lines > 3)) || (%lines < 1))
    {
        %lines = 1;
    }
    %count = ClientGroup.getCount();
    %i = 0;
    while (%i < %count)
    {
        %cl = ClientGroup.getObject(%i);
        commandToClient(%cl, 'centerPrint', %message, %time, %lines);
        %i = %i + 1;
    }
}
function bottomPrintAll(%message, %time, %lines)
{
    if (((%lines $= "") || (%lines > 3)) || (%lines < 1))
    {
        %lines = 1;
    }
    %count = ClientGroup.getCount();
    %i = 0;
    while (%i < %count)
    {
        %cl = ClientGroup.getObject(%i);
        commandToClient(%cl, 'bottomPrint', %message, %time, %lines);
        %i = %i + 1;
    }
}
function centerPrint(%client, %message, %time, %lines)
{
    if (((%lines $= "") || (%lines > 3)) || (%lines < 1))
    {
        %lines = 1;
    }
    commandToClient(%client, 'CenterPrint', %message, %time, %lines);
}
function bottomPrint(%client, %message, %time, %lines)
{
    if (((%lines $= "") || (%lines > 3)) || (%lines < 1))
    {
        %lines = 1;
    }
    commandToClient(%client, 'BottomPrint', %message, %time, %lines);
}
function clearCenterPrint(%client)
{
    commandToClient(%client, 'ClearCenterPrint');
}
function clearBottomPrint(%client)
{
    commandToClient(%client, 'ClearBottomPrint');
}
function clearCenterPrintAll()
{
    %count = ClientGroup.getCount();
    %i = 0;
    while (%i < %count)
    {
        %cl = ClientGroup.getObject(%i);
        commandToClient(%cl, 'ClearCenterPrint');
        %i = %i + 1;
    }
}
function clearBottomPrintAll()
{
    %count = ClientGroup.getCount();
    %i = 0;
    while (%i < %count)
    {
        %cl = ClientGroup.getObject(%i);
        commandToClient(%cl, 'ClearBottomPrint');
        %i = %i + 1;
    }
}
