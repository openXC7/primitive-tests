PREFIX ?= /snap/nextpnr-kintex/current
DB_DIR=${PREFIX}/opt/nextpnr-xilinx/external/prjxray-db
CHIPDB=../chipdb
PROJECT=idelay

PART = xc7k325tffg676-1

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
	nextpnr-xilinx --chipdb ${CHIPDB}/${PART}.bin --xdc ${PROJECT}.xdc --json ${PROJECT}.json --fasm $@ --verbose --debug
	
${PROJECT}.frames: ${PROJECT}.fasm
	fasm2frames --part ${PART} --db-root ${DB_DIR}/kintex7 $< > $@

${PROJECT}.bit: ${PROJECT}.frames
	xc7frames2bit --part_file ${DB_DIR}/kintex7/${PART}/part.yaml --part_name ${PART} --frm_file $< --output_file $@

.PHONY: show
show: ${PROJECT}.json
	yosys -p "read_json ${PROJECT}.json; show"

.PHONY: svg
svg: ${PROJECT}.json
	netlistsvg ${PROJECT}.json
	xdg-open out.svg

.PHONY: clean
clean:
	@rm -f *.bit
	@rm -f *.frames
	@rm -f *.fasm
	@rm -f *.json
	@rm -f *.svg
