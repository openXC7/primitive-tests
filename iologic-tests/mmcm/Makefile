PREFIX ?= /snap/nextpnr-kintex/current
#DB_DIR=${PREFIX}/opt/nextpnr-xilinx/external/prjxray-db/kintex7/
DB_DIR=../../db-workspace-for-kintex7/
CHIPDB=../chipdb
PROJECT=mmcm

PART = xc7k160tffg676-2

.PHONY: all
all: ${PROJECT}.bit

${PROJECT}.json: ${PROJECT}.v
	yosys -p "synth_xilinx -flatten -abc9 -nobram -arch xc7 -top ${PROJECT}; write_json ${PROJECT}.json" $<

# The chip database only needs to be generated once
# that is why we don't clean it with make clean
${CHIPDB}/${PART}.bin:
	python3 ${PREFIX}/opt/nextpnr-xilinx/python/bbaexport.py --device ${PART} --bba ${PART}.bba
	bbasm -l ${PART}.bba ${CHIPDB}/${PART}.bin
	rm -f ${PART}.bba

${PROJECT}.fasm: ${PROJECT}.json ${CHIPDB}/${PART}.bin ${PROJECT}.xdc
	/usr/local/bin/nextpnr-xilinx --chipdb ${CHIPDB}/${PART}.bin --xdc ${PROJECT}.xdc --json ${PROJECT}.json --fasm $@ --verbose --debug
	
${PROJECT}.frames: ${PROJECT}.fasm
	fasm2frames --part ${PART} --db-root ${DB_DIR} $< > $@

${PROJECT}.bit: ${PROJECT}.frames
	xc7frames2bit --part_file ${DB_DIR}/${PART}/part.yaml --part_name ${PART} --frm_file $< --output_file $@

.PHONY: clean
clean:
	@rm -f *.bit
	@rm -f *.frames
	@rm -f *.fasm
	@rm -f *.json
