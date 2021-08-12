-- SPDX-License-Identifier: MIT
-- SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.DE1_SoC_pkg.all;

entity DE1_SoC is port (
  CLOCK_50  : in std_logic;
  CLOCK2_50 : in std_logic;
  CLOCK3_50 : in std_logic;
  CLOCK4_50 : in std_logic;

  GPIO_0 : inout std_logic_vector(0 to 35);
  GPIO_1 : inout std_logic_vector(0 to 35);
  HEX0   : out   std_logic_vector(0 to 6);
  HEX1   : out   std_logic_vector(0 to 6);
  HEX2   : out   std_logic_vector(0 to 6);
  HEX3   : out   std_logic_vector(0 to 6);
  HEX4   : out   std_logic_vector(0 to 6);
  HEX5   : out   std_logic_vector(0 to 6);
  KEY  : in  std_logic_vector(0 to 3);
  LEDR : out std_logic_vector(0 to 9);
  SW   : in  std_logic_vector(0 to 9);

  HPS_CONV_USB_N   : inout std_logic;
  HPS_DDR3_ADDR    : out   std_logic_vector(14 downto 0);
  HPS_DDR3_BA      : out  std_logic_vector(2 downto 0);
  HPS_DDR3_CAS_N   : out   std_logic;
  HPS_DDR3_CKE     : out   std_logic;
  HPS_DDR3_CK_N    : out   std_logic;
  HPS_DDR3_CK_P    : out   std_logic;
  HPS_DDR3_CS_N    : out   std_logic;
  HPS_DDR3_DM      : out   std_logic_vector(3 downto 0);
  HPS_DDR3_DQ      : inout std_logic_vector(31 downto 0);
  HPS_DDR3_DQS_N   : inout std_logic_vector(3 downto 0);
  HPS_DDR3_DQS_P   : inout std_logic_vector(3 downto 0);
  HPS_DDR3_ODT     : out   std_logic;
  HPS_DDR3_RAS_N   : out   std_logic;
  HPS_DDR3_RESET_N : out   std_logic;
  HPS_DDR3_RZQ     : in    std_logic;
  HPS_DDR3_WE_N    : out   std_logic;
  HPS_ENET_GTX_CLK : out   std_logic;
  HPS_ENET_INT_N   : inout std_logic;
  HPS_ENET_MDC     : out   std_logic;
  HPS_ENET_MDIO    : inout std_logic;
  HPS_ENET_RX_CLK  : in    std_logic;
  HPS_ENET_RX_DATA : in    std_logic_vector(3 downto 0);
  HPS_ENET_RX_DV   : in    std_logic;
  HPS_ENET_TX_DATA : out   std_logic_vector(3 downto 0);
  HPS_ENET_TX_EN   : out   std_logic;
  HPS_FLASH_DATA   : inout std_logic_vector(3 downto 0);
  HPS_FLASH_DCLK   : out   std_logic;
  HPS_FLASH_NCSO   : out   std_logic;
  HPS_GSENSOR_INT  : inout std_logic;
  HPS_I2C1_SCLK    : inout std_logic;
  HPS_I2C1_SDAT    : inout std_logic;
  HPS_I2C2_SCLK    : inout std_logic;
  HPS_I2C2_SDAT    : inout std_logic;
  HPS_I2C_CONTROL  : inout std_logic;
  HPS_KEY          : inout std_logic;
  HPS_LED          : inout std_logic;
  HPS_LTC_GPIO     : inout std_logic;
  HPS_SD_CLK       : out   std_logic;
  HPS_SD_CMD       : inout std_logic;
  HPS_SD_DATA      : inout std_logic_vector(3 downto 0);
  HPS_SPIM_CLK     : out   std_logic;
  HPS_SPIM_MISO    : in    std_logic;
  HPS_SPIM_MOSI    : out   std_logic;
  HPS_SPIM_SS      : inout std_logic;
  HPS_UART_RX      : in    std_logic;
  HPS_UART_TX      : out   std_logic;
  HPS_USB_CLKOUT   : in    std_logic;
  HPS_USB_DATA     : inout std_logic_vector(7 downto 0);
  HPS_USB_DIR      : in    std_logic;
  HPS_USB_NXT      : in    std_logic;
  HPS_USB_STP      : out   std_logic
);
end entity;

architecture arch1 of DE1_SoC is
  signal clk_i, rst_ni, op_mod_i, vectorial_op_i, tag_i, in_valid_i, flush_i, out_ready_i : std_logic;
  signal rnd_mode_i : roundmode_e;
  signal op_i : operation_e;
  signal src_fmt_i, dst_fmt_i : fp_format_e;
  signal int_fmt_i : int_format_e;

  signal in_ready_o, out_valid_o, busy_o : std_logic;
  signal status_o : status_t;
  signal status_reg : status_t := (others => '0');

  signal operands_i : op_vec(2 downto 0)(63 downto 0);
  signal result_reg, result_o, altchip_data : std_logic_vector(63 downto 0);
  signal altchip_valid : std_logic;
  type hex_slv is array (0 to 5) of std_logic_vector(0 to 6);
  signal HEX : hex_slv;


  signal result_mux : std_logic_vector(15 downto 0);

  signal ext_ack, ext_irq, ext_busen, ext_rw : std_logic;
  signal ext_addr : std_logic_vector(5 downto 0);
  signal ext_byten : std_logic_vector(7 downto 0);
  signal ext_wdata, ext_rdata : std_logic_vector(63 downto 0);

  signal acknowledge, completed : std_logic;

  signal reg_addr : std_logic_vector(ext_addr'range);

  type oper_state is (READY, WAIT1, READING, DONE);
  signal state : oper_state := READY;

  signal reset_n : std_logic;

  function byte_mask(signal byte_enable : in std_logic_vector) return std_logic_vector is
    variable res : std_logic_vector((byte_enable'length*8)-1 downto 0);
  begin
    if byte_enable'ascending then
      for i in byte_enable'reverse_range loop
        res(8*(i+1)-1 downto 8*i) := (others => byte_enable(byte_enable'high-i));
      end loop;
    else
      for i in byte_enable'range loop
        res(8*(i+1)-1 downto 8*i) := (others => byte_enable(i));
      end loop;
    end if;
    return res;
  end function byte_mask;

  function reversed(signal vec : std_logic_vector) return std_logic_vector is 
    variable rev : std_logic_vector(vec'reverse_range);
  begin
    for i in rev'range loop
      rev(i) := vec(i);
    end loop;
    return rev;
  end function reversed;
begin
  rst_ni <= KEY(3) and reset_n;
  tag_i <= '0';
  flush_i <= '0';
  ext_irq <= '0';
  ext_ack <= acknowledge and ext_busen;

  process (all)
    variable opi : integer;
    alias slv is std_logic_vector;
  begin
    if not rst_ni then
      state <= READY;
      operands_i <= (others => (others => '0'));
      reg_addr <= (others => '0');
      result_reg <= (others => '0');
      in_valid_i <= '0';
      out_ready_i <= '0';
      completed <= '0';
    elsif rising_edge(clk_i) then
      in_valid_i <= '0';
      out_ready_i <= '0';
      acknowledge <= '0';
      if ext_busen then
        completed <= '1';
        acknowledge <= not completed; -- 1-cycle delayed
        reg_addr <= ext_addr;
        opi := to_integer(unsigned(ext_addr(5 downto 3)));
        if ext_rw then -- Read
          ext_rdata <= (others => '0');
          case opi is
            when 0 to 2 =>
              ext_rdata  <= operands_i(opi) and byte_mask(ext_byten);
              result_reg <= operands_i(opi);
            when 3 =>
              if ext_byten(0) then
                ext_rdata(2 downto 0) <= slv(to_unsigned(roundmode_e'pos(rnd_mode_i), clog2(roundmode_e'pos(roundmode_e'high)+1)));
                ext_rdata(6 downto 3) <= slv(to_unsigned(operation_e'pos(op_i), clog2(operation_e'pos(operation_e'high)+1)));
                ext_rdata(7) <= op_mod_i;
              end if;
              if ext_byten(1) then
                ext_rdata(10 downto 8) <= slv(to_unsigned(fp_format_e'pos(src_fmt_i), clog2(fp_format_e'pos(fp_format_e'high)+1)));
                ext_rdata(13 downto 11) <= slv(to_unsigned(fp_format_e'pos(dst_fmt_i), clog2(fp_format_e'pos(fp_format_e'high)+1)));
                ext_rdata(15 downto 14) <= slv(to_unsigned(int_format_e'pos(int_fmt_i), clog2(int_format_e'pos(int_format_e'high)+1)));
              end if;
              if ext_byten(2) then
                ext_rdata(16) <= vectorial_op_i;
              end if;
            when 4 =>
              case state is
                when READY =>
                  acknowledge <= '0';
                  in_valid_i <= '1';
                  state <= READING;
                when READING =>
                  if out_valid_o then
                    acknowledge <= '1';
                    status_reg <= status_o;
                    result_reg <= result_o;
                    ext_rdata  <= result_o and byte_mask(ext_byten);
                    out_ready_i <= '1';
                    state <= DONE;
                  else
                    acknowledge <= '0';
                  end if;
                when DONE =>
                  out_ready_i <= '1';
                  acknowledge <= '0';
                when others =>
                  acknowledge <= '0';
                  state <= READY;
              end case;
            when 5 =>
              ext_rdata <= (
                4 => status_reg.\NV\,
                3 => status_reg.\DZ\,
                2 => status_reg.\OF\,
                1 => status_reg.\UF\,
                0 => status_reg.\NX\,
                others => '0'
              );
            when others => null;
          end case;
        else -- Write
          case opi is
            when 0 to 2 =>
              operands_i(opi) <= ext_wdata and byte_mask(ext_byten);
              result_reg <= ext_wdata;
            when 3 =>
              if ext_byten(0) then
                rnd_mode_i <= roundmode_e'val(to_integer(unsigned(ext_wdata(2 downto 0))));
                op_i <= operation_e'val(to_integer(unsigned(ext_wdata(6 downto 3))));
                op_mod_i <= ext_wdata(7);
              end if;
              if ext_byten(1) then
                src_fmt_i <= fp_format_e'val(to_integer(unsigned(ext_wdata(10 downto 8))));
                dst_fmt_i <= fp_format_e'val(to_integer(unsigned(ext_wdata(13 downto 11))));
                int_fmt_i <= int_format_e'val(to_integer(unsigned(ext_wdata(15 downto 14))));
              end if;
              if ext_byten(2) then
                vectorial_op_i <= ext_wdata(16);
              end if;
              result_reg <= ext_wdata;
            when others => null;
          end case;
        end if;
      else -- ext_busen
        state <= READY;
        completed <= '0';
      end if;
    end if;
  end process;
  
  LEDR(0 to 9) <= (others => '0');
  HEX0 <= HEX(0);
  HEX1 <= HEX(1);
  HEX2 <= HEX(2);
  HEX3 <= HEX(3);
  HEX4 <= HEX(4);
  HEX5 <= HEX(5);

  with SW(0 to 1) select result_mux <=
    result_reg(15 downto 0)  when "00",
    result_reg(31 downto 16) when "10", -- reversed bits
    result_reg(47 downto 32) when "01",
    result_reg(63 downto 48) when "11",
    x"----" when others;
  
  seg_gen: for i in 0 to 3 generate
    segop: entity work.conv7seg port map (
      bin => result_mux(4*(i+1)-1 downto 4*i),
      en  => '1',
      hex => HEX(i)
    );
  end generate;
  
  addrhi: entity work.conv7seg port map (
    bin => "00" & reg_addr(5 downto 4),
    en  => '1',
    hex => HEX(5)
  );
  addrlo: entity work.conv7seg port map (
    bin => reg_addr(3 downto 0),
    en  => '1',
    hex => HEX(4)
  );

  toplevel: fpnew_nogen port map (
    clk_i          => clk_i,
    rst_ni         => rst_ni,
    operands_i     => operands_i,
    rnd_mode_i     => rnd_mode_i,
    op_i           => op_i,
    op_mod_i       => op_mod_i,
    src_fmt_i      => src_fmt_i,
    dst_fmt_i      => dst_fmt_i,
    int_fmt_i      => int_fmt_i,
    vectorial_op_i => vectorial_op_i,
    tag_i          => tag_i,
    in_valid_i     => in_valid_i,
    in_ready_o     => in_ready_o,
    flush_i        => flush_i,
    result_o       => result_o,
    status_o       => status_o,
    tag_o          => open,
    out_valid_o    => out_valid_o,
    out_ready_i    => out_ready_i,
    busy_o         => busy_o
  );
  
  system: soc_system port map (
    memory_mem_a => HPS_DDR3_ADDR,
    memory_mem_ba => HPS_DDR3_BA,
    memory_mem_ck => HPS_DDR3_CK_P,
    memory_mem_ck_n => HPS_DDR3_CK_N,
    memory_mem_cke => HPS_DDR3_CKE,
    memory_mem_cs_n => HPS_DDR3_CS_N,
    memory_mem_ras_n => HPS_DDR3_RAS_N,
    memory_mem_cas_n => HPS_DDR3_CAS_N,
    memory_mem_we_n => HPS_DDR3_WE_N,
    memory_mem_reset_n => HPS_DDR3_RESET_N,
    memory_mem_dq => HPS_DDR3_DQ,
    memory_mem_dqs => HPS_DDR3_DQS_P,
    memory_mem_dqs_n => HPS_DDR3_DQS_N,
    memory_mem_odt => HPS_DDR3_ODT,
    memory_mem_dm => HPS_DDR3_DM,
    memory_oct_rzqin => HPS_DDR3_RZQ,

    hps_io_hps_io_emac1_inst_TX_CLK => HPS_ENET_GTX_CLK,
    hps_io_hps_io_emac1_inst_TXD0 => HPS_ENET_TX_DATA(0),
    hps_io_hps_io_emac1_inst_TXD1 => HPS_ENET_TX_DATA(1),
    hps_io_hps_io_emac1_inst_TXD2 => HPS_ENET_TX_DATA(2),
    hps_io_hps_io_emac1_inst_TXD3 => HPS_ENET_TX_DATA(3),
    hps_io_hps_io_emac1_inst_RXD0 => HPS_ENET_RX_DATA(0),
    hps_io_hps_io_emac1_inst_MDIO => HPS_ENET_MDIO,
    hps_io_hps_io_emac1_inst_MDC => HPS_ENET_MDC,
    hps_io_hps_io_emac1_inst_RX_CTL => HPS_ENET_RX_DV,
    hps_io_hps_io_emac1_inst_TX_CTL => HPS_ENET_TX_EN,
    hps_io_hps_io_emac1_inst_RX_CLK => HPS_ENET_RX_CLK,
    hps_io_hps_io_emac1_inst_RXD1 => HPS_ENET_RX_DATA(1),
    hps_io_hps_io_emac1_inst_RXD2 => HPS_ENET_RX_DATA(2),
    hps_io_hps_io_emac1_inst_RXD3 => HPS_ENET_RX_DATA(3),

    hps_io_hps_io_qspi_inst_IO0 => HPS_FLASH_DATA(0),
    hps_io_hps_io_qspi_inst_IO1 => HPS_FLASH_DATA(1),
    hps_io_hps_io_qspi_inst_IO2 => HPS_FLASH_DATA(2),
    hps_io_hps_io_qspi_inst_IO3 => HPS_FLASH_DATA(3),
    hps_io_hps_io_qspi_inst_SS0 => HPS_FLASH_NCSO,
    hps_io_hps_io_qspi_inst_CLK => HPS_FLASH_DCLK,

    hps_io_hps_io_sdio_inst_CMD => HPS_SD_CMD,
    hps_io_hps_io_sdio_inst_D0 => HPS_SD_DATA(0),
    hps_io_hps_io_sdio_inst_D1 => HPS_SD_DATA(1),
    hps_io_hps_io_sdio_inst_CLK => HPS_SD_CLK,
    hps_io_hps_io_sdio_inst_D2 => HPS_SD_DATA(2),
    hps_io_hps_io_sdio_inst_D3 => HPS_SD_DATA(3),

    hps_io_hps_io_usb1_inst_D0 => HPS_USB_DATA(0),
    hps_io_hps_io_usb1_inst_D1 => HPS_USB_DATA(1),
    hps_io_hps_io_usb1_inst_D2 => HPS_USB_DATA(2),
    hps_io_hps_io_usb1_inst_D3 => HPS_USB_DATA(3),
    hps_io_hps_io_usb1_inst_D4 => HPS_USB_DATA(4),
    hps_io_hps_io_usb1_inst_D5 => HPS_USB_DATA(5),
    hps_io_hps_io_usb1_inst_D6 => HPS_USB_DATA(6),
    hps_io_hps_io_usb1_inst_D7 => HPS_USB_DATA(7),
    hps_io_hps_io_usb1_inst_CLK => HPS_USB_CLKOUT,
    hps_io_hps_io_usb1_inst_STP => HPS_USB_STP,
    hps_io_hps_io_usb1_inst_DIR => HPS_USB_DIR,
    hps_io_hps_io_usb1_inst_NXT => HPS_USB_NXT,

    hps_io_hps_io_spim1_inst_CLK => HPS_SPIM_CLK,
    hps_io_hps_io_spim1_inst_MOSI => HPS_SPIM_MOSI,
    hps_io_hps_io_spim1_inst_MISO => HPS_SPIM_MISO,
    hps_io_hps_io_spim1_inst_SS0 => HPS_SPIM_SS,

    hps_io_hps_io_uart0_inst_RX => HPS_UART_RX,
    hps_io_hps_io_uart0_inst_TX => HPS_UART_TX,

    hps_io_hps_io_i2c0_inst_SDA => HPS_I2C1_SDAT,
    hps_io_hps_io_i2c0_inst_SCL => HPS_I2C1_SCLK,

    hps_io_hps_io_i2c1_inst_SDA => HPS_I2C2_SDAT,
    hps_io_hps_io_i2c1_inst_SCL => HPS_I2C2_SCLK,

    hps_io_hps_io_gpio_inst_GPIO09 => HPS_CONV_USB_N,
    hps_io_hps_io_gpio_inst_GPIO35 => HPS_ENET_INT_N,
    hps_io_hps_io_gpio_inst_GPIO40 => HPS_LTC_GPIO,
    hps_io_hps_io_gpio_inst_GPIO48 => HPS_I2C_CONTROL,
    hps_io_hps_io_gpio_inst_GPIO53 => HPS_LED,
    hps_io_hps_io_gpio_inst_GPIO54 => HPS_KEY,
    hps_io_hps_io_gpio_inst_GPIO61 => HPS_GSENSOR_INT,

    sys_ref_clk_clk => CLOCK_50,
    
    sys_clk_clk => clk_i,

    altchip_id_clkin_clk => CLOCK_50,
    altchip_id_output_valid => altchip_valid,
    altchip_id_output_data => altchip_data,
    altchip_id_reset_reset => not reset_n,
    id_low_export => altchip_data(31 downto 0),
    id_hi_export => altchip_data(63 downto 32),
    
    hps_f2h_irq0_irq => (others => '0'),
    hps_f2h_irq1_irq => (others => '0'),
    hps_h2f_gp_gp_in => (others => '0'),
    hps_h2f_mpu_events_eventi => '0',
    hps_0_f2h_dma_req2_dma_req => '0',
    hps_0_f2h_dma_req2_dma_single => '0',
    hps_0_f2h_dma_req3_dma_req => '0',
    hps_0_f2h_dma_req3_dma_single => '0',
    
    hps_h2f_reset_reset_n => reset_n,

    external_bridge_acknowledge => ext_ack,   -- external_bridge.acknowledge
    external_bridge_irq         => ext_irq,   --                .irq
    external_bridge_address     => ext_addr,  --                .address
    external_bridge_bus_enable  => ext_busen, --                .bus_enable
    external_bridge_byte_enable => ext_byten, --                .byte_enable
    external_bridge_rw          => ext_rw,    --                .rw
    external_bridge_write_data  => ext_wdata, --                .write_data
    external_bridge_read_data   => ext_rdata  --                .read_data
  );
end architecture;
