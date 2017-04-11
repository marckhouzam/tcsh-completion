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

### On Linux

**tcsh-completion** uses the existing bash completion scripts available on the system.
As long as these scripts are already available at */usr/share/bash-completion/bash_completion*,
you can jump directly to the section below.  The scripts should be present at least on an Ubuntu
system.  If they are not present, you must install them there somehow.

### On Mac

**tcsh-completion** uses the existing bash completion scripts available on the system.
These scripts are not installed by default.  To install them using Homebrew you can do:
```
brew install bash-completion
```

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

Should you need to refresh the set of completions, for example after installing a new tool,
you can run the alias **completion-refresh**.  Note that this will only refresh the completion
list on the shell where you ran the alias.

## Details

**tcsh-completion** setups a tcsh *complete* command for each available bash completion script, and delegates to the bash script to actually perform the completion; it then redirects the result to tcsh.

**tcsh-completion** currenlty looks for bash completion scripts in */usr/share/bash-completion/completions* as well as in *extra-scripts.txt* which can be found and modified by the user in the **tcsh-completion** git repository location.

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

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
