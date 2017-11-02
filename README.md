wpwmm4(1) -- Web Page With Make and M4 - generate static web pages
====

## SYNOPSIS
Simple use the make command. The Makefile is compatible with FreeBSD's and NetBSD's make.
On Linux should install _bmake_ package.

## DESCRIPTION
With wpwmm4 can create static web pages from `m4` files.
The generating is done by `make`. You can use external scripts or
commands.

## OVERVIEW

### Requirements
- make (BSD's make, use bmake package of your distro)
- m4 (compatible with BSD's m4 and GNU's m4 too)
- some knowledge about HTML and programming

### Features
- incremental build (with make)
- automatically generated pages (similar webpage with different content)
- layouts
- expandable, programmable via m4 or can insert output of any program

### Nutshell
- convert items of `${TARGETS}`: `${SRC_DIR}/*.m4` -> `${DEST_DIR}/*.html`
- create items of `${TARGETS_MANUAL}`: use own programs, scripts
- create items of `${VIRTUALS}`: use templates from `${VIRT_DIR}`
- can call scripts from _scripts/_ directory and use their outputs

## USAGE
You should create a `config.mk` file in a directory and
set the following variables inside this file. You can use _.include_
in your `config.mk` of course.

### Basic variables
* COMMON_DIR:
Where the `00_defines.m4` is. Commonly is the same directory as
`Makefile`.

* INCLUDE_DIR:
The directory where the user-based includes `m4` are. It's relative
to the main source directory.

* SRC_DIR:
This variable points to the source directory where the source files 
(usually `*.m4`) are. It can contain subdirectories.

* ASSETS_DIR:
In this directory are the static files (`*.css`, `*.js`, etc.).

* DEST_DIR:
The compiled (created) HTML's place. The subdirectory tree of
`SRC_DIR` is created in this directory by `make`.

* FLAG_DIR:
The directory where the flags are. Flags are simple files which
store information about building. There is only one flag:
`${FLAG_MKDIR}` which signs the time when the directory structure is
created in `${DEST_DIR}` and stores the list of created directories.
You can add plus depend via `${MKDIR_REQ}` - so can re-build the
directory structure after this file changed.

* LAYOUT_DIR:
Here are the layouts.

* VIRT_DIR:
This directory contains the templates of virtual pages.

* TARGETS:
The space-seperated list of static files (virtual pages aren't included)
what should create. Don't include the `${DEST_DIR}`
because it's included by the building system. You can
use directories of course.
Its automated requirement is the same file in `${SRC_DIR}` replacing
*html* extension to *m4* extension.

* TARGETS_MANUAL:
The space-seperated list of static files what should create.
Don't include the `${DEST_DIR}`
because it's included by the building system. These targets don't have
automatically generated requirement as the `${TARGETS}` above.

* GREQ:
Global requirement. It's needed by _every_ target. Default is empty.

* foo.html_REQ:
Additional requirements of `foo.html` which is included in
`${TARGETS}` variable (see above). The `foo.m4` is automatically
added. These variables are optional.

* M4:
The `m4` command. In most cases can set simply to `m4` (in _PATH_).
This variable is optional, default value is `m4`.

* M4_PARAMS:
Parameters of `m4` command. The default value is
*-P -I include -D_SRC_DIR=${SRC_DIR}*. Please note that option
*-P* is neccessary because we use builtin macros with `m4_` prefix.

### Variables inside sources
The following variables are created dynamically during building and
you can use them in your m4 sources and templates.

* _DIRECTORY:
The target directory inside `${DEST_DIR}` (without `${DEST_DIR}` prefix). The root
of `${DEST_DIR}` is "." (dot).

* _FILE:
The target filename which is under generating (without any extension).

### Helpers
The system ships some helpers which you can use in your files. They are
defined in `00_defines.m4`. Here is the list of helpers:

* _BODY(options,content):
Produces `<body $options>$content</body>`.

* _CHARSET(charset):
Produces `<meta charset="$charset">`.

* _CLASS(class1,class2,...):
Produces `class="$class1 $class2 ..."`.

* _CSS(cssfile):
Produces `<link rel="stylesheet" href=$cssfile>`.

* _DIV(class,content,options):
Produces `<div class=$class $options>$content</div>`.

* _HEAD(options,content):
Produces `<head $options>$content</head>`.

* _HREF(url,text,options,title):
Produces `<a href=$url $options title=$title>text</a>`.

* _META(parameters):
Produces `<meta $parameters>`.

* _STAG(tagname,parameters):
Produces `<$tagname $parameters>`.

* _TAG(tagname,content,options):
Produces `<$tagname $options>$content</$tagname>`.

* _TITLE(title,options):
Produces `<title $options>$title</title>`.

### Virtuals
The virtual pages haven't source (m4) files.
It's useful when you want create similar pages with similar content
(for example listing of PDF files, listing images, ...).

You should create groups of `VIRTUALS` (you can add only ONE virtual
to a group). You can do it with the following variables:

* VIRTUALS:
Contains the name of the categories. E.g.
`VIRTUALS=cat1 cat2`.
The categories is separated by a space character.

* VIRTUALTEMPLATE_*:
You can set (following the example above) `VIRTUALTEMPLATE_cat1` and
`VIRTUALTEMPLATE_cat2` variables. Their values say which template
should use to generate the virtual pages. The templates are stored in
`VIRT_DIR` directory.
In your template files you can use dynamically created variables,
see [Variables inside sources][] section below.

* VIRTUALDIR_*:
This variable points to the target directory where the generated pages should
appear. You have to set every category, so you have to set `VIRTUALDIR_cat1`
and `VIRTUALDIR_cat2` too.

* VIRTUALOUT_*:
The output filenames. For example `VIRTUAL_cat1=foo1.html foo2.html`.
In this case you will have `${VIRTUALDIR_cat1}/foo1.html` and
`${VIRTUALDIR_cat1}/foo2.html`.

* VIRTUALREQ_*:
Additional requirements to the virtual category. The `${VIRTUALTEMPLATE_*}.m4` is
added automatically.

* VIRTUALREQRULE_*:
A simple transformation rule to define a requirement by file. The transformation rule
is applied on the elements of `${VIRTUALOUT_*}` variables. For example
`VIRTUALREQ_foo=C,.html,.dat,` rule will transform every `.html` extension
into `.dat` extension: the `${DESTDIR}/foodir/bar.html` will depend on
`foodir/bar.dat` file. Please note that the value of `${VIRTUALDIR_*}
isn't included automatically so if you want it you should do it!
Be careful about recursive dependencies! See the possible modifiers in the
manual of _make(1)!

### Hooks
You can define hooks which run at specified event. You can use the
`${.TARGET}` macro in the definition because `make` will expand this
variable when it needed (and not in definition). If you don't want view
the command should prefix with _@_ sign.

* HOOK_PRE_HTML:
It runs before generating a html file from a m4 file. Default value is
`${MSG1} Building ${.TARGET}`.

* HOOK_POST_HTML:
It runs after generating a html file from a m4 file. Default value is
empty. This hook is useful for example if you want check the validity
of HTML file (e.g. with tidy, see http://www.html-tidy.org/).

* HOOK_PRE_VHTML:
It runs before generating a html file from virtual template (see
[Virtuals][] above). The default value is `${MSG1} Building virtual ${.TARGET}`.

* HOOK_POST_VHTML:
It runs after generating a html file from virtual template. Default value
is empty.

### Special targets
You can define some special targets in your `config.mk'.

* pre-everything:
This target will execute _before_ any other target (except _clean_ of course).
For example you can run a script which creates some files, even a file what is
used in wpwmm4. With this target can emulate the tags feature (using
[Virtuals][] feature). Another idea is automatically generate the
`${TARGETS}` variable (with the `find` command).

* clean-other:
When you run _clean_ target (which deletes everything in `${DEST_DIR}` directory)
it will run too.

### Information targets
There are some special targets to help debug your config.

* show-config:
Show the main variables.

* show-targets:
Show the targets (including virtual targets).

* show-req:
Show the targets with their requirements. The target begins a line without any
whitespace, the requirements are prefixed by two spaces. Between the
latest requirement and the next target is an empty line inserted.

* show-virtuals:
This target will show the defined virtuals and their configs.

### Built-in commands
There are some commands which can help. They are defined in `00_defines.m4`.
Here is the list:

* _SCRIPT(`command`):
Executes `command` and paste its output ( __stdout__ and __stderr__ too). It
uses the `m4`'s `esyscmd` macro.

* _LAYOUT(`layout`,`VarName1`,`Var1`,`VarName2`,`Var2`,...):
Load the `layout` layout. It uses `m4`'s `include` macro. You can define the
web page layout at the beginning of source file.
This command will assign the variables `VarName1`, `VarName2`,...
with values `Var1`, `Var2`.

* _LAYOUT_PRE(`pre`):
The `pre` is printed before the included content.

* _LAYOUT_POST(`post`):
The `post` is printed after the included content.

* _INCL(`file`):
Includes the `file`. The `divert` is -1 so this macro doesn't produce
any output. It's ideal to load a file with macro definitions.

* _2_BODY(`*`):
The `*` will into the body tag. This macro collects all inputs and
doesn't print anything. With `_PR_BODY` can print (and clear) the content.

* _2_HEAD(`*`):
Same as `_2_BODY` but it collects into head tag.

* _PR_BODY:
Print and reset the content collected by `_2_BODY`. 
It's a simple `undivert` macro.

* _PR_HEAD:
Similar as `_PR_BODY`.

* _PR_ALL:
It prints `<!DOCTYPE html><html>`, calls `_PR_HEAD` and `_PR_BODY` and after it
closes the `html` tag.

## TIPS
* use of `!=`:
You can use `!=` in `TARGETS` assingment (run a shell command and its output
will the value). In this case you shouldn't add every file, you can use the
`find` command (for example). Of course can use with other variables.

## FILES
config.mk

## EXAMPLES
A generated example is my personal homepage (in hungarian): http://uzsolt.hu/ and
its source file are at https://svn.uzsolt.hu/uzsolt.hu/wpwmm4-uzsolt.hu/ and a github
mirror: https://github.com/uzsolt/wpwmm4-uzsolt.hu.

It's a simple complicated example but it demonstrates the power of wpwmm4 :) It has

* a multi-level menu (without JS)
* galleries (inside "Képek"), with automatically-generated sprite (a big picture
  in thumbnail, and shows only a part of this picutre - reduce the number of requests so
  faster page loading)!
* pdf items (inside "Oktatás") with "tags"
* notes or blog entries (inside "Feljegyzések")
* automatically generates LaTeX-samples (inside "Feljegyzések"/"LaTeX")

## SEE ALSO
m4(1), make(1)

## AUTHOR
Zsolt Udvari (uzsolt@uzsolt.hu, www.uzsolt.hu)
