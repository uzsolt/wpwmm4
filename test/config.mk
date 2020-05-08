COMMON_DIR=	../

SRC_DIR=	src/
DEST_DIR=	generated/

HOOK_PRE_HTML=
HOOK_PRE_VHTML=

TEST-CATEGORIES=	\
	BODY \
	CHARSET \
	CLASS \
	CSS \
	DIV \
	DIVBE \
	HEAD \
	TAG \
	TITLE

.for g in ${TEST-CATEGORIES}
TEST-${g}!=	echo ${SRC_DIR}test-${g:tl}-*.m4
TEST-${g}:=	${TEST-${g}:T:R}
TARGETS+=	${TEST-${g}:@v@${v}.html@}
.endfor
