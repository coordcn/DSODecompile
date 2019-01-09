datablock ShapeBaseImageData(SwordImage)
{
    .id = 605;
    .shapeFile = "art/shapes/weapons/grossmesser/messer.dts";
    .emap = 1;
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .attacksType = 0;
    .hitGroupType[0] = Slashing;
    .hitGroupType[1] = Piercing;
    .hitDirection[0] = 1;
    .hitDirection[1] = 0;
    .hitDirection[2] = 0;
    .hitDirection[3] = 0;
    .correctMuzzleVector = 0;
    .className = "WeaponImage";
    .item = SwordWeapon;
    .stateName[0] = "Ready";
    .stateTransitionOnTriggerDown[0] = "PreFire";
    .stateName[1] = "PreFire";
    .stateFireSubState[1] = PreFire;
    .stateTransitionOnTimeout[1] = "PreFire_onTimeout";
    .stateTransitionOnTriggerUp[1] = "PreFire_onTrigerUp";
    .stateTransitionOnAltTriggerDown[1] = "FireCancel";
    .stateWaitForTimeout[1] = 0;
    .stateAllowImageChange[1] = 0;
    .stateScript[1] = "onImagePrefire";
    .stateName[2] = "PreFire_onTimeout";
    .stateFireSubState[2] = PreFire;
    .stateTransitionOnTriggerUp[2] = "Fire";
    .stateTransitionOnAltTriggerDown[2] = "FireCancel";
    .stateAllowImageChange[2] = 0;
    .stateName[3] = "PreFire_onTrigerUp";
    .stateFireSubState[3] = PreFire;
    .stateTransitionOnTimeout[3] = "Fire";
    .stateTransitionOnAltTriggerDown[3] = "FireCancel";
    .stateWaitForTimeout[3] = 0;
    .stateAllowImageChange[3] = 0;
    .stateName[4] = "FireCancel";
    .stateTransitionOnTimeout[4] = "PostFireWait";
    .stateAllowImageChange[4] = 0;
    .stateScript[4] = "onImageFireCancel";
    .stateName[5] = "Fire";
    .stateFireSubState[5] = Fire;
    .stateFire[5] = 1;
    .stateTransitionOnTimeout[5] = "PostFire";
    .stateTransitionOnAltTriggerDown[5] = "FireCancelRecoil";
    .stateWaitForTimeout[5] = 0;
    .stateAllowImageChange[5] = 0;
    .stateScript[5] = "onImageFire";
    .stateName[6] = "FireCancelRecoil";
    .stateTransitionOnTimeout[6] = "PostFire";
    .stateAllowImageChange[6] = 0;
    .stateScript[6] = "onImageFireCancel";
    .stateName[7] = "PostFire";
    .stateFireSubState[7] = Recoil;
    .stateTransitionOnTimeout[7] = "PostFireWait";
    .stateAllowImageChange[7] = 0;
    .stateName[8] = "PostFireWait";
    .stateFireSubState[8] = PostFire;
    .stateTimeoutValue[8] = 1;
    .stateTransitionOnTimeout[8] = "PostFireWaitForTriggerUp";
    .stateAllowImageChange[8] = 0;
    .stateName[9] = "PostFireWaitForTriggerUp";
    .stateTransitionOnTriggerUp[9] = "PostFireWaitForAltTriggerUp";
    .stateAllowImageChange[9] = 0;
    .stateName[10] = "PostFireWaitForAltTriggerUp";
    .stateTransitionOnAltTriggerUp[10] = "Ready";
    .stateAllowImageChange[10] = 0;
    .class = "WeaponImage";
};
