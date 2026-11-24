/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (64-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of /Users/silence/Desktop/黑苹果相关/EFI/OC/ACPI/SSDT-ASPM-FIX.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000194 (404)
 *     Revision         0x02
 *     Checksum         0xB7
 *     OEM ID           "HACK"
 *     OEM Table ID     "AspmFix"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20260408 (539362312)
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "AspmFix", 0x00001000)
{
    External (_SB_.PCI0.GPP5, DeviceObj)
    External (_SB_.PCI0.GPP5.LAN_, DeviceObj)
    External (_SB_.PCI0.GPP6, DeviceObj)
    External (_SB_.PCI0.GPP6.WLAN, DeviceObj)

    Scope (\_SB.PCI0.GPP5)
    {
        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
        {
            Return (Zero)
        }
    }

    Scope (\_SB.PCI0.GPP5.LAN)
    {
        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
        {
            Return (Zero)
        }

        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 != ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b") /* Unknown UUID */))
            {
                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            If ((Arg2 == Zero))
            {
                Return (Buffer (One)
                {
                     0x03                                             // .
                })
            }

            Return (Package (0x04)
            {
                "built-in", 
                Buffer (One)
                {
                     0x01                                             // .
                }, 

                "pci-aspm-default", 
                Zero
            })
        }
    }

    Scope (\_SB.PCI0.GPP6)
    {
        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
        {
            Return (Zero)
        }
    }

    Scope (\_SB.PCI0.GPP6.WLAN)
    {
        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
        {
            Return (Zero)
        }

        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 != ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b") /* Unknown UUID */))
            {
                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            If ((Arg2 == Zero))
            {
                Return (Buffer (One)
                {
                     0x03                                             // .
                })
            }

            Return (Package (0x04)
            {
                "built-in", 
                Buffer (One)
                {
                     0x01                                             // .
                }, 

                "pci-aspm-default", 
                Zero
            })
        }
    }
}

