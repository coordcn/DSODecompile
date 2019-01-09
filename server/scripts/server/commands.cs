function serverCmdToggleWeaponSlot(%client, %slot)
{
    %client.getControlObject().toggleWeaponSlot(%slot);
}
function serverCmdUnmountWeapon(%client)
{
    %client.getControlObject().unmountAllImages();
}
