# Not Just Another Reincarnation Of Inifile

We all know ini-files and how great they are at holding directives for application execution.

Powershell cmdlets and functions are equally great at their flexibility to pass them parameters to influence their functionality.
However, stretching that flexibility comes at a price: the string of parameter names and values become longer as the number of parameters increases.
If entered by hand, the number of typo's or mistakes increases too and for repeated execution, it  takes too much time to type.

There are several solutions to handle these problems, such as complete execution strings held in cmd-files but the easiest solution is keeping all parameters in an ini-file and passing its name to the program as an override for locally defined parameters or as the only parameter input.

Typically, the content of ini-files consists of one or more headers (called "sections") in square brackets, each one of them followed by one or more key=value pairs.
Powershell can read that content into a hashtable (usually called $ini), a section becomes a first level key in that hashtable, its key=value pairs become the value of the first level hashtable and are also a hashtable. So, to retrieve the value of a key under section, you specify $value = $ini.section.key.

Okay, the above is all basic.

This reincarnation of the ini-file implementation in PowerShell adds a couple of features.

* It addresses the fact that an ini-file is clear text and so can have its content revealed by any text editor. 2 different file extensions provide some protection by hiding the content, so it takes more time to unveil what is inside.
* True multilevel hashtable support: the usual "nosection" section is dropped and the section header is extended with a punctuation colon to separate hashtable levels: [level 1:level 2:level 3] etc.
* Comments are left out while reading the content of an ini-file because these comments are only useful while editing the file, they are not required during parameter interpretation.

These are the PowerShell cmdlets supplied:

1. Set-IniFile: reads, edits and optionally copies an existing ini-file. It's supposed to be used manually so it doesn't accept pipeline input. You get the option to save a clone if the target destination happens to be R/O. Source and target files containing equivalent content have the same file timestamps.

2. Get-IniFile: reads an existing ini-file and outputs a hashtable holding a mixture of any levels of sections (0 to as many as specified), keys and their values. Comments are left out by default but reappear using the -Comments switch. 
