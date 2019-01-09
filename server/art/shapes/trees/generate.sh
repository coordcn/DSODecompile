#!/bin/sh
# Скрипт для генерации тестовых деревьев.

# for i in 1 2 3 4 5 6 7 8 9
for i in apple birch elm fir pine maple mulberry oak willow
do
	# cp -r defaulttree tree$i
	sed -i -e "s/defaulttree/tree$i/g" tree$i/{defaulttree.cs,defaulttree.DAE,materials.cs}
	a=tree$i/defaulttree
	b=tree$i/tree$i
	for j in .cs .DAE _bark_diffuse.dds _bark_normal_specular.dds _diffuse_transparency.dds _frond_diffuse_transparency.dds _frond_normal_specular.dds _normal_specular.dds
	do
		mv $a$j $b$j
	done
done
