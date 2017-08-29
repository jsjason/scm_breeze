**This repo adds a hacky shell implementation for `git branch`, removing Ruby dependency.**


## Installation

```bash
git clone git://github.com/jsjason/scm_breeze.git ~/.scm_breeze
~/.scm_breeze/install.sh
source ~/.bashrc   # or source ~/.zshrc
```

The install script creates required default configs and adds the following line
to your `.bashrc` or `.zshrc`:

`[ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"`

**Note:** SCM Breeze performs much faster if you have ruby installed.
