function FindProxyForURL(url, host) {

	// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	// =-=-=-=   Fichier proxy.pac -configuration pour metice pc linux
	// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	// =-=-=-=
	// =-=-=-=   Dernière modification : CALPETARD Olivier 13/06/2017
	// =-=-=-=   
	// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=



	if (shExpMatch(host, "hubole.ac-reunion.fr")) 
	return "PROXY 172.18.40.1:3128";
	else if (shExpMatch(host, "sso.ac-reunion.fr"))
	return "PROXY 172.18.40.1:3128";
	else if (shExpMatch(host, "seshat.ac-reunion.fr"))
	return "PROXY 172.18.40.1:3128";
	else if (shExpMatch(host, "10.210.9.10"))
	return "DIRECT";
	else if (shExpMatch(host, "easidoc.fr"))
	return "PROXY 172.18.40.1:3128";
	else if (shExpMatch(host, "poppy-project.org"))
	return "PROXY 172.18.40.1:3128";
	
	

	
	
	// -----
	// Vers le proxy par défaut pour les autres destinations
	// -----
	else
	return "PROXY 127.0.0.1:3128"
}

