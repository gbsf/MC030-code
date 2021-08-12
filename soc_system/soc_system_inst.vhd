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
			hps_0_f2h_dma_req2_dma_req             : in    std_logic                     := 'X';             -- dma_req
			hps_0_f2h_dma_req2_dma_single          : in    std_logic                     := 'X';             -- dma_single
			hps_0_f2h_dma_req2_dma_ack             : out   std_logic;                                        -- dma_ack
			hps_0_f2h_dma_req3_dma_req             : in    std_logic                     := 'X';             -- dma_req
			hps_0_f2h_dma_req3_dma_single          : in    std_logic                     := 'X';             -- dma_single
			hps_0_f2h_dma_req3_dma_ack             : out   std_logic;                                        -- dma_ack
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
			to_external_bus_bridge_0_interrupt_irq : out   std_logic                                         -- irq
		);
	end component soc_system;

	u0 : component soc_system
		port map (
			altchip_id_clkin_clk                   => CONNECTED_TO_altchip_id_clkin_clk,                   --                   altchip_id_clkin.clk
			altchip_id_output_valid                => CONNECTED_TO_altchip_id_output_valid,                --                  altchip_id_output.valid
			altchip_id_output_data                 => CONNECTED_TO_altchip_id_output_data,                 --                                   .data
			altchip_id_reset_reset                 => CONNECTED_TO_altchip_id_reset_reset,                 --                   altchip_id_reset.reset
			external_bridge_acknowledge            => CONNECTED_TO_external_bridge_acknowledge,            --                    external_bridge.acknowledge
			external_bridge_irq                    => CONNECTED_TO_external_bridge_irq,                    --                                   .irq
			external_bridge_address                => CONNECTED_TO_external_bridge_address,                --                                   .address
			external_bridge_bus_enable             => CONNECTED_TO_external_bridge_bus_enable,             --                                   .bus_enable
			external_bridge_byte_enable            => CONNECTED_TO_external_bridge_byte_enable,            --                                   .byte_enable
			external_bridge_rw                     => CONNECTED_TO_external_bridge_rw,                     --                                   .rw
			external_bridge_write_data             => CONNECTED_TO_external_bridge_write_data,             --                                   .write_data
			external_bridge_read_data              => CONNECTED_TO_external_bridge_read_data,              --                                   .read_data
			hps_0_f2h_dma_req2_dma_req             => CONNECTED_TO_hps_0_f2h_dma_req2_dma_req,             --                 hps_0_f2h_dma_req2.dma_req
			hps_0_f2h_dma_req2_dma_single          => CONNECTED_TO_hps_0_f2h_dma_req2_dma_single,          --                                   .dma_single
			hps_0_f2h_dma_req2_dma_ack             => CONNECTED_TO_hps_0_f2h_dma_req2_dma_ack,             --                                   .dma_ack
			hps_0_f2h_dma_req3_dma_req             => CONNECTED_TO_hps_0_f2h_dma_req3_dma_req,             --                 hps_0_f2h_dma_req3.dma_req
			hps_0_f2h_dma_req3_dma_single          => CONNECTED_TO_hps_0_f2h_dma_req3_dma_single,          --                                   .dma_single
			hps_0_f2h_dma_req3_dma_ack             => CONNECTED_TO_hps_0_f2h_dma_req3_dma_ack,             --                                   .dma_ack
			hps_f2h_irq0_irq                       => CONNECTED_TO_hps_f2h_irq0_irq,                       --                       hps_f2h_irq0.irq
			hps_f2h_irq1_irq                       => CONNECTED_TO_hps_f2h_irq1_irq,                       --                       hps_f2h_irq1.irq
			hps_h2f_gp_gp_in                       => CONNECTED_TO_hps_h2f_gp_gp_in,                       --                         hps_h2f_gp.gp_in
			hps_h2f_gp_gp_out                      => CONNECTED_TO_hps_h2f_gp_gp_out,                      --                                   .gp_out
			hps_h2f_mpu_events_eventi              => CONNECTED_TO_hps_h2f_mpu_events_eventi,              --                 hps_h2f_mpu_events.eventi
			hps_h2f_mpu_events_evento              => CONNECTED_TO_hps_h2f_mpu_events_evento,              --                                   .evento
			hps_h2f_mpu_events_standbywfe          => CONNECTED_TO_hps_h2f_mpu_events_standbywfe,          --                                   .standbywfe
			hps_h2f_mpu_events_standbywfi          => CONNECTED_TO_hps_h2f_mpu_events_standbywfi,          --                                   .standbywfi
			hps_h2f_reset_reset_n                  => CONNECTED_TO_hps_h2f_reset_reset_n,                  --                      hps_h2f_reset.reset_n
			hps_io_hps_io_emac1_inst_TX_CLK        => CONNECTED_TO_hps_io_hps_io_emac1_inst_TX_CLK,        --                             hps_io.hps_io_emac1_inst_TX_CLK
			hps_io_hps_io_emac1_inst_TXD0          => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD0,          --                                   .hps_io_emac1_inst_TXD0
			hps_io_hps_io_emac1_inst_TXD1          => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD1,          --                                   .hps_io_emac1_inst_TXD1
			hps_io_hps_io_emac1_inst_TXD2          => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD2,          --                                   .hps_io_emac1_inst_TXD2
			hps_io_hps_io_emac1_inst_TXD3          => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD3,          --                                   .hps_io_emac1_inst_TXD3
			hps_io_hps_io_emac1_inst_RXD0          => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD0,          --                                   .hps_io_emac1_inst_RXD0
			hps_io_hps_io_emac1_inst_MDIO          => CONNECTED_TO_hps_io_hps_io_emac1_inst_MDIO,          --                                   .hps_io_emac1_inst_MDIO
			hps_io_hps_io_emac1_inst_MDC           => CONNECTED_TO_hps_io_hps_io_emac1_inst_MDC,           --                                   .hps_io_emac1_inst_MDC
			hps_io_hps_io_emac1_inst_RX_CTL        => CONNECTED_TO_hps_io_hps_io_emac1_inst_RX_CTL,        --                                   .hps_io_emac1_inst_RX_CTL
			hps_io_hps_io_emac1_inst_TX_CTL        => CONNECTED_TO_hps_io_hps_io_emac1_inst_TX_CTL,        --                                   .hps_io_emac1_inst_TX_CTL
			hps_io_hps_io_emac1_inst_RX_CLK        => CONNECTED_TO_hps_io_hps_io_emac1_inst_RX_CLK,        --                                   .hps_io_emac1_inst_RX_CLK
			hps_io_hps_io_emac1_inst_RXD1          => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD1,          --                                   .hps_io_emac1_inst_RXD1
			hps_io_hps_io_emac1_inst_RXD2          => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD2,          --                                   .hps_io_emac1_inst_RXD2
			hps_io_hps_io_emac1_inst_RXD3          => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD3,          --                                   .hps_io_emac1_inst_RXD3
			hps_io_hps_io_qspi_inst_IO0            => CONNECTED_TO_hps_io_hps_io_qspi_inst_IO0,            --                                   .hps_io_qspi_inst_IO0
			hps_io_hps_io_qspi_inst_IO1            => CONNECTED_TO_hps_io_hps_io_qspi_inst_IO1,            --                                   .hps_io_qspi_inst_IO1
			hps_io_hps_io_qspi_inst_IO2            => CONNECTED_TO_hps_io_hps_io_qspi_inst_IO2,            --                                   .hps_io_qspi_inst_IO2
			hps_io_hps_io_qspi_inst_IO3            => CONNECTED_TO_hps_io_hps_io_qspi_inst_IO3,            --                                   .hps_io_qspi_inst_IO3
			hps_io_hps_io_qspi_inst_SS0            => CONNECTED_TO_hps_io_hps_io_qspi_inst_SS0,            --                                   .hps_io_qspi_inst_SS0
			hps_io_hps_io_qspi_inst_CLK            => CONNECTED_TO_hps_io_hps_io_qspi_inst_CLK,            --                                   .hps_io_qspi_inst_CLK
			hps_io_hps_io_sdio_inst_CMD            => CONNECTED_TO_hps_io_hps_io_sdio_inst_CMD,            --                                   .hps_io_sdio_inst_CMD
			hps_io_hps_io_sdio_inst_D0             => CONNECTED_TO_hps_io_hps_io_sdio_inst_D0,             --                                   .hps_io_sdio_inst_D0
			hps_io_hps_io_sdio_inst_D1             => CONNECTED_TO_hps_io_hps_io_sdio_inst_D1,             --                                   .hps_io_sdio_inst_D1
			hps_io_hps_io_sdio_inst_CLK            => CONNECTED_TO_hps_io_hps_io_sdio_inst_CLK,            --                                   .hps_io_sdio_inst_CLK
			hps_io_hps_io_sdio_inst_D2             => CONNECTED_TO_hps_io_hps_io_sdio_inst_D2,             --                                   .hps_io_sdio_inst_D2
			hps_io_hps_io_sdio_inst_D3             => CONNECTED_TO_hps_io_hps_io_sdio_inst_D3,             --                                   .hps_io_sdio_inst_D3
			hps_io_hps_io_usb1_inst_D0             => CONNECTED_TO_hps_io_hps_io_usb1_inst_D0,             --                                   .hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1             => CONNECTED_TO_hps_io_hps_io_usb1_inst_D1,             --                                   .hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2             => CONNECTED_TO_hps_io_hps_io_usb1_inst_D2,             --                                   .hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3             => CONNECTED_TO_hps_io_hps_io_usb1_inst_D3,             --                                   .hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4             => CONNECTED_TO_hps_io_hps_io_usb1_inst_D4,             --                                   .hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5             => CONNECTED_TO_hps_io_hps_io_usb1_inst_D5,             --                                   .hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6             => CONNECTED_TO_hps_io_hps_io_usb1_inst_D6,             --                                   .hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7             => CONNECTED_TO_hps_io_hps_io_usb1_inst_D7,             --                                   .hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK            => CONNECTED_TO_hps_io_hps_io_usb1_inst_CLK,            --                                   .hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP            => CONNECTED_TO_hps_io_hps_io_usb1_inst_STP,            --                                   .hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR            => CONNECTED_TO_hps_io_hps_io_usb1_inst_DIR,            --                                   .hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT            => CONNECTED_TO_hps_io_hps_io_usb1_inst_NXT,            --                                   .hps_io_usb1_inst_NXT
			hps_io_hps_io_spim1_inst_CLK           => CONNECTED_TO_hps_io_hps_io_spim1_inst_CLK,           --                                   .hps_io_spim1_inst_CLK
			hps_io_hps_io_spim1_inst_MOSI          => CONNECTED_TO_hps_io_hps_io_spim1_inst_MOSI,          --                                   .hps_io_spim1_inst_MOSI
			hps_io_hps_io_spim1_inst_MISO          => CONNECTED_TO_hps_io_hps_io_spim1_inst_MISO,          --                                   .hps_io_spim1_inst_MISO
			hps_io_hps_io_spim1_inst_SS0           => CONNECTED_TO_hps_io_hps_io_spim1_inst_SS0,           --                                   .hps_io_spim1_inst_SS0
			hps_io_hps_io_uart0_inst_RX            => CONNECTED_TO_hps_io_hps_io_uart0_inst_RX,            --                                   .hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX            => CONNECTED_TO_hps_io_hps_io_uart0_inst_TX,            --                                   .hps_io_uart0_inst_TX
			hps_io_hps_io_i2c0_inst_SDA            => CONNECTED_TO_hps_io_hps_io_i2c0_inst_SDA,            --                                   .hps_io_i2c0_inst_SDA
			hps_io_hps_io_i2c0_inst_SCL            => CONNECTED_TO_hps_io_hps_io_i2c0_inst_SCL,            --                                   .hps_io_i2c0_inst_SCL
			hps_io_hps_io_i2c1_inst_SDA            => CONNECTED_TO_hps_io_hps_io_i2c1_inst_SDA,            --                                   .hps_io_i2c1_inst_SDA
			hps_io_hps_io_i2c1_inst_SCL            => CONNECTED_TO_hps_io_hps_io_i2c1_inst_SCL,            --                                   .hps_io_i2c1_inst_SCL
			hps_io_hps_io_gpio_inst_GPIO09         => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO09,         --                                   .hps_io_gpio_inst_GPIO09
			hps_io_hps_io_gpio_inst_GPIO35         => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO35,         --                                   .hps_io_gpio_inst_GPIO35
			hps_io_hps_io_gpio_inst_GPIO40         => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO40,         --                                   .hps_io_gpio_inst_GPIO40
			hps_io_hps_io_gpio_inst_GPIO48         => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO48,         --                                   .hps_io_gpio_inst_GPIO48
			hps_io_hps_io_gpio_inst_GPIO53         => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO53,         --                                   .hps_io_gpio_inst_GPIO53
			hps_io_hps_io_gpio_inst_GPIO54         => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO54,         --                                   .hps_io_gpio_inst_GPIO54
			hps_io_hps_io_gpio_inst_GPIO61         => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO61,         --                                   .hps_io_gpio_inst_GPIO61
			id_hi_export                           => CONNECTED_TO_id_hi_export,                           --                              id_hi.export
			id_low_export                          => CONNECTED_TO_id_low_export,                          --                             id_low.export
			memory_mem_a                           => CONNECTED_TO_memory_mem_a,                           --                             memory.mem_a
			memory_mem_ba                          => CONNECTED_TO_memory_mem_ba,                          --                                   .mem_ba
			memory_mem_ck                          => CONNECTED_TO_memory_mem_ck,                          --                                   .mem_ck
			memory_mem_ck_n                        => CONNECTED_TO_memory_mem_ck_n,                        --                                   .mem_ck_n
			memory_mem_cke                         => CONNECTED_TO_memory_mem_cke,                         --                                   .mem_cke
			memory_mem_cs_n                        => CONNECTED_TO_memory_mem_cs_n,                        --                                   .mem_cs_n
			memory_mem_ras_n                       => CONNECTED_TO_memory_mem_ras_n,                       --                                   .mem_ras_n
			memory_mem_cas_n                       => CONNECTED_TO_memory_mem_cas_n,                       --                                   .mem_cas_n
			memory_mem_we_n                        => CONNECTED_TO_memory_mem_we_n,                        --                                   .mem_we_n
			memory_mem_reset_n                     => CONNECTED_TO_memory_mem_reset_n,                     --                                   .mem_reset_n
			memory_mem_dq                          => CONNECTED_TO_memory_mem_dq,                          --                                   .mem_dq
			memory_mem_dqs                         => CONNECTED_TO_memory_mem_dqs,                         --                                   .mem_dqs
			memory_mem_dqs_n                       => CONNECTED_TO_memory_mem_dqs_n,                       --                                   .mem_dqs_n
			memory_mem_odt                         => CONNECTED_TO_memory_mem_odt,                         --                                   .mem_odt
			memory_mem_dm                          => CONNECTED_TO_memory_mem_dm,                          --                                   .mem_dm
			memory_oct_rzqin                       => CONNECTED_TO_memory_oct_rzqin,                       --                                   .oct_rzqin
			sys_clk_clk                            => CONNECTED_TO_sys_clk_clk,                            --                            sys_clk.clk
			sys_ref_clk_clk                        => CONNECTED_TO_sys_ref_clk_clk,                        --                        sys_ref_clk.clk
			sys_ref_reset_reset                    => CONNECTED_TO_sys_ref_reset_reset,                    --                      sys_ref_reset.reset
			to_external_bus_bridge_0_interrupt_irq => CONNECTED_TO_to_external_bus_bridge_0_interrupt_irq  -- to_external_bus_bridge_0_interrupt.irq
		);

