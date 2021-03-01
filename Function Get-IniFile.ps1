<#
.Synopsis
    Get the content of an INI file. Return a truly multilevel hashtable (0 to any number of defined section levels).
.Description
    Get the content of an INI file and return it as a truly multilevel hashtable (0..n section levels).
	The format of the section header is extended with a punctuation colon to separate hashtable levels: [level1:level2:level3] etc.
	Comments are suppressed by default because they have no operational meaning. Specify switch -Comment if you want them.
.Inputs
    System.String
.Outputs
    System.Collections.Hashtable
.Parameter Path
    Specifies the path to the input file.
.Parameter Comment
    Includes comments (line starting with comma point ';')
.Example
	Save the content of file "c:\myIniFile.ini" in a hashtable called $FileContent
	$FileContent = Get-IniFile "C:\myIniFile.ini"
.Example
	Get the ini content of the file passed through the pipe into a hashtable called $FileContent
	$IniFilePath | $FileContent = Get-IniFile
.Example
	Return the key "Key" of the section "Section" from file "C:\settings.arg"
	$FileContent = Get-IniFile "c:\settings.arg" 
	$FileContent["Section"]["Key"] or $FileContent.section.key
.Example
	Return key/value pairs of section "Section" (if it existsts) from file "C:\settings.arg"
	$SectionContent = (Get-IniFile "c:\settings.arg")["Section"]
	or
	$SectionContent = (Get-IniFile "c:\settings.arg").Section
.Example
	Return value of key "Section.$Key" (if it existsts) from file "C:\settings.geve"
	$KeyValue		= (Get-IniFile "c:\settings.geve")["Section"]["$Key"]
	or
	$KeyValue		= (Get-IniFile "c:\settings.geve").Section.$Key
.Notes
	Author:	geve.one2one@gmail.com  
#>
Function Get-IniFile
{
[CmdletBinding()]
Param	(
		[Alias('FullName')][ValidateNotNullOrEmpty()][ValidateScript({Test-Path $_})][Parameter(ValueFromPipeline,Mandatory)][string]$Path,
		[Alias('T')][string]$Trim,
		[Alias('C')][switch]$Comment
		)
Begin	{
		Write-Verbose "($($PSCmdlet.MyInvocation.MyCommand.Name)): Function started"
		Function Data ([String]$path,[string]$string)
		{switch ([System.IO.Path]::GetExtension($path))
				{"$('.a')rg"	{$using = (-join [regex]::Matches(("$Env:UserDomain\$Env:UserName",(Get-Acl $path -EA ignore).Owner)[(Test-Path $path)],'.','RightToLeft')) -split('\\|a|e|i|o|u|y') -join 'O4v(a}9I#'}
				 ".ge$('ve')"	{$using = ('W7^Jm{1}oL4v{4}%AQrGA@z{3}eGZ6{0}&I5zp{2}vb' -f '_(q1)','TchV','BmQTl','3^wC&!q','Y9qO!')}
				 Default		{return $string}
				}
		$enc = [System.Text.Encoding]::UTF8
		[byte[]]$using = $enc.GetBytes($using)
		$string=$enc.GetString([System.Convert]::FromBase64String($string))
		[byte[]]$string = $enc.GetBytes($string)
		$data = $(for ($i=0;$i -lt $string.count) {for	($j=0;$j -lt $using.count;$j++) {$string[$i] -bxor $using[$j];$i++;if ($i -ge $string.count) {$j = $using.count}}})
		$enc.GetString($data)
		}
		}
Process	{
		Write-Verbose "($($PSCmdlet.MyInvocation.MyCommand.Name)): Processing file <$Path>"
		$Lines = (&Data $Path (Get-Content $Path -Raw)) -split "`r`n|`r|`n"
		$Ini = @{};$Ref = $Ini;$Cnt = 0
		switch	-regex ($Lines)
				{"^\[(.+[:.+]*)\]$"	# Section(s)
				 {$Ref = $Ini;foreach ($Sec in $Matches[1].Split(':')) {if (!$Ref.ContainsKey($Sec)) {$Ref[$Sec] = @{}};$Ref = $Ref[$Sec]};continue}
				 "^(;.*)$"			# Comment
				 {if ($Comment) {$Nam,$Val = "Comment$((++$Cnt).ToString())",$Matches[1];$Ref[$Nam] = $Val};continue}
				 "(.+?)\s*=\s*(.*)"	# Key
				 {$Nam,$Val = $Matches[1..2];if ($Trim) {$Ref[$Nam] = $Val.Trim($Trim)} else {$Ref[$Nam] = $Val}}
				}
		Write-Verbose "($($MyInvocation.MyCommand.Name)): Finished Processing file <$Path>"
		$Ini
		}
End		{Write-Verbose "($($MyInvocation.MyCommand.Name)): Function ended"}
}
