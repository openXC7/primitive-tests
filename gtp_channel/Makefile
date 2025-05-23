PROJECT_NAME = gtp_channel
#PREFIX ?= /snap/openxc7/current/opt/nextpnr-xilinx
PREFIX=../../../nextpnr-xilinx/xilinx/
DB_DIR=${PREFIX}/external/prjxray-db
CHIPDB=../chipdb

PART = xc7a35tfgg484-2
DBPART = $(shell echo ${PART} | sed -e 's/-[0-9]//g')
SPEEDGRADE = $(shell echo ${PART} | sed -e 's/.*\-\([0-9]\)/\1/g')

.PHONY: all
all: ${PROJECT_NAME}.bit

${PROJECT_NAME}.json: ${PROJECT_NAME}.v
	yosys -p "hierarchy; synth_xilinx -flatten -abc9 -arch xc7  -top ${PROJECT_NAME}; write_json ${PROJECT_NAME}.json;" $<

# The chip database only needs to be generated once
# that is why we don't clean it with make clean
${CHIPDB}/${DBPART}.bin:
	pypy3 ${PREFIX}/python/bbaexport.py --device ${DBPART}-${SPEEDGRADE} --bba ${DBPART}.bba
	bbasm -l ${DBPART}.bba ${CHIPDB}/${DBPART}.bin
#	rm -f ${DBPART}.bba

${PROJECT_NAME}.fasm: ${PROJECT_NAME}.json ${CHIPDB}/${DBPART}.bin
	nextpnr-xilinx --chipdb ${CHIPDB}/${DBPART}.bin --xdc ${PROJECT_NAME}.xdc  --json $< --write ${PROJECT_NAME}_routed.json --fasm $@  --freq 100 #--verbose --debug

${PROJECT_NAME}.frames: ${PROJECT_NAME}.fasm
	fasm2frames --part ${PART} --db-root ${DB_DIR}/artix7 $< > $@

${PROJECT_NAME}.bit: ${PROJECT_NAME}.frames
	xc7frames2bit --part_file ${DB_DIR}/artix7/${PART}/part.yaml --part_name ${PART} --frm_file $< --output_file $@

.PHONY: clean pnrclean
clean:
	@rm -f *.bit
	@rm -f *.frames
	@rm -f *.fasm
	@rm -f *.json

pnrclean:
	rm *.fasm *.frames *.bit

