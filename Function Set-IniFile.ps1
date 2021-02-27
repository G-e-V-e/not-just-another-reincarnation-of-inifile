<#
.Synopsis
    Convert the original file (containing valid .ini content) and write it to the target file.
.Description
    Get the original file path, convert content, optionally edit and finally output it to target path. Support -whatif.
	2 file extensions have a special meaning: one for local and another for cross-system obfuscation of the file content.
.Inputs
    System.String
.Outputs
    System.IO.FileInfo (if PassThru requested)
.Parameter Path
    Specifies the file path to the original data.
.Parameter Target
    Specifies the target path. If omitted, Path becomes Target and editing is implied. The target file extension defines its output format.
	A copy may be saved if the target file happens to be Read Only.
.Parameter Edit
    Allows editing the content before saving it.
.Parameter PassThru
    Output System.IO.FileItem object.
.Example
    Convert the contents of file "C:\ProjectX\myIniFile.ini" into a file called "C:\ProjectX\myIniFile.arg" and pass the file item information to output 
	$ArgFullName = (Set-IniFile -Path "C:\ProjectX\myIniFile.ini" -Target "C:\ProjectX\myIniFile.arg" -Passthru).FullName
.Example
    Edit and save file "C:\ProjectX\myIniFile.geve".
	Set-IniFile "C:\ProjectX\myIniFile.geve"
.Notes
	Author:	geve.one2one@gmail.com  
#>
Function Set-IniFile
{
[CmdletBinding(SupportsShouldProcess=$true)]
Param	(
		[Alias('FullName')][Parameter(Position=0)][String]$Path,
		[Alias('T')][Parameter(Position=1)][string]$Target,
		[Alias('E')][Parameter(Position=2)][switch]$Edit,
		[Alias('P')][Parameter(Position=3)][switch]$PassThru
		)
Begin	{
		Write-Verbose "($($PSCmdlet.MyInvocation.MyCommand.Name)): Function started"
		Function Data ([String]$path,[string]$string,[String]$action)
		{switch ([System.IO.Path]::GetExtension($Path))
				{"$('.a')rg"	{$using = (-join [regex]::Matches(("$Env:UserDomain\$Env:UserName",(Get-Acl $Path -EA ignore).Owner)[(Test-Path $Path)],'.','RightToLeft')) -split('\\|a|e|i|o|u|y') -join 'O4v(a}9I#'}
				 ".ge$('ve')"	{$using = ('W7^Jm{1}oL4v{4}%AQrGA@z{3}eGZ6{0}&I5zp{2}vb' -f '_(q1)','TchV','BmQTl','3^wC&!q','Y9qO!')}
				 Default		{return $string}
				}
		$enc = [System.Text.Encoding]::UTF8
		[byte[]]$using = $enc.GetBytes($using)
		if ($action -ne 'x') {$string=$enc.GetString([System.Convert]::FromBase64String($string))}
		[byte[]]$string = $enc.GetBytes($string)
		$data = $(for ($i=0;$i -lt $string.count) {for	($j=0;$j -lt $using.count;$j++) {$string[$i] -bxor $using[$j];$i++;if ($i -ge $string.count) {$j = $using.count}}})
		if ($action -ne 'x') {$enc.GetString($data)} else {[System.Convert]::ToBase64String($data)}
		}
		Function Test-WriteAccess ([String]$Path)
		{try {[System.io.file]::OpenWrite($Path).close();$true} catch {$false}
		}
		Add-Type -AssemblyName 'System.Windows.Forms'
		}
Process	{
		Write-Verbose "($($PSCmdlet.MyInvocation.MyCommand.Name)): Processing file <$Path>"
		
		if		(!$Path)
				{# Get $Path
				$OpenFileDialog = New-Object 'System.Windows.Forms.OpenFileDialog'
				$OpenFileDialog.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory()
				$OpenFileDialog.Title = "Select file path..."
				$OpenFileDialog.Filter = "INI type files|*.a$('rg');*.$('g')eve;*$('.in')i|All files (*.*)| *.*"
				$OpenFileDialog.ShowHelp = $true
				$result = $OpenFileDialog.ShowDialog()
				if		($result -eq "OK")
						{$Path = $OpenFileDialog.FileName;$OpenFileDialog.Dispose()}
				else	{Throw "Select file path dialog terminated on user request."}
				}
		if		(!(Test-Path -Path $Path))		{Throw	"File path <$Path> does not exist."}
		if		(!$Target)						{$Target = $Path}
		if		($Target -eq $Path)				{$Edit = $true}
		$PathItem = Get-Item $Path
		$TmpPath = "$Env:Tmp\$($PathItem.BaseName).ini"
		&Data $Path (Get-Content $Path -Raw) | Out-File -FilePath $TmpPath
		$TmpItem = Get-Item $TmpPath
		$TmpItem.LastWriteTime = $PathItem.LastWriteTime
		
		$changed = $false
		if		($Edit -and ([Environment]::UserInteractive))
				{
				$Process = Start-Process 'Notepad.exe' -ArgumentList $TmpPath -UseNewEnvironment -PassThru
				$Process.WaitForExit()
				if		($TmpItem.LastWriteTime -ne $PathItem.LastWriteTime)
						{$TmpData = (Get-Content $TmpPath -raw);$changed = $true}
				}
		while	($changed -and !(Test-WriteAccess $Target))
				{
				$SaveFileDialog = New-Object 'windows.forms.savefiledialog'
				$SaveFileDialog.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory()
				$SaveFileDialog.title = "No write access to $Target, save file as a local copy?"
				$SaveFileDialog.filter = "INI type files|*.a$('rg');*.$('g')eve;*.in$('i')|All Files|*.*"
				$SaveFileDialog.ShowHelp = $true
				$result = $SaveFileDialog.ShowDialog()
				if		($result -eq "OK")
						{$Target = $SaveFileDialog.FileName;$SaveFileDialog.Dispose()}
				else	{Throw "No write access to target file <$Target>."}
				}
		if		($changed -or ($Target -ne $Path))
				{
				if		($pscmdlet.ShouldProcess($Target,'Out-File'))
						{&Data $Target (Get-Content $TmpPath -Raw) x | Out-File -FilePath $Target}
				}
		$TargetItem = Get-Item $Target
		if		(!$changed -and ($Target -ne $Path))
				{
				if		($pscmdlet.ShouldProcess($Target,'Synchronize file times'))
						{
						$TargetItem.CreationTime = $PathItem.CreationTime
						$TargetItem.LastWriteTime = $PathItem.LastWriteTime
						$TargetItem.LastAccessTime = $PathItem.LastAccessTime
						}
				}
		Remove-Item $TmpPath
		Write-Verbose "($($MyInvocation.MyCommand.Name)): Finished Processing file <$Path>"
		if		($PassThru)	{$TargetItem}
		}
End		{Write-Verbose "($($PSCmdlet.MyInvocation.MyCommand.Name)): Function ended"}
}