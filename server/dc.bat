echo off & color 0A
::ָ����ʼ�ļ���
set DIR="%cd%"
echo DIR=%DIR%

:: ���� /R ��ʾ��Ҫ�������ļ���,ȥ����ʾ���������ļ���
:: %%f ��һ������,�����ڵ�����,�����������ֻ����һ����ĸ���,ǰ�����%%
:: ��������ͨ���,����ָ����׺��,*.*��ʾ�����ļ�
for /R %DIR% %%f in (*.cs.dso) do ( 
	echo %%f
	.\ThinkTanksScriptDecompiler.exe %%f --dc
)
pause

