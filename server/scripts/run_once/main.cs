$runOnceFileList = new ArrayObject("")
{
};
%file = findFirstFile("./*.cs.dso");
while (!(%file $= ""))
{
    %filename = fileName(%file);
    if (!(%filename $= "main.cs.dso"))
    {
        $runOnceFileList.push_back(%file);
    }
    %file = findNextFile();
}
if ($runOnceFileList.count() <= 0)
{
    %file = findFirstFile("./*.cs");
    while (!(%file $= ""))
    {
        %filename = fileName(%file);
        if (!(%filename $= "main.cs"))
        {
            $runOnceFileList.push_back(%file);
        }
        %file = findNextFile();
    }
}
%i = 0;
while (%i < $runOnceFileList.count())
{
    %file = $runOnceFileList.getKey(%i);
    %doneFilePath = %file @ ".done";
    if (isFile(%doneFilePath))
    {
    }
    else
    {
        if (getSubStr(%file, strlen(%file) - 4) $= ".dso")
        {
            if (isFile(getSubStr(%file, 0, strlen(%file) - 4) @ ".cs.done"))
            {
            }
        }
        else
        {
            exec(%file);
            %fileObj = new FileObject("")
            {
            };
            %fileObj.openForWrite(%doneFilePath);
            %fileObj.close();
            %fileObj.delete();
            hack("RUN_ONCE:" SPC %file SPC "-" SPC %filename);
        }
    }
    %i = %i + 1;
}
$runOnceFileList.delete();
$runOnceFileList = 0;

