// Fichier configuration firefox

// Si vous utilisez un fichier de configuration de proxy, décommentez ci-dessous (+renommer fichier en quesiton) :
//pref("network.proxy.autoconfig_url", "file:///tmp/netlogon/icones/posteslinux/proxy_etab.pac");

// IMPORTANT : Si votre proxy (Amon) n'est pas en 172.18.248.1:3128,  
//merci de changer les infos juste ci-dessous :
pref("network.proxy.ftp", "172.18.248.1");
pref("network.proxy.ftp_port", 3128);
pref("network.proxy.http", "172.18.248.1");
pref("network.proxy.http_port", 3128);
pref("network.proxy.share_proxy_settings", true);
pref("network.proxy.socks", "172.18.248.1");
pref("network.proxy.socks_port", 3128);
pref("network.proxy.ssl", "172.18.248.1");
pref("network.proxy.ssl_port", 3128);
pref("network.proxy.type", 1);

//pref("network.proxy.share_proxy_settings", true);
pref("network.proxy.no_proxies_on", "127.0.0.1, localhost");

// Page de démarrage
//pref("browser.startup.homepage", "https://lite.qwant.com");

// disable default browser check
pref("browser.shell.checkDefaultBrowser", false);

// disable application updates
pref("app.update.enabled", false)

// disables the 'know your rights' button from displaying on first run 
pref("browser.rights.3.shown", true);

// disables the request to send performance data from displaying
pref("toolkit.telemetry.prompted", 2);
pref("toolkit.telemetry.rejected", true);

// Download
lockPref("browser.download.manager.closeWhenDone", true);
lockPref("browser.download.manager.retention", 0);
lockPref("browser.download.useDownloadDir", false);
