datablock FormationDrawData(NullFormationDrawData)
{
    .local = 1;
    .formationType = 0;
    .basicTexture = "";
    .maxSkillTexture = "";
    .size = "0 0 0";
    .normalScale = "0 0 0";
    .mountedScale = "0 0 0";
};
datablock FormationDrawData(WallFormationDrawData)
{
    .local = 1;
    .formationType = 1;
    .basicTexture = "art/textures/Formations/wall_1.png";
    .maxSkillTexture = "art/textures/Formations/wall_100.png";
    .size = "22.5 10 1";
    .normalScale = "2.25 1.5 3.5";
    .mountedScale = "3 2.25 5";
    .mountedRenderOffset = "0 0 -0.32";
};
datablock FormationDrawData(WedgeFormationDrawData)
{
    .local = 1;
    .formationType = 2;
    .basicTexture = "art/textures/Formations/wedge_1.png";
    .maxSkillTexture = "art/textures/Formations/wedge_100.png";
    .size = "22.5 22.5 1";
    .normalScale = "1.5 1.5 3.5";
    .mountedScale = "3 3 5";
    .renderOffset = "0 0.15 0";
    .mountedRenderOffset = "0 0 -0.32";
};
datablock FormationDrawData(CircleFormationDrawData)
{
    .local = 1;
    .formationType = 3;
    .basicTexture = "art/textures/Formations/circle_1.png";
    .maxSkillTexture = "art/textures/Formations/circle_100.png";
    .size = "19 19 1";
    .normalScale = "1.5 1.5 3.5";
    .mountedScale = "3 3 5";
    .renderScale = 1.15;
    .mountedRenderOffset = "0 0 -0.32";
};

