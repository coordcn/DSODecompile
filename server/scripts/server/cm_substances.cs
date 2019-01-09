new SimGroup(SubstancesGroup)
{
    singleton substance(QuestWheatBig)
    {
        .ter2_id = 189;
        .terrainMaterialName = "QuestWheatBig";
        .tunnelFloorMaterialName = "TunnelFloorMaterial";
        .tunnelCeilingMaterialName = "TunnelCeilingMaterial";
        .tunnelWallMaterialName = "TunnelWallsMaterial";
        .quantity_k = 1;
        .maxHeightDiffBeforeFall = 4;
        .canBeDigged = 0;
        .canBeShaped = 1;
        .diggedObjectID = 1558;
        .droppedObjectID = 1558;
        .footstepsType = "soil";
        .WalkSpeedMultiplier = 1;
        .HorseSpeedMultiplier = 1;
        .WheelSpeedMultiplier = 0.85;
        .SledgeSpeedMultuplier = 0.2;
    };
};

