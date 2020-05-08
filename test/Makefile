include config.mk

MSG=		@printf '\033[1;10m==> %-15s\033[0m'
MSG_PASSED=	printf '\033[1;32m [ PASS ]\033[0m\n'
MSG_ERROR=	printf '\033[1;31m [ FAIL ]\033[0m\n'
DIFF=	/usr/bin/diff

EXPECTDIR=	expect/
FAILS=	fails

all:	pre ${TEST-CATEGORIES:@v@test-${v:tl}@}
	@[ `stat -f "%z" ${FAILS}` -gt 0 ] \
		&& ( printf "\n\033[1;31mFailed tests:\n\033[0m" ; \
		     sed "s,^,  ," ${FAILS} ; true ) \
		|| true

.for category in ${TEST-CATEGORIES}
.for t in ${TEST-${category}}
${t}::	${DEST_DIR}${t}.html ${EXPECTDIR}${t}.html
	$(MSG) "${t:T}"
	@$(DIFF) ${DEST_DIR}${t}.html ${EXPECTDIR}${t}.html > /dev/null \
	  && ( $(MSG_PASSED) || true ) \
	  || (echo ${t} >> ${FAILS} ; $(MSG_ERROR))

${DEST_DIR}${t}.html:
	@$(MAKE) -f ../Makefile ${DEST_DIR}${t}.html
.endfor
.endfor # category

.for category in ${TEST-CATEGORIES}
test-${category:tl}:	${TEST-${category}}
.endfor

clean:
	@rm -rf ${DEST_DIR}*

pre:
	@: > ${FAILS}

.PHONY:	all pre
.PHONY:	test-body ${TEST-BODY}
