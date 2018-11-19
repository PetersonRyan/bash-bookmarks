## Bash Bookmarks

Store directory bookmarks for your terminal. Access or open them by an index or by name

Every terminal window you open will list your bookmarks upon opening, for easy access!

## Commands

```
bbs <name>        : Save current directory as <name>
bb  <index/name>  : Go to bookmark with index <index> or name <name>
bbo <index/name>  : Open bookmark with index <index> or name <name> in file manager
bbl               : List all bookmarks
bbd <index/name>  : Remove bookmark with index <index> or name <name>
bb  -r            : Resets bookmarks to nothing
```

## Installation Instructions

Run the following commands to download the file into your user directory, and add it to your bash profile
```
curl https://raw.githubusercontent.com/PetersonRyan/bash-bookmarks/master/bash-bookmarks.sh --output ~/.bash-bookmarks.sh
echo source ~/.bash-bookmarks.sh >> ~/.profile

```
