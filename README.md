# NAME
wpwmm4(1) -- Web Page With Make and M4 - generate static web pages

# SYNOPSIS
Simple use the make command. The Makefile is compatible with FreeBSD's and NetBSD's make.
On Linux should install _bmake_ package.

# DESCRIPTION
With wpwmm4 can create static web pages from **m4** files.
The generating is done by **make**. You can use external scripts or
commands.

# OVERVIEW

## Requirements
- make (BSD's make, use _bmake_ package of your distro)
- m4 (compatible with BSD's m4 and GNU's m4 too)
- some knowledge about HTML and programming

## Features
- incremental build (with _make_)
- automatically generated pages (similar webpage with different content)
- layouts
- expandable, programmable via _m4_ or can insert output of any program

## Nutshell
- convert items of **${TARGETS}**: **${SRC_DIR}/*.m4** -> **${DEST_DIR}/*.html**
- create items of **${TARGETS_MANUAL}**: use own programs, scripts
- create items of **${VIRTUALS}**: use templates from **${VIRT_DIR}**
- can call scripts from _scripts/_ directory and use their outputs

# USAGE
You should create a **config.mk** file in a directory and
set the following variables inside this file. You can use _.include_
in your **config.mk** of course.

## Basic variables
* _COMMON\_DIR_:
Where the **00_defines.m4** is. Commonly is the same directory as
**Makefile**.

* _INCLUDE\_DIR_:
The directory where the user-based includes **m4** are. It's relative
to the main source directory.

* _SRC\_DIR_:
This variable points to the source directory where the source files 
(usually **\*.m4**) are. It can contain subdirectories.

* _ASSETS\_DIR_:
In this directory are the static files (***.css**, ***.js**, etc.).

* _DEST\_DIR_:
The compiled (created) HTML's place. The subdirectory tree of
**${SRC_DIR}** is created in this directory by _make_.

* _FLAG\_DIR_:
The directory where the flags are. Flags are simple files which
store information about building. There is only one flag:
**${FLAG_MKDIR}** which signs the time when the directory structure is
created in **${DEST_DIR}** and stores the list of created directories.
You can add plus depend via **${MKDIR_REQ}** - so can re-build the
directory structure after this file changed.

* _LAYOUT\_DIR_:
Here are the layouts.

* _VIRT\_DIR_:
This directory contains the templates of virtual pages.

* _TARGETS_:
The space-seperated list of static files (virtual pages aren't included)
what should create. Don't include the **${DEST_DIR}**
because it's included by the building system. You can
use directories of course.
Its automated requirement is the same file in **${SRC_DIR}** replacing
*html* extension to *m4* extension.

* _TARGETS\_MANUAL_:
The space-seperated list of static files what should create.
Don't include the **${DEST_DIR}**
because it's included by the building system. These targets don't have
automatically generated requirement as the **${TARGETS}** above.

* _GREQ_:
Global requirement. It's needed by _every_ target. Default is empty.

* _foo.html\_REQ_:
Additional requirements of **foo.html** which is included in
**${TARGETS}** variable (see above). The **foo.m4** is automatically
added. These variables are optional.

* _M4_:
The _m4_ command. In most cases can set simply to _m4_ (in _PATH_).
This variable is optional, default value is _m4_

* _M4\_PARAMS_:
Parameters of **m4** command. The default value is
**-P -I include -D_SRC_DIR=${SRC_DIR}**.
Please note that option
*-P* is neccessary because we use builtin macros with **m4_** prefix.

## Variables inside sources
The following variables are created dynamically during building and
you can use them in your _m4_ sources and templates.

* _\_DIRECTORY_:
The target directory inside **${DEST_DIR}** (without **${DEST_DIR}** prefix). The root
of **${DEST_DIR}** is "." (dot).

* _\_FILE_:
The target filename which is under generating (without any extension).

## Helpers
The system ships some helpers which you can use in your files. They are
defined in **00_defines.m4**. Here is the list of helpers:

* _\_BODY(options,content)_:
Produces **\<body $options\>$content\</body\>**.

* _\_CHARSET(charset)_:
Produces **\<meta charset="$charset"\>**.

* _\_CLASS(class1,class2,...)_:
Produces **class="$class1 $class2 ..."**.

* _\_CSS(cssfile)_:
Produces **\<link rel="stylesheet" href=$cssfile\>**.

* _\_DIV(class,content,options)_:
Produces **\<div class=$class $options\>$content\</div\>**.

* _\_HEAD(options,content)_:
Produces **\<head $options\>$content\</head\>**.

* _\_HREF(url,text,options,title)_:
Produces **\<a href=$url $options title=$title\>text\</a\>**.

* _\_META(parameters)_:
Produces **\<meta $parameters\>**.

* _\_OL(parameters)_:
Produces ordered list **\<ol\>\<li\>$1\</li\>\<li\>$2\</li\>...\</ol\>**. You can
specify the items in parameter list, separated by comma. Be careful
about quoting! You can nest but in the second level should use double
quote, on third level triple quote, and so on (to avoid macro expansion
before the right time).

* _\_STAG(tagname,parameters)_:
Produces **\<$tagname $parameters\>**.

* _\_TAG(tagname,content,options)_:
Produces **\<$tagname $options\>$content\</$tagname\>**.

* _\_TITLE(title,options)_:
Produces **<title $options>$title</title>**.

* _\_UL(parameters)_:
Same as **_OL**.

## Virtuals
The virtual pages haven't source (m4) files.
It's useful when you want create similar pages with similar content
(for example listing of PDF files, listing images, ...).

You should create groups of **VIRTUALS** (you can add only ONE virtual
to a group). You can do it with the following variables:

* _VIRTUALS_:
Contains the name of the categories. E.g.
**VIRTUALS=cat1 cat2**.
The categories is separated by a space character.

* _VIRTUALTEMPLATE\_*_:
You can set (following the example above) **VIRTUALTEMPLATE_cat1** and
**VIRTUALTEMPLATE_cat2** variables. Their values say which template
should use to generate the virtual pages. The templates are stored in
**VIRT_DIR** directory.
In your template files you can use dynamically created variables,
see [Variables inside sources][] section below.

* _VIRTUALDIR\_*_:
This variable points to the target directory where the generated pages should
appear. You have to set every category, so you have to set **VIRTUALDIR_cat1**
and **VIRTUALDIR_cat2** too.

* _VIRTUALOUT\_*_:
The output filenames. For example **VIRTUAL_cat1=foo1.html foo2.html**.
In this case you will have **${VIRTUALDIR_cat1}/foo1.html** and
**${VIRTUALDIR_cat1}/foo2.html**.

* _VIRTUALREQ\_\*_:
Additional requirements to the virtual category. The **${VIRTUALTEMPLATE_*}.m4** is
added automatically.

* _VIRTUALREQRULE\_\*_:
A simple transformation rule to define a requirement by file. The transformation rule
is applied on the elements of **${VIRTUALOUT_*}** variables. For example
**VIRTUALREQ_foo=C,.html,.dat,** rule will transform every **.html** extension
into **.dat** extension: the **${DESTDIR}/foodir/bar.html** will depend on
**foodir/bar.dat** file. Please note that the value of **${VIRTUALDIR_*}
isn't included automatically so if you want it you should do it!
Be careful about recursive dependencies! See the possible modifiers in the
manual of **make(1)**!

## Hooks
You can define hooks which run at specified event. You can use the
**${.TARGET}** macro in the definition because _make_ will expand this
variable when it needed (and not in definition). If you don't want view
the command should prefix with _@_ sign.

* _HOOK\_PRE\_HTML_:
It runs before generating a html file from a _m4_ file. Default value is
**${MSG1} Building ${.TARGET}**.

* _HOOK\_POST\_HTML_:
It runs after generating a html file from a _m4_ file. Default value is
empty. This hook is useful for example if you want check the validity
of HTML file (e.g. with tidy, see http://www.html-tidy.org/).

* _HOOK\_PRE\_VHTML_:
It runs before generating a html file from virtual template (see
[Virtuals][] above). The default value is **${MSG1} Building virtual ${.TARGET}**.

* _HOOK\_POST\_VHTML_:
It runs after generating a html file from virtual template. Default value
is empty.

## Special targets
You can define some special targets in your **config.mk'.

* _pre-everything_:
This target will execute _before_ any other target (except _clean_ of course).
For example you can run a script which creates some files, even a file what is
used in wpwmm4. With this target can emulate the tags feature (using
[Virtuals][] feature). Another idea is automatically generate the
**${TARGETS}** variable (with the **find** command).

* _clean-other_:
When you run _clean_ target (which deletes everything in **${DEST_DIR}** directory)
it will run too.

## Information targets
There are some special targets to help debug your config.

* _show-config_:
Show the main variables.

* _show-hooks_:
Show the hooks.

* _show-targets_:
Show the targets (including virtual targets).

* _show-req_:
Show the targets with their requirements. The target begins a line without any
whitespace, the requirements are prefixed by two spaces. Between the
latest requirement and the next target is an empty line inserted.

* _show-virtuals_:
This target will show the defined virtuals and their configs.

## Generally usable variables in m4 files
There are some variables you can use and set in your **m4** files.

* _LANG_:
The document's language. It is used by **_PR_ALL** to create the main
**html** tag with **lang** property.

## Built-in commands
There are some commands which can help. They are defined in **00_defines.m4**.
Here is the list:

* _\_SCRIPT(command)_:
Executes **$command** and paste its output ( __stdout__ and __stderr__ too). It
uses the _m4_'s **esyscmd** macro.

* _\_LAYOUT(layout,VarName1,Var1,VarName2,Var2,...)_:
Load the **$layout** layout. It uses _m4_'s _include_ macro. You can define the
web page layout at the beginning of source file.
This command will assign the variables **VarName1**, **VarName2**,...
with values **Var1**, **Var2**.

* _\_LAYOUT\_PRE(pre)_:
The **$pre** is printed before the included content.

* _\_LAYOUT\_POST(post)_:
The **$post** is printed after the included content.

* _\_INCL(file)_:
Includes the **$file**. The _divert_ is -1 so this macro doesn't produce
any output. It's ideal to load a file with macro definitions.

* _\_2\_BODY(text)_:
The **$text** will into the body tag. This macro collects all inputs and
doesn't print anything. With _\_PR\_BODY_ can print (and clear) the content.

* _\_2\_HEAD(text)_:
Same as **_2_BODY** but it collects into **head** tag.

* _\_PR\_BODY_:
Print and reset the content collected by **_2_BODY**. 
It's a simple _undivert_ macro.

* _\_PR\_HEAD_:
Similar as **_PR_BODY**.

* _\_PR\_ALL_:
It prints **\<!DOCTYPE html\>\<html lang="LANG"\>**, calls **_PR_HEAD** and **_PR_BODY** and after it
closes the **html** tag.

# TIPS
* use of **!=**:
You can use **!=** in **TARGETS** assingment (run a shell command and its output
will the value). In this case you shouldn't add every file, you can use the
**find** command (for example). Of course can use with other variables.

# FILES
config.mk

# EXAMPLES
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

# SEE ALSO
m4(1), make(1)

# AUTHOR
Zsolt Udvari (uzsolt@uzsolt.hu, www.uzsolt.hu)
