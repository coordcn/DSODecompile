datablock RangedWeaponData(BaseBow)
{
    .local = 1;
    .stateName[0] = "Ready";
    .stateTransitionOnTriggerDown[0] = "AmmoCheck";
    .stateScript[0] = "onRangedImageReady";
    .stateName[1] = "PreFire";
    .stateFireSubState[1] = PreFire;
    .stateTransitionOnTimeout[1] = "PreFire_onTimeout";
    .stateTransitionOnTriggerUp[1] = "Fire";
    .stateTransitionOnAltTriggerDown[1] = "FireCancel";
    .stateWaitForTimeout[1] = 0;
    .stateAllowImageChange[1] = 0;
    .stateSequence[1] = "Prefire";
    .stateDirection[1] = 1;
    .stateFreezeAnimation[1] = 0;
    .stateScript[1] = "onRangedImagePrefire";
    .stateName[2] = "PreFire_onTimeout";
    .stateFireSubState[2] = PreFire;
    .stateTransitionOnTriggerUp[2] = "Fire";
    .stateTransitionOnAltTriggerDown[2] = "FireCancel";
    .stateAllowImageChange[2] = 0;
    .stateSequence[2] = "Prefire";
    .stateDirection[2] = 0;
    .stateFreezeAnimation[2] = 1;
    .stateName[3] = "PreFire_onTrigerUp";
    .stateFireSubState[3] = PreFire;
    .stateTransitionOnTimeout[3] = "Fire";
    .stateTransitionOnAltTriggerDown[3] = "FireCancel";
    .stateWaitForTimeout[3] = 0;
    .stateAllowImageChange[3] = 0;
    .stateName[4] = "FireCancel";
    .stateTransitionOnTimeout[4] = "PostFireWait";
    .stateAllowImageChange[4] = 0;
    .stateScript[4] = "onRangedImageFireCancel";
    .stateName[5] = "Fire";
    .stateFireSubState[5] = Fire;
    .stateFire[5] = 1;
    .stateTransitionOnTimeout[5] = "PostFire";
    .stateTransitionOnAltTriggerDown[5] = "FireCancelRecoil";
    .stateWaitForTimeout[5] = 0;
    .stateAllowImageChange[5] = 0;
    .stateScript[5] = "onRangedImageFire";
    .stateName[6] = "FireCancelRecoil";
    .stateTransitionOnTimeout[6] = "PostFire";
    .stateAllowImageChange[6] = 0;
    .stateScript[6] = "onRangedImageFireCancel";
    .stateName[7] = "PostFire";
    .stateFireSubState[7] = Recoil;
    .stateTransitionOnTimeout[7] = "PostFireWait";
    .stateAllowImageChange[7] = 0;
    .stateName[8] = "PostFireWait";
    .stateFireSubState[8] = PostFire;
    .stateTimeoutValue[8] = 0;
    .stateTransitionOnTimeout[8] = "PostFireWaitForTriggerUp";
    .stateAllowImageChange[8] = 0;
    .stateName[9] = "PostFireWaitForTriggerUp";
    .stateTransitionOnTriggerUp[9] = "PostFireWaitForAltTriggerUp";
    .stateAllowImageChange[9] = 0;
    .stateName[10] = "PostFireWaitForAltTriggerUp";
    .stateTransitionOnAltTriggerUp[10] = "Ready";
    .stateAllowImageChange[10] = 0;
    .stateName[11] = "Draw";
    .stateFireSubState[11] = Draw;
    .stateTransitionOnTimeout[11] = "Ready";
    .stateWaitForTimeout[11] = 1;
    .stateAllowImageChange[11] = 0;
    .stateScript[11] = "onRangedImageDraw";
    .stateName[12] = "Attach";
    .stateFireSubState[12] = Attached;
    .stateAllowImageChange[12] = 1;
    .stateScript[12] = "onRangedImageInactive";
    .stateName[13] = "BlockingReady";
    .stateFireSubState[13] = Blocking;
    .stateAllowImageChange[13] = 0;
    .stateName[14] = "BlockedHit";
    .stateFireSubState[14] = BlockedHit;
    .stateTransitionOnTimeout[14] = "BlockingReady";
    .stateWaitForTimeout[14] = 1;
    .stateAllowImageChange[14] = 0;
    .stateName[16] = "AmmoCheck";
    .stateFireSubState[16] = AmmoCheck;
    .stateTransitionOnTriggerUp[16] = "AmmoCheckFailTimeout";
    .stateWaitForTimeout[16] = 0;
    .stateName[17] = "AmmoCheckFailTimeout";
    .stateTransitionOnTimeout[17] = "Ready";
    .stateTimeoutValue[17] = 0.5;
};
datablock RangedWeaponData(CompositeBow : BaseBow)
{
    .id = 52;
    .Object_typeID = 603;
    .AgilityNeed = 40;
    .StrengthNeed = 30;
    .MaxAccuracy = 0.8;
    .Emax = 2.9;
    .BasePrefireAnimTime = 1.3;
    .BaseRecoilAnimTime = 1.2;
    .allowedAmmoIDs = "656 657 658 659 660 1339 1582";
    .DurabilityPerShot = 40;
    .StaminaRate = 20;
    .shapeFile = "art/models/3d-2d/weapons/bows/composite_bow_export_01.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .attackType = AttackBow;
    .weaponType = WeaponBow;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = "";
    .FractureMultiplier = "";
    .StunMultiplier = "";
    .correctMuzzleVector = 0;
};
datablock RangedWeaponData(SimpleBow : BaseBow)
{
    .id = 49;
    .Object_typeID = 600;
    .AgilityNeed = 10;
    .StrengthNeed = 10;
    .MaxAccuracy = 1.2;
    .Emax = 1.9;
    .BasePrefireAnimTime = 1.3;
    .BaseRecoilAnimTime = 1.2;
    .allowedAmmoIDs = "656 657 658 659 660 1339 1582";
    .DurabilityPerShot = 40;
    .StaminaRate = 20;
    .shapeFile = "art/models/3d-2d/weapons/bows/simple_bow_export_01.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .attackType = AttackBow;
    .weaponType = WeaponBow;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = "";
    .FractureMultiplier = "";
    .StunMultiplier = "";
    .correctMuzzleVector = 0;
};
datablock RangedWeaponData(ShortBow : BaseBow)
{
    .id = 50;
    .Object_typeID = 601;
    .AgilityNeed = 30;
    .StrengthNeed = 20;
    .MaxAccuracy = 0.9;
    .Emax = 2.3;
    .BasePrefireAnimTime = 1.1;
    .BaseRecoilAnimTime = 1.1;
    .allowedAmmoIDs = "656 657 658 659 660 1339 1582";
    .DurabilityPerShot = 20;
    .StaminaRate = 10;
    .shapeFile = "art/models/3d-2d/weapons/bows/short_bow_export_01.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .attackType = AttackBow;
    .weaponType = WeaponBow;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = "";
    .FractureMultiplier = "";
    .StunMultiplier = "";
    .correctMuzzleVector = 0;
};
datablock RangedWeaponData(LongBow : BaseBow)
{
    .id = 51;
    .Object_typeID = 602;
    .AgilityNeed = 50;
    .StrengthNeed = 40;
    .MaxAccuracy = 0.5;
    .Emax = 3.7;
    .BasePrefireAnimTime = 1.7;
    .BaseRecoilAnimTime = 1.3;
    .allowedAmmoIDs = "656 657 658 659 660 1339 1582";
    .DurabilityPerShot = 20;
    .StaminaRate = 30;
    .shapeFile = "art/models/3d-2d/weapons/bows/longbow_export_01.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .attackType = AttackBow;
    .weaponType = WeaponBow;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = "";
    .FractureMultiplier = "";
    .StunMultiplier = "";
    .correctMuzzleVector = 0;
};
datablock RangedWeaponData(BaseCrossbow)
{
    .local = 1;
    .stateName[0] = "Ready";
    .stateTransitionOnTriggerDown[0] = "AmmoCheck";
    .stateScript[0] = "onRangedImageReady";
    .stateName[1] = "PreFire";
    .stateFireSubState[1] = PreFire;
    .stateTransitionOnTimeout[1] = "PreFire_onTimeout";
    .stateTransitionOnTriggerUp[1] = "Fire";
    .stateTransitionOnAltTriggerDown[1] = "FireCancel";
    .stateWaitForTimeout[1] = 0;
    .stateAllowImageChange[1] = 0;
    .stateSequence[1] = "Reload";
    .stateDirection[1] = 1;
    .stateFreezeAnimation[1] = 0;
    .stateScript[1] = "onRangedImagePrefire";
    .stateName[2] = "PreFire_onTimeout";
    .stateFireSubState[2] = PreFire;
    .stateTransitionOnTriggerUp[2] = "Fire";
    .stateTransitionOnAltTriggerDown[2] = "FireCancel";
    .stateAllowImageChange[2] = 0;
    .stateSequence[2] = "Reload";
    .stateDirection[2] = 0;
    .stateFreezeAnimation[2] = 1;
    .stateName[3] = "PreFire_onTrigerUp";
    .stateFireSubState[3] = PreFire;
    .stateTransitionOnTimeout[3] = "Fire";
    .stateTransitionOnAltTriggerDown[3] = "FireCancel";
    .stateWaitForTimeout[3] = 0;
    .stateAllowImageChange[3] = 0;
    .stateName[4] = "FireCancel";
    .stateTransitionOnTimeout[4] = "PostFireWait";
    .stateAllowImageChange[4] = 0;
    .stateScript[4] = "onRangedImageFireCancel";
    .stateName[5] = "Fire";
    .stateFireSubState[5] = Fire;
    .stateFire[5] = 1;
    .stateTransitionOnTimeout[5] = "PostFire";
    .stateTransitionOnAltTriggerDown[5] = "FireCancelRecoil";
    .stateWaitForTimeout[5] = 0;
    .stateAllowImageChange[5] = 0;
    .stateScript[5] = "onRangedImageFire";
    .stateName[6] = "FireCancelRecoil";
    .stateTransitionOnTimeout[6] = "PostFire";
    .stateAllowImageChange[6] = 0;
    .stateScript[6] = "onRangedImageFireCancel";
    .stateName[7] = "PostFire";
    .stateFireSubState[7] = Recoil;
    .stateTransitionOnTimeout[7] = "Reload";
    .stateAllowImageChange[7] = 0;
    .stateName[8] = "PostFireWait";
    .stateFireSubState[8] = PostFire;
    .stateTimeoutValue[8] = 0;
    .stateTransitionOnTimeout[8] = "PostFireWaitForTriggerUp";
    .stateAllowImageChange[8] = 0;
    .stateName[9] = "PostFireWaitForTriggerUp";
    .stateTransitionOnTriggerUp[9] = "PostFireWaitForAltTriggerUp";
    .stateAllowImageChange[9] = 0;
    .stateName[10] = "PostFireWaitForAltTriggerUp";
    .stateTransitionOnAltTriggerUp[10] = "Ready";
    .stateAllowImageChange[10] = 0;
    .stateName[11] = "Draw";
    .stateFireSubState[11] = Draw;
    .stateTransitionOnTimeout[11] = "Reload";
    .stateWaitForTimeout[11] = 1;
    .stateAllowImageChange[11] = 0;
    .stateScript[11] = "onRangedImageDraw";
    .stateName[12] = "Attach";
    .stateFireSubState[12] = Attached;
    .stateAllowImageChange[12] = 1;
    .stateScript[12] = "onRangedImageInactive";
    .stateName[13] = "BlockingReady";
    .stateFireSubState[13] = Blocking;
    .stateAllowImageChange[13] = 0;
    .stateName[14] = "BlockedHit";
    .stateFireSubState[14] = BlockedHit;
    .stateTransitionOnTimeout[14] = "BlockingReady";
    .stateWaitForTimeout[14] = 1;
    .stateAllowImageChange[14] = 0;
    .stateName[15] = "Reload";
    .stateFireSubState[15] = Reload;
    .stateTransitionOnTimeout[15] = "Reloaded";
    .stateAllowImageChange[15] = 0;
    .stateName[16] = "AmmoCheck";
    .stateFireSubState[16] = AmmoCheck;
    .stateTransitionOnTriggerUp[16] = "AmmoCheckFailTimeout";
    .stateWaitForTimeout[16] = 0;
    .stateName[17] = "AmmoCheckFailTimeout";
    .stateTransitionOnTimeout[17] = "Ready";
    .stateTimeoutValue[17] = 0.5;
    .stateName[18] = "Reloaded";
    .stateTransitionOnTimeout[18] = "Ready";
    .stateAllowImageChange[18] = 0;
    .stateScript[18] = "onRangedImageReloaded";
};
datablock RangedWeaponData(LightCrossbow : BaseCrossbow)
{
    .id = 53;
    .Object_typeID = 604;
    .AgilityNeed = 10;
    .StrengthNeed = 15;
    .MaxAccuracy = 0.9;
    .Emax = 4.2;
    .BasePrefireAnimTime = 0.8;
    .BaseRecoilAnimTime = 1;
    .allowedAmmoIDs = "662 663 664 1340 1583";
    .DurabilityPerShot = 20;
    .StaminaRate = 25;
    .shapeFile = "art/models/3d-2d/weapons/crossbows/light_crossbow_export_01.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .attackType = AttackCrossbow;
    .weaponType = WeaponCrossbow;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = "";
    .FractureMultiplier = "";
    .StunMultiplier = "";
    .correctMuzzleVector = 0;
};
datablock RangedWeaponData(Arbalest : BaseCrossbow)
{
    .id = 54;
    .Object_typeID = 605;
    .AgilityNeed = 10;
    .StrengthNeed = 20;
    .MaxAccuracy = 0.8;
    .Emax = 4.9;
    .BasePrefireAnimTime = 0.8;
    .BaseRecoilAnimTime = 1.1;
    .allowedAmmoIDs = "662 663 664 1340 1583";
    .DurabilityPerShot = 20;
    .StaminaRate = 25;
    .shapeFile = "art/models/3d-2d/weapons/crossbows/arbalest_export_01.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .attackType = AttackCrossbow;
    .weaponType = WeaponCrossbow;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = "";
    .FractureMultiplier = "";
    .StunMultiplier = "";
    .correctMuzzleVector = 0;
};
datablock RangedWeaponData(HeavyCrossbow : BaseCrossbow)
{
    .id = 55;
    .Object_typeID = 606;
    .AgilityNeed = 10;
    .StrengthNeed = 40;
    .MaxAccuracy = 0.7;
    .Emax = 5.6;
    .BasePrefireAnimTime = 0.9;
    .BaseRecoilAnimTime = 1.3;
    .allowedAmmoIDs = "662 663 664 1340 1583";
    .DurabilityPerShot = 20;
    .StaminaRate = 50;
    .shapeFile = "art/models/3d-2d/weapons/crossbows/heavy_crossbow_export_01.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .attackType = AttackCrossbow;
    .weaponType = WeaponCrossbow;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = "";
    .FractureMultiplier = "";
    .StunMultiplier = "";
    .correctMuzzleVector = 0;
};
datablock RangedWeaponData(Sling)
{
    .id = 56;
    .Object_typeID = 607;
    .AgilityNeed = 10;
    .StrengthNeed = 10;
    .MaxAccuracy = 1.9;
    .Emax = 8;
    .BasePrefireAnimTime = 1;
    .BaseRecoilAnimTime = 0.8;
    .allowedAmmoIDs = 1096;
    .DurabilityPerShot = 20;
    .StaminaRate = 20;
    .shapeFile = "art/models/3d-2d/weapons/ammunition/sling_export_01.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .attackType = AttackSling;
    .weaponType = WeaponSling;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = "";
    .FractureMultiplier = "";
    .StunMultiplier = "";
    .correctMuzzleVector = 0;
    .stateName[0] = "Ready";
    .stateTransitionOnTriggerDown[0] = "AmmoCheck";
    .stateScript[0] = "onRangedImageReady";
    .stateName[1] = "PreFire";
    .stateFireSubState[1] = PreFire;
    .stateTransitionOnTimeout[1] = "PreFire_onTimeout";
    .stateTransitionOnTriggerUp[1] = "Fire";
    .stateTransitionOnAltTriggerDown[1] = "FireCancel";
    .stateWaitForTimeout[1] = 0;
    .stateAllowImageChange[1] = 0;
    .stateSequence[1] = "Sling_prefire";
    .stateScript[1] = "onRangedImagePrefire";
    .stateName[2] = "PreFire_onTimeout";
    .stateFireSubState[2] = PreFire;
    .stateTransitionOnTriggerUp[2] = "Fire";
    .stateTransitionOnAltTriggerDown[2] = "FireCancel";
    .stateAllowImageChange[2] = 0;
    .stateSequence[2] = "Sling_prefire";
    .stateName[3] = "PreFire_onTrigerUp";
    .stateFireSubState[3] = PreFire;
    .stateTransitionOnTimeout[3] = "Fire";
    .stateTransitionOnAltTriggerDown[3] = "FireCancel";
    .stateWaitForTimeout[3] = 0;
    .stateAllowImageChange[3] = 0;
    .stateName[4] = "FireCancel";
    .stateTransitionOnTimeout[4] = "PostFireWait";
    .stateAllowImageChange[4] = 0;
    .stateScript[4] = "onRangedImageFireCancel";
    .stateName[5] = "Fire";
    .stateFireSubState[5] = Fire;
    .stateFire[5] = 1;
    .stateTransitionOnTimeout[5] = "PostFire";
    .stateTransitionOnAltTriggerDown[5] = "FireCancelRecoil";
    .stateWaitForTimeout[5] = 0;
    .stateAllowImageChange[5] = 0;
    .stateScript[5] = "onRangedImageFire";
    .stateName[6] = "FireCancelRecoil";
    .stateTransitionOnTimeout[6] = "PostFire";
    .stateAllowImageChange[6] = 0;
    .stateScript[6] = "onRangedImageFireCancel";
    .stateName[7] = "PostFire";
    .stateFireSubState[7] = Recoil;
    .stateTransitionOnTimeout[7] = "PostFireWait";
    .stateAllowImageChange[7] = 0;
    .stateName[8] = "PostFireWait";
    .stateFireSubState[8] = PostFire;
    .stateTimeoutValue[8] = 0;
    .stateTransitionOnTimeout[8] = "PostFireWaitForTriggerUp";
    .stateAllowImageChange[8] = 0;
    .stateName[9] = "PostFireWaitForTriggerUp";
    .stateTransitionOnTriggerUp[9] = "PostFireWaitForAltTriggerUp";
    .stateAllowImageChange[9] = 0;
    .stateName[10] = "PostFireWaitForAltTriggerUp";
    .stateTransitionOnAltTriggerUp[10] = "Ready";
    .stateAllowImageChange[10] = 0;
    .stateName[11] = "Draw";
    .stateFireSubState[11] = Draw;
    .stateTransitionOnTimeout[11] = "Ready";
    .stateWaitForTimeout[11] = 1;
    .stateAllowImageChange[11] = 0;
    .stateScript[11] = "onRangedImageDraw";
    .stateName[12] = "Attach";
    .stateFireSubState[12] = Attached;
    .stateAllowImageChange[12] = 1;
    .stateScript[12] = "onRangedImageInactive";
    .stateName[13] = "BlockingReady";
    .stateFireSubState[13] = Blocking;
    .stateAllowImageChange[13] = 0;
    .stateName[14] = "BlockedHit";
    .stateFireSubState[14] = BlockedHit;
    .stateTransitionOnTimeout[14] = "BlockingReady";
    .stateWaitForTimeout[14] = 1;
    .stateAllowImageChange[14] = 0;
    .stateName[16] = "AmmoCheck";
    .stateFireSubState[16] = AmmoCheck;
    .stateTransitionOnTriggerUp[16] = "AmmoCheckFailTimeout";
    .stateWaitForTimeout[16] = 0;
    .stateName[17] = "AmmoCheckFailTimeout";
    .stateTransitionOnTimeout[17] = "Ready";
    .stateTimeoutValue[17] = 0.5;
};

