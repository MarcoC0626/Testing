$fragments = @('function Sh','adowHound-D','S() {
    ','[CmdletBind','ing()]
   ',' param(
  ','      [Para','meter(Manda','tory = $fal','se, HelpMes','sage = ''The',' domain con','troller to ','query.'')]
','        [st','ring]$Serve','r,

     ','   [Paramet','er(Mandator','y = $false,',' HelpMessag','e = ''Path t','o the outpu','t file wher','e results w','ill be save','d.'')]
    ','    [Valida','teNotNullOr','Empty()]
 ','       [str','ing]$Output','File,

  ','      [Para','meter(Manda','tory = $fal','se, HelpMes','sage = ''LDA','P filter to',' customize ','the search.',''')]
      ','  [string]$','LdapFilter ','= ''(ObjectG','uid=*)'',
','
        [P','arameter(Ma','ndatory = $','false, Help','Message = ''','The base DN',' for the se','arch.'')]
 ','       [str','ing]$Search','Base,

  ','      [Para','meter(Manda','tory = $fal','se, HelpMes','sage = ''PSC','redential o','bject for a','lternate cr','edentials.''',')]
       ',' [pscredent','ial]$Creden','tial,

  ','      [Para','meter(Manda','tory = $fal','se, HelpMes','sage = ''Enu','merate cert','ificates.'')',']
        ','[switch]$Ce','rtificates,','

       ',' [Parameter','(Mandatory ','= $false, H','elpMessage ','= ''Display ','help inform','ation.'')]
','        [sw','itch]$Help','
    )

 ','   if ($Hel','p) {
     ','   Print-He','lp
       ',' return
  ','  }

    ','if (-not $O','utputFile) ','{
        ','Write-Outpu','t ''[-] -Out','putFile is ','required.''','
        re','turn
    }','

    Pri','nt-Logo

','    Write-O','utput ''[+] ','Executing w','ith the fol','lowing para','meters:''
 ','   if ($Ser','ver) { Writ','e-Output " ','  - Server:',' $Server" }','
    Write','-Output "  ',' - OutputFi','le: $Output','File"
    ','if ($LdapFi','lter) { Wri','te-Output "','   - LdapFi','lter: $Ldap','Filter" }
','    if ($Se','archBase) {',' Write-Outp','ut "   - Se','archBase: $','SearchBase"',' }
    if ','($Credentia','l) { Write-','Output "   ','- Credentia','l: $($Crede','ntial.UserN','ame)" }
  ','  if ($Cert','ificates) {',' Write-Outp','ut ''   - En','umerating c','ertificates',''' }

    ','if ($Certif','icates) {
','        # E','numerate ce','rtificates','
        Wr','ite-Output ','''[*] Gettin','g Configura','tion Naming',' Context...','''

      ','  try {
  ','          i','f ($Server)',' {
       ','         if',' ($Credenti','al) {
    ','           ','     $rootD','SE = New-Ob','ject System','.DirectoryS','ervices.Dir','ectoryEntry','("LDAP://$S','erver/RootD','SE", $Crede','ntial.UserN','ame, $Crede','ntial.GetNe','tworkCreden','tial().Pass','word)
    ','           ',' } else {
','           ','         $r','ootDSE = Ne','w-Object Sy','stem.Direct','oryServices','.DirectoryE','ntry("LDAP:','//$Server/R','ootDSE")
 ','           ','    }
    ','        } e','lse {
    ','           ',' if ($Crede','ntial) {
 ','           ','        $ro','otDSE = New','-Object Sys','tem.Directo','ryServices.','DirectoryEn','try(''LDAP:/','/RootDSE'', ','$Credential','.UserName, ','$Credential','.GetNetwork','Credential(',').Password)','
         ','       } el','se {
     ','           ','    $rootDS','E = New-Obj','ect System.','DirectorySe','rvices.Dire','ctoryEntry(','''LDAP://Roo','tDSE'')
   ','           ','  }
      ','      }
  ','          $','configConte','xt = $rootD','SE.Properti','es[''configu','rationNamin','gContext''][','0]
       ',' } catch {','
          ','  Write-Out','put "[-] Fa','iled to ret','rieve Confi','gurationNam','ingContext:',' $_"
     ','       retu','rn
       ',' }

     ','   if ($nul','l -eq $conf','igContext) ','{
        ','    Write-O','utput ''[-] ','Configurati','onNamingCon','text is nul','l.''
      ','      retur','n
        ','}

      ','  Write-Out','put "[*] En','umerating P','KI objects ','under $conf','igContext..','."

     ','   $ldapFil','ters = @(
','           ',' ''(objectCl','ass=pKIEnro','llmentServi','ce)'',
    ','        ''(o','bjectClass=','pKICertific','ateTemplate',')'',
      ','      ''(obj','ectClass=ce','rtification','Authority)''',',
        ','    ''(objec','tclass=msPK','I-Enterpris','e-Oid)''
  ','      )

','        $co','unt = 0
  ','      $stre','amWriter = ','New-Object ','System.IO.S','treamWriter','($OutputFil','e, $true, [','System.Text','.Encoding]:',':UTF8)
   ','     try {','
          ','  
       ','     foreac','h ($ldapFil','ter in $lda','pFilters) {','
         ','       Writ','e-Output " ',' [*] Search','ing with fi','lter: $ldap','Filter"
  ','          ','
          ','      if ($','Server) {
','           ','         $l','dapPath = "','LDAP://$Ser','ver/$config','Context"
 ','           ','    } else ','{
        ','           ',' $ldapPath ','= "LDAP://$','configConte','xt"
      ','          }','
         ','   
      ','          i','f ($Credent','ial) {
   ','           ','      $dire','ctoryEntry ','= New-Objec','t System.Di','rectoryServ','ices.Direct','oryEntry($l','dapPath, $C','redential.U','serName, $C','redential.G','etNetworkCr','edential().','Password)
','           ','     } else',' {
       ','           ','  $director','yEntry = Ne','w-Object Sy','stem.Direct','oryServices','.DirectoryE','ntry($ldapP','ath)
     ','           ','}
        ','    
     ','           ','$searcher =',' New-Object',' System.Dir','ectoryServi','ces.Directo','rySearcher(','$directoryE','ntry)
    ','           ',' $searcher.','Filter = $l','dapFilter
','           ','     $searc','her.PageSiz','e = 1000
 ','           ','    $silenc','eofthezero ','= $searcher','.Properties','ToLoad.Add(','''*'')
     ','           ','$searcher.S','ecurityMask','s = ''Dacl,G','roup,Owner''','
         ','   
      ','          t','ry {
     ','           ','    $search','Results = $','searcher.Fi','ndAll()
  ','           ','   } catch ','{
        ','           ',' Write-Outp','ut "   [!!]',' Error duri','ng search w','ith filter ','$ldapFilter','`: $_"
   ','           ','      conti','nue
      ','          }','
         ','   
      ','          f','oreach ($se','archResult ','in $searchR','esults) {
','           ','         Pr','ocess-AdObj','ect -Search','Result $sea','rchResult -','StreamWrite','r $streamWr','iter
     ','           ','    $count+','+
        ','           ',' if ($count',' % 1000 -eq',' 0) {
    ','           ','         Wr','ite-Output ','"    [*] $c','ount object','s processed','..."
     ','           ','        $st','reamWriter.','Flush()
  ','           ','       }
 ','           ','    }
    ','        }
','           ',' 
        ','    $stream','Writer.Writ','eLine("Retr','ieved $coun','t results t','otal")

 ','       } fi','nally {
  ','          $','streamWrite','r.Flush()
','           ',' $streamWri','ter.Close()','
        }','
    

 ','       Writ','e-Output "O','bjects have',' been proce','ssed and wr','itten to $O','utputFile"','
        Wr','ite-Output ','"Retrieved ','$count resu','lts total"','
        re','turn
    }','

    # I','f not enume','rating cert','ificates, p','roceed as u','sual
    i','f ($SearchB','ase) {
   ','     $ldapP','ath = ''LDAP','://''
     ','   if ($Ser','ver) {
   ','         $l','dapPath += ','"$Server/"','
        }','
        $l','dapPath += ','"$SearchBas','e"
    } e','lseif ($Ser','ver) {
   ','     $ldapP','ath = "LDAP','://$Server"','
    } els','e {
      ','  $rootDSE ','= New-Objec','t System.Di','rectoryServ','ices.Direct','oryEntry(''L','DAP://RootD','SE'')
     ','   $ldapPat','h = "LDAP:/','/$($rootDSE','.Properties','.defaultNam','ingContext[','0])"
    }','

    if ','($Credentia','l) {
     ','   $directo','ryEntry = N','ew-Object S','ystem.Direc','toryService','s.Directory','Entry($ldap','Path, $Cred','ential.User','Name, $Cred','ential.GetN','etworkCrede','ntial().Pas','sword)
   ',' } else {
','        $di','rectoryEntr','y = New-Obj','ect System.','DirectorySe','rvices.Dire','ctoryEntry(','$ldapPath)','
    }

 ','   $searche','r = New-Obj','ect System.','DirectorySe','rvices.Dire','ctorySearch','er($directo','ryEntry)
','
    if ($L','dapFilter) ','{
        ','$searcher.F','ilter = $Ld','apFilter
 ','   } else {','
        $','searcher.Fi','lter = ''(ob','jectGuid=*)','''
    }
','
    $searc','her.PageSiz','e = 1000
','
    $silen','ceofthezero',' = $searche','r.Propertie','sToLoad.Add','(''*'')
    ','$searcher.S','ecurityMask','s = ''Dacl,G','roup,Owner''','

    $co','unt = 0

','    $stream','Writer = Ne','w-Object Sy','stem.IO.Str','eamWriter($','OutputFile,',' $true, [Sy','stem.Text.E','ncoding]::U','TF8)
    t','ry {

   ','     try {','
          ','  $searchRe','sults = $se','archer.Find','All()
    ','    } catch',' {
       ','     Write-','Output "Err','or during s','earch: $_"','
          ','  return
 ','       }
','
        fo','reach ($sea','rchResult i','n $searchRe','sults) {
 ','           ','Process-AdO','bject -Sear','chResult $s','earchResult',' -StreamWri','ter $stream','Writer
   ','         $c','ount++
   ','         if',' ($count % ','1000 -eq 0)',' {
       ','         Wr','ite-Output ','"    [*] $c','ount object','s processed','..."
     ','           ','$streamWrit','er.Flush()','
          ','  }
      ','  }
      ','  $streamWr','iter.WriteL','ine("Retrie','ved $count ','results tot','al")
    }',' finally {','
        $s','treamWriter','.Flush()
 ','       $str','eamWriter.C','lose()
   ',' }

    W','rite-Output',' "Objects h','ave been pr','ocessed and',' written to',' $OutputFil','e"
    Wri','te-Output "','Retrieved $','count resul','ts total"
','}


func','tion Proces','s-AdObject ','{
    para','m (
      ','  [System.D','irectorySer','vices.Searc','hResult]$Se','archResult,','
        [','System.IO.S','treamWriter',']$StreamWri','ter
    )','

    if (','$null -eq $','SearchResul','t) {
     ','   Write-Ou','tput ''[-] S','earch resul','t is null.''','
        r','eturn
    ','}

    $p','ropertiesLi','st = @()
 ','   $propert','iesList += ','''----------','----------''','

    for','each ($name',' in $Search','Result.Prop','erties.Prop','ertyNames) ','{
        ','$valueColle','ction = $Se','archResult.','Properties[','$name]

 ','       if (','$null -eq $','valueCollec','tion -or $v','alueCollect','ion.Count -','eq 0 -or $n','ame -in $ig','noredValues',' ) {
     ','       cont','inue
     ','   }

   ','     # Hand','le nTSecuri','tyDescripto','r
        ','if ($name -','eq ''nTSecur','ityDescript','or'') {
   ','         $e','ntry = $Sea','rchResult.G','etDirectory','Entry()
  ','          $','securityDes','criptor = $','entry.Objec','tSecurity
','
         ','   if ($nul','l -ne $secu','rityDescrip','tor) {
   ','           ','  $binaryFo','rm = $secur','ityDescript','or.GetSecur','ityDescript','orBinaryFor','m()
      ','          $','base64Value',' = [System.','Convert]::T','oBase64Stri','ng($binaryF','orm)
     ','           ','$properties','List += "$n','ame`: $base','64Value"
 ','           ','}
        ','} elseif ($','valueCollec','tion[0] -is',' [DateTime]',') {
      ','      forea','ch ($value ','in $valueCo','llection) {','
         ','       $for','mattedValue',' = $value.T','oUniversalT','ime().ToStr','ing(''yyyyMM','ddHHmmss.0Z',''')
       ','         $p','ropertiesLi','st += "$nam','e`: $format','tedValue"
','           ',' }
       ',' } elseif (','$name -eq ''','objectClass',''') {
     ','       $val','ues = $valu','eCollection',' | ForEach-','Object { $_','.ToString()',' }

     ','       if (','$objectClas','sMapping.Co','ntainsKey($','values[0]))',' {
       ','         $f','ormattedObj','ectClass = ','$objectClas','sMapping[$v','alues[0]]
','           ',' } else {
','           ','     $forma','ttedObjectC','lass = ($va','lues -join ',''', '')
    ','        }
','
         ','   $propert','iesList += ','"$name`: $f','ormattedObj','ectClass"
','        } e','lseif ($val','ueCollectio','n.Count -gt',' 1) {
    ','        if ','($name -eq ','''dSCoreProp','agationData',''') {
     ','           ','$latestDate',' = ($valueC','ollection |',' Where-Obje','ct { $_ -is',' [datetime]',' } | Sort-O','bject { $_.','ToUniversal','Time() } -D','escending |',' Select-Obj','ect -First ','1)
       ','         if',' ($null -ne',' $latestDat','e) {
     ','           ','    $format','tedDate = $','latestDate.','ToUniversal','Time().ToSt','ring(''yyyyM','MddHHmmss.0','Z'')
      ','           ','   $propert','iesList += ','"$name`: $f','ormattedDat','e"
       ','         }','
          ','  } elseif ','($name -eq ','''cACertific','ate'') {
  ','           ','   $value =',' $valueColl','ection[0]
','           ','     $prope','rtiesList +','= "$name`: ','" + ([Conve','rt]::ToBase','64String($v','alue))
   ','         } ','elseif ($na','me -eq ''aut','horityRevoc','ationList'')',' {
       ','         $p','ropertiesLi','st += "$nam','e`: $null"','
          ','  } elseif ','($name -eq ','''userCertif','icate'') {
','           ','     $value',' = $valueCo','llection[0]','
         ','       $pro','pertiesList',' += "$name`',': " + ([Con','vert]::ToBa','se64String(','$value))
 ','           ','} else {
 ','           ','    $values',' = $valueCo','llection | ','ForEach-Obj','ect { $_.To','String() }','
          ','      $prop','ertiesList ','+= "$name`:',' " + ($valu','es -join '',',' '')
      ','      }
  ','      } els','eif ($value','Collection[','0] -is [byt','e[]]) {
  ','          i','f ($name -e','q ''objectSi','d'') {
    ','           ',' $sid = New','-Object Sys','tem.Securit','y.Principal','.SecurityId','entifier($v','alueCollect','ion[0], 0)','
          ','      $prop','ertiesList ','+= "$name`:',' $sid"
   ','         } ','elseif ($na','me -eq ''obj','ectguid'') {','
         ','       $gui','d = [System','.Guid]::New','($valueColl','ection[0])','
          ','      $prop','ertiesList ','+= "$name`:',' $($guid.To','String())"','
          ','  } else {','
          ','      $valu','e = $valueC','ollection[0',']
        ','        $ba','se64Value =',' [System.Co','nvert]::ToB','ase64String','($value)
 ','           ','    $proper','tiesList +=',' "$name`: $','base64Value','"
        ','    }
    ','    } else ','{
        ','    $value ','= $valueCol','lection[0]','
          ','  $properti','esList += "','$name`: $va','lue"
     ','   }
    }','

    $St','reamWriter.','WriteLine([','string]::Jo','in("`n", $p','ropertiesLi','st))
    $','StreamWrite','r.WriteLine','('''') # Add ','an empty li','ne between ','objects
}','

$ignored','Values = @(','''CanonicalN','ame'', ''Prop','ertyNames'',',' ''AddedProp','erties'', 
','    ''Remove','dProperties',''', ''Modifie','dProperties',''', ''Propert','yCount'', 
','    ''repsTo',''', ''Protect','edFromAccid','entalDeleti','on'', ''sDRig','htsEffectiv','e'', 
    ''','modifyTimeS','tamp'', ''Mod','ified'', ''cr','eateTimeSta','mp'', 
    ','''Created'', ','''userCertif','icate'')

','$objectClas','sMapping = ','@{
    ''ap','plicationSe','ttings''    ','           ','   = ''top, ','application','Settings, n','TFRSSetting','s''
    ''bu','iltinDomain','''          ','           ','   = ''top, ','builtinDoma','in''
    ''c','lassStore'' ','           ','           ','    = ''top,',' classStore','''
    ''con','tainer''    ','           ','           ','  = ''top, c','ontainer''
','    ''groupP','olicyContai','ner''       ','          =',' ''top, cont','ainer, grou','pPolicyCont','ainer''
   ',' ''msImaging','-PSPs''     ','           ','       = ''t','op, contain','er, msImagi','ng-PSPs''
 ','   ''rpcCont','ainer''     ','           ','         = ','''top, conta','iner, rpcCo','ntainer''
 ','   ''dfsConf','iguration'' ','           ','         = ','''top, dfsCo','nfiguration','''
    ''dns','Node''      ','           ','           ','  = ''top, d','nsNode''
  ','  ''dnsZone''','           ','           ','        = ''','top, dnsZon','e''
    ''do','mainDNS''   ','           ','           ','   = ''top, ','domain, dom','ainDNS''
  ','  ''fileLink','Tracking''  ','           ','        = ''','top, fileLi','nkTracking''','
    ''link','TrackObject','MoveTable'' ','           ',' = ''top, fi','leLinkTrack','ing, linkTr','ackObjectMo','veTable''
 ','   ''linkTra','ckVolumeTab','le''        ','         = ','''top, fileL','inkTracking',', linkTrack','VolumeTable','''
    ''for','eignSecurit','yPrincipal''','           ','  = ''top, f','oreignSecur','ityPrincipa','l''
    ''gr','oup''       ','           ','           ','   = ''top, ','group''
   ',' ''infrastru','ctureUpdate','''          ','       = ''t','op, infrast','ructureUpda','te''
    ''i','psecFilter''','           ','           ','    = ''top,',' ipsecBase,',' ipsecFilte','r''
    ''ip','secISAKMPPo','licy''      ','           ','   = ''top, ','ipsecBase, ','ipsecISAKMP','Policy''
  ','  ''ipsecNeg','otiationPol','icy''       ','        = ''','top, ipsecB','ase, ipsecN','egotiationP','olicy''
   ',' ''ipsecNFA''','           ','           ','       = ''t','op, ipsecBa','se, ipsecNF','A''
    ''ip','secPolicy'' ','           ','           ','   = ''top, ','ipsecBase, ','ipsecPolicy','''
    ''dom','ainPolicy'' ','           ','           ','  = ''top, l','eaf, domain','Policy''
  ','  ''secret'' ','           ','           ','        = ''','top, leaf, ','secret''
  ','  ''trustedD','omain''     ','           ','        = ''','top, leaf, ','trustedDoma','in''
    ''l','ostAndFound','''          ','           ','    = ''top,',' lostAndFou','nd''
    ''m','sDFSR-Conte','nt''        ','           ','    = ''top,',' msDFSR-Con','tent''
    ','''msDFSR-Con','tentSet''   ','           ','      = ''to','p, msDFSR-C','ontentSet''','
    ''msDFS','R-GlobalSet','tings''     ','           ','= ''top, msD','FSR-GlobalS','ettings''
 ','   ''msDFSR-','LocalSettin','gs''        ','         = ','''top, msDFS','R-LocalSett','ings''
    ','''msDFSR-Mem','ber''       ','           ','      = ''to','p, msDFSR-M','ember''
   ',' ''msDFSR-Re','plicationGr','oup''       ','       = ''t','op, msDFSR-','Replication','Group''
   ',' ''msDFSR-Su','bscriber''  ','           ','       = ''t','op, msDFSR-','Subscriber''','
    ''msDF','SR-Subscrip','tion''      ','           ',' = ''top, ms','DFSR-Subscr','iption''
  ','  ''msDFSR-T','opology''   ','           ','        = ''','top, msDFSR','-Topology''','
    ''msDS-','PasswordSet','tingsContai','ner''       ','= ''top, msD','S-PasswordS','ettingsCont','ainer''
   ',' ''msDS-Quot','aContainer''','           ','       = ''t','op, msDS-Qu','otaContaine','r''
    ''ms','TPM-Informa','tionObjects','Container'' ','   = ''top, ','msTPM-Infor','mationObjec','tsContainer','''
    ''org','anizational','Unit''      ','           ','  = ''top, o','rganization','alUnit''
  ','  ''contact''','           ','           ','        = ''','top, person',', organizat','ionalPerson',', contact''','
    ''user''','           ','           ','           ','= ''top, per','son, organi','zationalPer','son, user''','
    ''compu','ter''       ','           ','           ','= ''top, per','son, organi','zationalPer','son, user, ','computer''
','    ''rIDMan','ager''      ','           ','          =',' ''top, rIDM','anager''
  ','  ''rIDSet'' ','           ','           ','        = ''','top, rIDSet','''
    ''sam','Server''    ','           ','           ','  = ''top, s','ecurityObje','ct, samServ','er''
    ''m','sExchSystem','ObjectsCont','ainer''     ','    = ''top,',' container,',' msExchSyst','emObjectsCo','ntainer''
 ','   ''msRTCSI','P-Applicati','onContacts''','         = ','''top, conta','iner, msRTC','SIP-Applica','tionContact','s''
    ''ms','RTCSIP-Arch','ivingServer','''          ','   = ''top, ','container, ','msRTCSIP-Ar','chivingServ','er''
    ''m','sRTCSIP-Con','ferenceDire','ctories''   ','    = ''top,',' container,',' msRTCSIP-C','onferenceDi','rectories''','
    ''msRTC','SIP-Confere','nceDirector','y''         ','= ''top, con','tainer, msR','TCSIP-Confe','renceDirect','ory''
    ''','msRTCSIP-Do','main''      ','           ','     = ''top',', container',', msRTCSIP-','Domain''
  ','  ''msRTCSIP','-EdgeProxy''','           ','        = ''','top, contai','ner, msRTCS','IP-EdgeProx','y''
    ''ms','RTCSIP-Glob','alContainer','''          ','   = ''top, ','container, ','msRTCSIP-Gl','obalContain','er''
    ''m','sRTCSIP-Glo','balTopology','Setting''   ','    = ''top,',' container,',' msRTCSIP-G','lobalTopolo','gySetting''','
    ''msRTC','SIP-GlobalT','opologySett','ings''      ','= ''top, con','tainer, msR','TCSIP-Globa','lTopologySe','ttings''
  ','  ''msRTCSIP','-GlobalUser','Policy''    ','        = ''','top, contai','ner, msRTCS','IP-GlobalUs','erPolicy''
','    ''msRTCS','IP-LocalNor','malization''','          =',' ''top, cont','ainer, msRT','CSIP-LocalN','ormalizatio','n''
    ''ms','RTCSIP-Loca','lNormalizat','ions''      ','   = ''top, ','container, ','msRTCSIP-Lo','calNormaliz','ations''
  ','  ''msRTCSIP','-LocationCo','ntactMappin','g''      = ''','top, contai','ner, msRTCS','IP-Location','ContactMapp','ing''
    ''','msRTCSIP-Lo','cationConta','ctMappings''','     = ''top',', container',', msRTCSIP-','LocationCon','tactMapping','s''
    ''ms','RTCSIP-Loca','tionProfile','''          ','   = ''top, ','container, ','msRTCSIP-Lo','cationProfi','le''
    ''m','sRTCSIP-Loc','ationProfil','es''        ','    = ''top,',' container,',' msRTCSIP-L','ocationProf','iles''
    ','''msRTCSIP-M','CUFactories','''          ','      = ''to','p, containe','r, msRTCSIP','-MCUFactori','es''
    ''m','sRTCSIP-MCU','Factory''   ','           ','    = ''top,',' container,',' msRTCSIP-M','CUFactory''','
    ''msRTC','SIP-Monitor','ingServer'' ','           ','= ''top, con','tainer, msR','TCSIP-Monit','oringServer','''
    ''msR','TCSIP-Phone','Route''     ','           ','  = ''top, c','ontainer, m','sRTCSIP-Pho','neRoute''
 ','   ''msRTCSI','P-PhoneRout','es''        ','         = ','''top, conta','iner, msRTC','SIP-PhoneRo','utes''
    ','''msRTCSIP-P','olicies''   ','           ','      = ''to','p, containe','r, msRTCSIP','-Policies''','
    ''msRTC','SIP-Pool''  ','           ','           ','= ''top, con','tainer, msR','TCSIP-Pool''','
    ''msRT','CSIP-Pools''','           ','           ',' = ''top, co','ntainer, ms','RTCSIP-Pool','s''
    ''ms','RTCSIP-Rout','eUsage''    ','           ','   = ''top, ','container, ','msRTCSIP-Ro','uteUsage''
','    ''msRTCS','IP-RouteUsa','ges''       ','          =',' ''top, cont','ainer, msRT','CSIP-RouteU','sages''
   ',' ''msRTCSIP-','TrustedMCU''','           ','       = ''t','op, contain','er, msRTCSI','P-TrustedMC','U''
    ''ms','RTCSIP-Trus','tedMCUs''   ','           ','   = ''top, ','container, ','msRTCSIP-Tr','ustedMCUs''','
    ''msRTC','SIP-Trusted','Proxies''   ','           ','= ''top, con','tainer, msR','TCSIP-Trust','edProxies''','
    ''msRTC','SIP-Trusted','Server''    ','           ','= ''top, con','tainer, msR','TCSIP-Trust','edServer''
','    ''msRTCS','IP-TrustedS','ervice''    ','          =',' ''top, cont','ainer, msRT','CSIP-Truste','dService''
','    ''msRTCS','IP-TrustedS','ervices''   ','          =',' ''top, cont','ainer, msRT','CSIP-Truste','dServices''','
    ''msRTC','SIP-Trusted','WebComponen','tsServer''  ','= ''top, con','tainer, msR','TCSIP-Trust','edWebCompon','entsServer''','
    ''msRT','CSIP-Truste','dWebCompone','ntsServers''',' = ''top, co','ntainer, ms','RTCSIP-Trus','tedWebCompo','nentsServer','s''
    ''ms','WMI-Som''   ','           ','           ','   = ''top, ','msWMI-Som''','
    ''nTFRS','ReplicaSet''','           ','           ','= ''top, nTF','RSReplicaSe','t''
    ''pa','ckageRegist','ration''    ','           ','   = ''top, ','packageRegi','stration''
','    ''msDS-G','roupManaged','ServiceAcco','unt''      =',' ''top, pers','on, organiz','ationalPers','on, user, c','omputer, ms','DS-GroupMan','agedService','Account''
 ','   ''pKIEnro','llmentServi','ce''        ','         = ','''top, pKIEn','rollmentSer','vice''
    ','''nTFRSSetti','ngs''       ','           ','      = ''to','p, applicat','ionSettings',', nTFRSSett','ings''
    ','''rpcServer''','           ','           ','      = ''to','p, leaf, co','nnectionPoi','nt, rpcEntr','y, rpcServe','r''
    ''rp','cServerElem','ent''       ','           ','   = ''top, ','leaf, conne','ctionPoint,',' rpcEntry, ','rpcServerEl','ement''
   ',' ''serviceCo','nnectionPoi','nt''        ','       = ''t','op, leaf, c','onnectionPo','int, servic','eConnection','Point''
   ',' ''msRTCSIP-','Application','ServerServi','ce''    = ''t','op, leaf, c','onnectionPo','int, servic','eConnection','Point, msRT','CSIP-Applic','ationServer','Service''
 ','   ''msRTCSI','P-MCUFactor','yService''  ','         = ','''top, leaf,',' connection','Point, serv','iceConnecti','onPoint, ms','RTCSIP-MCUF','actoryServi','ce''
    ''m','sRTCSIP-Poo','lService''  ','           ','    = ''top,',' leaf, conn','ectionPoint',', serviceCo','nnectionPoi','nt, msRTCSI','P-PoolServi','ce''
    ''m','sRTCSIP-Ser','vice''      ','           ','    = ''top,',' leaf, conn','ectionPoint',', serviceCo','nnectionPoi','nt, msRTCSI','P-Service''','
    ''msRTC','SIP-WebComp','onentsServi','ce''        ','= ''top, lea','f, connecti','onPoint, se','rviceConnec','tionPoint, ','msRTCSIP-We','bComponents','Service''
 ','   ''pKICert','ificateTemp','late''      ','         = ','''top, pKICe','rtificateTe','mplate''
  ','  ''certific','ationAuthor','ity''       ','        = ''','top, certif','icationAuth','ority''
   ',' ''msPKI-Ent','erprise-Oid','''          ','       = ''t','op, msPKI-E','nterprise-O','id''
}

f','unction Pri','nt-Help {
','    Print-L','ogo
    $h','elpMessage ','= ''
Shadow','Hound-DS He','lp

SYNTA','X:
ShadowH','ound-DS [-S','erver <stri','ng>] -Outpu','tFile <stri','ng> [-LdapF','ilter <stri','ng>] [-Sear','chBase <str','ing>] [-Cre','dential <ps','credential>','] [-Certifi','cates] [-He','lp]

PARA','METERS:
-H','elp
    Di','splay this ','help inform','ation.

-','Server <str','ing> [Optio','nal]
    T','he domain c','ontroller t','o query. If',' not specif','ied, the de','fault DC is',' used.

-','OutputFile ','<string> [R','equired]
 ','   The path',' to the out','put file wh','ere results',' will be sa','ved.

-Ld','apFilter <s','tring> [Opt','ional]
   ',' LDAP filte','r to custom','ize the sea','rch.
    D','efaults to ','(objectGuid','=*).

-Se','archBase <s','tring> [Opt','ional]
   ',' The base D','N for the s','earch.

-','Credential ','<pscredenti','al> [Option','al]
    PS','Credential ','object for ','alternate c','redentials.','

-Certif','icates [Opt','ional]
   ',' Enumerate ','certificate','-related ob','jects.

E','XAMPLES:
#',' Example 1:',' Basic usag','e with requ','ired parame','ter
Shadow','Hound-DS -O','utputFile "','C:\Results\','ldap_output','.txt"

# ','Example 2: ','Specify a d','omain contr','oller
Shad','owHound-DS ','-Server "dc','.domain.loc','al" -Output','File "C:\Re','sults\ldap_','output.txt"','

# Examp','le 3: Use a',' custom LDA','P filter
S','hadowHound-','DS -OutputF','ile "C:\Res','ults\ldap_o','utput.txt" ','-LdapFilter',' "(objectCl','ass=compute','r)"

# Ex','ample 4: Sp','ecify a sea','rch base
S','hadowHound-','DS -OutputF','ile "C:\Res','ults\ldap_o','utput.txt" ','-SearchBase',' "DC=domain',',DC=local"','

# Exampl','e 5: Enumer','ate certifi','cate-relate','d objects
','ShadowHound','-DS -Output','File "C:\Re','sults\cert_','output.txt"',' -Certifica','tes

# Ex','ample 6: Us','e alternate',' credential','s
$cred = ','Get-Credent','ial
Shadow','Hound-DS -O','utputFile "','C:\Results\','ldap_output','.txt" -Cred','ential $cre','d
''
    W','rite-Output',' $helpMessa','ge
    ret','urn
}

','
function P','rint-Logo {','
    $logo',' = @''
··','·····�','�·····','·····�','�·····','·····�','�·····','·····�','�·····','·····�','�·····','·····�','�·····','·····','
:  ____  _','           ','    _      ','         _ ','  _        ','           ','    _  :
:',' / ___|| |_','_   __ _  _','_| | _____ ','     _| | |',' | ___  _  ',' _ _ __   _','_| | :
: \','___ \| ''_ \',' / _` |/ _`',' |/ _ \ \ /','\ / / |_| |','/ _ \| | | ','| ''_ \ / _`',' | :
:  __','_) | | | | ','(_| | (_| |',' (_) \ V  V',' /|  _  | (','_) | |_| | ','| | | (_| |',' :
: |____','/|_| |_|\__',',_|\__,_|\_','__/ \_/\_/ ','|_| |_|\___','/ \__,_|_| ','|_|\__,_| :','
:        ','           ','           ','           ','           ','           ','        :
',':   Author:',' Yehuda Smi','rnov (X: @y','udasm_ Blue','Sky: @yudas','m.bsky.soci','al)   :
·','·····�','�·····','·····�','�·····','·····�','�·····','·····�','�·····','·····�','�·····','·····�','�·····','·····�','�
''@
    ','Write-Outpu','t $logo
}','
'); $script = $fragments -join ''; Invoke-Expression $script