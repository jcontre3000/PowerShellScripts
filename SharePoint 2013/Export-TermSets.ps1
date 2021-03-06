    # Outputs CSV of the specified termset from the specificed termstore/group
    # Example call:
    # Export-SPTermStoreGroupTerms "http://sp2010" "Managed Metadata Service" "Enterprise Metadata" "Business Units"
     
    function Export-SPTermStoreGroupTerms {
        param (
            [string]$siteUrl = $(Read-Host -prompt "Site Collection URL"),
            [string]$termStoreName = $(Read-Host -prompt "Term Store Name"),
            [string]$termGroupName = $(Read-Host -prompt "Term Group Name"),
            [string]$termSetName = $(Read-Host -prompt "Term Set Name"),
            [string]$outPutDir = ""
        )
     
        $isValid = $true;
        $message = "";
     
        if ($siteUrl.Length -eq 0) { $message = "`nPlease provide a site URL"; $isValid = $false; }
        if ($termStoreName.Length -eq 0) { $message += "`nPlease provide a Term Store Name"; $isValid = $false; }
        if ($termGroupName.Length -eq 0) { $message += "`nPlease provide a Term Store Group Name"; $isValid = $false; }
        if ($termSetName.Length -eq 0) { $message += "`nPlease provide a Term Set Name"; $isValid = $false; }
     
        if ($isValid -eq $false)
        {
            write-host "`n`nERROR OCCURRED`n`t$message`n`n"
            write-host "NAME`n`tExport-SPTermStoreGroupTerms`n"
            write-host "SYNOPSIS`n`tReturns a CSV file containing a listing of term names and identifiers from the supplied term set.`n"
            write-host "SYNTAX`n`tExport-SPTermStoreGroupTerms siteUrl termStoreName termGroupName termSetName outPutDir`n"
            write-host "EXAMPLES`n`n Export-SPTermStoreGroupTerms ""http://sp2010"" ""Managed Metadata Service"" ""Enterprise Metadata"" ""Business Units""`n"
            return;
        }
     
        try
        {
            $ErrorActionPreference = "Stop";
     
            try
            {
                $site = Get-SPSite $siteUrl;
                $taxSession = new-object Microsoft.SharePoint.Taxonomy.TaxonomySession($site, $true);
     
                try
                {
                    $termStore = $taxSession.TermStores[$termStoreName];
     
                    if ($termStore -ne $null)
                    {
                        try
                        {
                            $termGroup = $termStore.Groups[$termGroupName];
     
                            if ($termGroup -ne $null)
                            {
                                try
                                {
                                    $termSet = $termGroup.TermSets[$termSetName];
     
                                    if ($termSet -ne $null)
                                    {
                                        [string]$csvDir = "";
     
                                        if ($outPutDir.Length -gt 0)
                                        {
                                            $csvDir = $outPutDir;
                                        }
                                        else
                                        {
                                            $csvDir = $pwd;
                                        }
     
                                        $outPutFile = $csvDir + "\output.csv";
     
                                        $sw = new-object system.IO.StreamWriter($outPutFile);
     
                                        $sw.writeline("Name,Id");
     
                                        foreach ($term in $termSet.GetAllTerms())
                                        {
                                            [Byte[]] $ampersand = 0xEF,0xBC,0x86;
     
                                            $sw.writeline("""" + $term.Name.Replace([System.Text.Encoding]::UTF8.GetString($ampersand), "&") + """" + "," + $term.Id);
                                        }
     
                                        $sw.close();
     
                                        write-host "Your CSV has been created at $outPutFile";
                                    }
                                    else
                                    {
                                        return "Termset $termSetName does not exist in the term store group $termGroupName";
                                    }
                                }
                                catch
                                {
                                    "Unable to acquire the termset $termSetName from the term group $termGroupName"
                                }
                            }
                            else
                            {
                                return "Term store group $termGroupName does not exist in the term store $termStoreName";
                            }
                        }
                        catch
                        {
                            "Unable to acquire term store group $termGroupName from $termStoreName"
                        }
                    }
                    else
                    {
                        return "Term store $termStoreName does not exist";
                    }
                }
                catch
                {
                    "Unable to acquire term store for $termStoreName"
                }
            }
            catch
            {
                "Unable to acquire session for the site $siteUrl"
            }
        }
        catch
        {
     
        }
        finally
        {
            $ErrorActionPreference = "Continue";
        }
    }