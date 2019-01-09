for %%i in (apple birch elm fir pine maple mulberry oak willow) do (
	rem xcopy defaulttree tree%%i /S
	rem xcopy tree%%i tree%%i%mid /S
	rem xcopy tree%%i tree%%i%big /S
)
