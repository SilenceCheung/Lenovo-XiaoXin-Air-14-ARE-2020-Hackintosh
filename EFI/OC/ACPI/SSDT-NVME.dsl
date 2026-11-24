DefinitionBlock ("", "SSDT", 2, "ACDT", "NVMeFix", 0x00000001)
{
    External (_SB_.PCI0.GPP3, DeviceObj)

    Scope (\_SB.PCI0.GPP3)
    {
        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status on PCIe Bridge
        {
            Return (Zero)
        }

        Device (NVME)
        {
            Name (_ADR, Zero)  // _ADR: Address 0x00000000 (Bus 2, Dev 0, Func 0)
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status (0 = Built-in / Non-removable)
            {
                Return (Zero)
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 != ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                {
                    Return (Buffer (One)
                    {
                         0x00
                    })
                }

                If ((Arg2 == Zero))
                {
                    Return (Buffer (One)
                    {
                         0x03
                    })
                }

                Return (Package ()
                {
                    "built-in", 
                    Buffer (One)
                    {
                         0x01
                    }, 

                    "device_type", 
                    Buffer ()
                    {
                        "nvme"
                    }, 

                    "model",
                    Buffer ()
                    {
                        "Toshiba RC100 NVMe SSD (Internal)"
                    },

                    "use-msi", 
                    Buffer (0x04)
                    {
                         0x01, 0x00, 0x00, 0x00
                    }, 

                    "ps-max-latency-us", 
                    Buffer (0x04)
                    {
                         0x00, 0x00, 0x00, 0x00
                    }
                })
            }
        }
    }
}
