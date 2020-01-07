<?php

# URL of the testwiki (as configured in .travis.yml).
$wgServer = "http://demowiki.example.com";
$wgScriptPath = "/w";
$wgArticlePath = "/wiki/$1";

$wgCacheDirectory = "$IP/cache";
$wgMainCacheType = CACHE_MEMCACHED;
$wgMemCachedServers = [ "127.0.0.1:11211" ];

$wgEnableUploads = true;

wfLoadSkin( 'Vector' );

$wgGroupPermissions['*']['noratelimit'] = true;

if ( version_compare( $wgVersion, '1.34-rc.0', '>=' ) ) {
	# This is a testwiki.
	# Restrictions like "no 123456 as a password" are not applicable to test accounts.
	$wgPasswordPolicy['policies'] = [
		'bureaucrat' => [],
		'sysop' => [],
		'interface-admin' => [],
		'bot' => [],
		'default' => []
	];
}

wfLoadExtensions( [
	'AbuseFilter',
	'CheckUser',
	'Echo',
	'PageForms',
	'MobileFrontend',
	'VisualEditor'
] );

# Default skin for Extension:MobileFrontend
wfLoadSkin( 'MinervaNeue' );

# Parsoid configuration (used by Extension:VisualEditor)
$wgVirtualRestConfig['modules']['parsoid'] = [
	'url' => 'http://demowiki.example.com:8142',
	'domain' => 'demowiki.example.com'
];
$wgDefaultUserOptions['visualeditor-enable'] = 1; # Enable VisualEditor for all users
