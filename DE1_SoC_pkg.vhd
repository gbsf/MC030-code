-- SPDX-License-Identifier: MIT
-- SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

library altera, ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use altera.altera_syn_attributes.all;

package DE1_SoC_pkg is
  function clog2(constant val : in integer) return positive;

  constant NUM_FP_FORMATS : positive := 5;
  constant FP_FORMAT_BITS : positive := clog2(NUM_FP_FORMATS);
  
  constant NUM_INT_FORMATS : positive := 4;
  constant INT_FORMAT_BITS : positive := clog2(NUM_INT_FORMATS);
  
  constant NUM_OPGROUPS : positive := 4;
  
  type fp_format_e is (FP32, FP64, FP16, FP8, FP16ALT);
  attribute enum_encoding of fp_format_e : type is "sequential";
  type int_format_e is (INT8, INT16, INT32, INT64);
  attribute enum_encoding of int_format_e : type is "sequential";
  
  type fmt_logic_t is array(fp_format_e) of std_logic;
  type fmt_unsigned_t is array (fp_format_e) of natural;

  type ifmt_logic_t is array(int_format_e) of std_logic;
  
  type fpu_features_t is record
    Width         : positive;
    EnableVectors : std_logic;
    EnableNanBox  : std_logic;
    FpFmtMask     : fmt_logic_t;
    IntFmtMask    : ifmt_logic_t;
  end record fpu_features_t;
  
  type status_t is record
    \NV\ : std_logic;
    \DZ\ : std_logic;
    \OF\ : std_logic;
    \UF\ : std_logic;
    \NX\ : std_logic;
  end record status_t;
  
  type operation_e is (
    FMADD, FNMSUB, ADD, MUL,     -- ADDMUL operation group
    DIV, SQRT,                   -- DIVSQRT operation group
    SGNJ, MINMAX, CMP, CLASSIFY, -- NONCOMP operation group
    F2F, F2I, I2F, CPKAB, CPKCD  -- CONV operation group
  );
  attribute enum_encoding of operation_e : type is "sequential";
  
  type roundmode_e is (RNE, RTZ, RDN, RUP, RMM, DYN);
  attribute enum_encoding of roundmode_e : type is "000 001 010 011 100 111"; -- note last element
  
  type pipe_config_t is (
    \BEFORE\,     -- registers are inserted at the inputs of the unit
    \AFTER\,      -- registers are inserted at the outputs of the unit
    \INSIDE\,     -- registers are inserted at predetermined (suboptimal) locations in the unit
    \DISTRIBUTED\ -- registers are evenly distributed, INSIDE >= AFTER >= BEFORE
  );
  attribute enum_encoding of pipe_config_t : type is "sequential";

  type opgroup_e is (ADDMUL, DIVSQRT, NONCOMP, CONV);
  attribute enum_encoding of opgroup_e : type is "sequential";
  
  -- Cannot be enum unfortunately
  subtype unit_type_t is std_logic_vector(1 downto 0);
  constant DISABLED : unit_type_t := "00";
  constant PARALLEL : unit_type_t := "01";
  constant MERGED   : unit_type_t := "10";

  type fmt_unit_types_t is array(fp_format_e) of unit_type_t;

  type opgrp_fmt_unit_types_t is array(opgroup_e) of fmt_unit_types_t;
  type opgrp_fmt_unsigned_t is array(opgroup_e) of fmt_unsigned_t;
  
  type fpu_implementation_t is record
    PipeRegs   : opgrp_fmt_unsigned_t;
    UnitTypes  : opgrp_fmt_unit_types_t;
    PipeConfig : pipe_config_t;
  end record fpu_implementation_t;
  
  constant RV64D_Xsflt_nobox : fpu_features_t := (
    Width         => 64,
    EnableVectors => '1',
    EnableNanBox  => '0',
    FpFmtMask     => "11111",
    IntFmtMask    => "1111"
  );
  
  constant DEFAULT_NOREGS : fpu_implementation_t := (
    PipeRegs   => (others => (others => 0)),
    UnitTypes  => (ADDMUL  => (others => PARALLEL),
                   DIVSQRT => (others => MERGED),
                   NONCOMP => (others => PARALLEL),
                   CONV    => (others => MERGED)),
    PipeConfig => BEFORE
  );
  
  constant PIPELINED : fpu_implementation_t := (
    PipeRegs   => (DIVSQRT => (others => 3),
                   others  => (others => 1)),
    UnitTypes  => (ADDMUL  => (others => PARALLEL),
                   DIVSQRT => (others => MERGED),
                   NONCOMP => (others => PARALLEL),
                   CONV    => (others => MERGED)),
    PipeConfig => DISTRIBUTED
  );
  
  alias DefaultFeatures : fpu_features_t is RV64D_Xsflt_nobox;

  type op_vec is array(natural range <>) of std_logic_vector;

  constant WIDTH : positive := 64;
  constant NUM_OPERANDS : positive := 3;
  component fpnew_nogen 
--    generic(
--      Features        : fpu_features_t := DefaultFeatures;
--      Implementation  : fpu_implementation_t := PIPELINED;
--      WIDTH           : positive := DefaultFeatures.Width; -- same as Features
--      NUM_OPERANDS    : positive := 3
--    );
    port(
      clk_i           : in    std_logic;
      rst_ni          : in    std_logic;
      operands_i      : in    op_vec(NUM_OPERANDS-1 downto 0)(WIDTH-1 downto 0);
      rnd_mode_i      : in    roundmode_e;
      op_i            : in    operation_e;
      op_mod_i        : in    std_logic;
      src_fmt_i       : in    fp_format_e;
      dst_fmt_i       : in    fp_format_e;
      int_fmt_i       : in    int_format_e;
      vectorial_op_i  : in    std_logic;
      tag_i           : in    std_logic;
      in_valid_i      : in    std_logic;
      in_ready_o      : out   std_logic;
      flush_i         : in    std_logic;
      result_o        : out   std_logic_vector(WIDTH-1 downto 0);
      status_o        : out   status_t;
      tag_o           : out   std_logic;
      out_valid_o     : out   std_logic;
      out_ready_i     : in    std_logic;
      busy_o          : out   std_logic
    );
  end component;
  
  component soc_system is
    port (
      altchip_id_clkin_clk                   : in    std_logic                     := 'X';             -- clk
      altchip_id_output_valid                : out   std_logic;                                        -- valid
      altchip_id_output_data                 : out   std_logic_vector(63 downto 0);                    -- data
      altchip_id_reset_reset                 : in    std_logic                     := 'X';             -- reset
      external_bridge_acknowledge            : in    std_logic                     := 'X';             -- acknowledge
      external_bridge_irq                    : in    std_logic                     := 'X';             -- irq
      external_bridge_address                : out   std_logic_vector(5 downto 0);                     -- address
      external_bridge_bus_enable             : out   std_logic;                                        -- bus_enable
      external_bridge_byte_enable            : out   std_logic_vector(7 downto 0);                     -- byte_enable
      external_bridge_rw                     : out   std_logic;                                        -- rw
      external_bridge_write_data             : out   std_logic_vector(63 downto 0);                    -- write_data
      external_bridge_read_data              : in    std_logic_vector(63 downto 0) := (others => 'X'); -- read_data
      hps_f2h_irq0_irq                       : in    std_logic_vector(31 downto 0) := (others => 'X'); -- irq
      hps_f2h_irq1_irq                       : in    std_logic_vector(31 downto 0) := (others => 'X'); -- irq
      hps_h2f_gp_gp_in                       : in    std_logic_vector(31 downto 0) := (others => 'X'); -- gp_in
      hps_h2f_gp_gp_out                      : out   std_logic_vector(31 downto 0);                    -- gp_out
      hps_h2f_mpu_events_eventi              : in    std_logic                     := 'X';             -- eventi
      hps_h2f_mpu_events_evento              : out   std_logic;                                        -- evento
      hps_h2f_mpu_events_standbywfe          : out   std_logic_vector(1 downto 0);                     -- standbywfe
      hps_h2f_mpu_events_standbywfi          : out   std_logic_vector(1 downto 0);                     -- standbywfi
      hps_h2f_reset_reset_n                  : out   std_logic;                                        -- reset_n
      hps_io_hps_io_emac1_inst_TX_CLK        : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
      hps_io_hps_io_emac1_inst_TXD0          : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
      hps_io_hps_io_emac1_inst_TXD1          : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
      hps_io_hps_io_emac1_inst_TXD2          : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
      hps_io_hps_io_emac1_inst_TXD3          : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
      hps_io_hps_io_emac1_inst_RXD0          : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
      hps_io_hps_io_emac1_inst_MDIO          : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
      hps_io_hps_io_emac1_inst_MDC           : out   std_logic;                                        -- hps_io_emac1_inst_MDC
      hps_io_hps_io_emac1_inst_RX_CTL        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
      hps_io_hps_io_emac1_inst_TX_CTL        : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
      hps_io_hps_io_emac1_inst_RX_CLK        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
      hps_io_hps_io_emac1_inst_RXD1          : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
      hps_io_hps_io_emac1_inst_RXD2          : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
      hps_io_hps_io_emac1_inst_RXD3          : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
      hps_io_hps_io_qspi_inst_IO0            : inout std_logic                     := 'X';             -- hps_io_qspi_inst_IO0
      hps_io_hps_io_qspi_inst_IO1            : inout std_logic                     := 'X';             -- hps_io_qspi_inst_IO1
      hps_io_hps_io_qspi_inst_IO2            : inout std_logic                     := 'X';             -- hps_io_qspi_inst_IO2
      hps_io_hps_io_qspi_inst_IO3            : inout std_logic                     := 'X';             -- hps_io_qspi_inst_IO3
      hps_io_hps_io_qspi_inst_SS0            : out   std_logic;                                        -- hps_io_qspi_inst_SS0
      hps_io_hps_io_qspi_inst_CLK            : out   std_logic;                                        -- hps_io_qspi_inst_CLK
      hps_io_hps_io_sdio_inst_CMD            : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
      hps_io_hps_io_sdio_inst_D0             : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
      hps_io_hps_io_sdio_inst_D1             : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
      hps_io_hps_io_sdio_inst_CLK            : out   std_logic;                                        -- hps_io_sdio_inst_CLK
      hps_io_hps_io_sdio_inst_D2             : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
      hps_io_hps_io_sdio_inst_D3             : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
      hps_io_hps_io_usb1_inst_D0             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
      hps_io_hps_io_usb1_inst_D1             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
      hps_io_hps_io_usb1_inst_D2             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
      hps_io_hps_io_usb1_inst_D3             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
      hps_io_hps_io_usb1_inst_D4             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
      hps_io_hps_io_usb1_inst_D5             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
      hps_io_hps_io_usb1_inst_D6             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
      hps_io_hps_io_usb1_inst_D7             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
      hps_io_hps_io_usb1_inst_CLK            : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
      hps_io_hps_io_usb1_inst_STP            : out   std_logic;                                        -- hps_io_usb1_inst_STP
      hps_io_hps_io_usb1_inst_DIR            : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
      hps_io_hps_io_usb1_inst_NXT            : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
      hps_io_hps_io_spim1_inst_CLK           : out   std_logic;                                        -- hps_io_spim1_inst_CLK
      hps_io_hps_io_spim1_inst_MOSI          : out   std_logic;                                        -- hps_io_spim1_inst_MOSI
      hps_io_hps_io_spim1_inst_MISO          : in    std_logic                     := 'X';             -- hps_io_spim1_inst_MISO
      hps_io_hps_io_spim1_inst_SS0           : out   std_logic;                                        -- hps_io_spim1_inst_SS0
      hps_io_hps_io_uart0_inst_RX            : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
      hps_io_hps_io_uart0_inst_TX            : out   std_logic;                                        -- hps_io_uart0_inst_TX
      hps_io_hps_io_i2c0_inst_SDA            : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SDA
      hps_io_hps_io_i2c0_inst_SCL            : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SCL
      hps_io_hps_io_i2c1_inst_SDA            : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
      hps_io_hps_io_i2c1_inst_SCL            : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
      hps_io_hps_io_gpio_inst_GPIO09         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
      hps_io_hps_io_gpio_inst_GPIO35         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO35
      hps_io_hps_io_gpio_inst_GPIO40         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO40
      hps_io_hps_io_gpio_inst_GPIO48         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO48
      hps_io_hps_io_gpio_inst_GPIO53         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO53
      hps_io_hps_io_gpio_inst_GPIO54         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
      hps_io_hps_io_gpio_inst_GPIO61         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO61
      id_hi_export                           : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
      id_low_export                          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
      memory_mem_a                           : out   std_logic_vector(14 downto 0);                    -- mem_a
      memory_mem_ba                          : out   std_logic_vector(2 downto 0);                     -- mem_ba
      memory_mem_ck                          : out   std_logic;                                        -- mem_ck
      memory_mem_ck_n                        : out   std_logic;                                        -- mem_ck_n
      memory_mem_cke                         : out   std_logic;                                        -- mem_cke
      memory_mem_cs_n                        : out   std_logic;                                        -- mem_cs_n
      memory_mem_ras_n                       : out   std_logic;                                        -- mem_ras_n
      memory_mem_cas_n                       : out   std_logic;                                        -- mem_cas_n
      memory_mem_we_n                        : out   std_logic;                                        -- mem_we_n
      memory_mem_reset_n                     : out   std_logic;                                        -- mem_reset_n
      memory_mem_dq                          : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
      memory_mem_dqs                         : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
      memory_mem_dqs_n                       : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
      memory_mem_odt                         : out   std_logic;                                        -- mem_odt
      memory_mem_dm                          : out   std_logic_vector(3 downto 0);                     -- mem_dm
      memory_oct_rzqin                       : in    std_logic                     := 'X';             -- oct_rzqin
      sys_clk_clk                            : out   std_logic;                                        -- clk
      sys_ref_clk_clk                        : in    std_logic                     := 'X';             -- clk
      sys_ref_reset_reset                    : in    std_logic                     := 'X';             -- reset
      to_external_bus_bridge_0_interrupt_irq : out   std_logic;                                        -- irq
      hps_0_f2h_dma_req2_dma_req             : in    std_logic                     := 'X';             -- dma_req
      hps_0_f2h_dma_req2_dma_single          : in    std_logic                     := 'X';             -- dma_single
      hps_0_f2h_dma_req2_dma_ack             : out   std_logic;                                        -- dma_ack
      hps_0_f2h_dma_req3_dma_req             : in    std_logic                     := 'X';             -- dma_req
      hps_0_f2h_dma_req3_dma_single          : in    std_logic                     := 'X';             -- dma_single
      hps_0_f2h_dma_req3_dma_ack             : out   std_logic                                         -- dma_ack
    );
  end component soc_system;
end package;

package body DE1_SoC_pkg is
  function clog2(val : in integer) return positive is begin
    return positive(ceil(log2(real(val))));
  end function clog2;
end package body;
