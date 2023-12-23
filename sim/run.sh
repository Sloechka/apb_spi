export GIT_HOME="./../"
export SRC_DIR="${GIT_HOME}/src"
export TB_DIR="${GIT_HOME}/tb"

module load cadence/XCELIUMMAIN/19.03.009

xrun +access+rwc +xm64bit +gui      \
+incdir+${SRC_DIR}                  \
+incdir+${TB_DIR}                   \
+incdir+${TB_DIR}/apb               \
+incdir+${TB_DIR}/clk               \
${SRC_DIR}/apbspi_edge_detector.sv  \
${SRC_DIR}/apbspi_fifo.sv           \
${SRC_DIR}/apbspi_clk_div.sv        \
${SRC_DIR}/apbspi_apb_if.sv         \
${SRC_DIR}/apbspi_apb_ctrl.sv       \
${SRC_DIR}/apbspi_spi_if.sv         \
${SRC_DIR}/apbspi_spi_ctrl.sv       \
${SRC_DIR}/apbspi_top.sv            \
${TB_DIR}/apbspi_tb_top.sv          \
+top+tb_top                         \
+timescale+1ns/1ps