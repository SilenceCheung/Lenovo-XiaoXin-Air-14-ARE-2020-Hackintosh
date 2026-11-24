/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (64-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of /Users/silence/Desktop/黑苹果相关/EFI/OC/ACPI/SSDT-HPET.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x0000011E (286)
 *     Revision         0x02
 *     Checksum         0xA6
 *     OEM ID           "CORP"
 *     OEM Table ID     "HPET"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20230628 (539166248)
 */
DefinitionBlock ("", "SSDT", 2, "CORP", "HPET", 0x00000000)
{
    External (_SB_.PCI0.HPET, DeviceObj)
    External (_SB_.PCI0.HPET.XCRS, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.HPET.XSTA, MethodObj)    // 0 Arguments

    Scope (\_SB.PCI0.HPET)
    {
        Name (BUFX, Buffer (0x11)
        {
            /* 0000 */  0x22, 0x01, 0x09, 0x86, 0x09, 0x00, 0x01, 0x00,  // ".......
            /* 0008 */  0x00, 0xD0, 0xFE, 0x00, 0x04, 0x00, 0x00, 0x79,  // .......y
            /* 0010 */  0x00                                             // .
        })
        Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
        {
            If ((_OSI ("Darwin") || !CondRefOf (\_SB.PCI0.HPET.XCRS)))
            {
                Return (BUFX) /* \_SB_.PCI0.HPET.BUFX */
            }

            Return (\_SB.PCI0.HPET.XCRS ())
        }

        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If ((_OSI ("Darwin") || !CondRefOf (\_SB.PCI0.HPET.XSTA)))
            {
                Return (0x0F)
            }

            Return (\_SB.PCI0.HPET.XSTA ())
        }
    }
}

