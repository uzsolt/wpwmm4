include config.mk

COMMON_DIR?=/home/zsolt/progs/wpwmm4/
INCLUDE_DIR?=include/
FLAG_DIR?=flags/
M4_DEFINITIONS=00_defines.m4

FLAG_MKDIR=create-dirs

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

# Working Manual Targets
# Prepend the ${DEST_DIR}
WMTARGETS:=${TARGETS_MANUAL:S/^/${DEST_DIR}/}

# Target directories
# Remove the filenames
TDIR=${WTARGETS:H:u}

.for CATEG in ${VIRTUALS}
TDIR+=${DEST_DIR}${VIRTUALDIR_${CATEG}}
TDIR:=${TDIR}
.endfor

all: ${FLAG_DIR}${FLAG_MKDIR} assets ${WTARGETS} ${WMTARGETS} virtual

${FLAG_DIR}${FLAG_MKDIR}: config.mk ${MKDIR_REQ}
	${MSG} "Creating directory structure... (flagfile: ${.TARGET})"
	@${MKDIR} -p ${FLAG_DIR}
	@${MKDIR} -p ${TDIR:u}
	@echo ${TDIR:u} | tr ' ' '\n' | sort > ${FLAG_DIR}${FLAG_MKDIR}

create-dirs: ${FLAG_DIR}${FLAG_MKDIR}

# Create files using ${SRC_DIR}/*.m4 in ${DEST_DIR}/*.html
# Pass the directory of source file to m4 as `_DIRECTORY' and
# the created filename without path and extension as `_FILE'.
.for T in ${TARGETS}
CT:=${DEST_DIR}${T}
DEP:=${GREQ} ${T:S/^/${SRC_DIR}/:S/html$/m4/} ${${T}_REQ}
REQUIREMENT_${CT}:=${DEP}
ALLTARGET+=${CT}
ALLTARGET:=${ALLTARGET}
${CT}: ${DEP}
	${MSG1} Building ${.TARGET}
	@${INCL} ${.TARGET:S/${DEST_DIR}/${SRC_DIR}/:R}.m4 | \
	  ${M4} ${M4_FLAGS} \
	  -D_DIRECTORY=${.TARGET:H:S/${DEST_DIR}//} \
	  -D_FILE=${.TARGET:S/${DEST_DIR}//:R} \
	   > ${.TARGET}
.endfor

# Looping all ${VIRTUALS}
.for CATEG in ${VIRTUALS}
VIRTUAL_FILES+=${VIRTUALOUT_${CATEG}:S/^/${DEST_DIR}${VIRTUALDIR_${CATEG}}/}
VIRTUAL_FILES:=${VIRTUAL_FILES}
VIRTUALREQRULE_${CATEG}?=C,.*,,

# Create files from ${VIRTUALS} using ${VIRT_DIR}/*.m4
# Pass the directory as `_DIRECTORY' and create filename 
# without extension as `_FILE'
.for VOUT in ${VIRTUALOUT_${CATEG}}
CT:=${DEST_DIR}${VIRTUALDIR_${CATEG}}${VOUT}
DEP:=${GREQ} \
  ${DEST_DIR}${VIRTUALDIR_${CATEG}} \
  ${VIRT_DIR}${VIRTUALTEMPLATE_${CATEG}}.m4 \
  ${VIRTUALREQ_${CATEG}} \
  ${VOUT:${VIRTUALREQRULE_${CATEG}}} \
  ${${VIRTUALDIR_${CATEG}}${VOUT}_REQ}
REQUIREMENT_${CT}:=${DEP}
ALLTARGET+=${CT}
ALLTARGET:=${ALLTARGET}
${CT}: ${DEP}
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
.ifdef ASSETS_DIR
	@cp -r ${ASSETS_DIR} ${DEST_DIR}
.endif

virtual: pre-everything ${VIRTUAL_FILES}

clean: clean-other
	rm -rf ${DEST_DIR}
	rm -rf ${FLAG_DIR}

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

show-targets:
	@echo ${ALLTARGET} | tr ' ' '\n'

show-req:
.for T in ${ALLTARGET}
	@echo
	@echo ${T}:
	@printf "  %s\n" ${REQUIREMENT_${T}}
.endfor

show-virtuals:
	@echo "${VIRTVARS}"

.if !target(pre-everything)
pre-everything:
.endif
.if !target(clean-other)
clean-other:
.endif

.PHONY: all assets clean clean-other pre-everything show-config show-targets show-req show-virtuals virtual
.MAIN: all
