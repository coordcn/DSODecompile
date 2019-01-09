datablock AnimalData(WolfData : DefaultPlayerData)
{
    .id = 143;
    .animalTypeId = 755;
    .footprintTexture = "art/Textures/AnimalFootprints/Wolf_fs.png";
    .footprintTextureLinearSize = 0.4;
    .footprintGap = 0.6;
    .footprintTrackWidth = 0.4;
    .shapeFile = "art/models/3d/mobiles/wildanimals/wolf.dts";
    .soundFilesPrefix = "wolf";
    .behavior = "data/ai/cmAiWolf.xml";
    .boundingBox = "1 2.4 1.8";
    .runSurfaceAngle = 50;
    .maxHP = 150;
    .bodyRadius = 2.5;
    .rawCorpseObjectTypeID = 915;
    .skinnedCorpseObjectTypeID = 928;
    .WeaponData = "Wolf_Fang";
    .weaponWeight = 10;
    .powerHitStartingDistance = 1.2;
    .powerHitDamagingDistance = 1.4;
    .powerHitDamagingSector = 90;
    .powerHitMinSpeed = 15;
    .powerHitMaxSpeed = 25;
    .fastHitStartingDistance = 1.2;
    .fastHitDamagingDistance = 1.4;
    .fastHitDamagingSector = 90;
    .fastHitMinSpeed = 5;
    .fastHitMaxSpeed = 10;
    .walkAnimationSpeed = 1.72;
    .runAnimationSpeed = 1.21;
    .walkSpeed = 2;
    .runSpeed = 8;
    .animalType = "Predator";
};

