# getUserCommandInfo
     Check user commands in /usr/bin, and show information about packages that include these commands.

### Synopsis:
>    `getUCI.sh` [*-console*] [*filename*]

### Description:
>    Script searchs the named command <*`filename`*> in /user/bin and all other command that begin with <*`filename`*>, and it shows all packages that have included those commands.


> - ![Script Detail](https://github.com/nestorock/Bash-Scripts/blob/master/images/script-getUCI_001.jpg)


### Options:
>    `-console`: Show output detail to terminal. If this option is not set then output detail will be showed into a dialog using [xmessage](https://linux.die.net/man/1/xmessage) command.

 
### Ouput:
>    Script shows three list: `PACKAGES`, `COMMANDS (order by commands)`, `COMMANDS (order by packages)`.

- #### `PACKAGES`
>      Packages list that has included commands installed in /usr/bin.

> - ![PACKAGES list](https://github.com/nestorock/Bash-Scripts/blob/master/images/script-getUCI_002.jpg)

- #### `COMMANDS (order by commands)`
>      User's commands list installed in /usr/bin with its package owner, order by commands.

> - ![COMMANDS list (order by commands)](https://github.com/nestorock/Bash-Scripts/blob/master/images/script-getUCI_003.jpg)

- #### `COMMANDS (order by packages)`
>      User's commands list installed in /usr/bin with its package owner, order by packages.

> - ![COMMANDS list (order by packages)](https://github.com/nestorock/Bash-Scripts/blob/master/images/script-getUCI_004.jpg)
