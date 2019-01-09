datablock AnimalData(GrouseData : DefaultPlayerData)
{
    .id = 140;
    .animalTypeId = 762;
    .footprintTexture = "art/Textures/AnimalFootprints/Bird_fs.png";
    .footprintTextureLinearSize = 0.4;
    .footprintGap = 0.4;
    .footprintTrackWidth = 0.2;
    .shapeFile = "art/models/3d/mobiles/wildanimals/grouse.dts";
    .soundFilesPrefix = "grouse";
    .behavior = "data/ai/cmAiGrouse.xml";
    .boundingBox = "0.4 1 0.9";
    .runSurfaceAngle = 50;
    .maxHP = 15;
    .bodyRadius = 2.5;
    .rawCorpseObjectTypeID = 922;
    .skinnedCorpseObjectTypeID = 935;
    .walkAnimationSpeed = 4;
    .runAnimationSpeed = 2.57;
    .walkSpeed = 2;
    .runSpeed = 8;
    .animalType = "Passive";
};

