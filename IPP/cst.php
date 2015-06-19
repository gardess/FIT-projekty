<?php

#CST:xgarda04

// Proměnné pro zjištění, které parametry byly zadány
$nosubdirParam = 0;
$kParam = 0;
$oParam = 0;
$iParam = 0;
$wParam = 0;
$cParam = 0;
$pParam = 0;
$inputParam = 0;
$outputParam = 0;
$inputParams = array('nic', ':');
$outputParams = array('nic', ':');
$wParams = array('nic', ':');

// Cyklus sloužící na rozsekání parametrů --input, --output a -w
for ($i = 0; $i < $argc; $i++)
{
	// Parametr --input=fileordir
	if (('-' == $argv [$i][0]) && ('-' == $argv [$i][1]) && ('i' == $argv [$i][2]) && ('n' == $argv [$i][3]) && ('p' == $argv [$i][4]) && ('u' == $argv [$i][5]) && ('t' == $argv [$i][6]))
	{
		$inputParams = explode("=", $argv [$i]);
		$inputParam++; 
	}
	// Parametr --output=filename
	if (('-' == $argv [$i][0]) && ('-' == $argv [$i][1]) && ('o' == $argv [$i][2]) && ('u' == $argv [$i][3]) && ('t' == $argv [$i][4]) && ('p' == $argv [$i][5]) && ('u' == $argv [$i][6]) && ('t' == $argv [$i][7]))
	{
		$outputParams = explode("=", $argv [$i]);
		$outputParam++;
	}
	// Parametr -w=pattern
	if (('-' == $argv [$i][0]) && ('w' == $argv [$i][1]))
	{
		$wParams = explode("=", $argv [$i]);
		$wParam++;
	}
}

// Cyklus pro zjištění, které parametry byly zadány
for ($i = 0; $i < $argc; $i++)
{
	// kontrola parametru --help
	if (((strcmp('--help', $argv [$i]) == 0) || (strcmp('-h', $argv [$i]) == 0)) && ($argc == 2))
	{
		printhelp();
		exit(0);
	}
	elseif (((strcmp('--help', $argv [$i]) == 0) || (strcmp('-h', $argv [$i]) == 0)) && ($argc != 2))
	{
		fwrite(STDERR, "ERROR: Parametr --help nebyl zadán samostatně.\n");
		exit(1);
	}	
	elseif (strcmp('--nosubdir', $argv [$i]) == 0)
	{
		$nosubdirParam++;
	}
	elseif (strcmp('-k', $argv [$i]) == 0)
	{
		$kParam++;
	}
	elseif (strcmp('-o', $argv [$i]) == 0)
	{
		$oParam++;
	}
	elseif (strcmp('-i', $argv [$i]) == 0)
	{
		$iParam++;
	}
	elseif (strcmp('-c', $argv [$i]) == 0)
	{
		$cParam++;
	}
	elseif (strcmp('-p', $argv [$i]) == 0)
	{
		$pParam++;
	}
}
//echo "nosubdirParam: $nosubdirParam\nkParam: $kParam\noParam: $oParam\niParam: $iParam\nwParam: $wParam\ncParam: $cParam\npParam: $pParam\ninputParam: $inputParam\noutputParam: $outputParam\n";

if ($outputParam != 0)
{
		$output = fopen($outputParams [1], "w");
		if ($output == false)
		{
			//fwrite(STDERR, "ERROR: Nepodařilo se otevřít výstupní soubor.\n");
			exit(3);	
		}
}
else
{
	$output = STDOUT;
}

if (($nosubdirParam >= 1) && ($inputParam == 0))
{
	fwrite(STDERR, "ERROR: Nebyl zadán parametr input a byl zadán NEPOVOLENÝ parametr nosubdir.\n");
	exit(1);		
}

if ($inputParam == 0) // není zadán parametr --input, použije se aktuální adresář
{
	$input = getcwd();
	$strom = directorySearch($input, 0, 0);
	$pocetSouboru = sizeof($strom);
	$inputs = array();
	$obsah = array();
	for($i = 0; $i < $pocetSouboru; $i++)
	{
		$inputs [$i] = fopen($strom [$i], "r");
		if ($inputs [$i] == false) // nepodařilo se otevřít vstupní soubor
		{
			fwrite(STDERR, "ERROR: Nepodařilo se otevřít vstupní soubor.\n");
			exit(21);
		}
		$obsah [$i] = stream_get_contents($inputs [$i], -1, 0);
		fclose($inputs [$i]);
	}
	$strom = directorySearch($input, 0, $pParam);
}
else // parametr --input je zadán
{
	if (is_file($inputParams [1])) // je zadán pouze jeden soubor ke spracování
	{
		$inputs = array();
		$inputs [0] = fopen($inputParams [1], "r");
		if ($inputs [0] == false) // nepodařilo se otevřít vstupní soubor
		{
			fwrite(STDERR, "ERROR: Nepodařilo se otevřít vstupní soubor.\n");
			exit(2);
		}
		$obsah = array();
		$obsah [0] = stream_get_contents($inputs [0], -1, 0);
		fclose($inputs [0]);
	}
	elseif (is_dir($inputParams [1])) // ke zpracování je zadána složka
	{
		$strom = directorySearch($inputParams [1], $nosubdirParam, 0);
		$pocetSouboru = sizeof($strom);
		$inputs = array();
		$obsah = array();
		for($i = 0; $i < $pocetSouboru; $i++)
		{
			$inputs [$i] = fopen($strom [$i], "r");
			if ($inputs [$i] == false) // nepodařilo se otevřít vstupní soubor
			{
				fwrite(STDERR, "ERROR: Nepodařilo se otevřít vstupní soubor.\n");
				exit(21);
			}
			$obsah [$i] = stream_get_contents($inputs [$i], -1, 0);
			fclose($inputs [$i]);
		}
		$strom = directorySearch($inputParams [1], $nosubdirParam, $pParam);
	}
	else
	{
		//fwrite(STDERR, "ERROR: Spatny soubor.\n");
		exit(2);
	}
}



/////////////////////////////////////////////////////////////////////////
// Běh programu dle zadaný parametrů
if (($nosubdirParam >= 2) || ($inputParam >= 2) || ($outputParam >= 2) || ($kParam >= 2) || ($oParam >= 2) || ($iParam >= 2) || ($wParam >= 2) || ($cParam >= 2) || ($pParam >= 2))
{
	fwrite(STDERR, "ERROR: Některý parametr byl zadán dvakrát.\n");
	exit(1);	
}
elseif ($kParam == 1) // parametr -k
{
	if (($kParam == $oParam) || ($kParam == $iParam) || ($kParam == $wParam) || ($kParam == $cParam))
	{
		fwrite(STDERR, "ERROR: Parametr -k byl zadán s dalším nepovoleným parametrem.\n");
		exit(1);		
	}	
	$rozmer = sizeof($inputs);
	$poleNazvu = array();
	$poleHodnot = array();
	if($rozmer == 1)
	{
		$obsah [0] = mazRetezec($obsah [0]);
		$obsah [0] = mazaniMakra($obsah [0]);
		$obsah [0] = komentare($obsah [0], $cParam);
		$celkem = klicovaSlova($obsah [0], $kParam);
		$cesta = realpath($inputParams[1]);
		$poleNazvu [0] = $cesta;
		$poleHodnot [0] = $celkem;
	}
	else
	{
		$celkem = 0;
		for($i = 0; $i < $rozmer; $i++)
		{
			$obsah [$i] = mazRetezec($obsah [$i]);
			$obsah [$i] = mazaniMakra($obsah [$i]);
			$obsah [$i] = komentare($obsah [$i], $cParam);
			$pocet = klicovaSlova($obsah[$i], $kParam);
			$poleNazvu [$i] = $strom [$i];
			$poleHodnot [$i] = $pocet;
			$celkem = $celkem + $pocet;
		}
	}
	array_multisort($poleNazvu, $poleHodnot);
	$poleNazvu [$rozmer] = "CELKEM:";
	$poleHodnot [$rozmer] = $celkem;	
	vypis($poleNazvu, $poleHodnot, $output);
	return 0;
}
elseif ($oParam == 1) // parametr -o
{
	if (($oParam == $iParam) || ($oParam == $wParam) || ($oParam == $cParam))
	{
		fwrite(STDERR, "ERROR: Parametr -o byl zadán s dalším nepovoleným parametrem.\n");
		exit(1);		
	}
	$rozmer = sizeof($inputs);
	$poleNazvu = array();
	$poleHodnot = array();
	if($rozmer == 1)
	{
		$obsah [0] = mazRetezec($obsah [0]);
		$obsah [0] = mazaniMakra($obsah [0]);
		$obsah [0] = komentare($obsah [0], $cParam);
		$obsah [0] = klicovaSlova($obsah [0], $kParam);
		$obsah [0] = identifikatory($obsah [0], $iParam);
		$celkem = operatory($obsah [0], $oParam);
		$cesta = realpath($inputParams[1]);
		$poleNazvu [0] = $cesta;
		$poleHodnot [0] = $celkem;
	}
	else
	{
		$celkem = 0;
		for($i = 0; $i < $rozmer; $i++)
		{
			$obsah [$i] = mazRetezec($obsah [$i]);
			$obsah [$i] = mazaniMakra($obsah [$i]);
			$obsah [$i] = komentare($obsah [$i], $cParam);
			$obsah [$i] = klicovaSlova($obsah[$i], $kParam);
			$obsah [$i] = identifikatory($obsah [$i], $iParam);
			$pocet = operatory($obsah[$i], $oParam);
			$poleNazvu [$i] = $strom [$i];
			$poleHodnot [$i] = $pocet;
			$celkem = $celkem + $pocet;
		}
	}
	array_multisort($poleNazvu, $poleHodnot);
	$poleNazvu [$rozmer] = "CELKEM:";
	$poleHodnot [$rozmer] = $celkem;	
	vypis($poleNazvu, $poleHodnot, $output);
	return 0;	
}
elseif ($iParam == 1) // parametr -i
{
	if (($iParam == $wParam) || ($iParam == $cParam))
	{
		fwrite(STDERR, "ERROR: Parametr -i byl zadán s dalším nepovoleným parametrem.\n");
		exit(1);		
	}
	$rozmer = sizeof($inputs);
	$poleNazvu = array();
	$poleHodnot = array();
	if($rozmer == 1)
	{
		$obsah [0] = mazRetezec($obsah [0]);
		$obsah [0] = mazaniMakra($obsah [0]);
		$obsah [0] = komentare($obsah [0], $cParam);
		$obsah [0] = klicovaSlova($obsah [0], $kParam);
		$celkem = identifikatory($obsah [0], $iParam);
		$cesta = realpath($inputParams[1]);
		$poleNazvu [0] = $cesta;
		$poleHodnot [0] = $celkem;
	}
	else
	{
		$celkem = 0;
		for($i = 0; $i < $rozmer; $i++)
		{
			$obsah [$i] = mazRetezec($obsah [$i]);
			$obsah [$i] = mazaniMakra($obsah [$i]);
			$obsah [$i] = komentare($obsah [$i], $cParam);
			$obsah [$i] = klicovaSlova($obsah[$i], $kParam);
			$pocet = identifikatory($obsah [$i], $iParam);
			$poleNazvu [$i] = $strom [$i];
			$poleHodnot [$i] = $pocet;
			$celkem = $celkem + $pocet;
		}
	}
	array_multisort($poleNazvu, $poleHodnot);
	$poleNazvu [$rozmer] = "CELKEM:";
	$poleHodnot [$rozmer] = $celkem;	
	vypis($poleNazvu, $poleHodnot, $output);
	return 0;	
}
elseif ($cParam == 1) // parametr -c
{
	if ($cParam == $wParam)
	{
		fwrite(STDERR, "ERROR: Parametr -c byl zadán s dalším nepovoleným parametrem.\n");
		exit(1);		
	}
	$rozmer = sizeof($inputs);
	$poleNazvu = array();
	$poleHodnot = array();
	if($rozmer == 1)
	{
		$obsah [0] = mazRetezec($obsah [0]);
		$celkem = komentare($obsah [0], $cParam);
		$cesta = realpath($inputParams[1]);
		$poleNazvu [0] = $cesta;
		$poleHodnot [0] = $celkem;
	}
	else
	{
		$celkem = 0;
		for($i = 0; $i < $rozmer; $i++)
		{
			$obsah [$i] = mazRetezec($obsah [$i]);
			$pocet = komentare($obsah[$i], $cParam);
			$poleNazvu [$i] = $strom [$i];
			$poleHodnot [$i] = $pocet;
			$celkem = $celkem + $pocet;
		}
	}
	array_multisort($poleNazvu, $poleHodnot);
	$poleNazvu [$rozmer] = "CELKEM:";
	$poleHodnot [$rozmer] = $celkem;	
	vypis($poleNazvu, $poleHodnot, $output);
	return 0;
}
elseif ($wParam == 1) // parametr -w
{
	$rozmer = sizeof($inputs);
	$poleNazvu = array();
	$poleHodnot = array();
	if($rozmer == 1)
	{
		$celkem = vyhledaniPodretez($obsah [0], $wParams [1]);
		$cesta = realpath($inputParams[1]);
		$poleNazvu [0] = $cesta;
		$poleHodnot [0] = $celkem;
	}
	else
	{
		$celkem = 0;
		for($i = 0; $i < $rozmer; $i++)
		{
			$pocet = vyhledaniPodretez($obsah[$i], $wParams [1]);
			$poleNazvu [$i] = $strom [$i];
			$poleHodnot [$i] = $pocet;
			$celkem = $celkem + $pocet;
		}
	}
	array_multisort($poleNazvu, $poleHodnot);
	$poleNazvu [$rozmer] = "CELKEM:";
	$poleHodnot [$rozmer] = $celkem;	
	vypis($poleNazvu, $poleHodnot, $output);
	return 0;
}
else // zadán neznámý parametr
{
	fwrite(STDERR, "ERROR: Neznámý parametr.\n");
	exit(1);	
}
/////////////////////////////////////////////////////////////////////////


// Funkce pro výpis nápovědy 
function printhelp()
{
	printf("CST - C Stats\n");
	printf("1. projekt do předmětu IPP\n");
	printf("Autor: Milan Gardáš\n");
	printf("\n");
	printf("Použití:\n");
	printf("cst.php\t[--help|-h] [--input=path] [--output=filename] [--nosubdir]\n\t[-k|-i|-o|-c|-w=\"pattern\"] [-p]\n");
	printf("\n");
	printf("Popis:\t");
	printf("Skript analyzuje zdrojové soubory jazyka C a dle zadaných parametrů\n\tvypisuje statistiky komentářů, klíčových slov, operátorů a řetězců.\n\n");
	printf("help\t Zobrazí nápovědu\n");
	printf("input\t Zadaný vstupní soubor nebo adresář se zdrojovým kódem v jazyce C\n");
	printf("output\t Zadaný textový vstupní soubor v kódování ISO-8859-2\n");
	printf("nosubdir Prohledávání bude prováděno pouze v zadaném adresáři, ale už ne v jeho\n\t podadresářích\n");
	printf("k\t Vypíše počet všech výskytů klíčových slov v každém zdrojovém souboru\n\t a celkem\n");
	printf("o\t Vypíše počet výskytů jednoduchých operátorů v každém zdrojovém souboru\n\t a celkem\n");
	printf("i\t Vypíše počet výskytů identifikátorů v každém zdrojovém souboru a celkem\n");
	printf("w\t Vyhledá přesný textový řetězec pattern ve všech zdrojových kódech\n\t a vypíše počet nepřekrývajících se výskytů na soubor i celkem\n");
	printf("c\t Vypíše celkový počet znaků komentářů včetně uvozujích znaků komentářů\n\t na soubor a celkem\n");
	printf("p\t V kombinaci s předchozími (až na --help) způsobí, že soubory se budou\n\t vypisovat bez úplné cesty k souboru\n");

}

// Funkce rozhoduje která, z níže uvedených funkcí pro získání obsahu adresářů se použije
// param1: cesta k adresáři
// param2: hodnota parametru --nosubdir
// param3: hodnota parametru -p
// return: seřazený seznam souborů
function directorySearch($path, $nosubdirParam, $pParam)
{
	if ($nosubdirParam >= 1) // prohledávám pouze samotný adresář
	{
		$filesList = prohledavacSlozky($path);	
	}
	else // prohledávám i podadresáře
	{
		$filesList = prohledavacSlozek($path);
	}
	if ($pParam >= 1) //odstraňuje cestu k souboru tzn. zanechá pouze název souboru
	{
		$size = sizeof($filesList);
		for($i = 0; $i < $size; $i++)
		{
			$nazev = explode("/", $filesList [$i]);
			$nazevSize = sizeof($nazev);
			$filesList [$i] = $nazev [$nazevSize - 1];
		}
	}
	//sort($filesList);
	return $filesList;
}

// Funkce vyhledá v ve složce v parametru soubory s příponou .c a .h, Prohledává pouze samotnou složku.
// param1: cesta k adresáři
// return: seznam souborů
function prohledavacSlozky($path)
{
	$soub = scandir($path);
	$i = 0;
	$j = 0;
	foreach ($soub as $i => $hodnota)
	{
		$delkaNazvu = strlen($soub [$i]);
		if ($delkaNazvu <= 1)
		{
			continue;
		}
		if (($soub [$i][$delkaNazvu-2] == '.') && (($soub [$i][$delkaNazvu-1] == 'c') || ($soub [$i][$delkaNazvu-1] == 'h')))
		{
			$soubory [$j] = $soub [$i];
			$soubory [$j] = realpath($soubory [$j]);
			$j++;
		}
	}
	return $soubory;
}

// Funkce prohledá adresáře a podadresáře v cestě, která je zadána v parametru a vrátí pole s názvy souborů s příponami .c a .h
// param1: cesta k adresáři
// return: seznam souborů
function prohledavacSlozek($path) 
{
    $adresar = new RecursiveDirectoryIterator($path);
    $iterator = new RecursiveIteratorIterator($adresar);
    $files = new RegexIterator($iterator, '/^.+\.[ch]$/i', RegexIterator::GET_MATCH);
    $soubory = array();
    foreach($files as $soubor) {
        $soubory = array_merge($soubory, $soubor);
    }
    $velikost = sizeof($soubory);
    for($i = 0; $i < $velikost; $i++)
    {
		$soubory [$i] = realpath($soubory [$i]);
	}
	return $soubory;
}

// Funkce, která počítá velikost komentářů a v případě nulového druhého parametru komentáře nahrazuje mezerami
// param1: obsah vstupního souboru
// param2: hodnotu parametru -c
// return: počet znaků komentářů nebo soubor s odstraněnými komentáři
function komentare($soubor, $cParam)
{
	$velikost = strlen($soubor);
	
	//$soubor = mazRetezec($soubor);
	//$soubor = mazaniMakra($soubor);
	
	$koment = 0;
	$komentVic = 0;
	$komentRad = 0;

	// počítání a případné odstranění komentářů začínající znakem /*
	for ($i = 0; $i < $velikost; $i++)
	{
		if (($soubor [$i] == '/') && ($soubor [$i+1] == '*'))
		{
			$koment = 1;
		}
		if (($soubor [$i] == '*') && ($soubor [$i+1] == '/'))
		{
			$koment = 0;
			$komentVic = $komentVic + 2;
			if ($cParam == 0)
			{
				$soubor [$i] = " ";
				$soubor [$i+1] = " ";
			}
		}
		if ($koment == 1)
		{
			$komentVic++;
			if ($cParam == 0)
			{
				$soubor [$i] = " ";
			}
		}
	}

	$koment = 0;
	$test = 0;
	$radek = 0;
	
	// počítání a případné odstranění komentářů začínající znakem //
	for ($i = 0; $i < $velikost; $i++)
	{
		if (($soubor [$i] == '/') && ($soubor [$i+1] == '/'))
		{
			$koment = 1;
		}
		if (($soubor [$i] == '\\') && ($soubor [$i+1] == "\n") && ($koment == 1))
		{
			$radek = 1;
			$komentRad = $komentRad - 1;
		}
		if (($soubor [$i] == "\n") && ($koment == 1))
		{
			if ($koment == 1)
			{
				$komentRad = $komentRad + 1;
			}
			$koment = 0;
			if ($radek == 1)
			{
				$koment = 1;
				$radek = 0;
			}
		}
		if ($koment == 1)
		{
			$komentRad++;
			if ($cParam == 0)
			{
				$soubor [$i] = " ";
			}
		}
	}
	$celkem = $komentVic + $komentRad;
	if ($cParam == 1)
	{
		return $celkem;
	}
	else
	{
		return $soubor;
	}
}

// Funkce nahradí znak makra za mezeru
// param1: obsah souboru
// return: soubor s odstraněnými makry
function mazaniMakra($soubor)
{
	$size = strlen($soubor);
	$maz = 0;
	$radek = 0;
	for($i = 0; $i < $size; $i++)
	{
		if ($soubor [$i] == '#')
		{
			$maz = 1;
		}
		if (($soubor [$i] == '\\') && ($soubor [$i+1] == "\n") && ($maz == 1))
		{
			$radek = 1;

		}
		if (($soubor [$i] == "\n") && ($maz == 1))
		{
			if ($maz == 1)
			{
				$soubor [$i] = " ";
			}
			$maz = 0;
			if ($radek == 1)
			{
				$maz = 1;
				$radek = 0;
			}
		}
		if ($maz == 1)
		{
			$soubor [$i] = " ";
		}
	}
	return $soubor;
}

// Funkce vyhledá podřetězec zadaný druhým parametrem, v řetězci což je první parametr a navrátí počet výskytů podřetězce
// param1: obsah souboru
// param2: vyhledávaný podřetězec
// return: počet vyhledávaných podřetězců v souboru
function vyhledaniPodretez($soubor, $podretez)
{
	$delkaPodretez = strlen($podretez);
	$pocet = 0;
	$offset = 0;
	for(;;)
	{
		$nalezl = strpos($soubor, $podretez, $offset);
		if($nalezl == true)
		{
			$offset = $nalezl + $delkaPodretez;
			$pocet++;
		}
		else
		{
			break;
		}
	}
	return $pocet;
}

// Funkce nahradí řetězce mezerami
// param1: obsah souboru
// return: soubor s odstraněnými řetězci
function mazRetezec($soubor)
{
	$velikost = strlen($soubor);
	$maz = 0;
	for($i = 0; $i < $velikost; $i++)
	{
		if((($soubor [$i] =='\\') && ($soubor [$i+1] == '"')) || (($soubor [$i] =='\\') && ($soubor [$i+1] == '\'')))
		{
			$soubor [$i] = " ";
			$soubor [$i+1] = " ";
			$i = $i + 2;
		}
		if(((($soubor [$i] == '"') && ($soubor [$i-1] != '\\')) || (($soubor [$i] == '\'') && ($soubor [$i-1] != '\\'))) && ($maz == 0))
		{
			$maz = 1;
			$soubor [$i] = " ";
			$i++;
		}
		if((($soubor [$i] == '"') || ($soubor [$i] == '\'')) && ($maz == 1))
		{
			$soubor [$i] = " ";
			$maz = 0;
		}
		if($maz == 1)
		{
			$soubor [$i] = " ";
		}
	}
	return $soubor;
}

// Funkce slouží k vyhledání klíčových slov jazyka C
// param1: obsah prohledávaného souboru
// param2: hodnota parametru -k
// return: počet klíčových slov nebo obsah souboru s odstraněnými klíčovými slovy
function klicovaSlova($soubor, $kParam)
{
	$regVyraz = "/([\W]|^)("."auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|inline|int|long|register|restrict|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|_Bool|_Complex|_Imaginary".")([\W])/";
	$pocet = 0;
	for(;;)
	{
		$souborOK = $soubor;
		$soubor = preg_filter($regVyraz, " ", $soubor, -1,$shoda);
		$pocet = $pocet + $shoda;
		if ($shoda == 0)
		{
			break;
		}
		$shoda = 0;
	}
	if ($kParam == 1)
	{
		return $pocet;
	}
	else
	{
		return $souborOK;
	}
}

// Funkce slouží k vyhledání jednoduchých operátorů
// param1: obsah prohledávaného souboru
// param2: hodnota parametru -o
// return: počet jednoduchých operátorů nebo obsah souboru s odstraněnými jednoduchými operátory
function operatory($soubor, $oParam)
{
	$regVyraz = "/(\+\+|\-\-|\+|\-|\+=|\-=|\*|\*=|\/|\/=|%|%=|<|<=|>|>=|==|!=|!|&&|\|\||<<|<<=|>>|>>=|~|&|&=|\||\|=|->|=|\^|\^=)/"; 
	$pocet = 0;
	$shoda = 0;
	for(;;)
	{
		$souborOK = $soubor;
		$soubor = preg_filter($regVyraz, " ", $soubor, -1,$shoda);
		$pocet = $pocet + $shoda;
		if ($shoda == 0)
		{
			break;
		}
		$shoda = 0;
	}
	if ($oParam == 1)
	{
		return $pocet;
	}
	else
	{
		return $souborOK;
	}
}

// Funkce slouží k vyhledání identifikátorů
// param1: obsah prohledávaného souboru
// param2: hodnota parametru -i
// return: počet identifikátorů nebo obsah souboru s odstraněnými identifikátory
function identifikatory($soubor, $iParam)
{
	$regVyraz = "/([A-Za-z_][A-Za-z0-9]*)/"; 
	$pocet = 0;
	$shoda = 0;
	for(;;)
	{
		$souborOK = $soubor;
		$soubor = preg_filter($regVyraz, " ", $soubor, -1,$shoda);
		$pocet = $pocet + $shoda;
		if ($shoda == 0)
		{
			break;
		}
		$shoda = 0;
	}
	if ($iParam == 1)
	{
		return $pocet;
	}
	else
	{
		return $souborOK;
	}
}

// Funkce slouží k zarovnánému vypsání výstupu skriptu
// param1: cesta souborů k vypsání
// param2: číselné hodnoty k vypsání
// param3: soubor do kterého se má zapisovat
// return: nul v případě úspěchu
function vypis($poleNazvu, $poleHodnot, $output)
{
	$velikost = sizeof($poleNazvu);
	$nazevMax = strlen($poleNazvu [0]);
	$hodnotaMax = strlen($poleHodnot [0]);
	for($i = 0; $i < $velikost; $i++)
	{
		$delkaN = strlen($poleNazvu [$i]);
		if ($delkaN > $nazevMax)
		{
			$nazevMax = $delkaN;
		}
		$delkaH = strlen($poleHodnot [$i]);
		if ($delkaH > $hodnotaMax)
		{
			$hodnotaMax = $delkaH;
		}
	}

	for($i = 0; $i < $velikost; $i++)
	{
		$poleNazvu [$i][$nazevMax] = " ";
		fwrite($output, "$poleNazvu[$i]");
		$velHod = strlen ($poleHodnot [$i]);
		if ($velHod < $hodnotaMax)
		{
			$j = $hodnotaMax - $velHod;
			for($j;; $j--)
			{
				if($j == 0)
				{
					break;
				}
				fwrite($output, " ");
			}
		}
		fwrite($output, "$poleHodnot[$i]\n");
	}
	return 0;
}

?>
