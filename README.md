# not-just-another-reincarnation-of-inifile

We all know ini-files and how great they are at holding directives for application execution.

Powershell cmdlets and functions are equally great at their flexibility to pass them parameters to influence their functionality.
However, stretching that flexibility comes at a price: the string of parameter names and values become longer as the number of parameters increases.
If entered by hand, the number of typo's or mistakes increases too and repeated execution takes too much time.

There are several solutions to handle these problems, such as complete execution strings held in cmd-files but the easiest solution is keeping all parameters in an ini-file and passing its name to the program as an override for locally defined parameters or as the only parameter input.

Typically, the content of ini-files consists of one or more headers (called "sections"), each one of them followed by one or more key=value pairs.
Powershell can read that content into a hashtable (usually called $ini), a section becomes a first level key in the hashtable, its key=value pairs become the value of the first level hashtable and are also a hashtable. So, to retrieve the value of a key under section, you specify $value = $ini.section.key. Still deeper levels of nesting can be achieved by combining a section with a key (such as "section:key") and use that as a section name.

Okay, the above is all basic.

This reincarnation of the ini-file implementation in PoweerShell adds some interesting features.

1. It addresses the fact that an ini-files is clear text and so can have its content revealed by any text editor. 2 different file extensions provide some protection by hiding the content, so it takes some more time to unveil what is inside.

2. Comments are left out while reading the content of an ini-file because these comments are only useful while editing the file, they are not required during parameter interpretation.
