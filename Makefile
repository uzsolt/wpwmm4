include config.mk

COMMON_DIR?=/home/zsolt/progs/wpwmm4/
INCLUDE_DIR?=include/
M4_DEFINITIONS=00_defines.m4

# If there are unset we're using default values
M4?=m4
M4_FLAGS?=-P -I ${COMMON_DIR} -I ${INCLUDE_DIR} \
		  -D_SRC_DIR=${SRC_DIR} -D_LAYOUT_DIR=${LAYOUT_DIR}
CAT?=cat
MKDIR=@mkdir -p

MSG=@echo "==>"
MSG1=@echo "  ==>"
MSG2=@echo "    ==>"

INCL=${CAT} ${COMMON_DIR}${M4_DEFINITIONS}

# Working Targets
# Prepend the ${DEST_DIR}
WTARGETS=${TARGETS:S/^/${DEST_DIR}/}

# Target directories
# Remove the filenames
TDIR=${WTARGETS:H:u}

.for CATEG in ${VIRTUALS}
TDIR+=${DEST_DIR}${VIRTUALDIR_${CATEG}}
.endfor

all: assets ${WTARGETS} virtual

# Create directories inside ${DEST_DIR}
${TDIR:u}: pre-everything
	${MKDIR} -p ${TDIR:u}

# Create files using ${SRC_DIR}/*.m4 in ${DEST_DIR}/*.html
# Pass the directory of source file to m4 as `_DIRECTORY' and
# the created filename without path and extension as `_FILE'.
.for T in ${TARGETS}
${DEST_DIR}${T}: ${GREQ} ${TDIR} ${T:S/^/${SRC_DIR}/:S/html$/m4/} ${${T}_REQ}
	${MSG1} Building ${.TARGET}
	@${INCL} ${.TARGET:S/${DEST_DIR}/${SRC_DIR}/:R}.m4 | \
	  ${M4} ${M4_FLAGS} \
	  -D_DIRECTORY=${.TARGET:H:S/${DEST_DIR}//:H} \
	  -D_FILE=${.TARGET:S/${DEST_DIR}//:R} \
	   > ${.TARGET}
.endfor

# Looping all ${VIRTUALS}
.for CATEG in ${VIRTUALS}
VIRTUAL_FILES+=${VIRTUALOUT_${CATEG}:S/^/${DEST_DIR}${VIRTUALDIR_${CATEG}}/}
VIRTUALREQRULE_${CATEG}?=C,.*,,

# Create files from ${VIRTUALS} using ${VIRT_DIR}/*.m4
# Pass the directory as `_DIRECTORY' and create filename 
# without extension as `_FILE'
.for VOUT in ${VIRTUALOUT_${CATEG}}
${DEST_DIR}${VIRTUALDIR_${CATEG}}${VOUT}: ${GREQ} \
  ${DEST_DIR}${VIRTUALDIR_${CATEG}} \
  ${VIRT_DIR}${VIRTUALTEMPLATE_${CATEG}}.m4 \
  ${VIRTUALREQ_${CATEG}} \
  ${VOUT:${VIRTUALREQRULE_${CATEG}}}
	${MSG} Virtual ${VIRTUALTEMPLATE_${CATEG}}: ${.TARGET}
	${MKDIR} ${VIRTUALOUT_${CATEG}:H:S/^/${DEST_DIR}${VIRTUALDIR_${CATEG}}/}
	@${INCL} ${VIRT_DIR}${VIRTUALTEMPLATE_${CATEG}}.m4 | \
	  ${M4} ${M4_FLAGS} \
	  -D_DIRECTORY=${.TARGET:S/${DEST_DIR}//:H} \
	  -D_FILE=${.TARGET:S/${DEST_DIR}//:C/.*\///:R} \
	  > ${.TARGET}
.endfor
.endfor
# End of looping ${VIRTUALS}

assets::
	@cp -r ${ASSETS_DIR} ${DEST_DIR}

virtual: pre-everything ${VIRTUAL_FILES}

clean: clean-other
	rm -rf ${DEST_DIR}

.for VAR in ASSETS_DIR COMMON_DIR DEST_DIR INCLUDE_DIR LAYOUT_DIR SRC_DIR VIRT_DIR
VARIABLES:=${VARIABLES}${VAR} = ${${VAR}}${.newline}
.endfor

.for VAR in ${VIRTUALS:O}
VIRTVARS:=${VIRTVARS}*** ${VAR} ***${.newline}\
TEMPLATE: ${VIRTUALTEMPLATE_${VAR}}${.newline}\
OUT: ${VIRTUALOUT_${VAR}}${.newline}\
REQ: ${VIRTUALREQ_${VAR}}${.newline}\
REQRULE: ${VIRTUALREQRULE_${VAR}}${.newline}\
${.newline}
.endfor

show-config:
	@echo "${VARIABLES}"

show-virtuals:
	@echo "${VIRTVARS}"

.if !target(pre-everything)
pre-everything:
.endif
.if !target(clean-other)
clean-other:
.endif

.PHONY: assets clean clean-other pre-everything show-config show-virtuals virtual
.MAIN: all
