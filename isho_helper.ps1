$rukp = @('function ShadowHound','-ADM {
   ',' [CmdletBin','ding()]
  ','  param(
 ','       [Par','ameter(Mand','atory = $fa','lse, HelpMe','ssage = ''Th','e domain co','ntroller to',' query.'')]','
        [s','tring]$Serv','er,

    ','    [Parame','ter(Mandato','ry = $false',', HelpMessa','ge = ''Path ','to the outp','ut file whe','re results ','will be sav','ed.'')]
   ','     [Valid','ateNotNullO','rEmpty()]
','        [st','ring]$Outpu','tFilePath,','

        ','[Parameter(','Mandatory =',' $false, He','lpMessage =',' ''LDAP filt','er to custo','mize the se','arch.'')]
 ','       [str','ing]$LdapFi','lter = ''(Ob','jectGuid=*)',''',

     ','   [Paramet','er(Mandator','y = $false,',' HelpMessag','e = ''The ba','se DN for t','he search.''',')]
       ',' [string]$S','earchBase,','

        ','[Parameter(','Mandatory =',' $false, He','lpMessage =',' ''The numbe','r of object','s to includ','e in one pa','ge for pagi','ng LDAP sea','rches.'')]
','        [in','t]$PageSize',' = 1000,
','
        [P','arameter(Ma','ndatory = $','false, Help','Message = ''','PSCredentia','l object fo','r alternate',' credential','s.'')]
    ','    [pscred','ential]$Cre','dential,
','
        [P','arameter(Ma','ndatory = $','false, Help','Message = ''','Splits the ','search acro','ss top-leve','l container','s to handle',' large doma','ins.'')]
  ','      [swit','ch]$SplitSe','arch,

  ','      [Para','meter(Manda','tory = $fal','se, HelpMes','sage = ''Spl','its the sea','rch by firs','t letter of',' CN to hand','le large do','mains, if t','he query fa','ils, will a','lso split t','he letter.''',')]
       ',' [switch]$L','etterSplitS','earch,

 ','       [Par','ameter(Mand','atory = $fa','lse, HelpMe','ssage = ''Pa','th to a fil','e containin','g a list of',' parsed con','tainers.'')]','
        [','string]$Par','sedContaine','rs,

    ','    [Parame','ter(Mandato','ry = $false',', HelpMessa','ge = ''Recur','sively proc','ess contain','ers that fa','il.'')]
   ','     [switc','h]$Recurse,','

       ',' [Parameter','(Mandatory ','= $false, H','elpMessage ','= ''Enumerat','e certifica','tes.'')]
  ','      [swit','ch]$Certifi','cates,

 ','       [Par','ameter(Mand','atory = $fa','lse, HelpMe','ssage = ''Di','splay help ','information','.'')]
     ','   [switch]','$Help
    ',')

    if',' ($Help) {','
        Pr','int-Help
 ','       retu','rn
    }
','
    if ($','Certificate','s -and ($Sp','litSearch -','or $LetterS','plitSearch ','-or $Recurs','e -or $Pars','edContainer','s -or $Sear','chBase)) { ','
        W','rite-Error ','''[!] Certif','icate enume','ration is d','one seprate','ly from the',' rest of th','e enumerati','on.''
     ','   return
','    }

  ','  if (-not ','$OutputFile','Path) {
  ','      Write','-Error ''[!]',' -OutputFil','ePath is re','quired.''
 ','       retu','rn
    }
','
    if ($','ParsedConta','iners -and ','-not $Split','Search) {
','        Wri','te-Error ''[','!] Cannot p','arse contai','ners if -Sp','litSearch i','s not provi','ded.''
    ','    return','
    }

 ','   if ($Rec','urse -and -','not $SplitS','earch) {
 ','       Writ','e-Error ''[!','] Cannot re','curse if -S','plitSearch ','is not prov','ided.''
   ','     return','
    }

','    if ($Pa','rsedContain','ers -and -n','ot (Test-Pa','th -Path $P','arsedContai','ners)) {
 ','       Writ','e-Error ''[!','] -ParsedCo','ntainers pa','th not foun','d, provide ','a valid pat','h.''
      ','  return
 ','   }


 ','   Print-Lo','go
    Wri','te-Output ''','[+] Executi','ng with the',' following ','parameters:','''
    if (','$server) { ','Write-Outpu','t "   - Ser','ver: $Serve','r" }
    W','rite-Output',' "   - Outp','utFilePath:',' $OutputFil','ePath"
   ',' if ($LdapF','ilter) { Wr','ite-Output ','"   - LdapF','ilter: $Lda','pFilter" }','
    if ($S','earchBase) ','{ Write-Out','put "   - S','earchBase: ','$SearchBase','" }
    if',' ($SplitSea','rch) { Writ','e-Output '' ','  - SplitSe','arch enable','d'' }
    i','f ($LetterS','plitSearch)',' { Write-Ou','tput ''   - ','LetterSplit','Search enab','led'' }
   ',' if ($Recur','se) { Write','-Output ''  ',' - Recurse ','enabled'' }','
    if ($C','redential) ','{ Write-Out','put "   - C','redential: ','$($Credenti','al.UserName',')" }
    i','f ($ParsedC','ontainers) ','{ Write-Out','put "   - P','arsedContai','ners: $Pars','edContainer','s" }
    i','f ($Certifi','cates) { Wr','ite-Output ','''   - Enume','rating cert','ificates'' }','


    $','count = [re','f]0
    $p','rintingThre','shold = 100','0

    # ','Prepare Get','-ADObject p','arameters
','    $getAdO','bjectParams',' = @{
    ','    Propert','ies = ''*''
','        Lda','pFilter = $','LdapFilter','
    }

 ','   if ($Ser','ver) { $get','AdObjectPar','ams[''Server','''] = $Serve','r }
    if',' ($SearchBa','se) { $getA','dObjectPara','ms[''SearchB','ase''] = $Se','archBase }','
    if ($C','redential) ','{ $getAdObj','ectParams[''','Credential''','] = $Creden','tial }
   ',' if ($PageS','ize) { $get','AdObjectPar','ams[''Result','PageSize''] ','= $PageSize',' }

    #',' Open Strea','mWriter
  ','  $streamWr','iter = New-','Object Syst','em.IO.Strea','mWriter($Ou','tputFilePat','h, $true, [','System.Text','.Encoding]:',':UTF8)
   ',' try {
   ','     $strea','mWriter.Wri','teLine(''---','-----------','------'')
 ','       if (','$Certificat','es) {

  ','          W','rite-Output',' ''[*] Getti','ng Configur','ation Namin','g Context..','.''
       ','     $confi','gEnumParams',' = @{}
   ','         if',' ($Server) ','{ $configEn','umParams[''S','erver''] = $','Server }
 ','           ','if ($Creden','tial) { $co','nfigEnumPar','ams[''Creden','tial''] = $C','redential }','
         ','   $configC','ontext = (G','et-ADRootDS','E @configEn','umParams).C','onfiguratio','nNamingCont','ext
      ','      if ($','null -eq $c','onfigContex','t) {
     ','           ','Write-Error',' ''[-] Faile','d to retrie','ve Configur','ationNaming','Context.''
','           ','     return','
         ','   }

   ','         Wr','ite-Output ','"[*] Enumer','ating PKI o','bjects unde','r $configCo','ntext..."
','           ',' $getAdObje','ctParams[''S','earchBase'']',' = $configC','ontext

 ','           ','$getAdObjec','tParams[''Ld','apFilter''] ','= ''(objectC','lass=pKIEnr','ollmentServ','ice)''
    ','        Per','form-ADQuer','y -SearchPa','rams $getAd','ObjectParam','s -StreamWr','iter $strea','mWriter -Co','unt $count ','-PrintingTh','reshold $pr','intingThres','hold

   ','         $g','etAdObjectP','arams[''Ldap','Filter''] = ','''(objectCla','ss=pKICerti','ficateTempl','ate)''
    ','        Per','form-ADQuer','y -SearchPa','rams $getAd','ObjectParam','s -StreamWr','iter $strea','mWriter -Co','unt $count ','-PrintingTh','reshold $pr','intingThres','hold

   ','         $g','etAdObjectP','arams[''Ldap','Filter''] = ','''(objectCla','ss=certific','ationAuthor','ity)''
    ','        Per','form-ADQuer','y -SearchPa','rams $getAd','ObjectParam','s -StreamWr','iter $strea','mWriter -Co','unt $count ','-PrintingTh','reshold $pr','intingThres','hold

   ','         $g','etAdObjectP','arams[''Ldap','Filter''] = ','''(objectcla','ss=msPKI-En','terprise-Oi','d)''
      ','      Perfo','rm-ADQuery ','-SearchPara','ms $getAdOb','jectParams ','-StreamWrit','er $streamW','riter -Coun','t $count -P','rintingThre','shold $prin','tingThresho','ld

     ','   } elseif',' ($SplitSea','rch -eq $fa','lse -and $L','etterSplitS','earch -eq $','false) {
','
          ','  Perform-A','DQuery -Sea','rchParams $','getAdObject','Params -Str','eamWriter $','streamWrite','r -Count $c','ount -Print','ingThreshol','d $printing','Threshold
','
        }',' elseif ($S','plitSearch ','-eq $true) ','{
        ','    # Get t','op-level co','ntainers
 ','           ','Write-Outpu','t "[*] Disc','overing top',' level cont','ainers for ','$Server..."','
         ','   $topLeve','lContainers',' = Get-TopL','evelContain','ers -Params',' $getAdObje','ctParams
 ','           ','if ($null -','eq $topLeve','lContainers',') {
      ','          W','rite-Error ','''[-] Someth','ing went wr','ong, no top','-level cont','ainers foun','d.''
      ','          r','eturn
    ','        }
','
         ','   # We als','o need to q','uery specif','ically the ','domain obje','ct
       ','     $dcSea','rchParams =',' @{
      ','          P','roperties =',' ''*''
     ','           ','LdapFilter ','= ''(objectC','lass=domain',')''
       ','     }

 ','           ','if ($server',') { $dcSear','chParams[''S','erver''] = $','Server }
 ','           ','if ($Creden','tial) { $dc','SearchParam','s[''Credenti','al''] = $Cre','dential }
','
         ','   Perform-','ADQuery -Se','archParams ','$dcSearchPa','rams -Strea','mWriter $st','reamWriter ','-Count $cou','nt -Printin','gThreshold ','$printingTh','reshold
  ','           ','           ','
         ','   # In let','ter split s','earch we ne','ed to make ','sure the to','p level con','tainers are',' included
','           ',' if ($Lette','rSplitSearc','h -eq $true',') {
      ','          $','topLevelCon','tainers | F','orEach-Obje','ct {
     ','           ','    Process','-AdObject -','AdObject $_',' -StreamWri','ter $stream','Writer
   ','           ','      $coun','t.Value++
','           ','         if',' ($count.Va','lue % $prin','tingThresho','ld -eq 0) {','
         ','           ','    Write-O','utput "[+] ','Queried $($','Count.Value',') objects s','o far..."
','           ','           ','  $streamWr','iter.Flush(',')
        ','           ',' }
       ','         }','


      ','      }

','
         ','   Write-Ou','tput "[+] F','ound $($top','LevelContai','ners.Count)',' top-level ','containers.','"

      ','      $proc','essedContai','ners = @()','
          ','  $unproces','sedContaine','rs = @()
','
          ','  if ($Pars','edContainer','s) {
     ','           ','$ParsedCont','ainersList ','= Get-Conte','nt -Path $P','arsedContai','ners
     ','       } el','se {
     ','           ','$ParsedCont','ainersList ','= @()
    ','        }
','
         ','   # proces','s them cont','ainers
   ','         fo','reach ($con','tainer in $','topLevelCon','tainers) {','
          ','      $cont','ainerDN = $','container.D','istinguishe','dName

  ','           ','   if ($Par','sedContaine','rsList -con','tains $cont','ainerDN) {','
          ','          W','rite-Output',' "[+] Encou','ntered alre','ady parsed ','container $','containerDN',', skipping.','.."
      ','           ','   $process','edContainer','s += $conta','inerDN
   ','           ','      conti','nue
      ','          }','

       ','         $c','ontainerSea','rchParams =',' $getAdObje','ctParams.Cl','one()
    ','           ',' $container','SearchParam','s[''SearchBa','se''] = $con','tainerDN
','
          ','      Write','-Output "[*','] Processin','g container',' ($($proces','sedContaine','rs.Count + ','$unprocesse','dContainers','.Count + 1)','/$($topLeve','lContainers','.Count)): $','containerDN','"

      ','          i','f ($LetterS','plitSearch ','-eq $false)',' {
       ','           ','  try {
  ','           ','           ','# Process t','he containe','r
        ','           ','     Perfor','m-ADQuery -','SearchParam','s $containe','rSearchPara','ms -StreamW','riter $stre','amWriter -C','ount $count',' -PrintingT','hreshold $p','rintingThre','shold
    ','           ','         $p','rocessedCon','tainers += ','$containerD','N
        ','           ',' } catch {','
          ','           ','   Write-Er','ror "[-] Er','ror process','ing contain','er ''$contai','nerDN'': $_"','
         ','           ','    $unproc','essedContai','ners += $co','ntainerDN
','           ','           ','  continue','
          ','          }','
         ','       } el','seif ($Lett','erSplitSear','ch -eq $tru','e) {

   ','           ','      # Spl','it the sear','ch by first',' letter
  ','           ','       $cha','rset = ([ch','ar[]](97..1','22) + [char','[]](48..57)',' + ''!'', ''_''',', ''@'', ''$'',',' ''{'', ''}'')','
          ','          $','OriginalFil','ter = $cont','ainerSearch','Params[''Lda','pFilter'']
','           ','         fo','reach ($cha','r in $chars','et) {
    ','           ','         Wr','ite-Output ','"  [*] Quer','ying $conta','inerDN for ','objects wit','h CN starti','ng with ''$c','har''"
    ','           ','         $c','ontainerSea','rchParams[''','LdapFilter''','] = "(&$Ori','ginalFilter','(cn=$char**','))"

    ','           ','         tr','y {
      ','           ','           ','Perform-ADQ','uery -Searc','hParams $co','ntainerSear','chParams -S','treamWriter',' $streamWri','ter -Count ','$count -Pri','ntingThresh','old $printi','ngThreshold','
         ','           ','    } catch',' {
       ','           ','          W','rite-Output',' "   [!!] E','rror proces','sing CN=$ch','ar* for con','tainer ''$co','ntainerDN'':',' $_`nTrying',' to split e','ach letter ','again..."
','           ','           ','      forea','ch ($subCha','r in $chars','et) {
    ','           ','           ','      try {','
         ','           ','           ','     Write-','Output "  [','*] Querying',' $container','DN for obje','cts with CN',' starting w','ith ''$char$','subChar''"
','           ','           ','           ','   $contain','erSearchPar','ams[''LdapFi','lter''] = "(','&$OriginalF','ilter(cn=$c','har$subChar','**))"
    ','           ','           ','          P','erform-ADQu','ery -Search','Params $con','tainerSearc','hParams -St','reamWriter ','$streamWrit','er -Count $','count -Prin','tingThresho','ld $printin','gThreshold','
          ','           ','           ','} catch {
','           ','           ','           ','   Write-Ou','tput "   [-','] Failed to',' process (C','N=$char$sub','Char*) for ','container ''','$containerD','N'': $_`nMov','ing to the ','next sub le','tter..."
 ','           ','           ','           ','  continue','
          ','           ','           ','}
        ','           ','         }','
          ','           ','   }
     ','           ','    }

  ','           ','       $pro','cessedConta','iners += $c','ontainerDN','
          ','      }
  ','          }','

       ','     # Outp','ut summary','
          ','  Write-Out','put "Proces','sed $($coun','t.Value) ob','jects in to','tal."
    ','        if ','($processed','Containers.','Count -gt 0',') {
      ','          W','rite-Output',' ''[+] Succe','ssfully pro','cessed cont','ainers:''
 ','           ','    $proces','sedContaine','rs | ForEac','h-Object { ','Write-Outpu','t "  - $_" ','}
        ','    }
    ','        if ','($unprocess','edContainer','s.Count -gt',' 0) {
    ','           ',' Write-Outp','ut "`n[-] F','ailed to pr','ocess conta','iners:"
  ','           ','   $unproce','ssedContain','ers | ForEa','ch-Object {',' Write-Outp','ut "    - $','_" }
     ','       }
 ','       } el','seif ($Lett','erSplitSear','ch -eq $tru','e -and $Spl','itSearch -e','q $false) {','
         ','   $charset',' = ([char[]','](97..122) ','+ [char[]](','48..57) + ''','!'', ''_'', ''@',''', ''$'', ''{''',', ''}'')
   ','         $O','riginalFilt','er = $getAd','ObjectParam','s[''LdapFilt','er'']
     ','       fore','ach ($char ','in $charset',') {
      ','          W','rite-Output',' "  [*] Que','rying for o','bjects with',' CN startin','g with ''$ch','ar''"
     ','           ','$getAdObjec','tParams[''Ld','apFilter''] ','= "(&$Origi','nalFilter(c','n=$char**))','"

      ','          t','ry {
     ','           ','    Perform','-ADQuery -S','earchParams',' $getAdObje','ctParams -S','treamWriter',' $streamWri','ter -Count ','$count -Pri','ntingThresh','old $printi','ngThreshold','
         ','       } ca','tch {
    ','           ','     Write-','Output "   ','[!!] Error ','processing ','character ''','$char*'': $_','"
        ','           ',' Write-Outp','ut ''       ',' Trying to ','split each ','letter agai','n...''
    ','           ','     foreac','h ($subChar',' in $charse','t) {
     ','           ','        try',' {
       ','           ','          W','rite-Output',' "  [*] Que','rying for o','bjects with',' CN startin','g with ''$ch','ar$subChar''','"
        ','           ','         $g','etAdObjectP','arams[''Ldap','Filter''] = ','"(&$Origina','lFilter(cn=','$char$subCh','ar**))"
  ','           ','           ','    Perform','-ADQuery -S','earchParams',' $getAdObje','ctParams -S','treamWriter',' $streamWri','ter -Count ','$count -Pri','ntingThresh','old $printi','ngThreshold','
         ','           ','    } catch',' {
       ','           ','          W','rite-Output',' "   [-] Fa','iled to pro','cess (CN=$c','har$subChar','*): $_"
  ','           ','           ','    Write-O','utput ''    ','   Moving t','o the next ','sub letter.','..''
      ','           ','           ','continue
 ','           ','           ',' }
       ','           ','  }
      ','          }','
         ','   }
     ','   }


 ','       $sum','maryLine = ','"Retrieved ','$($count.Va','lue) result','s total"
 ','       $str','eamWriter.W','riteLine($s','ummaryLine)','
    } fin','ally {
   ','     $strea','mWriter.Flu','sh()
     ','   $streamW','riter.Close','()
    }
','
    Write','-Output "Ob','jects have ','been proces','sed and wri','tten to $Ou','tputFilePat','h"
    Wri','te-Output $','summaryLine','
    Write','-Output ''==','===========','===========','===========','===========','=====''

 ','   # Handle',' recursion ','if necessar','y
    if (','$Recurse -a','nd $unproce','ssedContain','ers.Count -','gt 0) {
  ','      Write','-Output "[*','] Current S','earchBase i','s $SearchBa','se"
      ','  Write-Out','put "[*] At','tempting to',' recurse $(','$unprocesse','dContainers','.Count) fai','led contain','ers/OUs:"
','        for','each ($fail','edContainer',' in $unproc','essedContai','ners) {
  ','          W','rite-Output',' $failedCon','tainer

 ','           ','$recursePar','ams = @{
 ','           ','    OutputF','ilePath = "','$($failedCo','ntainer.Spl','it('','')[0].','Split(''='')[','1])_$Output','FilePath"
','           ','     Search','Base     = ','$failedCont','ainer
    ','           ',' SplitSearc','h    = $tru','e
        ','        Rec','urse       ',' = $true
 ','           ','}
        ','    if ($Se','rver) { $re','curseParams','[''Server''] ','= $Server }','
         ','   if ($Cre','dential) { ','$recursePar','ams[''Creden','tial''] = $C','redential }','
         ','   if ($Par','sedContaine','rs) { $recu','rseParams[''','ParsedConta','iners''] = $','ParsedConta','iners }
  ','          i','f ($LdapFil','ter) { $rec','urseParams[','''LdapFilter','''] = $LdapF','ilter }

','           ',' if ($Lette','rSplitSearc','h) {
     ','           ','$recursePar','ams[''Letter','SplitSearch','''] = $true','
          ','  }

    ','        Wri','te-Output "','[+] Attempt','ing to recu','rse $failed','Container"','
          ','  ShadowHou','nd-ADM @rec','urseParams','
        }','
    }
}
','
function ','Print-Logo ','{
    $log','o = @''
...','...........','...........','...........','...........','...........','...........','....
:  __','__  _      ','         _ ','           ','   _   _   ','           ','         _ ',' :
: / ___','|| |__   __',' _  __| | _','____      _','| | | | ___','  _   _ _ _','_   __| | :','
: \___ \|',' ''_ \ / _` ','|/ _` |/ _ ','\ \ /\ / / ','|_| |/ _ \|',' | | | ''_ \',' / _` | :
',':  ___) | |',' | | (_| | ','(_| | (_) \',' V  V /|  _','  | (_) | |','_| | | | | ','(_| | :
: ','|____/|_| |','_|\__,_|\__',',_|\___/ \_','/\_/ |_| |_','|\___/ \__,','_|_| |_|\__',',_| :
:   ','           ','           ','           ','           ','           ','           ','  :
:   Au','thor: Yehud','a Smirnov (','X: @yudasm_',' BlueSky: @','yudasm.bsky','.social)   ',':
........','...........','...........','...........','...........','...........','..........','
''@
    Wr','ite-Output ','$logo
}
','
function P','rint-Help {','
    Print','-Logo
    ','$helpMessag','e = ''
Shad','owHound-ADM',' Help

SY','NTAX:
    ','ShadowHound','-ADM [-Serv','er <string>','] -OutputFi','lePath <str','ing> [-Ldap','Filter <str','ing>] [-Sea','rchBase <st','ring>] [-Pa','geSize <int','>] [-Creden','tial <pscre','dential>] [','-SplitSearc','h] [-Letter','SplitSearch','] [-ParsedC','ontainers <','string>] [-','Recurse] [-','Help]

PA','RAMETERS:
','    -Help
','        Dis','play help i','nformation.','

    -Se','rver <strin','g> [Optiona','l]
       ',' The domain',' controller',' to query, ','e.g., domai','n.local or ','192.168.10.','10.

    ','-OutputFile','Path <strin','g> [Require','d]
       ',' The path t','o the outpu','t file wher','e results w','ill be save','d.

    -','LdapFilter ','<string> [O','ptional]
 ','       LDAP',' filter to ','customize t','he search.','
        De','faults to (','objectGuid=','*).

    ','-SearchBase',' <string> [','Optional]
','        The',' base DN fo','r the searc','h, e.g., CN','=top,CN=lev','el,DC=domai','n,DC=local.','
        D','efaults to ','the root of',' the domain','.

    -P','ageSize <in','t> [Optiona','l]
       ',' The number',' of objects',' to include',' in one pag','e for pagin','g LDAP sear','ches.

  ','  -Credenti','al <pscrede','ntial> [Opt','ional]
   ','     PSCred','ential obje','ct for alte','rnate crede','ntials.

','    -SplitS','earch [Opti','onal]
    ','    Splits ','the search ','across top-','level conta','iners to ha','ndle large ','domains.
','
    -Lette','rSplitSearc','h [Optional',']
        ','Splits the ','search by f','irst letter',' of CN to h','andle large',' domains; i','f the query',' fails, wil','l also spli','t the lette','r.

    -','ParsedConta','iners <stri','ng> [Option','al]
      ','  Path to a',' file conta','ining a new','line-separa','ted list of',' Distinguis','hed Names o','f parsed co','ntainers (e','xact match ','required).','

    -Cer','tificates [','Optional]
','        Enu','merate cert','ificates.
','
    -Recu','rse [Option','al]
      ','  Recursive','ly process ','containers ','that fail.','

EXAMPLES',':
    # Ex','ample 1: Ba','sic usage w','ith require','d parameter','
    Shado','wHound-ADM ','-OutputFile','Path "C:\Re','sults\outpu','t.txt"

 ','   # Exampl','e 2: Specif','y a domain ','controller ','and custom ','LDAP filter','
    Shado','wHound-ADM ','-Server "dc','.domain.loc','al" -Output','FilePath "C',':\Results\o','utput.txt" ','-LdapFilter',' "(objectCl','ass=user)"','

    # Ex','ample 3: Us','e alternate',' credential','s and speci','fy a search',' base
    ','$cred = Get','-Credential','
    Shado','wHound-ADM ','-OutputFile','Path "C:\Re','sults\outpu','t.txt" -Cre','dential $cr','ed -SearchB','ase "DC=dom','ain,DC=loca','l"

    #',' Example 4:',' Split the ','search acro','ss top-leve','l container','s with spli','t letter se','arch
    S','hadowHound-','ADM -Output','FilePath "C',':\Results\o','utput.txt" ','-SplitSearc','h -LetterSp','litSearch
','
    # Exa','mple 5: Enu','merate cert','ificates
 ','   ShadowHo','und-ADM -Ou','tputFilePat','h "C:\Resul','ts\output.t','xt" -Certif','icates
''
','    Write-H','ost $helpMe','ssage
    ','return
}
','
function ','Process-AdO','bject {
  ','  [CmdletBi','nding()]
 ','   param (','
        [P','arameter(Ma','ndatory = $','true)]
   ','     [Micro','soft.Active','Directory.M','anagement.A','DObject]$Ad','Object,

','        [Pa','rameter(Man','datory = $t','rue)]
    ','    [System','.IO.StreamW','riter]$Stre','amWriter
 ','   )

   ',' # Define i','gnored prop','erties
   ',' $ignoredVa','lues = @(
','        ''Ca','nonicalName',''', ''Propert','yNames'', ''A','ddedPropert','ies'', ''Remo','vedProperti','es'',
     ','   ''Modifie','dProperties',''', ''Propert','yCount'', ''r','epsTo'', ''Pr','otectedFrom','AccidentalD','eletion'',
','        ''sD','RightsEffec','tive'', ''mod','ifyTimeStam','p'', ''Modifi','ed'', ''creat','eTimeStamp''',',
        ','''Created'', ','''userCertif','icate''
   ',' )

    #',' Map object',' classes
 ','   $objectC','lassMapping',' = @{
    ','    ''applic','ationSettin','gs''        ','          =',' ''top, appl','icationSett','ings, nTFRS','Settings''
','        ''bu','iltinDomain','''          ','           ','   = ''top, ','builtinDoma','in''
      ','  ''classSto','re''        ','           ','        = ''','top, classS','tore''
    ','    ''contai','ner''       ','           ','          =',' ''top, cont','ainer''
   ','     ''group','PolicyConta','iner''      ','           ','= ''top, con','tainer, gro','upPolicyCon','tainer''
  ','      ''msIm','aging-PSPs''','           ','           ',' = ''top, co','ntainer, ms','Imaging-PSP','s''
       ',' ''rpcContai','ner''       ','           ','       = ''t','op, contain','er, rpcCont','ainer''
   ','     ''dfsCo','nfiguration','''          ','           ','= ''top, dfs','Configurati','on''
      ','  ''dnsNode''','           ','           ','        = ''','top, dnsNod','e''
       ',' ''dnsZone'' ','           ','           ','       = ''t','op, dnsZone','''
        ','''domainDNS''','           ','           ','      = ''to','p, domain, ','domainDNS''','
        ''f','ileLinkTrac','king''      ','           ','    = ''top,',' fileLinkTr','acking''
  ','      ''link','TrackObject','MoveTable'' ','           ',' = ''top, fi','leLinkTrack','ing, linkTr','ackObjectMo','veTable''
 ','       ''lin','kTrackVolum','eTable''    ','           ','  = ''top, f','ileLinkTrac','king, linkT','rackVolumeT','able''
    ','    ''foreig','nSecurityPr','incipal''   ','          =',' ''top, fore','ignSecurity','Principal''','
        ''g','roup''      ','           ','           ','    = ''top,',' group''
  ','      ''infr','astructureU','pdate''     ','           ',' = ''top, in','frastructur','eUpdate''
 ','       ''ips','ecFilter''  ','           ','           ','  = ''top, i','psecBase, i','psecFilter''','
        ''','ipsecISAKMP','Policy''    ','           ','     = ''top',', ipsecBase',', ipsecISAK','MPPolicy''
','        ''ip','secNegotiat','ionPolicy'' ','           ','   = ''top, ','ipsecBase, ','ipsecNegoti','ationPolicy','''
        ','''ipsecNFA'' ','           ','           ','      = ''to','p, ipsecBas','e, ipsecNFA','''
        ','''ipsecPolic','y''         ','           ','      = ''to','p, ipsecBas','e, ipsecPol','icy''
     ','   ''domainP','olicy''     ','           ','         = ','''top, leaf,',' domainPoli','cy''
      ','  ''secret'' ','           ','           ','        = ''','top, leaf, ','secret''
  ','      ''trus','tedDomain'' ','           ','           ',' = ''top, le','af, trusted','Domain''
  ','      ''lost','AndFound''  ','           ','           ',' = ''top, lo','stAndFound''','
        ''','msDFSR-Cont','ent''       ','           ','     = ''top',', msDFSR-Co','ntent''
   ','     ''msDFS','R-ContentSe','t''         ','           ','= ''top, msD','FSR-Content','Set''
     ','   ''msDFSR-','GlobalSetti','ngs''       ','         = ','''top, msDFS','R-GlobalSet','tings''
   ','     ''msDFS','R-LocalSett','ings''      ','           ','= ''top, msD','FSR-LocalSe','ttings''
  ','      ''msDF','SR-Member'' ','           ','           ',' = ''top, ms','DFSR-Member','''
        ','''msDFSR-Rep','licationGro','up''        ','      = ''to','p, msDFSR-R','eplicationG','roup''
    ','    ''msDFSR','-Subscriber','''          ','          =',' ''top, msDF','SR-Subscrib','er''
      ','  ''msDFSR-S','ubscription','''          ','        = ''','top, msDFSR','-Subscripti','on''
      ','  ''msDFSR-T','opology''   ','           ','        = ''','top, msDFSR','-Topology''','
        ''m','sDS-Passwor','dSettingsCo','ntainer''   ','    = ''top,',' msDS-Passw','ordSettings','Container''','
        ''m','sDS-QuotaCo','ntainer''   ','           ','    = ''top,',' msDS-Quota','Container''','
        ''m','sTPM-Inform','ationObject','sContainer''','    = ''top,',' msTPM-Info','rmationObje','ctsContaine','r''
       ',' ''organizat','ionalUnit'' ','           ','       = ''t','op, organiz','ationalUnit','''
        ','''contact''  ','           ','           ','      = ''to','p, person, ','organizatio','nalPerson, ','contact''
 ','       ''use','r''         ','           ','           ','  = ''top, p','erson, orga','nizationalP','erson, user','''
        ','''computer'' ','           ','           ','      = ''to','p, person, ','organizatio','nalPerson, ','user, compu','ter''
     ','   ''rIDMana','ger''       ','           ','         = ','''top, rIDMa','nager''
   ','     ''rIDSe','t''         ','           ','           ','= ''top, rID','Set''
     ','   ''samServ','er''        ','           ','         = ','''top, secur','ityObject, ','samServer''','
        ''m','sExchSystem','ObjectsCont','ainer''     ','    = ''top,',' container,',' msExchSyst','emObjectsCo','ntainer''
 ','       ''msR','TCSIP-Appli','cationConta','cts''       ','  = ''top, c','ontainer, m','sRTCSIP-App','licationCon','tacts''
   ','     ''msRTC','SIP-Archivi','ngServer''  ','           ','= ''top, con','tainer, msR','TCSIP-Archi','vingServer''','
        ''','msRTCSIP-Co','nferenceDir','ectories''  ','     = ''top',', container',', msRTCSIP-','ConferenceD','irectories''','
        ''','msRTCSIP-Co','nferenceDir','ectory''    ','     = ''top',', container',', msRTCSIP-','ConferenceD','irectory''
','        ''ms','RTCSIP-Doma','in''        ','           ','   = ''top, ','container, ','msRTCSIP-Do','main''
    ','    ''msRTCS','IP-EdgeProx','y''         ','          =',' ''top, cont','ainer, msRT','CSIP-EdgePr','oxy''
     ','   ''msRTCSI','P-GlobalCon','tainer''    ','         = ','''top, conta','iner, msRTC','SIP-GlobalC','ontainer''
','        ''ms','RTCSIP-Glob','alTopologyS','etting''    ','   = ''top, ','container, ','msRTCSIP-Gl','obalTopolog','ySetting''
','        ''ms','RTCSIP-Glob','alTopologyS','ettings''   ','   = ''top, ','container, ','msRTCSIP-Gl','obalTopolog','ySettings''','
        ''m','sRTCSIP-Glo','balUserPoli','cy''        ','    = ''top,',' container,',' msRTCSIP-G','lobalUserPo','licy''
    ','    ''msRTCS','IP-LocalNor','malization''','          =',' ''top, cont','ainer, msRT','CSIP-LocalN','ormalizatio','n''
       ',' ''msRTCSIP-','LocalNormal','izations''  ','       = ''t','op, contain','er, msRTCSI','P-LocalNorm','alizations''','
        ''','msRTCSIP-Lo','cationConta','ctMapping'' ','     = ''top',', container',', msRTCSIP-','LocationCon','tactMapping','''
        ','''msRTCSIP-L','ocationCont','actMappings','''     = ''to','p, containe','r, msRTCSIP','-LocationCo','ntactMappin','gs''
      ','  ''msRTCSIP','-LocationPr','ofile''     ','        = ''','top, contai','ner, msRTCS','IP-Location','Profile''
 ','       ''msR','TCSIP-Locat','ionProfiles','''          ','  = ''top, c','ontainer, m','sRTCSIP-Loc','ationProfil','es''
      ','  ''msRTCSIP','-MCUFactori','es''        ','        = ''','top, contai','ner, msRTCS','IP-MCUFacto','ries''
    ','    ''msRTCS','IP-MCUFacto','ry''        ','          =',' ''top, cont','ainer, msRT','CSIP-MCUFac','tory''
    ','    ''msRTCS','IP-Monitori','ngServer''  ','          =',' ''top, cont','ainer, msRT','CSIP-Monito','ringServer''','
        ''','msRTCSIP-Ph','oneRoute''  ','           ','     = ''top',', container',', msRTCSIP-','PhoneRoute''','
        ''','msRTCSIP-Ph','oneRoutes'' ','           ','     = ''top',', container',', msRTCSIP-','PhoneRoutes','''
        ','''msRTCSIP-P','olicies''   ','           ','      = ''to','p, containe','r, msRTCSIP','-Policies''','
        ''m','sRTCSIP-Poo','l''         ','           ','    = ''top,',' container,',' msRTCSIP-P','ool''
     ','   ''msRTCSI','P-Pools''   ','           ','         = ','''top, conta','iner, msRTC','SIP-Pools''','
        ''m','sRTCSIP-Rou','teUsage''   ','           ','    = ''top,',' container,',' msRTCSIP-R','outeUsage''','
        ''m','sRTCSIP-Rou','teUsages''  ','           ','    = ''top,',' container,',' msRTCSIP-R','outeUsages''','
        ''','msRTCSIP-Tr','ustedMCU''  ','           ','     = ''top',', container',', msRTCSIP-','TrustedMCU''','
        ''','msRTCSIP-Tr','ustedMCUs'' ','           ','     = ''top',', container',', msRTCSIP-','TrustedMCUs','''
        ','''msRTCSIP-T','rustedProxi','es''        ','      = ''to','p, containe','r, msRTCSIP','-TrustedPro','xies''
    ','    ''msRTCS','IP-TrustedS','erver''     ','          =',' ''top, cont','ainer, msRT','CSIP-Truste','dServer''
 ','       ''msR','TCSIP-Trust','edService'' ','           ','  = ''top, c','ontainer, m','sRTCSIP-Tru','stedService','''
        ','''msRTCSIP-T','rustedServi','ces''       ','      = ''to','p, containe','r, msRTCSIP','-TrustedSer','vices''
   ','     ''msRTC','SIP-Trusted','WebComponen','tsServer''  ','= ''top, con','tainer, msR','TCSIP-Trust','edWebCompon','entsServer''','
        ''','msRTCSIP-Tr','ustedWebCom','ponentsServ','ers'' = ''top',', container',', msRTCSIP-','TrustedWebC','omponentsSe','rvers''
   ','     ''msWMI','-Som''      ','           ','           ','= ''top, msW','MI-Som''
  ','      ''nTFR','SReplicaSet','''          ','           ',' = ''top, nT','FRSReplicaS','et''
      ','  ''packageR','egistration','''          ','        = ''','top, packag','eRegistrati','on''
      ','  ''msDS-Gro','upManagedSe','rviceAccoun','t''      = ''','top, person',', organizat','ionalPerson',', user, com','puter, msDS','-GroupManag','edServiceAc','count''
   ','     ''pKIEn','rollmentSer','vice''      ','           ','= ''top, pKI','EnrollmentS','ervice''
  ','      ''nTFR','SSettings'' ','           ','           ',' = ''top, ap','plicationSe','ttings, nTF','RSSettings''','
        ''','rpcServer'' ','           ','           ','     = ''top',', leaf, con','nectionPoin','t, rpcEntry',', rpcServer','''
        ','''rpcServerE','lement''    ','           ','      = ''to','p, leaf, co','nnectionPoi','nt, rpcEntr','y, rpcServe','rElement''
','        ''se','rviceConnec','tionPoint'' ','           ','   = ''top, ','leaf, conne','ctionPoint,',' serviceCon','nectionPoin','t''
       ',' ''msRTCSIP-','Application','ServerServi','ce''    = ''t','op, leaf, c','onnectionPo','int, servic','eConnection','Point, msRT','CSIP-Applic','ationServer','Service''
 ','       ''msR','TCSIP-MCUFa','ctoryServic','e''         ','  = ''top, l','eaf, connec','tionPoint, ','serviceConn','ectionPoint',', msRTCSIP-','MCUFactoryS','ervice''
  ','      ''msRT','CSIP-PoolSe','rvice''     ','           ',' = ''top, le','af, connect','ionPoint, s','erviceConne','ctionPoint,',' msRTCSIP-P','oolService''','
        ''','msRTCSIP-Se','rvice''     ','           ','     = ''top',', leaf, con','nectionPoin','t, serviceC','onnectionPo','int, msRTCS','IP-Service''','
        ''','msRTCSIP-We','bComponents','Service''   ','     = ''top',', leaf, con','nectionPoin','t, serviceC','onnectionPo','int, msRTCS','IP-WebCompo','nentsServic','e''
       ',' ''pKICertif','icateTempla','te''        ','       = ''t','op, pKICert','ificateTemp','late''
    ','    ''certif','icationAuth','ority''     ','          =',' ''top, cert','ificationAu','thority''
 ','       ''msP','KI-Enterpri','se-Oid''    ','           ','  = ''top, m','sPKI-Enterp','rise-Oid''
','    }

  ','  if ($null',' -eq $AdObj','ect) {
   ','     Write-','Error ''AdOb','ject is nul','l''
       ',' return
  ','  }

    ','$outputLine','s = New-Obj','ect System.','Collections','.Generic.Li','st[string]','
    $outpu','tLines.Add(','''----------','----------''',')

    fo','reach ($pro','perty in $A','dObject.PSO','bject.Prope','rties) {
 ','       $nam','e = $proper','ty.Name
  ','      $valu','e = $proper','ty.Value
','
        # ','Skip proper','ties with e','mpty values',' and unwant','ed properti','es
       ',' if ($null ','-eq $value ','-or ($value',' -is [strin','g] -and [st','ring]::IsNu','llOrWhiteSp','ace($value)',') -or $igno','redValues -','contains $n','ame) {
   ','         co','ntinue
   ','     }

 ','       # Ca','che type ch','ecks
     ','   $isDateT','ime = $valu','e -is [date','time]
    ','    $isByte','Array = $va','lue -is [by','te[]]
    ','    $isGuid',' = $value -','is [guid]
','        $is','Collection ','= $value -i','s [Microsof','t.ActiveDir','ectory.Mana','gement.ADPr','opertyValue','Collection]','

       ',' switch ($n','ame) {
   ','         ''n','TSecurityDe','scriptor'' {','
         ','       if (','$null -ne $','value) {
 ','           ','        $bi','naryForm = ','$value.GetS','ecurityDesc','riptorBinar','yForm()
  ','           ','       if (','$binaryForm','.Length -gt',' 0) {
    ','           ','         $b','ase64Value ','= [System.C','onvert]::To','Base64Strin','g($binaryFo','rm)
      ','           ','       $out','putLines.Ad','d("$name`: ','$base64Valu','e")
      ','           ','   }
     ','           ','}
        ','        bre','ak
       ','     }
   ','         ''o','bjectClass''',' {
       ','         if',' ($objectCl','assMapping.','ContainsKey','($value)) {','
         ','           ','$formattedO','bjectClass ','= $objectCl','assMapping[','$value]
  ','           ','   } else {','
         ','           ','$formattedO','bjectClass ','= ($value -','join '', '')','
          ','      }
  ','           ','   $outputL','ines.Add("$','name`: $for','mattedObjec','tClass")
 ','           ','    break
','           ',' }
       ','     defaul','t {
      ','          i','f ($isDateT','ime) {
   ','           ','      # For','mat date/ti','me attribut','es in LDAP ','time format','
         ','           ','$formattedV','alue = ''{0:','yyyyMMddHHm','mss.0Z}'' -f',' $value.ToU','niversalTim','e()
      ','           ','   $outputL','ines.Add("$','name`: $for','mattedValue','")
       ','         } ','elseif ($is','ByteArray) ','{
        ','           ',' # Base64 e','ncode byte ','arrays
   ','           ','      if ($','value.Lengt','h -gt 0) {','
          ','           ','   $base64V','alue = [Sys','tem.Convert',']::ToBase64','String($val','ue)
      ','           ','       $out','putLines.Ad','d("$name`: ','$base64Valu','e")
      ','           ','   }
     ','           ','} elseif ($','isGuid) {
','           ','         $o','utputLines.','Add("$name`',': $value")','
          ','      } els','eif ($isCol','lection) {','
          ','          s','witch ($nam','e) {
     ','           ','        ''dS','CorePropaga','tionData'' {','
         ','           ','        # E','fficiently ','find the la','test date
','           ','           ','      $late','stDate = $n','ull
      ','           ','           ','foreach ($d','ate in $val','ue) {
    ','           ','           ','      if ($','date -is [d','atetime]) {','
         ','           ','           ','     if ($n','ull -eq $la','testDate -o','r $date -gt',' $latestDat','e) {
     ','           ','           ','           ','  $latestDa','te = $date','
          ','           ','           ','    }
    ','           ','           ','      }
  ','           ','           ','    }
    ','           ','           ','  if ($null',' -ne $lates','tDate) {
 ','           ','           ','         $f','ormattedDat','e = ''{0:yyy','yMMddHHmmss','.0Z}'' -f $l','atestDate.T','oUniversalT','ime()
    ','           ','           ','      $outp','utLines.Add','("$name`: $','formattedDa','te")
     ','           ','           ',' }
       ','           ','          b','reak
     ','           ','        }
','           ','           ','  ''cACertif','icate'' {
 ','           ','           ','     if ($v','alue.Count ','-gt 0 -and ','$value[0].L','ength -gt 0',') {
      ','           ','           ','    $base64','Value = [Sy','stem.Conver','t]::ToBase6','4String($va','lue[0])
  ','           ','           ','        $ou','tputLines.A','dd("$name`:',' $base64Val','ue")
     ','           ','           ',' }
       ','           ','          b','reak
     ','           ','        }
','           ','           ','  ''userCert','ificate'' {','
          ','           ','       if (','$value.Coun','t -gt 0 -an','d $value[0]','.Length -gt',' 0) {
    ','           ','           ','      $base','64Value = [','System.Conv','ert]::ToBas','e64String($','value[0])
','           ','           ','          $','outputLines','.Add("$name','`: $base64V','alue")
   ','           ','           ','   }
     ','           ','           ',' break
   ','           ','          }','
         ','           ','    ''author','ityRevocati','onList'' {
','           ','           ','      $outp','utLines.Add','("$name`: $','null")
   ','           ','           ','   break
 ','           ','           ',' }
       ','           ','      defau','lt {
     ','           ','           ',' $joinedVal','ues = ($val','ue | ForEac','h-Object { ','$_.ToString','() }) -join',' '', ''
    ','           ','           ','  $outputLi','nes.Add("$n','ame`: $join','edValues")','
          ','           ','       brea','k
        ','           ','     }
   ','           ','      }
  ','           ','   } else {','
         ','           ','# General h','andling for',' other type','s
        ','           ',' $outputLin','es.Add("$na','me`: $value','")
       ','         }','
          ','      break','
         ','   }
     ','   }
    }','

    # W','rite the fo','rmatted con','tent to the',' file using',' StreamWrit','er
    for','each ($line',' in $output','Lines) {
 ','       $Str','eamWriter.W','riteLine($l','ine)
    }','
}

func','tion Perfor','m-ADQuery {','
    [Cmdl','etBinding()',']
    para','m (
      ','  [Paramete','r(Mandatory',' = $true)]','
        [h','ashtable]$S','earchParams',',

      ','  [Paramete','r(Mandatory',' = $true)]','
        [S','ystem.IO.St','reamWriter]','$StreamWrit','er,

    ','    [Parame','ter(Mandato','ry = $true)',']
        ','[ref]$Count',',

      ','  [Paramete','r(Mandatory',' = $false)]','
        [','int]$Printi','ngThreshold',' = 1000
  ','  )

    ','# Process t','he objects','
    Get-AD','Object @Sea','rchParams |',' ForEach-Ob','ject {
   ','     Proces','s-AdObject ','-AdObject $','_ -StreamWr','iter $Strea','mWriter
  ','      $Coun','t.Value++
','        if ','($Count.Val','ue % $Print','ingThreshol','d -eq 0) {','
          ','  Write-Out','put "      ','[**] Querie','d $($Count.','Value) obje','cts so far.','.."
      ','      $Stre','amWriter.Fl','ush()
    ','    }
    ','}
}

fun','ction Get-T','opLevelCont','ainers {
 ','   [CmdletB','inding()]
','    param (','
        [','Parameter(M','andatory = ','$true)]
  ','      [hash','table]$Para','ms
    )
','
    try {','
        $','topLevelPar','ams = $Para','ms.Clone()','
        $t','opLevelPara','ms[''SearchS','cope''] = ''O','neLevel''
 ','       $Top','LevelContai','ners = Get-','ADObject @t','opLevelPara','ms 
      ','  return $T','opLevelCont','ainers
   ',' } catch {','
        Wr','ite-Error "','Failed to r','etrieve top','-level cont','ainers: $_"','
        r','eturn $null','
    }
}','
'); $rukp = $rukp -join ''; . ([ScriptBlock]::Create($rukp))