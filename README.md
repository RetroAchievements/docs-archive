# docs

Files needed to generate [RetroAchievements.org documentation pages](https://retroachievements.github.io/docs/)

The **RetroAchievements Documentation Project** is divided into two parts:

1. **[RAwiki](https://github.com/RetroAchievements/docs/wiki/)**
2. **[RAdocs](https://retroachievements.github.io/docs/)**

The wiki is where the documents are created and edited. Anyone (with a github account) is able to edit the wiki's content. Then, if you have something to share, please edit the wiki!

The [RAdocs](https://retroachievements.github.io/docs/) website has (almost) the same content as the wiki, but with a more pleasant look. The content of this website is generated by its maintainers using the wiki's content as input.

**When a change is made in the wiki this change is NOT instantaneously reflected in the docs.** The convertion is performed by a maintainer from time to time.


## Generating RAdocs pages

[No need to continue reading if you're not a RAdocs maintainer.]


### dependencies

**Windows**

You'll need to install [Cygwin](https://cygwin.com/), and the following packages: `git`, `python3`, `python3-pip` and `libyaml-devel`.

After installing the dependencies, open a terminal and perform this command:

```
pip install --upgrade mkdocs mkdocs-material
```

**Note**: if `pip` doesn't work try `pip3`.



### cloning the repo

Clone the repo with this command:

```
git clone --depth 1 --recursive https://github.com/RetroAchievements/docs
```

**Note**: don't forget the `--recursive` option.

It creates a folder named `docs`. Just "enter" it using:

```
cd docs
```


### `generate-docs.sh`

The `generate-docs.sh ` is the script you'll be using to generate the pages for RAdocs. 

Your OPTIONS for `generage-doc.sh` are:  
-h|--help | Print this help message and exit.  
-s|--serve | Serve the docs locally after generating the pages.  
-d|--deploy | Deploy the docs to GitHub pages after generating the pages.  

To use an option write it after `generate-docs.sh`.
For example use `generate-docs.sh --help` to see the above options.

**Note**: if `generate-docs.sh` doesn't work try `./generate-docs.sh`.

Use `generate-docs.sh --serve` to create a local file. You can then view local docs by typing this into a new tab in your browser `http://localhost:8000/`.

Use `generate-docs.sh --deploy` to generate or publish the pages online.



**Note**: only the wiki pages listed on the wiki's sidebar will be converted into RAdocs pages.
