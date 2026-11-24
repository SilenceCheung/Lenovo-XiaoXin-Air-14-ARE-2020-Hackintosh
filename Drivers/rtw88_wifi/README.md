# Realtek RTL8822CE PCIe Wi-Fi Driver for macOS Sequoia
# 联想小新 Air 14 ARE 2020 专用 RTL8822CE 驱动与 ASPM 补丁套件

本项目提供了针对 Realtek RTL8822CE (`10ec:c822`) PCIe 无线网卡在 macOS 15 Sequoia / 14 Sonoma 下的完整驱动解决方案，彻底解决了 AMD Renoir 平台上的 **1,977 次 DMA 总线超时死锁** 与 **丢包断网** 顽疾。

## 组件清单
1. **`SSDT-ASPM-FIX.dsl` / `SSDT-ASPM-FIX.aml`**：
   * ACPI 热补丁，向 `\_SB.PCI0.GPP6.WLAN` 注入 `"pci-aspm-default" = 0`，关闭总线 ASPM 低功耗状态，彻底清除 DMA 超时。
2. **`rtw88.kext`**：
   * 编译完成的高稳定性内核扩展驱动（直接部署于 `EFI/OC/Kexts/`）。
3. **`rtw88ctl`**：
   * 用户态命令行管理工具，支持终端内快速扫描（scan）与连接（connect）Wi-Fi。
4. **`src/`**：
   * 包含全套 C++/C 驱动源码、Linux mac80211 适配层、微码固件与 MacKernelSDK 编译环境。

详细的软硬件攻坚机理、内核分析与编译教程请参阅：  
👉 [docs/RTW88_WIFI_DRIVER_GUIDE.md](../../docs/RTW88_WIFI_DRIVER_GUIDE.md)
