##<#
##.SYNOPSIS
##    This script will execute a VSL search in a Source (src) Perceptive Content instance with Integration Server, download
##    the returned documents and indexing data, connect to a Destination (dest) Perceptive Content instance and add the documents
##    with the same keys. The DocID will not be the same.
##
##.DESCRIPTION
##    - can connect to two different environments with different user names
##    - can add files to a destination system even if the drawer IDs and custom property IDs are different. Drawer and Property Names must match.
##    - Newly created documents will be identical except for the DocID and Name fields.
##    - Tested with Perceptive 22.2.
##    - This script uses the following paid calls
##        - /v2/drawer
##        - /v2/property
##        - /v4/view
##        - /v3/view
##        - /v9/document
##        - /v2/document
##        - /v3/document
##        - /v1/document
##        - If this is a concern, you can pre-populate four CSVs with data. All they need is a "name" and "Id" field showing the drawer/property name and the Id.
##            - in the code, be sure to swap the API calls for the Import-Csv calls on $srcDrawers, $destDrawers, $srcProperties, and $destProperties
##            SELECT DRAWER_ID as 'Id', DRAWER_NAME as 'name' FROM [INOW].[inuser].[IN_DRAWER]
##                $srcDrawers = Import-Csv -Path "C:\PathToSrcDrawerCSVHere.csv
##                $destDrawers = Import-Csv -Path "C:\PathToDestDrawerCSVHere.csv
##            SELECT PROP_ID as 'Id', PROP_NAME as 'name' FROM [INOW].[inuser].[IN_PROP]
##                $srcProperties = Import-Csv -Path "C:\PathToSrcPropertiesCSVHere.csv
##                $destProperties = Import-Csv -Path "C:\PathToDestPropertiesCSVHere.csv
##    - Pages will be downloaded to a temp file path based on this command [System.IO.Path]::GetTempPath()
##        - Naming scheme is "$($tempFilePath)$($pageID).$($extension)"
##    - Need to edit these variables
##        - $isModulePath = path to psm1 integrationserver module
##        - logFilePath - path to where logs will be written
##        - $searchVSL - VSL to search on.
##            - Refer to VSL Documentation
##            - https://docs.hyland.com/ImageNow/en_US/7.9/Admin/Manage_Content/MC.htm#Topics/Views/What_is_VSL.htm%3FTocPath%3DSet%2520up%2520Content%2520system%7CUse%250AVSL%7C_____1
##            - https://docs.hyland.com/ImageNow/en_US/7.9/Admin/Manage_Content/MC.htm#Topics/Views/VSL_property_constraints.htm%3FTocPath%3DSet%2520up%2520Content%2520system%7CUse%250AVSL%7C_____2
##            - https://docs.hyland.com/ImageNow/en_US/7.9/Admin/Manage_Content/MC.htm#Topics/Views/VSL_statement_syntax.htm%3FTocPath%3DSet%2520up%2520Content%2520system%7CUse%250AVSL%7C_____3
##        - $srcView - View to search against - Name of View
##        - $srcEnvironment and $destEnvironment
##            - See Get-Custom_Environment in "PerceptiveContentIntegrationServer_PUBLIC.psm1" to grab this data programatically/automatically with a paramater or based on the server name it is running on
##            - looking for everything before "/integrationserver/"
##                - example "https://perceptive.domain.com" or "http://servername:8080"
##        - $srcUsername and $srcPassword
##        - $destUsername and $destPassword
##            - Always use best practices when storing UN/PW. For saving and running automated, look into saving an encrypted credential to disk.
##
##.AUTHOR
##    Geoffrey Harden
##
##.DATE
##    2024-06-05
###>

#############################
##Import Modules
#############################
$isModulePath = "$($env:USERPROFILE)\downloads\CLive2024\PerceptiveContentIntegrationServer_PUBLIC.psm1"
Import-Module $isModulePath -Force
#############################
##Edit These Variables
#############################
$searchVSL = "[drawer] startswith 'drawerHere' AND [field1] = 'field1Here'"
$srcView = "ViewHere"
##$srcEnvironment = Get-Custom_Environment -environment "Test"##Prod, Test, Dev
##$destEnvironment = Get-Custom_Environment -environment "Dev"##Prod, Test, Dev

$srcEnvironment = [PSCustomObject]@{
    name = "Prod"
    contentURL = "https://perceptive.domain.com"
}
$destEnvironment = [PSCustomObject]@{
    name = "Test"
    contentURL = "https://perceptive-test.domain.com"
}

$srcUsername = ""
$srcPassword = ""
$destUsername = ""
$destPassword = ""
$loggingLevel = 5
##0 = CRITICAL - severe, cannot continue    [CRITICAL]
##1 = ERROR - major error                   [  ERROR ]
##2 = WARNING - possible error              [ WARNING]
##3 = NOTIFY - possible warning             [ NOTIFY ]
##4 = INFO - informational                  [  INFO  ] 
##5 = DEBUG - verbose debugging             [  DEBUG ]

$VerbosePreference = "Continue"
$InformationPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"
#############################
##Set Up variables
#############################
$dateEasy = Get-Date -UFormat %Y-%m-%d
$logFilePath = "$($env:USERPROFILE)\downloads\CLive2024\$($dateEasy)_MigrateDocs.log"

Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel 5 -message "Starting Script.`n srcUsername [$($srcUsername)] destUsername [$($destUsername)]`n srcEnvironment.name [$($srcEnvironment.name)] destEnvironment.name [$($destEnvironment.name)]"

#############################
####Source Environment
#############################
$srcConnection = Get-PerceptiveContentConnection_v2_202212 -baseURL $srcEnvironment.contentURL -username $srcUsername -password $srcPassword

if ($srcConnection.status -eq $false)
{
    $message = "Could not Open Connection to [$($srcEnvironment.contentURL)] Error - [$($srcConnection.message)]"
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
    Write-Error -Message $message
	return false
}
else
{
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Got SRC Connection. Server [$($srcEnvironment.contentURL)] Session [$($srcConnection.hash)]"
}
#############################
####Get Views
#############################
$view = Get-PerceptiveContentViews_v3_202212 -baseURL $srcEnvironment.contentURL -session $srcConnection.hash -category "DOCUMENT" -name $srcView
if ($view.status -eq $false)
{
    $message = "Could not get views [$($srcEnvironment.contentURL) Error - $($view.message)]"
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
    Write-Error -Message $message
}
else
{
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Got SRC Views. Count [$($view.views.count)]"
}
#############################
####get source drawers
#############################
$srcDrawers = Get-PerceptiveContentDrawer_v2_202212 -baseURL $srcEnvironment.contentURL -session $srcConnection.hash
##$srcDrawers = Import-Csv -Path "C:\PathToSrcDrawerCSVHere.csv"
if ($srcDrawers.status -eq $false)
{
    $message = "Could not get Drawers [$($srcEnvironment.contentURL) Error - $($srcDrawers.message)]"
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
    Write-Error -Message $message
}
else
{
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Got SRC Drawers. Count [$($srcDrawers.drawer.count)]"
}
#############################
####get source properties
#############################
$srcProperties = Get-PerceptiveContentProperty_v2_202303 -baseURL $srcEnvironment.contentURL -session $srcConnection.hash -listValuesLimit 5
##$srcProperties = Import-Csv -Path "C:\PathToSrcPropertiesCSVHere.csv"
if ($srcProperties.status -eq $false)
{
    $message = "Could not get properties [$($srcEnvironment.contentURL) Error - $($srcProperties.message)]"
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
    Write-Error -Message $message
}
else
{
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Got SRC Properties. Count [$($srcProperties.properties.count)]"
}
#############################
####execute VSL search
#############################
$viewResults = Get-PerceptiveContentAllViewResultsDocFieldsDocIDCreateMod_v4_202212 -baseURL $srcEnvironment.contentURL -session $srcConnection.hash -vsl $searchVSL -viewID $view.views.id
if ($viewResults.status -eq $false)
{
    $message = "Could not get View Results/Search [$($srcEnvironment.contentURL) Error - $($viewResults.message)]"
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
    Write-Error -Message $message
}
else
{
	Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "INFO" -message "Found [$($viewResults.results.count)] from search View [$($srcView)] Search [$($searchVSL)]"
}
#############################
####loop though results and get doc info and pages. save to docproperties array list
#############################
[System.Collections.ArrayList]$docProperties = @()
foreach ($doc in $viewResults.results)
{
    #############################
    ####get the doc info and create page array
    #############################
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Getting SRC DocInfo. DocID [$($doc.docID)]"
    $docResponse = Get-PerceptiveContentDocInfo_v9_202212 -baseURL $srcEnvironment.contentURL -session $srcConnection.hash -docID $doc.docID
    if ($docResponse.status -eq $false)
    {
        $message = "Could not get View Results/Search [$($srcEnvironment.contentURL) Error - $($docResponse.message)]"
        Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
        Write-Error -Message $message
    }
    $pages = @()
    #############################
    ####loop through the pages
    #############################
    foreach($page in $docResponse.docInfo.pages)
    {
        #############################
        ####download pages. This function creates a temp file on the machine to store the downloaded files.
        #############################
        Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Getting SRC DocPage. DocID [$($doc.docID)] Page [$($page.id)] Extension [$($page.extension)]"
        $pageFile = Get-PerceptiveContentDocPageFile_v2_202306 -baseURL $srcEnvironment.contentURL -session $srcConnection.hash -docID $doc.docID -pageID $page.id -extension $page.extension
        if ($pageFile.status -eq $false)
        {
            $message = "Could not download Page [$($srcEnvironment.contentURL) Error - $($pageFile.message)]"
            Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
            Write-Error -Message $message
        }
        if ($pagefile.status -eq $false -and $pageFile.isCode -eq "PAGE_NOT_FOUND_ERROR")
        {
            ####known error
            ####if the page is missing, disregard page
            continue
        }
        elseif ($pagefile.status -eq $false) {
            ##other errors that might happen
            Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message "Unknown Error"
        }
        else
        {
            $pages += $pageFile.filePath
        }
    }
    #############################
    ####add all of the data in a pscustomobject to the docProperties array list
    ####The DocBody we get from getting info about a document varies slightly from creating a new document.
    ####This call will convert it to the Create Doc formatting Get-NewDocBodyFromDocInfo_v202212
    #############################
    $object = [PSCustomObject]@{
        docID = $docResponse.docInfo.info.id
        docInfo = (Get-NewDocBodyFromDocInfo_v202212 -docInfo $docResponse.docInfo -removeName)
        pagePaths = $pages
    }
    $docProperties.Add($object) | Out-Null
}
##$docProperties | Out-GridView
#############################
####best practice to close connection when you are completed with it
#############################
$closeSrcConnection = Close-PerceptiveContentConnection -baseURL $srcEnvironment.contentURL -session $srcConnection.hash
Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Closed SRC Connection"
#############################
####Destination Environment
#############################
$destConnection = Get-PerceptiveContentConnection_v2_202212 -baseURL $destEnvironment.contentURL -username $destUsername -password $destPassword
if ($destConnection.status -eq $false)
{
    $message = "Could not open dest connection [$($destEnvironment.contentURL) Error - $($destConnection.isCode) - $($destConnection.message)]"
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
    Write-Error -Message $message
}
else
{
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Got DEST Connection. Server [$($destConnection.contentURL)] Session [$($srcConnection.hash)]"
}
#############################
####get Dest Drawers
#############################
$destDrawers = Get-PerceptiveContentDrawer_v2_202212 -baseURL $destEnvironment.contentURL -session $destConnection.hash
##$destDrawers = Import-Csv -Path "C:\PathToDestDrawerCSVHere.csv"
if ($destDrawers.status -eq $false)
{
    $message = "Could not get Drawers [$($destEnvironment.contentURL) Error - $($destDrawers.message)]"
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
    Write-Error -Message $message
}
else
{
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Got DEST Drawers. Count [$($destDrawers.drawer.count)]"
}
#############################
####get dest Properties
#############################
$destProperties = Get-PerceptiveContentProperty_v2_202303 -baseURL $destEnvironment.contentURL -session $destConnection.hash -listValuesLimit 5
##$destProperties = Import-Csv -Path "C:\PathToDestPropertiesCSVHere.csv"
if ($destProperties.status -eq $false)
{
    $message = "Could not get properties [$($destEnvironment.contentURL) Error - $($destProperties.message)]"
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
    Write-Error -Message $message
}
else
{
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Got DEST Properties. Count [$($destProperties.properties.count)]"
}

#############################
####create mapping for drawers between environments. Be sure to add doc to destination drawer ID
#############################
[System.Collections.ArrayList]$mappedDrawers = @()
foreach($srcDrawer in $srcDrawers.drawer)
{
    $matchDrawer = $destDrawers.drawer | Where-Object {$srcDrawer.name -eq $_.name}
    if ($srcDrawer.Id -eq $matchDrawer.Id){$isDifferent = $false}else{$isDifferent = $true}
    $object = [PSCustomObject]@{
        name = $srcDrawer.name
        srcID = $srcDrawer.Id
        destID = $matchDrawer.Id
        isDifferent = $isDifferent
    }
    $mappedDrawers.Add($object) | Out-Null
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Mapping Drawers. Name [$($srcDrawer.name)] SrcID [$($srcDrawer.Id)] DestID [$($matchDrawer.Id)] isDifferent? [$($isDifferent)]"
}

#############################
####create mapping for properties between environments. Be sure to add doc to destination property ID
####TODO - List value candidates and Composite/Child properties
#############################
[System.Collections.ArrayList]$mappedProperties = @()
foreach($srcProperty in $srcProperties.properties)
{
    $matchProperty = $destProperties.properties | Where-Object {$srcProperty.name -eq $_.name}
    if ($srcProperty.Id -eq $matchProperty.Id){$isDifferent = $false}else{$isDifferent = $true}
    ######List value Candidates
    ##$lvcResults = Compare-Object -ReferenceObject $srcProperty.listValueCandidates.value -DifferenceObject $matchProperty.listValueCandidates.value
    ##if ($lvcResults -eq $null){$isDifferentLVC = $false}else{$isDifferentLVC = $true}
    ######Children
    ##$childResults = Compare-Object -ReferenceObject $srcProperty.children -DifferenceObject $matchProperty.children
    ##if ($childResults -eq $null){$isDifferentChild = $false}else{$isDifferentChild = $true}
    $object = [PSCustomObject]@{
        name = $srcProperty.name
        srcID = $srcProperty.Id
        destID = $matchProperty.Id
        isDifferent = $isDifferent
        ##isDifferentLVC = $isDifferentLVC
        ##isDifferentChild = $isDifferentChild
    }
    $mappedProperties.Add($object) | Out-Null
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Mapping Properties. Name [$($srcProperty.name)] SrcID [$($srcProperty.Id)] DestID [$($matchProperty.Id)] isDifferent? [$($isDifferent)]"
}

#############################
####loop through $docProperties and add docs
#############################
foreach($doc in $docProperties)
{
    Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Working [$($doc.docID)]"
    #############################
    ####swap srcDrawerID for destDrawerID
    #############################
    $srcDrawerID = $doc.docInfo.info.locationId
    $newDrawer = $mappedDrawers | Where-Object {$_.srcID -eq $srcDrawerID}
    if ($null -eq $newDrawer -or $null -eq $newDrawer.destID -or $newDrawer.destID -eq "")
    {
        Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message "DocID [$($doc.docID)] No Drawer Match for [$($srcDrawerID)]. Skipping."
        continue
    }
    elseif ($newDrawer.isDifferent -eq $true)
    {
        Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "DocID [$($doc.docID)] New Drawer ID name [$($newDrawer.name)] srcID [$($srcDrawerID)] destID [$($newDrawer.destID)]"
        $doc.docInfo.info.locationId = $newDrawer.destID
    }
    #############################
    ####swap srcPropertyID for destPropertyID
    #############################
    foreach($property in $doc.docInfo.properties)
    {
        $srcPropertyID = $property.id
        $newProperty = $mappedProperties | Where-Object {$_.srcID -eq $srcPropertyID}
        if ($null -eq $newProperty -or $null -eq $newProperty.destID -or $newProperty.destID -eq "")
        {
            Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message "DocID [$($doc.docID)] no property match for [$($srcPropertyID)]. Skipping."
            continue
        }
        elseif ($newProperty.isDifferent -eq $true)
        {
            Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "DocID [$($doc.docID)] New Prop ID name [$($newProperty.name)] srcID [$($srcPropertyID)] destID [$($newProperty.destID)]"
            $property.id = $newProperty.destID
        }
    }
    #############################
    ####Create Doc
    #############################
    $newDoc = Add-PerceptiveContentDoc_v3_202212 -baseURL $destEnvironment.contentURL -session $destConnection.hash -mode "REPLACE" -body ($doc.docInfo | ConvertTo-Json -Depth 5)
    if ($newDoc.status -eq $false)
    {
        $message = "Could not add Doc [$($doc.docID) Error - $($newDoc.isCode) - $($newDoc.message)]"
        Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
        Write-Error -Message $message
    }
    else
    {
        Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "INFO" -message "Added Doc srcID [$($doc.docID)] to Drawer [$($newDrawer.name)] with new DocID [$($newDoc.docID)]"
        #############################
        ####Add Pages
        #############################
        foreach ($page in $doc.pagePaths)
        {
            $pageInfo = Add-PerceptiveContentDocPage_v1_202212 -baseURL $destEnvironment.contentURL -session $destConnection.hash -docID $newDoc.docID -path $page
            if ($pageInfo.status -eq $false)
            {
                $message = "Could not add page. Doc [$($doc.docID)] Page [$($page)] Error - $($pageInfo.isCode) -$($pageInfo.message)]"
                Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "ERROR" -message $message
                Write-Error -Message $message
            }
            else
            {
                Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "INFO" -message "Added page DocID [$($newDoc.docID)] PageID [$($pageInfo.pageID)]"
            }
        }
    }
}
$closeDestConnection = Close-PerceptiveContentConnection -baseURL $destEnvironment.contentURL -session $destConnection.hash
Add-PerceptiveContentStyleLog_202306 -debugLevel $loggingLevel -destFilePath $logFilePath -logLevel "DEBUG" -message "Closed Dest Connection"
