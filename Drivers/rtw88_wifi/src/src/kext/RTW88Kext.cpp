// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
// RTW88Kext.cpp — top-level IOService, delegates to PCI or USB device classes

#include "RTW88Kext.hpp"
#include <IOKit/IOLib.h>

#define super IOService
OSDefineMetaClassAndStructors(RTW88Kext, IOService)

bool RTW88Kext::init(OSDictionary *props)
{
    IOLog("rtw88: RTW88Kext::init\n");
    return super::init(props);
}

IOService *RTW88Kext::probe(IOService *provider, SInt32 *score)
{
    IOLog("rtw88: RTW88Kext::probe\n");
    return super::probe(provider, score);
}

bool RTW88Kext::start(IOService *provider)
{
    IOLog("rtw88: RTW88Kext::start\n");
    if (!super::start(provider)) return false;
    registerService();
    return true;
}

void RTW88Kext::stop(IOService *provider)
{
    IOLog("rtw88: RTW88Kext::stop\n");
    super::stop(provider);
}

void RTW88Kext::free()
{
    super::free();
}

#include "RTW88PCIDevice.hpp"
#include "RTW88IEEE80211.hpp"
#include "RTW88UserClient.hpp"
#include <libkern/c++/OSMetaClass.h>
#include <libkern/c++/OSSymbol.h>

inline void *operator new(size_t, void *p) noexcept { return p; }

extern "C" kern_return_t rtw88_init_metaclasses(void)
{
    IOLog("rtw88: rtw88_init_metaclasses called\n");

    const OSSymbol *sym = OSSymbol::withCStringNoCopy("RTW88PCIDevice");
    if (sym) {
        const OSMetaClass *meta = OSMetaClass::getMetaClassWithName(sym);
        sym->release();
        if (meta) {
            IOLog("rtw88: RTW88PCIDevice already registered in IOKit\n");
            return KERN_SUCCESS;
        }
    }

    void *handle = OSMetaClass::preModLoad("com.rtw88.driver");
    if (!handle) {
        IOLog("rtw88: OSMetaClass::preModLoad failed\n");
        return KERN_FAILURE;
    }

    ::new (&RTW88Kext::gMetaClass) RTW88Kext::MetaClass();
    ::new (&RTW88PCIDevice::gMetaClass) RTW88PCIDevice::MetaClass();
    ::new (&RTW88IEEE80211::gMetaClass) RTW88IEEE80211::MetaClass();
    ::new (&RTW88UserClient::gMetaClass) RTW88UserClient::MetaClass();

    OSReturn res = OSMetaClass::postModLoad(handle);
    if (res != kOSReturnSuccess) {
        IOLog("rtw88: OSMetaClass::postModLoad failed: 0x%x\n", res);
        return KERN_FAILURE;
    }

    IOLog("rtw88: All metaclasses successfully registered into IOKit runtime!\n");
    return KERN_SUCCESS;
}

extern "C" void rtw88_cleanup_metaclasses(void)
{
    RTW88UserClient::gMetaClass.~MetaClass();
    RTW88IEEE80211::gMetaClass.~MetaClass();
    RTW88PCIDevice::gMetaClass.~MetaClass();
    RTW88Kext::gMetaClass.~MetaClass();
}
