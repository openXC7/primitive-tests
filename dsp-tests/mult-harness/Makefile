PREFIX ?= /snap/openxc7/current
DB_DIR=${PREFIX}/opt/nextpnr-xilinx/external/prjxray-db
CHIPDB=../chipdb
PROJECT=mult_harness

PART = xc7k160tffg676-2

.PHONY: all
all: ${PROJECT}.bit

${PROJECT}.rtlil: ${PROJECT}.py
	./${PROJECT}.py

${PROJECT}.json: ${PROJECT}.rtlil ${PROJECT}.v
	yosys -p "read_ilang ${PROJECT}.rtlil; read_verilog ${PROJECT}.v; synth_xilinx -abc9 -nobram -arch xc7 -top mult_harness; write_json ${PROJECT}.json"

# The chip database only needs to be generated once
# that is why we don't clean it with make clean
${CHIPDB}/${PART}.bin:
	pypy3 ${PREFIX}/opt/nextpnr-xilinx/python/bbaexport.py --device ${PART} --bba ${PART}.bba
	bbasm -l ${PART}.bba ${CHIPDB}/${PART}.bin
	rm -f ${PART}.bba

${PROJECT}.fasm: ${PROJECT}.json ${CHIPDB}/${PART}.bin ${PROJECT}.xdc
	nextpnr-xilinx --chipdb ${CHIPDB}/${PART}.bin --xdc ${PROJECT}.xdc --json ${PROJECT}.json --fasm $@ --freq 100 # --verbose --debug --router router1

${PROJECT}.frames: ${PROJECT}.fasm
	fasm2frames --part ${PART} --db-root ${DB_DIR}/kintex7 $< | tee $@ > /dev/null

${PROJECT}.bit: ${PROJECT}.frames
	xc7frames2bit --part_file ${DB_DIR}/kintex7/${PART}/part.yaml --part_name ${PART} --frm_file $< --output_file $@

program: ${PROJECT}.bit
	openFPGALoader -c ft2232 $<

run:
	./serial-dump.py

show: ${PROJECT}.json
	yosys -p "read_json ${PROJECT}.json; cd mult; show"
	dotty  ~/.yosys_show.dot

.PHONY: clean
clean:
	@rm -f *.bit
	@rm -f *.frames
	@rm -f *.fasm
	@rm -f *.json
	@rm -f *.rtlil
