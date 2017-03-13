# tcsh-completion

**tcsh-completion** provides completion of sub-commands for the tcsh shell.
It does this for commands such as *git*, *npm*, *docker*, and many more.

For example it allows you to do:
```
git chec<tab>
```
and will complete to
```
git checkout
```
or even
```
git checkout <tab>
```
and will provide a list of all available branches to checkout.

## Installation

You must be using **tcsh** as your shell.

### To try it in the current shell
With npm (although this is not a node or Javascript project):
```
git clone https://github.com/marckhouzam/tcsh-completion.git
cd tcsh-completion
npm install
source ${HOME}/.tcsh-completion.tcsh
```

Without npm:
```
git clone https://github.com/marckhouzam/tcsh-completion.git
cd tcsh-completion
./setup-tcsh-completion.bash
source ${HOME}/.tcsh-completion.tcsh
```
### To set it up for any new shell
First perform the steps above to setup the completion commands.
Then, if not added already, add a line to your *.tcshrc* or *.cshrc* file
to source the generated *${HOME}/.tcsh-completion.tcsh* file.

You should then be able to perform completion of sub-commands for many of your favorite tools.

## Details

**tcsh-completion** setups a tcsh *complete* command for each available bash completion script, and delegates to the bash script to actually perform the completion; it then redirects the result to tcsh.

**tcsh-completion** currenlty looks for bash completion scripts in */usr/share/bash-completion/completions* as well as in *extra-scripts.txt* which can be found and modified by the user in the **tcsh-completion** git repository location.

## License

MIT

## Troubleshooting

If completion does not work at all for some commands, e.g. *git*, you can see if the tcsh *complete* command was properly setup for the command in question.  For example run:
```
complete git
```
and you should see something like (where the paths may vary slightly):
```
'p,*,`bash ${HOME}/git/tcsh-completion/tcsh-completion.bash __git_wrap__git_main /usr/share/bash-completion/completions/gitk "${COMMAND_LINE}"`,'
```
If you don't see such output, then re-do the installation steps above.
