// WatusiAdsPatch.m — Patch de ads para Watusi (sem jailbreak, sem JIT)
// Compile no Mac com: clang -fobjc-arc -dynamiclib -arch arm64 -mios-version-min=14.0 \
//   -framework Foundation -framework UIKit WatusiAdsPatch.m -o WatusiAdsPatch.dylib

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

static BOOL (*original_settingsHasValidLicense)(id self, SEL _cmd);

static BOOL patched_settingsHasValidLicense(id self, SEL _cmd) {
    NSLog(@"[WatusiAdsPatch] settingsHasValidLicense → YES (patched)");
    return YES;  // Always licensed
}

// ─────────────────────────────────────────────
// HOOK: Bloquear showBanner
// ─────────────────────────────────────────────

static void (*original_showBanner)(id self, SEL _cmd);

static void patched_showBanner(id self, SEL _cmd) {
    NSLog(@"[WatusiAdsPatch] showBanner blocked");
    // Don't call original - banner suppressed
}

static void (*original_showRandomBannerView)(id self, SEL _cmd);

static void patched_showRandomBannerView(id self, SEL _cmd) {
    NSLog(@"[WatusiAdsPatch] showRandomBannerView blocked");
    // Don't call original
}

// ─────────────────────────────────────────────
// HOOK: Forçar devHideBanner = YES
// ─────────────────────────────────────────────

static BOOL (*original_devHideBanner)(id self, SEL _cmd);

static BOOL patched_devHideBanner(id self, SEL _cmd) {
    NSLog(@"[WatusiAdsPatch] devHideBanner → YES (patched)");
    return YES;
}

static void (*original_setDevHideBanner)(id self, SEL _cmd, BOOL arg1);

static void patched_setDevHideBanner(id self, SEL _cmd, BOOL arg1) {
    NSLog(@"[WatusiAdsPatch] setDevHideBanner:%d → forced YES", arg1);
    original_setDevHideBanner(self, _cmd, YES);
}

// ─────────────────────────────────────────────
// HOOK: Bloquear purchase alerts
// ─────────────────────────────────────────────

static void (*original_showPurchaseAlert)(id self, SEL _cmd, id controller);

static void patched_showPurchaseAlert(id self, SEL _cmd, id controller) {
    NSLog(@"[WatusiAdsPatch] showPurchaseAlertFromController: blocked");
    // Suppress
}

static void (*original_showHowToRemoveAds)(id self, SEL _cmd, id controller);

static void patched_showHowToRemoveAds(id self, SEL _cmd, id controller) {
    NSLog(@"[WatusiAdsPatch] showHowToRemoveAdsAlertFromController: blocked");
    // Suppress
}

// ─────────────────────────────────────────────
// Instalação dos hooks
// ─────────────────────────────────────────────

__attribute__((constructor))
static void init_hooks(void) {
    NSLog(@"[WatusiAdsPatch] Initializing hooks...");
    
    // Hook WSABSettings.settingsHasValidLicense
    Class WSABSettings = NSClassFromString(@"WSABSettings");
    if (WSABSettings) {
        SEL sel = @selector(settingsHasValidLicense);
        Method method = class_getClassMethod(WSABSettings, sel);
        if (method) {
            original_settingsHasValidLicense = (BOOL (*)(id, SEL))method_getImplementation(method);
            method_setImplementation(method, (IMP)patched_settingsHasValidLicense);
            NSLog(@"[WatusiAdsPatch] ✓ Hooked WSABSettings.settingsHasValidLicense");
        }
    }
    
    // Hook FRBannerAdManager
    Class FRBannerAdManager = NSClassFromString(@"FRBannerAdManager");
    if (FRBannerAdManager) {
        // showBanner
        Method m1 = class_getInstanceMethod(FRBannerAdManager, @selector(showBanner));
        if (m1) {
            original_showBanner = (void (*)(id, SEL))method_getImplementation(m1);
            method_setImplementation(m1, (IMP)patched_showBanner);
            NSLog(@"[WatusiAdsPatch] ✓ Hooked FRBannerAdManager.showBanner");
        }
        
        // showRandomBannerView
        Method m2 = class_getInstanceMethod(FRBannerAdManager, @selector(showRandomBannerView));
        if (m2) {
            original_showRandomBannerView = (void (*)(id, SEL))method_getImplementation(m2);
            method_setImplementation(m2, (IMP)patched_showRandomBannerView);
            NSLog(@"[WatusiAdsPatch] ✓ Hooked FRBannerAdManager.showRandomBannerView");
        }
        
        // devHideBanner
        Method m3 = class_getInstanceMethod(FRBannerAdManager, @selector(devHideBanner));
        if (m3) {
            original_devHideBanner = (BOOL (*)(id, SEL))method_getImplementation(m3);
            method_setImplementation(m3, (IMP)patched_devHideBanner);
            NSLog(@"[WatusiAdsPatch] ✓ Hooked FRBannerAdManager.devHideBanner");
        }
        
        // setDevHideBanner:
        Method m4 = class_getInstanceMethod(FRBannerAdManager, @selector(setDevHideBanner:));
        if (m4) {
            original_setDevHideBanner = (void (*)(id, SEL, BOOL))method_getImplementation(m4);
            method_setImplementation(m4, (IMP)patched_setDevHideBanner);
            NSLog(@"[WatusiAdsPatch] ✓ Hooked FRBannerAdManager.setDevHideBanner:");
        }
    }
    
    // Hook WSAccountController
    Class WSAccountController = NSClassFromString(@"WSAccountController");
    if (WSAccountController) {
        // showPurchaseAlertFromController:
        Method m5 = class_getInstanceMethod(WSAccountController, @selector(showPurchaseAlertFromController:));
        if (m5) {
            original_showPurchaseAlert = (void (*)(id, SEL, id))method_getImplementation(m5);
            method_setImplementation(m5, (IMP)patched_showPurchaseAlert);
            NSLog(@"[WatusiAdsPatch] ✓ Hooked WSAccountController.showPurchaseAlertFromController:");
        }
        
        // showHowToRemoveAdsAlertFromController:
        Method m6 = class_getInstanceMethod(WSAccountController, @selector(showHowToRemoveAdsAlertFromController:));
        if (m6) {
            original_showHowToRemoveAds = (void (*)(id, SEL, id))method_getImplementation(m6);
            method_setImplementation(m6, (IMP)patched_showHowToRemoveAds);
            NSLog(@"[WatusiAdsPatch] ✓ Hooked WSAccountController.showHowToRemoveAdsAlertFromController:");
        }
    }
    
    NSLog(@"[WatusiAdsPatch] All hooks installed successfully");
}
