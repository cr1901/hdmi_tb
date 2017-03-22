# Support for the MimasV2

import os

from fractions import Fraction

from litex.gen import *
from litex.gen.genlib.resetsync import AsyncResetSynchronizer

from litex.soc.cores.flash import spi_flash
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *

from litedram.modules import MT46H32M16
from litedram.phy import s6ddrphy
from litedram.core import ControllerSettings

from gateware import info
from gateware import cas

from targets.utils import csr_map_update


class _CRG(Module):
    def __init__(self, platform, clk_freq):
        # Clock domains for the system (soft CPU and related components run at).
        self.clock_domains.cd_sys = ClockDomain()
        # Clock domain for peripherals (such as HDMI output).
        self.clock_domains.cd_por = ClockDomain()
        self.clock_domains.cd_base100 = ClockDomain()
        self.reset = Signal()

        # Input 100MHz clock
        f0 = 100*1000000
        clk100 = platform.request("clk100")

        # Power on Reset (vendor agnostic)
        int_rst = Signal(reset=1)
        self.sync.por += int_rst.eq(0)
        self.comb += [
            self.cd_base100.clk.eq(clk100),
            self.cd_por.clk.eq(clk100),
            self.cd_por.rst.eq(~platform.request("user_btn", 5)),
            self.cd_sys.rst.eq(int_rst)
        ]

        self.sync.base100 += [
            self.cd_sys.clk.eq(~self.cd_sys.clk)
        ]

        # platform.add_period_constraint(self.cd_base50.clk, 20)


class BaseSoC(SoCCore):
    csr_peripherals = (
        "cas",
    )
    csr_map_update(SoCCore.csr_map, csr_peripherals)

    def __init__(self, platform, **kwargs):
        cpu_reset_address = platform.gateware_size

        clk_freq = 50*1000*1000
        SoCCore.__init__(self, platform, clk_freq,
            integrated_rom_size=0x5000,
            integrated_sram_size=0x2400,
            # integrated_main_ram_size=0x10000,
            uart_baudrate=(19200, 115200)[int(os.environ.get('JIMMO', '0'))],
            cpu_reset_address=cpu_reset_address,
            **kwargs)
        self.submodules.crg = _CRG(platform, clk_freq)
        self.platform.add_period_constraint(self.crg.cd_sys.clk, 1e9/clk_freq)

        bios_size = 0x8000
        # self.submodules.info = info.Info(platform, "mimasv2", self.__class__.__name__[:8])
        # self.submodules.cas = cas.ControlAndStatus(platform, clk_freq)

SoC = BaseSoC
