#import <substrate.h>

// === LICENSE CHECK ===
// Faz o app acreditar que a licença é válida
%hook WSABSettings
- (BOOL)settingsHasValidLicense {
    return YES;
}
%end

// === BANNER MANAGER ===
// Desativa todos os banners de anúncio
%hook FRBannerAdManager
- (void)showBanner {
    // Bloqueia exibição de banner padrão
}
- (void)showRandomBannerView {
    // Bloqueia exibição de banner aleatório
}
- (BOOL)devHideBanner {
    return YES; // Força esconder banner
}
- (void)setDevHideBanner:(BOOL)hide {
    %orig(YES); // Ignora parâmetro, sempre esconde
}
%end

// === SUPPRESS ALERTS ===
// Remove avisos de compra se existirem
%hook WABannersViewController
- (void)showPurchaseAlertFromController:(id)controller {
    // Suprime alerta de compra
}
- (void)showHowToRemoveAdsAlertFromController:(id)controller {
    // Suprime alerta "Como remover anúncios"
}
%end