singleton material(defaulttree_bark_material)
{
    .mapTo = "defaulttree_bark-material";
    .diffuseMap[0] = "art/shapes/trees/defaulttree/defaulttree_bark_diffuse.dds";
    .normalMap[0] = "art/shapes/trees/defaulttree/defaulttree_bark_normal_specular.dds";
    .specularMap[0] = "";
    .diffuseColor[0] = "1 1 1 1";
    .specular[0] = "0.9 0.9 0.9 1";
    .specularPower[0] = 10;
    .doubleSided = 0;
    .translucent = 0;
    .translucentBlendOp = "None";
    .pixelSpecular[0] = 1;
};
singleton material(defaulttree_material)
{
    .mapTo = "defaulttree-material";
    .diffuseMap[0] = "art/shapes/trees/defaulttree/defaulttree_diffuse_transparency.dds";
    .normalMap[0] = "art/shapes/trees/defaulttree/defaulttree_normal_specular.dds";
    .specularMap[0] = "";
    .diffuseColor[0] = "1 0.929412 0 1";
    .specular[0] = "0.9 0.9 0.9 1";
    .specularPower[0] = 10;
    .doubleSided = 0;
    .translucent = 0;
    .translucentBlendOp = "None";
    .pixelSpecular[0] = 1;
    .alphaTest = 1;
    .alphaRef = 127;
};
singleton material(defaulttree_fronds_material)
{
    .mapTo = "defaulttree_fronds-material";
    .diffuseMap[0] = "art/shapes/trees/defaulttree/defaulttree_frond_diffuse_transparency.dds";
    .normalMap[0] = "art/shapes/trees/defaulttree/defaulttree_frond_normal_specular.dds";
    .specular[0] = "0.9 0.9 0.9 1";
    .specularPower[0] = 10;
    .pixelSpecular[0] = 1;
    .translucentBlendOp = "None";
    .alphaTest = 1;
    .alphaRef = 114;
    .translucent = 1;
    .diffuseColor[0] = "1 0 0.0941177 1";
};
singleton material(defaulttree_ColorEffectR27G177B88_material)
{
    .mapTo = "ColorEffectR27G177B88-material";
    .diffuseMap[0] = "";
    .normalMap[0] = "";
    .specularMap[0] = "";
    .diffuseColor[0] = "0.105882 0.694118 0.345098 1";
    .specular[0] = "1 1 1 1";
    .specularPower[0] = 10;
    .doubleSided = 0;
    .translucent = 0;
    .translucentBlendOp = "None";
};

