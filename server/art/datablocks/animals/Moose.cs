datablock AnimalData(MooseData : DefaultPlayerData)
{
    .id = 144;
    .animalTypeId = 756;
    .footprintTexture = "art/Textures/AnimalFootprints/Moose_fs.png";
    .footprintTextureLinearSize = 0.5;
    .footprintGap = 1;
    .footprintTrackWidth = 0.5;
    .shapeFile = "art/models/3d/mobiles/wildanimals/moose.dts";
    .soundFilesPrefix = "moose";
    .behavior = "data/ai/cmAiMoose.xml";
    .boundingBox = "2.5 5 3.5";
    .runSurfaceAngle = 50;
    .maxHP = 300;
    .bodyRadius = 4.2;
    .rawCorpseObjectTypeID = 916;
    .skinnedCorpseObjectTypeID = 929;
    .WeaponData = "Moose_Hoof";
    .weaponWeight = 10;
    .powerHitStartingDistance = 1.7;
    .powerHitDamagingDistance = 1.8;
    .powerHitDamagingSector = 90;
    .powerHitMinSpeed = 20;
    .powerHitMaxSpeed = 30;
    .fastHitStartingDistance = 1.7;
    .fastHitDamagingDistance = 1.8;
    .fastHitDamagingSector = 90;
    .fastHitMinSpeed = 10;
    .fastHitMaxSpeed = 15;
    .walkAnimationSpeed = 0.95;
    .runAnimationSpeed = 0.52;
    .walkSpeed = 2;
    .runSpeed = 7.5;
    .animalType = "Peaceful";
};

