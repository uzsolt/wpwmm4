m4_divert(-1)

m4_dnl HTML helpers
m4_define(`_BODY',_TAG(body,`$1',`$2'))
m4_define(`_CHARSET',_META(charset="`$1'"))
m4_define(`_CLASS',class=$*)
m4_define(`_CSS',_STAG(link,`rel="stylesheet" href="$1"'))
m4_define(`_DIV',<div class="`$1'" `$3'>`$2'</div>)
m4_define(`_HEAD',_TAG(head,`$1',`$2'))
m4_define(`_HREF',_TAG(a,`$2',`href="$1" $3 title="`$4'"'))
m4_define(`_META',_STAG(meta,$*))
m4_define(`_STAG',<$1 $2>)
m4_define(`_TAG',<`$1' `$3'>`$2'</`$1'>)
m4_define(`_TITLE',_TAG(title,`$1',`$2'))

m4_dnl Built-in macros
m4_define(`_SCRIPT',``m4_esyscmd'(scripts/$1)')
m4_define(`_LAYOUT',m4_divert(-1)`_MASS_DEFINE(m4_shift($@))'`m4_include'(_LAYOUT_DIR$1)`m4_include'(end_layout.m4))
m4_define(`_LAYOUT_PRE',_2_BODY($1))
m4_define(`_LAYOUT_POST',m4_define(__layoutpost,$1))
m4_define(`_INCL',m4_divert(-1)`m4_include'($1))
m4_define(`_MASS_DEFINE',`m4_ifelse(m4_eval($#>1),1,`m4_define($1,$2) _MASS_DEFINE(m4_shift(m4_shift($@)))')')

m4_dnl Layout helpers
m4_define(`_DIVERT_HEAD',2)
m4_define(`_DIVERT_BODY',3)
m4_define(`_2_HEAD',`m4_define(`_OD',m4_divnum) m4_divert(_DIVERT_HEAD) $* m4_divert(_OD)')
m4_define(`_PR_HEAD',`<head>
m4_undivert(_DIVERT_HEAD)m4_dnl
</head>')
m4_define(`_2_BODY',`m4_define(`_OD',m4_divnum) m4_divert(_DIVERT_BODY) $* m4_divert(_OD)')
m4_define(`_PR_BODY',`<body>
m4_undivert(_DIVERT_BODY)m4_dnl
</body>')
m4_define(`_PR_ALL',`m4_divert(0)'m4_dnl
<!DOCTYPE html>
<html lang="LANG">
`_PR_HEAD
_PR_BODY'
</html>)
m4_divert(0)m4_dnl
