function serverCmdcreateWound(%client, %partOfBody)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.createWound(%partOfBody);
    }
}
function serverCmdcreateBleeding(%client, %partOfBody)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.createBleeding(%partOfBody);
    }
}
function serverCmdcreateFracture(%client, %partOfBody)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.createFracture(%partOfBody);
    }
}
function serverCmdremoveWound(%client, %partOfBody)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.removeWound(%partOfBody);
    }
}
function serverCmdremoveBleeding(%client, %partOfBody)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.removeBleeding(%partOfBody);
    }
}
function serverCmdremoveFracture(%client, %partOfBody)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.removeFracture(%partOfBody);
    }
}
function serverCmdhealWound(%client, %partOfBody, %durationMultiplier)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.healWound(%partOfBody, %durationMultiplier);
    }
}
function serverCmdhealFracture(%client, %partOfBody, %durationMultiplier)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.healFracture(%partOfBody, %durationMultiplier);
    }
}
function serverCmddealDamage(%client, %partOfBody)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.dealDamage(%partOfBody);
    }
}
function serverCmdcreateRest(%client, %duration, %healAmount)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.createRest(%duration, %healAmount);
    }
}
function serverCmdresuscitate(%client, %magnitude)
{
    echo(%client, %client.describeSelf(), %partOfBody);
    if (isObject(%client.Player) && %client.isGM())
    {
        %client.Player.resuscitate(%magnitude);
    }
}
function serverCmdCreate_formation(%client, %formation_type)
{
    echo(%client, %client.describeSelf(), %formation_type);
    %client.Player.Create_formation_and_invite_all(%formation_type);
}
function serverCmdOrder_to_formation(%client, %order_type)
{
    echo(%client, %client.describeSelf(), %order_type);
    %client.Player.Order_to_formation(%order_type);
}
