exec("art/forest/baseTreeDatablocks.cs");
new FamilyData(AppleFamilyData)
{
    .family = Apple;
    .naturalYoungTime = 50;
    .naturalMatureTime = 100;
    .playerPlantedYoungTime = 25;
    .playerPlantedMatureTime = 50;
    .isHardwood = 0;
};
new FamilyData(BirchFamilyData)
{
    .family = Birch;
    .naturalYoungTime = 40;
    .naturalMatureTime = 100;
    .playerPlantedYoungTime = 15;
    .playerPlantedMatureTime = 35;
    .isHardwood = 1;
};
new FamilyData(ElmFamilyData)
{
    .family = Elm;
    .naturalYoungTime = 80;
    .naturalMatureTime = 160;
    .playerPlantedYoungTime = 28;
    .playerPlantedMatureTime = 52;
    .isHardwood = 1;
};
new FamilyData(SpruceFamilyData)
{
    .family = Spruce;
    .naturalYoungTime = 40;
    .naturalMatureTime = 80;
    .playerPlantedYoungTime = 15;
    .playerPlantedMatureTime = 30;
    .isHardwood = 0;
};
new FamilyData(PineFamilyData)
{
    .family = Pine;
    .naturalYoungTime = 60;
    .naturalMatureTime = 100;
    .playerPlantedYoungTime = 20;
    .playerPlantedMatureTime = 33;
    .isHardwood = 0;
};
new FamilyData(MapleFamilyData)
{
    .family = Maple;
    .naturalYoungTime = 60;
    .naturalMatureTime = 95;
    .playerPlantedYoungTime = 20;
    .playerPlantedMatureTime = 30;
    .isHardwood = 1;
};
new FamilyData(MulberryFamilyData)
{
    .family = Mulberry;
    .naturalYoungTime = 60;
    .naturalMatureTime = 120;
    .playerPlantedYoungTime = 30;
    .playerPlantedMatureTime = 60;
    .isHardwood = 0;
};
new FamilyData(OakFamilyData)
{
    .family = Oak;
    .naturalYoungTime = 100;
    .naturalMatureTime = 180;
    .playerPlantedYoungTime = 35;
    .playerPlantedMatureTime = 60;
    .isHardwood = 1;
};
new FamilyData(AspenFamilyData)
{
    .family = Aspen;
    .naturalYoungTime = 60;
    .naturalMatureTime = 120;
    .playerPlantedYoungTime = 20;
    .playerPlantedMatureTime = 40;
    .isHardwood = 1;
};
new FamilyData(HazelFamilyData)
{
    .family = Hazel;
    .naturalYoungTime = 50;
    .naturalMatureTime = 100;
    .playerPlantedYoungTime = 15;
    .playerPlantedMatureTime = 30;
    .isHardwood = 0;
};
new FamilyData(JuniperFamilyData)
{
    .family = Juniper;
    .naturalYoungTime = 100;
    .naturalMatureTime = 200;
    .playerPlantedYoungTime = 100;
    .playerPlantedMatureTime = 200;
    .isHardwood = 0;
};
new FamilyData(SpinnyFamilyData)
{
    .family = Spinny;
    .naturalYoungTime = 110;
    .naturalMatureTime = 220;
    .playerPlantedYoungTime = 110;
    .playerPlantedMatureTime = 220;
    .isHardwood = 0;
};
new TSForestItemData(Natural_Apple_Ill_Minor : Apple_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Apple_Normal_Minor : Apple_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Apple_Great_Minor : Apple_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Apple_Stump_Minor : Apple_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Apple_Ill_Medium : Apple_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "644 1";
};
new TSForestItemData(Natural_Apple_Normal_Medium : Apple_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 50;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 6";
    .gatherables[2] = "1026 1";
    .gatherables[3] = "644 1";
};
new TSForestItemData(Natural_Apple_Great_Medium : Apple_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 6";
    .gatherables[2] = "1026 3";
    .gatherables[3] = "644 1";
};
new TSForestItemData(Natural_Apple_Stump_Medium : Apple_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 10;
};
new TSForestItemData(Natural_Apple_Ill_Major : Apple_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 3";
    .gatherables[2] = "644 1";
};
new TSForestItemData(Natural_Apple_Normal_Major : Apple_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 5";
    .gatherables[2] = "1026 3";
    .gatherables[3] = "644 1";
};
new TSForestItemData(Natural_Apple_Great_Major : Apple_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 200;
    .gatherables[0] = "236 8";
    .gatherables[1] = "237 10";
    .gatherables[2] = "1026 7";
    .gatherables[3] = "644 2";
};
new TSForestItemData(Natural_Apple_Stump_Major : Apple_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
};
new TSForestItemData(Natural_Birch_Ill_Minor : Birch_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Birch_Normal_Minor : Birch_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Birch_Great_Minor : Birch_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Birch_Stump_Minor : Birch_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Birch_Ill_Medium : Birch_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "645 1";
};
new TSForestItemData(Natural_Birch_Normal_Medium : Birch_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 50;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "645 1";
};
new TSForestItemData(Natural_Birch_Great_Medium : Birch_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 8";
    .gatherables[1] = "237 8";
    .gatherables[2] = "645 2";
};
new TSForestItemData(Natural_Birch_Stump_Medium : Birch_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
};
new TSForestItemData(Natural_Birch_Ill_Major : Birch_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 70;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "645 1";
};
new TSForestItemData(Natural_Birch_Normal_Major : Birch_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 160;
    .gatherables[0] = "236 4";
    .gatherables[1] = "237 7";
    .gatherables[2] = "645 1";
};
new TSForestItemData(Natural_Birch_Great_Major : Birch_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 320;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 14";
    .gatherables[2] = "645 4";
};
new TSForestItemData(Natural_Birch_Stump_Major : Birch_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Elm_Ill_Minor : Elm_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Elm_Normal_Minor : Elm_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Elm_Great_Minor : Elm_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Elm_Stump_Minor : Elm_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Elm_Ill_Medium : Elm_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 80;
    .gatherables[0] = "236 4";
    .gatherables[1] = "237 8";
    .gatherables[2] = "646 1";
};
new TSForestItemData(Natural_Elm_Normal_Medium : Elm_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 200;
    .gatherables[0] = "236 8";
    .gatherables[1] = "237 13";
    .gatherables[2] = "646 4";
};
new TSForestItemData(Natural_Elm_Great_Medium : Elm_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 400;
    .gatherables[0] = "236 12";
    .gatherables[1] = "237 16";
    .gatherables[2] = "646 4";
};
new TSForestItemData(Natural_Elm_Stump_Medium : Elm_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 80;
};
new TSForestItemData(Natural_Elm_Ill_Major : Elm_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 160;
    .gatherables[0] = "236 7";
    .gatherables[1] = "237 11";
    .gatherables[2] = "646 2";
};
new TSForestItemData(Natural_Elm_Normal_Major : Elm_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 400;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 16";
    .gatherables[2] = "646 2";
};
new TSForestItemData(Natural_Elm_Great_Major : Elm_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 800;
    .gatherables[0] = "236 16";
    .gatherables[1] = "237 20";
    .gatherables[2] = "646 8";
};
new TSForestItemData(Natural_Elm_Stump_Major : Elm_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 160;
};
new TSForestItemData(Natural_Fir_Ill_Minor : Fir_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Fir_Normal_Minor : Fir_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Fir_Great_Minor : Fir_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Fir_Stump_Minor : Fir_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Fir_Ill_Medium : Fir_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "647 1";
};
new TSForestItemData(Natural_Fir_Normal_Medium : Fir_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 50;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "647 1";
};
new TSForestItemData(Natural_Fir_Great_Medium : Fir_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 8";
    .gatherables[2] = "647 2";
};
new TSForestItemData(Natural_Fir_Stump_Medium : Fir_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
};
new TSForestItemData(Natural_Fir_Ill_Major : Fir_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 3";
    .gatherables[2] = "647 1";
};
new TSForestItemData(Natural_Fir_Normal_Major : Fir_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 7";
    .gatherables[2] = "647 2";
};
new TSForestItemData(Natural_Fir_Great_Major : Fir_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 200;
    .gatherables[0] = "236 8";
    .gatherables[1] = "237 12";
    .gatherables[2] = "647 4";
};
new TSForestItemData(Natural_Fir_Stump_Major : Fir_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
};
new TSForestItemData(Natural_Pine_Ill_Minor : Pine_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Pine_Normal_Minor : Pine_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Pine_Great_Minor : Pine_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Pine_Stump_Minor : Pine_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Pine_Ill_Medium : Pine_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 50;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "648 1";
};
new TSForestItemData(Natural_Pine_Normal_Medium : Pine_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 130;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 8";
    .gatherables[2] = "648 1";
};
new TSForestItemData(Natural_Pine_Great_Medium : Pine_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 250;
    .gatherables[0] = "236 13";
    .gatherables[1] = "237 12";
    .gatherables[2] = "648 2";
};
new TSForestItemData(Natural_Pine_Stump_Medium : Pine_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 50;
};
new TSForestItemData(Natural_Pine_Ill_Major : Pine_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 10";
    .gatherables[2] = "648 1";
};
new TSForestItemData(Natural_Pine_Normal_Major : Pine_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 250;
    .gatherables[0] = "236 12";
    .gatherables[1] = "237 13";
    .gatherables[2] = "648 2";
};
new TSForestItemData(Natural_Pine_Great_Major : Pine_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 500;
    .gatherables[0] = "236 20";
    .gatherables[1] = "237 20";
    .gatherables[2] = "648 5";
};
new TSForestItemData(Natural_Pine_Stump_Major : Pine_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
};
new TSForestItemData(Natural_Maple_Ill_Minor : Maple_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Maple_Normal_Minor : Maple_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Maple_Great_Minor : Maple_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Maple_Stump_Minor : Maple_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Maple_Ill_Medium : Maple_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 4";
    .gatherables[2] = "649 1";
};
new TSForestItemData(Natural_Maple_Normal_Medium : Maple_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 6";
    .gatherables[1] = "237 9";
    .gatherables[2] = "649 1";
};
new TSForestItemData(Natural_Maple_Great_Medium : Maple_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 200;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 16";
    .gatherables[2] = "649 3";
};
new TSForestItemData(Natural_Maple_Stump_Medium : Maple_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
};
new TSForestItemData(Natural_Maple_Ill_Major : Maple_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 7";
    .gatherables[2] = "649 1";
};
new TSForestItemData(Natural_Maple_Normal_Major : Maple_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 250;
    .gatherables[0] = "236 9";
    .gatherables[1] = "237 16";
    .gatherables[2] = "649 2";
};
new TSForestItemData(Natural_Maple_Great_Major : Maple_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 500;
    .gatherables[0] = "236 14";
    .gatherables[1] = "237 22";
    .gatherables[2] = "649 5";
};
new TSForestItemData(Natural_Maple_Stump_Major : Maple_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
};
new TSForestItemData(Natural_Mulberry_Ill_Minor : Mulberry_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Mulberry_Normal_Minor : Mulberry_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Mulberry_Great_Minor : Mulberry_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Mulberry_Stump_Minor : Mulberry_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Mulberry_Ill_Medium : Mulberry_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 10;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
    .gatherables[2] = "650 1";
};
new TSForestItemData(Natural_Mulberry_Normal_Medium : Mulberry_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 30;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "650 1";
};
new TSForestItemData(Natural_Mulberry_Great_Medium : Mulberry_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 50;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "650 1";
};
new TSForestItemData(Natural_Mulberry_Stump_Medium : Mulberry_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 10;
};
new TSForestItemData(Natural_Mulberry_Ill_Major : Mulberry_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
    .gatherables[0] = "236 2";
    .gatherables[1] = "650 1";
};
new TSForestItemData(Natural_Mulberry_Normal_Major : Mulberry_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 50;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "253 3";
    .gatherables[3] = "650 1";
};
new TSForestItemData(Natural_Mulberry_Great_Major : Mulberry_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 10";
    .gatherables[2] = "253 10";
    .gatherables[3] = "650 1";
};
new TSForestItemData(Natural_Mulberry_Stump_Major : Mulberry_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
};
new TSForestItemData(Natural_Oak_Ill_Minor : Oak_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Oak_Normal_Minor : Oak_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Oak_Great_Minor : Oak_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Oak_Stump_Minor : Oak_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Oak_Ill_Medium : Oak_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 120;
    .gatherables[0] = "236 4";
    .gatherables[1] = "237 8";
    .gatherables[2] = "651 2";
};
new TSForestItemData(Natural_Oak_Normal_Medium : Oak_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 300;
    .gatherables[0] = "236 9";
    .gatherables[1] = "237 14";
    .gatherables[2] = "651 3";
};
new TSForestItemData(Natural_Oak_Great_Medium : Oak_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 600;
    .gatherables[0] = "236 20";
    .gatherables[1] = "237 20";
    .gatherables[2] = "651 6";
};
new TSForestItemData(Natural_Oak_Stump_Medium : Oak_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 120;
};
new TSForestItemData(Natural_Oak_Ill_Major : Oak_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 240;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 12";
    .gatherables[2] = "651 3";
};
new TSForestItemData(Natural_Oak_Normal_Major : Oak_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 600;
    .gatherables[0] = "236 15";
    .gatherables[1] = "237 20";
    .gatherables[2] = "651 4";
};
new TSForestItemData(Natural_Oak_Great_Major : Oak_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 1200;
    .gatherables[0] = "236 30";
    .gatherables[1] = "237 28";
    .gatherables[2] = "651 8";
};
new TSForestItemData(Natural_Oak_Stump_Major : Oak_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 240;
};
new TSForestItemData(Natural_Aspen_Ill_Minor : Aspen_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Aspen_Normal_Minor : Aspen_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Aspen_Great_Minor : Aspen_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Aspen_Stump_Minor : Aspen_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Aspen_Ill_Medium : Aspen_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 4";
    .gatherables[2] = "652 1";
};
new TSForestItemData(Natural_Aspen_Normal_Medium : Aspen_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 100;
    .gatherables[0] = "236 4";
    .gatherables[1] = "237 7";
    .gatherables[2] = "652 2";
};
new TSForestItemData(Natural_Aspen_Great_Medium : Aspen_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 200;
    .gatherables[0] = "236 6";
    .gatherables[1] = "237 8";
    .gatherables[2] = "652 2";
};
new TSForestItemData(Natural_Aspen_Stump_Medium : Aspen_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
};
new TSForestItemData(Natural_Aspen_Ill_Major : Aspen_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 80;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "652 1";
};
new TSForestItemData(Natural_Aspen_Normal_Major : Aspen_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 200;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 8";
    .gatherables[2] = "652 2";
};
new TSForestItemData(Natural_Aspen_Great_Major : Aspen_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 400;
    .gatherables[0] = "236 9";
    .gatherables[1] = "237 11";
    .gatherables[2] = "652 4";
};
new TSForestItemData(Natural_Aspen_Stump_Major : Aspen_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 80;
};
new TSForestItemData(Natural_Hazel_Ill_Minor : Hazel_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Hazel_Normal_Minor : Hazel_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Hazel_Great_Minor : Hazel_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Hazel_Stump_Minor : Hazel_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Hazel_Ill_Medium : Hazel_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 10;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "1377 1";
};
new TSForestItemData(Natural_Hazel_Normal_Medium : Hazel_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 30;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 6";
    .gatherables[2] = "1396 3";
    .gatherables[3] = "1377 2";
};
new TSForestItemData(Natural_Hazel_Great_Medium : Hazel_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 8";
    .gatherables[2] = "1396 6";
    .gatherables[3] = "1377 2";
};
new TSForestItemData(Natural_Hazel_Stump_Medium : Hazel_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 10;
};
new TSForestItemData(Natural_Hazel_Ill_Major : Hazel_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 4";
    .gatherables[2] = "1377 1";
};
new TSForestItemData(Natural_Hazel_Normal_Major : Hazel_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 10";
    .gatherables[2] = "1396 10";
    .gatherables[3] = "1377 2";
};
new TSForestItemData(Natural_Hazel_Great_Major : Hazel_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 90;
    .gatherables[0] = "236 4";
    .gatherables[1] = "237 12";
    .gatherables[2] = "1396 16";
    .gatherables[3] = "1377 4";
};
new TSForestItemData(Natural_Hazel_Stump_Major : Hazel_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
};
new TSForestItemData(Natural_Juniper_Ill_Minor : Juniper_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Juniper_Normal_Minor : Juniper_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Juniper_Great_Minor : Juniper_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Juniper_Stump_Minor : Juniper_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Juniper_Ill_Medium : Juniper_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 10;
    .gatherables[0] = "237 ";
};
new TSForestItemData(Natural_Juniper_Normal_Medium : Juniper_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 30;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
    .gatherables[2] = "1378 1";
};
new TSForestItemData(Natural_Juniper_Great_Medium : Juniper_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
    .gatherables[2] = "1378 1";
};
new TSForestItemData(Natural_Juniper_Stump_Medium : Juniper_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 10;
};
new TSForestItemData(Natural_Juniper_Ill_Major : Juniper_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
    .gatherables[0] = "237 ";
    .gatherables[1] = "1378 1";
};
new TSForestItemData(Natural_Juniper_Normal_Major : Juniper_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 40;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
    .gatherables[2] = "1378 1";
};
new TSForestItemData(Natural_Juniper_Great_Major : Juniper_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 90;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 2";
    .gatherables[2] = "1378 1";
};
new TSForestItemData(Natural_Juniper_Stump_Major : Juniper_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 20;
};
new TSForestItemData(Natural_Spinny_Ill_Minor : Spinny_Ill_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Spinny_Normal_Minor : Spinny_Normal_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Spinny_Great_Minor : Spinny_Great_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Spinny_Stump_Minor : Spinny_Stump_Minor_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Spinny_Ill_Medium : Spinny_Ill_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(Natural_Spinny_Normal_Medium : Spinny_Normal_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(Natural_Spinny_Great_Medium : Spinny_Great_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(Natural_Spinny_Stump_Medium : Spinny_Stump_Medium_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(Natural_Spinny_Ill_Major : Spinny_Ill_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(Natural_Spinny_Normal_Major : Spinny_Normal_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(Natural_Spinny_Great_Major : Spinny_Great_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(Natural_Spinny_Stump_Major : Spinny_Stump_Major_Base)
{
    .plantedBy = Nature;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Apple_Ill_Minor : Apple_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Apple_Normal_Minor : Apple_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Apple_Great_Minor : Apple_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Apple_Stump_Minor : Apple_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Apple_Ill_Medium : Apple_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 20;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "644 1";
};
new TSForestItemData(PlayerMade_Apple_Normal_Medium : Apple_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 50;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 10";
    .gatherables[2] = "1026 2";
    .gatherables[3] = "644 1";
};
new TSForestItemData(PlayerMade_Apple_Great_Medium : Apple_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 10";
    .gatherables[2] = "1026 5";
    .gatherables[3] = "644 1";
};
new TSForestItemData(PlayerMade_Apple_Stump_Medium : Apple_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Apple_Ill_Major : Apple_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 3";
    .gatherables[2] = "644 1";
};
new TSForestItemData(PlayerMade_Apple_Normal_Major : Apple_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 5";
    .gatherables[2] = "1026 7";
    .gatherables[3] = "644 1";
};
new TSForestItemData(PlayerMade_Apple_Great_Major : Apple_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 200;
    .gatherables[0] = "236 8";
    .gatherables[1] = "237 10";
    .gatherables[2] = "1026 15";
    .gatherables[3] = "644 2";
};
new TSForestItemData(PlayerMade_Apple_Stump_Major : Apple_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Birch_Ill_Minor : Birch_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Birch_Normal_Minor : Birch_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Birch_Great_Minor : Birch_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Birch_Stump_Minor : Birch_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Birch_Ill_Medium : Birch_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 20;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "645 1";
};
new TSForestItemData(PlayerMade_Birch_Normal_Medium : Birch_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 50;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "645 1";
};
new TSForestItemData(PlayerMade_Birch_Great_Medium : Birch_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 8";
    .gatherables[1] = "237 8";
    .gatherables[2] = "645 2";
};
new TSForestItemData(PlayerMade_Birch_Stump_Medium : Birch_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Birch_Ill_Major : Birch_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 70;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "645 1";
};
new TSForestItemData(PlayerMade_Birch_Normal_Major : Birch_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 160;
    .gatherables[0] = "236 4";
    .gatherables[1] = "237 7";
    .gatherables[2] = "645 1";
};
new TSForestItemData(PlayerMade_Birch_Great_Major : Birch_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 320;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 14";
    .gatherables[2] = "645 4";
};
new TSForestItemData(PlayerMade_Birch_Stump_Major : Birch_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Elm_Ill_Minor : Elm_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Elm_Normal_Minor : Elm_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Elm_Great_Minor : Elm_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Elm_Stump_Minor : Elm_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Elm_Ill_Medium : Elm_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 80;
    .gatherables[0] = "236 4";
    .gatherables[1] = "237 8";
    .gatherables[2] = "646 1";
};
new TSForestItemData(PlayerMade_Elm_Normal_Medium : Elm_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 200;
    .gatherables[0] = "236 8";
    .gatherables[1] = "237 13";
    .gatherables[2] = "646 4";
};
new TSForestItemData(PlayerMade_Elm_Great_Medium : Elm_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 400;
    .gatherables[0] = "236 12";
    .gatherables[1] = "237 16";
    .gatherables[2] = "646 4";
};
new TSForestItemData(PlayerMade_Elm_Stump_Medium : Elm_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Elm_Ill_Major : Elm_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 160;
    .gatherables[0] = "236 7";
    .gatherables[1] = "237 11";
    .gatherables[2] = "646 2";
};
new TSForestItemData(PlayerMade_Elm_Normal_Major : Elm_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 400;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 16";
    .gatherables[2] = "646 2";
};
new TSForestItemData(PlayerMade_Elm_Great_Major : Elm_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 800;
    .gatherables[0] = "236 16";
    .gatherables[1] = "237 20";
    .gatherables[2] = "646 8";
};
new TSForestItemData(PlayerMade_Elm_Stump_Major : Elm_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Fir_Ill_Minor : Fir_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Fir_Normal_Minor : Fir_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Fir_Great_Minor : Fir_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Fir_Stump_Minor : Fir_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Fir_Ill_Medium : Fir_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 20;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "647 1";
};
new TSForestItemData(PlayerMade_Fir_Normal_Medium : Fir_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 50;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "647 1";
};
new TSForestItemData(PlayerMade_Fir_Great_Medium : Fir_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 8";
    .gatherables[2] = "647 2";
};
new TSForestItemData(PlayerMade_Fir_Stump_Medium : Fir_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Fir_Ill_Major : Fir_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 3";
    .gatherables[2] = "647 1";
};
new TSForestItemData(PlayerMade_Fir_Normal_Major : Fir_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 7";
    .gatherables[2] = "647 2";
};
new TSForestItemData(PlayerMade_Fir_Great_Major : Fir_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 200;
    .gatherables[0] = "236 8";
    .gatherables[1] = "237 12";
    .gatherables[2] = "647 4";
};
new TSForestItemData(PlayerMade_Fir_Stump_Major : Fir_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Pine_Ill_Minor : Pine_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Pine_Normal_Minor : Pine_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Pine_Great_Minor : Pine_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Pine_Stump_Minor : Pine_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Pine_Ill_Medium : Pine_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 50;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "648 1";
};
new TSForestItemData(PlayerMade_Pine_Normal_Medium : Pine_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 130;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 8";
    .gatherables[2] = "648 1";
};
new TSForestItemData(PlayerMade_Pine_Great_Medium : Pine_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 250;
    .gatherables[0] = "236 13";
    .gatherables[1] = "237 12";
    .gatherables[2] = "648 2";
};
new TSForestItemData(PlayerMade_Pine_Stump_Medium : Pine_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 50;
};
new TSForestItemData(PlayerMade_Pine_Ill_Major : Pine_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 10";
    .gatherables[2] = "648 1";
};
new TSForestItemData(PlayerMade_Pine_Normal_Major : Pine_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 250;
    .gatherables[0] = "236 12";
    .gatherables[1] = "237 13";
    .gatherables[2] = "648 2";
};
new TSForestItemData(PlayerMade_Pine_Great_Major : Pine_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 500;
    .gatherables[0] = "236 20";
    .gatherables[1] = "237 20";
    .gatherables[2] = "648 5";
};
new TSForestItemData(PlayerMade_Pine_Stump_Major : Pine_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
};
new TSForestItemData(PlayerMade_Maple_Ill_Minor : Maple_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Maple_Normal_Minor : Maple_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Maple_Great_Minor : Maple_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Maple_Stump_Minor : Maple_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Maple_Ill_Medium : Maple_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 4";
    .gatherables[2] = "649 1";
};
new TSForestItemData(PlayerMade_Maple_Normal_Medium : Maple_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 6";
    .gatherables[1] = "237 9";
    .gatherables[2] = "649 1";
};
new TSForestItemData(PlayerMade_Maple_Great_Medium : Maple_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 200;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 16";
    .gatherables[2] = "649 3";
};
new TSForestItemData(PlayerMade_Maple_Stump_Medium : Maple_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
};
new TSForestItemData(PlayerMade_Maple_Ill_Major : Maple_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 7";
    .gatherables[2] = "649 1";
};
new TSForestItemData(PlayerMade_Maple_Normal_Major : Maple_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 250;
    .gatherables[0] = "236 9";
    .gatherables[1] = "237 16";
    .gatherables[2] = "649 2";
};
new TSForestItemData(PlayerMade_Maple_Great_Major : Maple_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 500;
    .gatherables[0] = "236 14";
    .gatherables[1] = "237 22";
    .gatherables[2] = "649 5";
};
new TSForestItemData(PlayerMade_Maple_Stump_Major : Maple_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
};
new TSForestItemData(PlayerMade_Mulberry_Ill_Minor : Mulberry_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Mulberry_Normal_Minor : Mulberry_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Mulberry_Great_Minor : Mulberry_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Mulberry_Stump_Minor : Mulberry_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Mulberry_Ill_Medium : Mulberry_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 10;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
    .gatherables[2] = "650 1";
};
new TSForestItemData(PlayerMade_Mulberry_Normal_Medium : Mulberry_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 30;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "253 3";
    .gatherables[3] = "650 1";
};
new TSForestItemData(PlayerMade_Mulberry_Great_Medium : Mulberry_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 50;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "253 8";
    .gatherables[3] = "650 1";
};
new TSForestItemData(PlayerMade_Mulberry_Stump_Medium : Mulberry_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 10;
};
new TSForestItemData(PlayerMade_Mulberry_Ill_Major : Mulberry_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 20;
    .gatherables[0] = "236 2";
    .gatherables[1] = "650 1";
};
new TSForestItemData(PlayerMade_Mulberry_Normal_Major : Mulberry_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 50;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "253 6";
    .gatherables[3] = "650 1";
};
new TSForestItemData(PlayerMade_Mulberry_Great_Major : Mulberry_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 10";
    .gatherables[2] = "253 25";
    .gatherables[3] = "650 1";
};
new TSForestItemData(PlayerMade_Mulberry_Stump_Major : Mulberry_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 20;
};
new TSForestItemData(PlayerMade_Oak_Ill_Minor : Oak_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Oak_Normal_Minor : Oak_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Oak_Great_Minor : Oak_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Oak_Stump_Minor : Oak_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Oak_Ill_Medium : Oak_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 120;
    .gatherables[0] = "236 4";
    .gatherables[1] = "237 8";
    .gatherables[2] = "651 2";
};
new TSForestItemData(PlayerMade_Oak_Normal_Medium : Oak_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 300;
    .gatherables[0] = "236 9";
    .gatherables[1] = "237 14";
    .gatherables[2] = "651 3";
};
new TSForestItemData(PlayerMade_Oak_Great_Medium : Oak_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 600;
    .gatherables[0] = "236 20";
    .gatherables[1] = "237 20";
    .gatherables[2] = "651 6";
};
new TSForestItemData(PlayerMade_Oak_Stump_Medium : Oak_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 120;
};
new TSForestItemData(PlayerMade_Oak_Ill_Major : Oak_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 240;
    .gatherables[0] = "236 10";
    .gatherables[1] = "237 12";
    .gatherables[2] = "651 3";
};
new TSForestItemData(PlayerMade_Oak_Normal_Major : Oak_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 600;
    .gatherables[0] = "236 15";
    .gatherables[1] = "237 20";
    .gatherables[2] = "651 4";
};
new TSForestItemData(PlayerMade_Oak_Great_Major : Oak_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 1200;
    .gatherables[0] = "236 30";
    .gatherables[1] = "237 28";
    .gatherables[2] = "651 8";
};
new TSForestItemData(PlayerMade_Oak_Stump_Major : Oak_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 240;
};
new TSForestItemData(PlayerMade_Aspen_Ill_Minor : Aspen_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Aspen_Normal_Minor : Aspen_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Aspen_Great_Minor : Aspen_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Aspen_Stump_Minor : Aspen_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Aspen_Ill_Medium : Aspen_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 4";
    .gatherables[2] = "652 1";
};
new TSForestItemData(PlayerMade_Aspen_Normal_Medium : Aspen_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 100;
    .gatherables[0] = "236 4";
    .gatherables[1] = "237 7";
    .gatherables[2] = "652 2";
};
new TSForestItemData(PlayerMade_Aspen_Great_Medium : Aspen_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 200;
    .gatherables[0] = "236 6";
    .gatherables[1] = "237 8";
    .gatherables[2] = "652 2";
};
new TSForestItemData(PlayerMade_Aspen_Stump_Medium : Aspen_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
};
new TSForestItemData(PlayerMade_Aspen_Ill_Major : Aspen_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 80;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 5";
    .gatherables[2] = "652 1";
};
new TSForestItemData(PlayerMade_Aspen_Normal_Major : Aspen_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 200;
    .gatherables[0] = "236 5";
    .gatherables[1] = "237 8";
    .gatherables[2] = "652 2";
};
new TSForestItemData(PlayerMade_Aspen_Great_Major : Aspen_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 400;
    .gatherables[0] = "236 9";
    .gatherables[1] = "237 11";
    .gatherables[2] = "652 4";
};
new TSForestItemData(PlayerMade_Aspen_Stump_Major : Aspen_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 80;
};
new TSForestItemData(PlayerMade_Hazel_Ill_Minor : Hazel_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Hazel_Normal_Minor : Hazel_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Hazel_Great_Minor : Hazel_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Hazel_Stump_Minor : Hazel_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Hazel_Ill_Medium : Hazel_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 10;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 2";
    .gatherables[2] = "1377 1";
};
new TSForestItemData(PlayerMade_Hazel_Normal_Medium : Hazel_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 30;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 6";
    .gatherables[2] = "1396 8";
    .gatherables[3] = "1377 2";
};
new TSForestItemData(PlayerMade_Hazel_Great_Medium : Hazel_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 8";
    .gatherables[2] = "1396 12";
    .gatherables[3] = "1377 2";
};
new TSForestItemData(PlayerMade_Hazel_Stump_Medium : Hazel_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 10;
};
new TSForestItemData(PlayerMade_Hazel_Ill_Major : Hazel_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 20;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 4";
    .gatherables[2] = "1396 4";
    .gatherables[3] = "1377 1";
};
new TSForestItemData(PlayerMade_Hazel_Normal_Major : Hazel_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 10";
    .gatherables[2] = "1396 12";
    .gatherables[3] = "1377 2";
};
new TSForestItemData(PlayerMade_Hazel_Great_Major : Hazel_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 90;
    .gatherables[0] = "236 3";
    .gatherables[1] = "237 3";
    .gatherables[2] = "1396 20";
    .gatherables[3] = "1377 4";
};
new TSForestItemData(PlayerMade_Hazel_Stump_Major : Hazel_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 20;
};
new TSForestItemData(PlayerMade_Juniper_Ill_Minor : Juniper_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Juniper_Normal_Minor : Juniper_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Juniper_Great_Minor : Juniper_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Juniper_Stump_Minor : Juniper_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Juniper_Ill_Medium : Juniper_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 10;
    .gatherables[0] = "237 ";
};
new TSForestItemData(PlayerMade_Juniper_Normal_Medium : Juniper_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 30;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
    .gatherables[2] = "1378 1";
};
new TSForestItemData(PlayerMade_Juniper_Great_Medium : Juniper_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
    .gatherables[2] = "1378 1";
};
new TSForestItemData(PlayerMade_Juniper_Stump_Medium : Juniper_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 10;
};
new TSForestItemData(PlayerMade_Juniper_Ill_Major : Juniper_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 20;
    .gatherables[0] = "237 ";
    .gatherables[1] = "1378 1";
};
new TSForestItemData(PlayerMade_Juniper_Normal_Major : Juniper_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 40;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
    .gatherables[2] = "1378 1";
};
new TSForestItemData(PlayerMade_Juniper_Great_Major : Juniper_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 90;
    .gatherables[0] = "236 2";
    .gatherables[1] = "237 2";
    .gatherables[2] = "1378 1";
};
new TSForestItemData(PlayerMade_Juniper_Stump_Major : Juniper_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 20;
};
new TSForestItemData(PlayerMade_Spinny_Ill_Minor : Spinny_Ill_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Spinny_Normal_Minor : Spinny_Normal_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Spinny_Great_Minor : Spinny_Great_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Spinny_Stump_Minor : Spinny_Stump_Minor_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Spinny_Ill_Medium : Spinny_Ill_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(PlayerMade_Spinny_Normal_Medium : Spinny_Normal_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(PlayerMade_Spinny_Great_Medium : Spinny_Great_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(PlayerMade_Spinny_Stump_Medium : Spinny_Stump_Medium_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};
new TSForestItemData(PlayerMade_Spinny_Ill_Major : Spinny_Ill_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(PlayerMade_Spinny_Normal_Major : Spinny_Normal_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(PlayerMade_Spinny_Great_Major : Spinny_Great_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
    .gatherables[0] = "236 1";
    .gatherables[1] = "237 1";
};
new TSForestItemData(PlayerMade_Spinny_Stump_Major : Spinny_Stump_Major_Base)
{
    .plantedBy = Player;
    .woodAmount = 0;
};

