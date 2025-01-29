function Get-Custom_Environment{
	param(
		$environment
	)
    ####can hard code which environment name to send it to with the above param
	Write-verbose -message "$($environment)"
    ####based on the computername/server name, decides what environment and paths you can use
	$serverName = $env:computername
	$serverName = $serverName.ToUpper()
	if ($environment -eq $null)
	{
		Switch ($serverName)
		{
			"RemoteServerName_Prod"	    {$environment = "Prod";	$inserverPath = "\\domain.com\prod";			$remoteServer = "RemoteServerName_Prod"; $emailAgentPath = "\\RemoteServerName_Prod\z$\email_agent";	$contentURL = "http://perceptive.domain.com";		Break;}
			"ContentServerName_Prod"	{$environment = "Prod";	$inserverPath = "\\domain.com\prod";			$remoteServer = "RemoteServerName_Prod"; $emailAgentPath = "\\RemoteServerName_Prod\z$\email_agent";	$contentURL = "http://perceptive.domain.com";		Break;}
			"WebServerName_Prod"	    {$environment = "Prod";	$inserverPath = "\\domain.com\prod";			$remoteServer = "RemoteServerName_Prod"; $emailAgentPath = "\\RemoteServerName_Prod\z$\email_agent";	$contentURL = "http://perceptive.domain.com";		Break;}
			"ContentServerName_Test"	{$environment = "Test";	$inserverPath = "\\domain.com\test";			$remoteServer = "RemoteServerName_Test"; $emailAgentPath = "\\RemoteServerName_Test\z$\email_agent";	$contentURL = "http://perceptive-test.domain.com";	Break;}
			"ContentServerName_Dev"	    {$environment = "Dev";	$inserverPath = "\\ContentServerName_Dev\z$\inserverApp";	$remoteServer = "RemoteServerName_Dev"; $emailAgentPath = "\\RemoteServerName_Dev\z$\email_agent";	$contentURL = "http://perceptive-dev.domain.com";	Break;}
			default {
				Write-Host "Unknown Server Name. Using Test"
				$environment = "Test";	$inserverPath = "\\domain.com\test";			$remoteServer = "RemoteServerName_Test"; $emailAgentPath = "\\RemoteServerName_Test\z$\email_agent";	$contentURL = "http://perceptive-test.domain.com";	Break;
				break
			}
		}
	}
	else
	{
		Switch ($environment)
		{
			"Prod"	{$inserverPath = "\\domain.com\prod";				$remoteServer = "RemoteServerName_Prod";	$emailAgentPath = "\\RemoteServerName_Prod\z$\email_agent";	$contentURL = "http://perceptive.domain.com";		Break;}
			"Test"	{$inserverPath = "\\domain.com\test";				$remoteServer = "RemoteServerName_Test";	$emailAgentPath = "\\RemoteServerName_Test\z$\email_agent";	$contentURL = "http://perceptive-test.domain.com";	Break;}
			"Dev"	{$inserverPath = "\\ContentServerName_Dev\z$\inserverApp";	$remoteServer = "RemoteServerName_Dev";	$emailAgentPath = "\\RemoteServerName_Dev\z$\email_agent";	$contentURL = "http://perceptive-dev.domain.com";	Break;}
			default {
				Write-Host "Unknown Environment"
				break
			}
		}
	}
	return @{
		name = $environment
		inserverPath = $inserverPath
		serverName = $serverName
		emailAgentPath = $emailAgentPath
		contentURL = $contentURL
		remoteServer = $remoteServer
	}
}

#######Free vs Paid as of 2024-08-13
#######################
######Free
#######################
####Meta
##  Get-PerceptiveContentConnection_v2_202212
##  Get-PerceptiveContentUniqueID_v1_202307
####User
##  Get-PerceptiveContentUser_v2_202306
##  Get-PerceptiveContentUserInformation_v1_202306 (should be named v3... whoops)
##  Get-PerceptiveContentUserInformationDetailed_v1_202306
##  Remove-PerceptiveContentUser_v1_202306
##  Add-PerceptiveContentUser_v1_202306
##  Add-PerceptiveContentUserAndGetDetail
##  Set-PerceptiveContentUserInactive_v1_202306
##  Set-PerceptiveContentUserInactiveThenActive_v1_202306
##  Set-PerceptiveContentUserActive_v1_202306
##  Set-PerceptiveContentUserNameActive_v1_202306
##  Set-PerceptiveContentUserProfileInfo_v1_202306
####User Group
##  Set-PerceptiveContentGroupToUsers_v2_202306
##  Add-RemovePerceptiveContentUsersFromGroup_v1_202306
##  Get-PerceptiveContentUserGroupInfo_v2_202306
####Document
##  Add-PerceptiveContentDoc_v3_202212
##  Add-PerceptiveContentDocPage_v1_202212
#######################
######Paid
#######################
####Meta
##  Get-PerceptiveContentDrawer_v2_202212
##  Get-PerceptiveContentDocType_v1_202310
##  Add-PerceptiveContentDrawer_v1_202307
####Properties
##  Get-PerceptiveContentProperty_v2_202303
####User Group
##  Get-PerceptiveContentUserGroup_v1_202306
####View/Search
##  Get-PerceptiveContentViews_v3_202212
##  Get-PerceptiveContentViewResultDocIDs_v4_202212
##  Get-PerceptiveContentAllViewResultsDocFieldsDocIDCreateMod_v4_202212
##  Get-PerceptiveContentAllViewResultsWFFieldsWFID_v4_202212
####Document
##  Get-PerceptiveContentDocPageFile_v2_202306
##  Get-PerceptiveContentDocInfo_v9_202212
##  Update-PerceptiveContentDoc_V1_202212
##  Update-PerceptiveContentDocProperties_v6_202304
##  Remove-PerceptiveContentDocument_v1_202212
####Department
##  Get-PerceptiveContentDepartment_v1_202306
####Workflow
##  Get-PerceptiveContentWorkflowQueues_v1_202212
##  Add-PerceptiveContentItemToWorkflow_v1_202212
##  Move-PerceptiveContentItemAlreadyInWorkflow_v2_202301
##  Remove-PerceptiveContentItemFromWorkflow_v1_202307
##  Get-PerceptiveContentWFItemInfo_v1_202301









function Get-PerceptiveContentConnection_v2_202212 {
    <#
    .SYNOPSIS
    Used to create a connection and returns a session hash.
    .DESCRIPTION
    Returns a PSCustomObject that include the property hash. This should be saved and used on subsequent calls.
    Standard Response Fields are:
        header = response header
        responseBody = response body if available
        httpCode
        status = true or false
        message = and error messages combined. includes isCode and isMessage.
        isCode = $isErrorCode
        isMessage = $isErrorMessage
        hash = $session
        request = [PSCustomObject]@{
            header = $headers
            body = "None"
            url = "GET $($baseURL)/integrationserver/v2/connection/"
        }
    }
    .PARAMETER baseURL
    Everything before "/integrationserver/". Examples are "https://perceptive.domain.com" or "http://servername:8080" or "192.168.1.5:8080"
    .PARAMETER username
    The Username for the account you will be sigining into Perceptive Content with.
    .PARAMETER password
    The Password for the account you will be sigining into Perceptive Content with.
    .EXAMPLE
    $connection = Get-PerceptiveContentConnection_v2_202212 -baseURL "https://perceptive.domain.com" -username "admin" -password "Pa$$w0rd!"
    $connection.hash
    #>
    param (
        $baseURL,
        $username,
        $password
    )

    #############################
    ####create connection and get session
    #############################
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Username", $username)
    $headers.Add("X-IntegrationServer-Password", $password)
    $status = $true; $message = "";
    try{$connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v2/connection/" -Method 'GET' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        $session = $responseHeader.'X-IntegrationServer-Session-Hash'
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            hash = $session
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v2/connection/"
            }
        }
    }
}

function Close-PerceptiveContentConnection {
    param (
        $baseURL,
        $session
    )
    $connectionDeleteHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $connectionDeleteHeaders.Add("Accept", "application/json")
    $connectionDeleteHeaders.Add("X-IntegrationServer-Session-Hash", $session)
    $connectionDeleteResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/connection/" -Method 'DELETE' -Headers $connectionDeleteHeaders
    Write-Verbose -Message "Closed Session [$($session)]"
    return $true
}

function Get-PerceptiveContentUniqueID_v1_202307 {
    param (
        $baseURL,
        $session,
        $quantity=1##non-negative integer
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{$connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/uniqueId?quantity=$($quantity)" -Method 'GET' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            ids = $connectionResponse.uniqueIds
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v1/uniqueId?quantity=$($quantity)"
            }
        }
    }
}

function Get-PerceptiveContentDepartment_v1_202306 {
    param (
        $baseURL,
        $session,
        $departmentName##optional
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    [System.Collections.ArrayList]$departments = @()
    $status = $true; $message = "";
    try
    {
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/department" -Method 'GET' -Headers $headers -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        if ($null -eq $departmentName)
        {
            foreach ($dept in $response.departments){
                $departments.Add($dept) | Out-Null
            }
        }
        else
        {
            $department = $response.departments | Where-Object -Filter {$_.name -eq $departmentName}
            if ($departmentName.Name -ne "")
            {
                foreach ($dept in $department){
                    $departments.Add($dept) | Out-Null
                }
                ##$departments.Add($department.departments) | Out-Null
            }
            else
            {
                $status = $false; $message = "Did not find Department";   
            }
        }
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            departments = $departments
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v1/department"
            }
        }
    }
}

function Get-PerceptiveContentViews_v3_202212 {
    param (
        $baseURL,
        $session,
        $category="DOCUMENT",##DOCUMENT, FOLDER, TASK, WORKFLOW, FOLDER_CONTENT
		$name##optional
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $category = $category.ToUpper()
    $status = $true; $message = "";
	if ($category -notin "DOCUMENT","FOLDER","FOLDER_CONTENT","TASK","WORKFLOW")
    {
        $status = $false
        $message += "Did not pass in the correct View Category. Use one of the following [DOCUMENT,FOLDER,FOLDER_CONTENT,TASK,WORKFLOW]"
        [PSCustomObject]@{
            header = ""
            responseBody = ""
            httpCode = ""
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            views = ""
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v3/view?category=$($category)"
            }
        }
    }
    else {
        try
        {
            $response = Invoke-RestMethod "$($baseURL)/integrationserver/v3/view?category=$($category)" -Method 'GET' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
            $session = $responseHeader.'X-IntegrationServer-Session-Hash'
            if ($null -eq $name){$finalViews = $response.views}
            else{$finalViews = $response.views | Where-Object -Property name -eq $name}
        }
        catch
        {
            $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
            $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
            $httpCode = $_.Exception.Message
            if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
            $status = $false
        }
        finally
        {
            [PSCustomObject]@{
                header = $responseHeader
                responseBody = $response
                httpCode = $httpCode
                status = $status
                message = $message
                isCode = $isErrorCode
                isMessage = $isErrorMessage
                views = $finalViews
                request = [PSCustomObject]@{
                    header = $headers
                    body = "None"
                    url = "GET $($baseURL)/integrationserver/v3/view?category=$($category)"
                }
            }
        }
    }
}

function Get-PerceptiveContentWorkflowQueues_v1_202212 {
    param (
        $baseURL,
        $session,
        $queueName##optional
    )
    $workflowQueueHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $workflowQueueHeaders.Add("Accept", "application/json")
    $workflowQueueHeaders.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try {
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/workflowQueue" -Method 'GET' -Headers $workflowQueueHeaders -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        if ($queueName -ne $null)
        {
            $workflowQueue = $response.workflowQueues | Where-Object -Filter {$_.name -eq $queueName}
        }
        else{$workflowQueue = $response.workflowQueues}
        Write-Verbose -Message "Queue Name [$($workflowQueue.name)] ID [$($workflowQueue.id)]"
    }
    catch {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            workflowQueue = $workflowQueue
            request = [PSCustomObject]@{
                header = $workflowQueueHeaders
                body = "None"
                url = "GET $($baseURL)/integrationserver/v1/workflowQueue"
            }
        }
    }
}

function Get-PerceptiveContentViewResultDocIDs_v4_202212 {
    param (
        $baseURL,
        $session,
        $category="DOCUMENT",##DOCUMENT, FOLDER, TASK, WORKFLOW, FOLDER_CONTENT
		$viewID,##Admin_Mass. Test - 321Z1CX_012VW3CCQ00004N
		$vsl##[field5] startswith 'HERE'
		##$clientTimeZoneOffset,
		##$columnSelectors##optional
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
	$body = [PSCustomObject]@{
		vslText = $vsl
		##clientTimeZoneOffset = $clientTimeZoneOffset
		includeCPColFoundInVsl = $true
		##columnSelectors = [PSCustomObject]@{
		##	id = "0"
		##	sortOrder = 0
		##	sortDirection = "ASCENDING"
		##}
	} | ConvertTo-Json -Depth 5
    $status = $true; $message = "";
    try{
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v4/view/$($viewID)/result?category=$($category)" -Method 'POST' -Headers $headers -ContentType "application/json" -Body $body -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        $columnDocID = $response.resultColumns | Where-Object -Property name -eq "Document ID" | Select-Object -ExpandProperty id
        $values = $response.resultRows.fields | Where-Object -Property columnId -eq $columnDocID | Select-Object -ExpandProperty value
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            values = $values
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "POST $($baseURL)/integrationserver/v4/view/$($viewID)/result?category=$($category)"
            }
        }
    }
}

function Get-PerceptiveContentAllViewResultsDocFieldsDocIDCreateMod_v4_202212 {
    param (
        $baseURL,
        $session,
        ##$category,##DOCUMENT, FOLDER, TASK, WORKFLOW, FOLDER_CONTENT
		$viewID,##Admin_Mass. Test - 321Z1CX_012VW3CCQ00004N
		$vsl,##[field5] startswith 'HERE'
		##$clientTimeZoneOffset,
		##$columnSelectors##optional
        $limit
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    [System.Collections.ArrayList]$docInfo = @()
    $lastID = "0"
    $limitReached = $false
    try
    {
        do
        {
            if ($vsl -eq $null)
            {
                $body = [PSCustomObject]@{
                    vslText = "[docID] > '$($lastID)'"
                    includeCPColFoundInVsl = $true
                }
            }
            else
            {
                $body = [PSCustomObject]@{
                    vslText = "$($vsl) AND [docID] > '$($lastID)'"
                    includeCPColFoundInVsl = $true
                }
            }
            Write-Verbose -Message "$($body)"
            $body = $body | ConvertTo-Json -Depth 5
            $response = Invoke-RestMethod "$($baseURL)/integrationserver/v4/view/$($viewID)/result?category=DOCUMENT" -Method 'POST' -Headers $headers -ContentType "application/json" -Body $body -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
            $columnDocID = $response.resultColumns | Where-Object -Property name -eq "Document ID" | Select-Object -ExpandProperty id
            $columnDrawer = $response.resultColumns | Where-Object -Property name -eq "Drawer" | Select-Object -ExpandProperty id
            $columnDocType = $response.resultColumns | Where-Object -Property name -eq "Type" | Select-Object -ExpandProperty id
            $columnField1 = $response.resultColumns | Where-Object -Property name -eq "Field1" | Select-Object -ExpandProperty id
            $columnField2 = $response.resultColumns | Where-Object -Property name -eq "Field2" | Select-Object -ExpandProperty id
            $columnField3 = $response.resultColumns | Where-Object -Property name -eq "Field3" | Select-Object -ExpandProperty id
            $columnField4 = $response.resultColumns | Where-Object -Property name -eq "Field4" | Select-Object -ExpandProperty id
            $columnField5 = $response.resultColumns | Where-Object -Property name -eq "Field5" | Select-Object -ExpandProperty id
            $columnCreated = $response.resultColumns | Where-Object -Property name -eq "Created" | Select-Object -ExpandProperty id
            $columnModified = $response.resultColumns | Where-Object -Property name -eq "Modified" | Select-Object -ExpandProperty id
            $columnsCP = $response.resultColumns | Where-Object -Property datatype -eq "CUSTOM_PROPERTY"
            Write-Verbose -message "$($response.resultColumns.datatype -join "|")"
            $rowCount = $response.resultRows.Count
            $currentRow=1
            foreach ($row in $response.resultRows)
            {
                $docID = $row.fields | Where-Object -Property columnId -eq $columnDocID | Select-Object -ExpandProperty value
                $rowData = [PSCustomObject]@{
                    docID = $docID
                    drawer = $row.fields | Where-Object -Property columnId -eq $columnDrawer | Select-Object -ExpandProperty value
                    docType = $row.fields | Where-Object -Property columnId -eq $columnDocType | Select-Object -ExpandProperty value
                    field1 = $row.fields | Where-Object -Property columnId -eq $columnField1 | Select-Object -ExpandProperty value
                    field2 = $row.fields | Where-Object -Property columnId -eq $columnField2 | Select-Object -ExpandProperty value
                    field3 = $row.fields | Where-Object -Property columnId -eq $columnField3 | Select-Object -ExpandProperty value
                    field4 = $row.fields | Where-Object -Property columnId -eq $columnField4 | Select-Object -ExpandProperty value
                    field5 = $row.fields | Where-Object -Property columnId -eq $columnField5 | Select-Object -ExpandProperty value
                    created = convertFromEpoch -inputEpoch ($row.fields | Where-Object -Property columnId -eq $columnCreated | Select-Object -ExpandProperty value)
                    modified = convertFromEpoch -inputEpoch ($row.fields | Where-Object -Property columnId -eq $columnModified | Select-Object -ExpandProperty value)
                }
                ##Wait-Debugger
                foreach ($cp in $columnsCP)
                {
                    $cpName = $response.resultColumns | Where-Object {$_.id -eq $cp.id} | Select-Object -ExpandProperty name
                    $cpValue = $row.fields | Where-Object {$_.columnId -eq $cp.id} | Select-Object -ExpandProperty value
                    $rowData | Add-Member -MemberType NoteProperty -Name $cpName -Value $cpValue
                }
                $docInfo.Add($rowData) | Out-Null
                if ($currentRow -eq $rowCount)
                {
                    $lastID = $docID
                }
                $currentRow++
            }
            if ($limit -notin ("",$null))
            {
                if ($docInfo.Count -ge $limit)
                {
                    $limitReached = $true
                    $message += "Limit of [$($limit)] reached."
                }
            }
            Write-Verbose -Message "TotalSoFar [$($docInfo.Count)] LastID [$($lastID)] RowCount [$($rowCount)] Limit [$($limit)] Limit Reached [$($limitReached)]"
        }
        while(($response.hasMore -eq $true -and $status -eq $true -and $limitReached -eq $false))
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            results = $docInfo
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "POST $($baseURL)/integrationserver/v4/view/$($viewID)/result?category=DOCUMENT"
            }
        }
    }
}

function Get-PerceptiveContentAllViewResultsWFFieldsWFID_v4_202212 {
    param (
        $baseURL,
        $session,
        ##$category,##DOCUMENT, FOLDER, TASK, WORKFLOW, FOLDER_CONTENT
		$viewID,##Admin_Mass. Test - 321Z1CX_012VW3CCQ00004N
		$vsl##[field5] startswith 'HERE'
		##$clientTimeZoneOffset,
		##$columnSelectors##optional
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    [System.Collections.ArrayList]$itemInfo = @()
    $lastID = "0"
    try
    {
        do
        {
            if ($vsl -eq $null)
            {
                $body = [PSCustomObject]@{
                    vslText = "[wfItemId] > '$($lastID)'"
                    includeCPColFoundInVsl = $true
                }
            }
            else
            {
                $body = [PSCustomObject]@{
                    vslText = "$($vsl) AND [wfItemId] > '$($lastID)'"
                    includeCPColFoundInVsl = $true
                }
            }
            Write-Verbose -Message "$($body)"
            $body = $body | ConvertTo-Json -Depth 5
            $response = Invoke-RestMethod "$($baseURL)/integrationserver/v4/view/$($viewID)/result?category=WORKFLOW" -Method 'POST' -Headers $headers -ContentType "application/json" -Body $body -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
            $columnItemID = $response.resultColumns | Where-Object -Property name -eq "Item ID" | Select-Object -ExpandProperty id
            $columnItemType = $response.resultColumns | Where-Object -Property name -eq "Item Type" | Select-Object -ExpandProperty id
            $columnStatus = $response.resultColumns | Where-Object -Property name -eq "Status" | Select-Object -ExpandProperty id
            $columnQueue = $response.resultColumns | Where-Object -Property name -eq "Workflow Queue" | Select-Object -ExpandProperty id
            $columnTimeInQueue = $response.resultColumns | Where-Object -Property name -eq "Time In Queue" | Select-Object -ExpandProperty id
            $columnAddedDate = $response.resultColumns | Where-Object -Property name -eq "Added" | Select-Object -ExpandProperty id
            $columnAddedBy = $response.resultColumns | Where-Object -Property name -eq "Added By" | Select-Object -ExpandProperty id
            $columnRoutedDate = $response.resultColumns | Where-Object -Property name -eq "Routed" | Select-Object -ExpandProperty id
            $columnRoutedBy = $response.resultColumns | Where-Object -Property name -eq "Routed By" | Select-Object -ExpandProperty id
            $rowCount = $response.resultRows.Count
            $currentRow=1
            foreach ($row in $response.resultRows)
            {
                $itemID = $row.fields | Where-Object -Property columnId -eq $columnItemID | Select-Object -ExpandProperty value
                $rowData = [PSCustomObject]@{
                    itemID = $itemID
                    itemType = $row.fields | Where-Object -Property columnId -eq $columnItemType | Select-Object -ExpandProperty value
                    status = $row.fields | Where-Object -Property columnId -eq $columnStatus | Select-Object -ExpandProperty value
                    queue = $row.fields | Where-Object -Property columnId -eq $columnQueue | Select-Object -ExpandProperty value
                    timeInQueue = (convertFromEpochDuration -inputEpoch ($row.fields | Where-Object -Property columnId -eq $columnTimeInQueue | Select-Object -ExpandProperty value)).TotalHours
                    added = convertFromEpoch -inputEpoch ($row.fields | Where-Object -Property columnId -eq $columnAddedDate | Select-Object -ExpandProperty value)
                    addedBy = $row.fields | Where-Object -Property columnId -eq $columnAddedBy | Select-Object -ExpandProperty value
                    routed = convertFromEpoch -inputEpoch ($row.fields | Where-Object -Property columnId -eq $columnRoutedDate | Select-Object -ExpandProperty value)
                    routedBy = $row.fields | Where-Object -Property columnId -eq $columnRoutedBy | Select-Object -ExpandProperty value
                }
                $itemInfo.Add($rowData) | Out-Null
                if ($currentRow -eq $rowCount)
                {
                    $lastID = $itemID
                }
                $currentRow++
            }
            Write-Verbose -Message "TotalSoFar [$($itemInfo.Count)] LastID [$($lastID)] RowCount [$($rowCount)]"
        }
        while($response.hasMore -eq $true -and $status -eq $true)
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            results = $itemInfo
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "POST $($baseURL)/integrationserver/v4/view/$($viewID)/result?category=WORKFLOW"
            }
        }
    }
}

function Get-PerceptiveContentDocInfo_v9_202212 {
    param (
        $baseURL,
        $session,
        $docID
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)    
    $status = $true; $message = "";
    try{$response = Invoke-RestMethod "$($baseURL)/integrationserver/v9/document/$($docID)" -Method 'GET' -Headers $headers -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            docInfo = $response
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v9/document/$($docID)"
            }
        }
    }
}

function Get-PerceptiveContentWFItemInfo_v1_202301 {
    param (
        $baseURL,
        $session,
        $wfItemID
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)    
    $status = $true; $message = "";
    try{$response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/workflowItem/$($wfItemID)" -Method 'GET' -Headers $headers -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            wfItemInfo = $response
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v1/workflowItem/$($wfItemID)"
            }
        }
    }
}

function Update-PerceptiveContentDoc_V1_202212 {
    param (
        $baseURL,
        $session,
        $docID,
        $body
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{$response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/document/$($docID)" -Method 'PUT' -Headers $headers -Body $body -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        ##if ($status -eq $true){| Select-Object -Last 1}else{$docID = ""}
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            docID = $docID
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "POST $($baseURL)/integrationserver/v1/document/$($docID)"
            }
        }
    }
}

function Update-PerceptiveContentDocProperties_v6_202304 {
    param (
        $baseURL,
        $session,
        $docID,
        $body
    )
    ####conflict items come over as status 409. had to use -SkipHttpErrorCheck to let them though
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{$response = Invoke-RestMethod "$($baseURL)/integrationserver/v6/document/$($docID)" -Method 'PATCH' -Headers $headers -Body $body -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode -SkipHttpErrorCheck}
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        try {
            # Attempt to convert to JSON
            $conflictInfo = $_ | ConvertFrom-Json
        }
        catch {
            # Handle or log the error if conversion fails
            $conflictInfo = ""
        }
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)] Conflict [$($conflictInfo.instanceType)] [$($conflictInfo.id)]"}
        $status = $false
    }
    finally
    {
        if ($httpCode -eq 409)
        {
            $isErrorMessage = $responseHeader | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
            $isErrorCode = $responseHeader | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
            $message += "Code [$($isErrorCode)] Message [$($isErrorMessage)] Type [$($response.instanceType)] ID [$($response.id)]"
            $status = $false
        }
        elseif ($httpCode -in @(200,201)) {
            ##all is good
        }
        else {
            $isErrorMessage = $responseHeader | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
            $isErrorCode = $responseHeader | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
            ##$httpCode = $_.Exception.Message
            if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
            $status = $false
        }
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            conflictItem = $conflictInfo##returns instanceType and id
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "PATCH $($baseURL)/integrationserver/v6/document/$($docID)"
            }
        }
    }
}


function Add-PerceptiveContentDoc_v3_202212 {
    param (
        $baseURL,
        $session,
        $mode,##RETURN_CONFLICTS, REPLACE. Append doesn't seem to work.
        $body
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v3/document?action=$($mode)" -Method 'POST' -Headers $headers -Body $body -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        $newDocID = $responseHeader.Location.Split("/") | Select-Object -Last 1
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        try {
            # Attempt to convert to JSON
            $conflictInfo = $_ | ConvertFrom-Json
        }
        catch {
            # Handle or log the error if conversion fails
            $conflictInfo = ""
        }
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)] Conflict [$($conflictInfo.instanceType)] [$($conflictInfo.id)]"}
        $status = $false
    }
    finally
    {
        ##if ($status -eq $true){| Select-Object -Last 1}else{$docID = ""}
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            docID = $newDocID
            conflictInfo = $conflictInfo##returns instanceType and id
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "POST $($baseURL)/integrationserver/v3/document?action=$($mode)"
            }
        }
    }
}

function Add-PerceptiveContentDocPage_v1_202212 {
    param (
        $baseURL,
        $session,
        $docID,
        $path
    )

    $fileName = Split-Path -Path $path -Leaf
    $fileExtension = Split-Path -Path $path -Extension
    if(-Not (Test-Path $path))
    {
        return [PSCustomObject]@{
            header = ""
            body = ""
            httpCode = ""
            status = $false
            message = "Test-Path failed for DocID [$($docID)] and path [$($path)]"
            docID = ""
        }
    }
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("Content-Type", "application/octet-stream")
    $headers.Add("X-IntegrationServer-Resource-Name", $fileName)
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    if ($fileExtension -eq ".txt"){$addPageBody = [IO.File]::ReadAllText($path)}
    else{$addPageBody = [IO.File]::ReadAllBytes($path)}
    try
    {
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/document/$($docID)/page" -Method 'POST' -Headers $headers -Body $addPageBody -ContentType "application/octet-stream" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        Write-Verbose -Message "File name [$($fileName)] extension [$($fileExtension)]"
        Write-Verbose -Message "Page location [$($responseHeader.Location)]"
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        if ($status -eq $true)
        {
            $docID = ($responseHeader.Location.Split("/"))[6]
            $pageID = $responseHeader.Location.Split("/") | Select-Object -Last 1
        }
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            docID = $docID
            pageID = $pageID
            request = [PSCustomObject]@{
                header = $headers
                body = "Octet Stream - Skipped"
                url = "POST $($baseURL)/integrationserver/v1/document/$($docID)/page"
            }
        }
    }
}

function Remove-PerceptiveContentDocument_v1_202212 {
    param (
        $baseURL,
        $session,
        $docID
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/document/$($docID)" -Method 'DELETE' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        Write-Verbose -Message "Deleted [$($docID)]"
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "POST $($baseURL)/integrationserver/v1/document/$($docID)/page"
            }
        }
    }
}

function Get-PerceptiveContentDrawer_v2_202212 {
    param (
        $baseURL,
        $session,
        $drawerName##optional
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try
    {
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v2/drawer" -Method 'GET' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        if ($null -eq $drawerName)
        {
            $drawer = $response.drawers
            Write-Verbose -Message "Drawer Count [$($drawer.Length)]"
        }
        else
        {
            $drawer = $response.drawers | Where-Object -Filter {$_.name -eq $drawerName}
            Write-Verbose -Message "Drawer Name [$($drawer.Name)] ID [$($drawer.Id)]"
        }
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            drawer = $drawer
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v2/drawer"
            }
        }
    }  
}

function Get-PerceptiveContentDocType_v1_202310 {
    param (
        $baseURL,
        $session,
        $docTypeName##optional
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try
    {
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/documentType" -Method 'GET' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        if ($docTypeName)
        {
            $docType = $response.documentTypes | Where-Object {$_.name -eq $docTypeName}
        }
        else
        {
            $docType = $response.documentTypes
        }
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            docType = $docType
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v1/documentType"
            }
        }
    }  
}

function Add-PerceptiveContentDrawer_v1_202307 {
    param (
        $baseURL,
        $session,
        $name,
        $description,
        $departmentID
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    
    if ($null -eq $name -or $null -eq $description -or $null -eq $departmentID )
    {
        $status = $false; $message = "Name, Description, or DepartmentID is null";
    }

    try
    {
        $addToVSBody = [PSCustomObject]@{
            name = $name
            description = $description
            departmentId = $departmentID
        } | ConvertTo-Json -Depth 5
        if ($status -eq $true){$response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/management/drawer" -Method 'POST' -Headers $headers -body $addToVSBody -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    }
    catch
    {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally
    {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            drawerID = $response.Location.Split("/") | Select-Object -Last 1
            request = [PSCustomObject]@{
                header = $headers
                body = $addToVSBody
                url = "POST $($baseURL)/integrationserver/v1/management/drawer"
            }
        }
    }  
}

function Add-PerceptiveContentItemToWorkflow_v1_202212 {
    param (
        $baseURL,
        $session,
        $itemID,
        $itemType,##DOCUMENT, FOLDER
        $workflowQueueId,
        $priority##MEDIUM, LOW, HIGH
    )
    ######You have two areas to get the docID. in the response headers from create document, or add page. In this example it ends in 00017K
    ####Create Doc Response Location $baseURL/integrationserver/v1/document/321Z4DH_04LPR47NH00017K
    ####Add Page Response Location $baseURL/integrationserver/v1/document/321Z4DH_04LPR47NH00017K/page/321Z4DH_04LPR37NH0000WH
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    $body = [PSCustomObject]@{
        objectId = $itemID
        itemType = $itemType
        workflowQueueId = $workflowQueueId
        itemPriority = $priority
    }| ConvertTo-Json -Depth 5
    try{
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/workflowItem" -Method 'POST' -Headers $headers -Body $body -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode -ContentType "application/json"
        Write-Verbose -Message "Workflow location [$($responseHeader.Location)]"
        if ($responseHeader.Location -eq "")
        {
            $newItemID = ""
            $message += "Response does not contain an id. Add-PerceptiveContentItemToWorkflow_v1"
            $status = $false
        }
        else{$newItemID = $responseHeader.Location.Split("/") | Select-Object -Last 1}
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally{
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            itemID = $newItemID
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "POST $($baseURL)/integrationserver/v1/workflowItem"
            }
        }
    }
}

function Move-PerceptiveContentItemAlreadyInWorkflow_v2_202301 {
    param (
        $baseURL,
        $session,
        $itemID,##workflow item id
        ##$currentWorkflowQueueId,
        ##$currentWorkflowQueueName,
        ##$destinationWorkflowQueueId,
        $destinationWorkflowQueueName,
        $reason
    )
    
    $wfItem = Get-PerceptiveContentWFItemInfo_v1_202301 -baseURL $baseURL -session $session -wfItemID $itemID
    $wfItem | ConvertTo-Json -Depth 6 | Write-Verbose
    $destQueue = Get-PerceptiveContentWorkflowQueues_v1_202212 -baseURL $baseURL -session $session -queueName $destinationWorkflowQueueName
    $destQueue | ConvertTo-Json -Depth 6 | Write-Verbose
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    $body = [PSCustomObject]@{
        originWorkflowQueueId = $wfItem.wfItemInfo.workflowQueueId
        originWorkflowQueueName = $wfItem.wfItemInfo.workflowQueueName
        routeType = "MANUAL"
        reason = $reason
        destinationWorkflowQueueIds = @(
            $destQueue.workflowQueue.id
        )
    }| ConvertTo-Json -Depth 5
    try{
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v2/workflowItem/$($itemID)/routingAction" -Method 'POST' -Headers $headers -Body $body -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode -ContentType "application/json"
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally{
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "POST $($baseURL)/integrationserver/v2/workflowItem/$($itemID)/routingAction"
            }
        }
    }
}

function Remove-PerceptiveContentItemFromWorkflow_v1_202307 {
    param (
        $baseURL,
        $session,
        $itemID,##workflow item id
        $queueID##queue the item is in
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v1/workflowItem/$($itemID)?workflowQueueId=$($queueID)" -Method 'DELETE' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode -ContentType "application/json"
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally{
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "DELETE $($baseURL)/integrationserver/v1/workflowItem/$($itemID)?workflowQueueId=$($queueID)"
            }
        }
    }
}

function Get-NewDocBodyFromDocInfoCorrectDrawerModel_v202212 {
    param (
        $docInfo##Output from Get-PerceptiveContentDocInfo_v9_202212
    )
    $keys = $docInfo.info.keys | Select-Object -ExcludeProperty drawerId, documentTypeId | ConvertTo-Json -depth 10 | ConvertFrom-Json -depth 10
    $info = $docInfo.info | Select-Object -Property id, name, locationId, keys, notes | ConvertTo-Json -depth 10 | ConvertFrom-Json -depth 10 ##locationId, keys
    $info.keys = $keys | ConvertTo-Json -depth 10 | ConvertFrom-Json -depth 10
    $info.name = $info.id
    
    ##$propsWithChildren = 
    ##[System.Collections.ArrayList]$finalChildProps = @()
    [System.Collections.ArrayList]$properties = @()
    foreach($prop2 in $docInfo.properties | Where-Object {$_.type -ne "ARRAY"})
    {
        $object = [PSCustomObject]@{
            id = $prop2.id
            type = $prop2.type
            value = $prop2.value
            childProperties = $prop2.childProperties
        }
        $properties.Add($object) | Out-Null
    }
    foreach ($prop in $docInfo.properties | Where-Object {$_.type -eq "ARRAY"})
    {
        $finalProps = $prop | Select-Object -Property id, type, value, childProperties
        $finalProps.childProperties = $prop.childProperties | Select-Object -Property id, type, value
        $properties.Add($finalProps) | Out-Null
    }

    ##$properties =  | Select-Object -Property id, type, value, childProperties
    ##$properties+=($finalChildProps)
    ##$info = $properties.GetType()
    [PSCustomObject]@{
        info = $info
        properties = $properties
    }
}


function Get-NewDocBodyFromDocInfo_v202212 {
    param (
        $docInfo,##Output from Get-PerceptiveContentDocInfo_v9_202212,
        [switch]$autochooseModel,
        [switch]$removeLocation,
        [switch]$removeName
    )
    ####For use with Add-PerceptiveContentDoc_v3_202212
    ##$keys = $docInfo.info.keys | Select-Object -ExcludeProperty drawerId, documentTypeId
    ##$info = $docInfo.info | Select-Object -Property name, notes, locationId, keys
    ##$info.keys = $keys
    ##if ($removeLocation){$info.locationId = ""}
    ##if ($removeName){$info.name = ""}
    
    ####For use with Add-PerceptiveContentDoc_v3_202212
    if ($autochooseModel)
    {
        ####contentModel
        ####this only needs the Drawer, Fields 1-5, and doc type
        if ($docInfo.info.id -eq $docInfo.info.name)
        {
            $keys = $docInfo.info.keys | Select-Object -ExcludeProperty drawerId, documentTypeId | ConvertTo-Json -depth 10 | ConvertFrom-Json -depth 10
            $info = $docInfo.info | Select-Object -Property keys, notes | ConvertTo-Json -depth 10 | ConvertFrom-Json -depth 10 ##locationId, keys
            $info.keys = $keys | ConvertTo-Json -depth 10 | ConvertFrom-Json -depth 10
        }
        else
        {
            $keys = $docInfo.info.keys | Select-Object -ExcludeProperty drawerId, documentTypeId | ConvertTo-Json -depth 10 | ConvertFrom-Json -depth 10
            $info = $docInfo.info | Select-Object -Property keys, notes, name | ConvertTo-Json -depth 10 | ConvertFrom-Json -depth 10 ##locationId, keys
            $info.keys = $keys | ConvertTo-Json -depth 10 | ConvertFrom-Json -depth 10
        }
    }
    else
    {
        $keys = $docInfo.info.keys | Select-Object -ExcludeProperty drawerId, documentTypeId
        $info = $docInfo.info | Select-Object -Property name, notes, locationId, keys
        $info.keys = $keys
        if ($removeLocation){$info.locationId = ""}
        if ($removeName){$info.name = ""}
    }

    ##$propsWithChildren = 
    ##[System.Collections.ArrayList]$finalChildProps = @()
    [System.Collections.ArrayList]$properties = @()
    foreach($prop2 in $docInfo.properties | Where-Object {$_.type -ne "ARRAY"})
    {
        $object = [PSCustomObject]@{
            id = $prop2.id
            type = $prop2.type
            value = $prop2.value
            childProperties = $prop2.childProperties
        }
        $properties.Add($object) | Out-Null
    }
    foreach ($prop in $docInfo.properties | Where-Object {$_.type -eq "ARRAY"})
    {
        $finalProps = $prop | Select-Object -Property id, type, value, childProperties
        $finalProps.childProperties = $prop.childProperties | Select-Object -Property id, type, value
        $properties.Add($finalProps) | Out-Null
    }

    ##$properties =  | Select-Object -Property id, type, value, childProperties
    ##$properties+=($finalChildProps)
    ##$info = $properties.GetType()
    [PSCustomObject]@{
        info = $info
        properties = $properties
    }
}

function Get-PerceptiveContentProperty_v2_202303 {
    param (
        $baseURL,
        $session,
        $propertyName,##optional
        $listValuesLimit##Can be ALL, NONE, or non-negative integer
    )
    $status = $true; $message = "";
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    if ($listValuesLimit -eq $null) {$listValuesLimit = "NONE"}
    try{
        $response = Invoke-RestMethod "$($baseURL)/integrationserver/v2/property?listValuesLimit=$($listValuesLimit)" -Method 'GET' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode -ContentType "application/json"
        if ($propertyName -eq $null)
        {
            $properties = $response.properties | ConvertTo-Json -depth 5 | ConvertFrom-Json -Depth 5
        }
        else
        {
            $properties = $response.properties | Where-Object -Filter {$_.name -eq $propertyName}
        }
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally{
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $response
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            properties = $properties
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v2/property?listValuesLimit=$($listValuesLimit)"
            }
        }
    }
}

function Get-PerceptiveContentUser_v2_202306 {
    param (
        $baseURL,
        $session
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{$connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v2/user" -Method 'GET' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            users = $connectionResponse.users
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v2/user"
            }
        }
    }
}

function Get-PerceptiveContentUserInformation_v1_202306 {
    param (
        $baseURL,
        $session
    )
    ####broken in 7.7.0.139
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{$connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v3/user" -Method 'GET' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            users = $connectionResponse.users
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v3/user"
            }
        }
    }
}
function Get-PerceptiveContentUserInformationDetailed_v1_202306 {
    param (
        $baseURL,
        $session,
        $userID
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{$connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/user/$($userID)/extendedInfo" -Method 'GET' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            user = $connectionResponse
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v1/user/$($userID)/extendedInfo"
            }
        }
    }
}
function Remove-PerceptiveContentUser_v1_202306 {
    param (
        $baseURL,
        $session,
        $userID
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{$connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/user/$($userID)" -Method 'DELETE' -Headers $headers -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "DELETE $($baseURL)/integrationserver/v1/user/$($userID)"
            }
        }
    }
}

function Add-PerceptiveContentUser_v1_202306 {
    param (
        $baseURL,
        $session,
        $body
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    $newUserID = ""
    try{
        $connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/user" -Method 'POST' -Headers $headers -Body ($body | ConvertTo-Json -depth 5) -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        $newUserID = $responseHeader.Location.Split("/") | Select-Object -Last 1
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            newUserID = $newUserID
            request = [PSCustomObject]@{
                header = $headers
                body = ($body | ConvertTo-Json -depth 5)
                url = "POST $($baseURL)/integrationserver/v1/user"
            }
        }
    }
}

function Add-PerceptiveContentUserAndGetDetail {
    param (
        $baseURL,
        $session,
        $body
    )
    $addUser = Add-PerceptiveContentUser_v1_202306 -baseURL $baseURL -session $session -body $body
    if ($addUser.status -eq $false)
    {
        return $addUser
    }
    $getUserInfo = Get-PerceptiveContentUserInformationDetailed_v1_202306 -baseURL $baseURL -session $session -userID $addUser.newUserID
    if ($getUserInfo.status -eq $false)
    {
        return $getUserInfo
    }
    return [PSCustomObject]@{
        status = $true
        message = ""
        user = $getUserInfo.user
    }
}

function Set-PerceptiveContentUserInactive_v1_202306 {
    param (
        $baseURL,
        $session,
        $allUsers,##This is the user output from Get-PerceptiveContentUser_v2_202306 OR Get-PerceptiveContentUserInformation_v1_202306
        $userName
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $selectedUser = $allUsers | Where-Object {$_.name -eq $userName}
    $body = [PSCustomObject]@{
        name = (Switch-UTFSpecialCharacters -inputText $selectedUser.name)
        isActive = $false
    } | ConvertTo-Json -Depth 5
    $status = $true; $message = "";
    try{$connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/user/$($selectedUser.id)/account" -Method 'PUT' -Headers $headers -Body $body -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "POST $($baseURL)/integrationserver/v1/user/$($selectedUser.id)/account"
            }
        }
    }
}

function Set-PerceptiveContentUserInactiveThenActive_v1_202306 {
    param (
        $baseURL,
        $session,
        $allUsers,##This is the user output from Get-PerceptiveContentUser_v2_202306 OR Get-PerceptiveContentUserInformation_v1_202306
        $userName
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $selectedUser = $allUsers | Where-Object {$_.name -eq $userName}
    Write-Information -MessageData "$($selectedUser)"
    $status = $true; $message = "";
    $body1 = [PSCustomObject]@{
        name = (Switch-UTFSpecialCharacters -inputText $selectedUser.name)
        isActive = $false
    } | ConvertTo-Json -Depth 5
    $body2 = [PSCustomObject]@{
        name = (Switch-UTFSpecialCharacters -inputText $selectedUser.name)
        isActive = $true
    } | ConvertTo-Json -Depth 5
    try
    {
        $connectionResponse1 = Invoke-RestMethod "$($baseURL)/integrationserver/v1/user/$($selectedUser.id)/account" -Method 'PUT' -Headers $headers -Body $body1 -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
        $connectionResponse2 = Invoke-RestMethod "$($baseURL)/integrationserver/v1/user/$($selectedUser.id)/account" -Method 'PUT' -Headers $headers -Body $body2 -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            inactiveBody = $connectionResponse1
            activeBody = $connectionResponse2
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body1 = $body1
                body2 = $body2
                url = "PUT $($baseURL)/integrationserver/v1/user/$($selectedUser.id)/account"
            }
        }
    }
}


function Set-PerceptiveContentUserActive_v1_202306 {
    param (
        $baseURL,
        $session,
        $allUsers,##This is the user output from Get-PerceptiveContentUser_v2_202306 OR Get-PerceptiveContentUserInformation_v1_202306
        $userName
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $selectedUser = $allUsers | Where-Object {$_.name -eq $userName}
    Write-Information -MessageData "$($selectedUser)"
    $status = $true; $message = "";
    $body = [PSCustomObject]@{
        name = (Switch-UTFSpecialCharacters -inputText $selectedUser.name)
        isActive = $true
    } | ConvertTo-Json -Depth 5
    try
    {
        $connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/user/$($selectedUser.id)/account" -Method 'PUT' -Headers $headers -Body $body -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "PUT $($baseURL)/integrationserver/v1/user/$($selectedUser.id)/account"
            }
        }
    }
}

function Set-PerceptiveContentUserNameActive_v1_202306 {
    param (
        $baseURL,
        $session,
        $userID,
        $newName,
        $active##$true, $false
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("Content-Type", "application/json;charset=UTF-8")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    $body = [PSCustomObject]@{
        name = (Switch-UTFSpecialCharacters -inputText $newName)
        isActive = $active
    } | ConvertTo-Json -Depth 5
    try
    {
        $connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/user/$($userID)/account" -Method 'PUT' -Headers $headers -Body $body -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "PUT $($baseURL)/integrationserver/v1/user/$($userID)/account"
            }
        }
    }
}

function Set-PerceptiveContentUserProfileInfo_v1_202306 {
    param (
        $baseURL,
        $session,
        $userID,
        $userProfile
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    $body = $userProfile | ConvertTo-Json -Depth 5
    try
    {
        $connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/user/$($userID)/profile" -Method 'PUT' -Headers $headers -Body $body -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "PUT $($baseURL)/integrationserver/v1/user/$($userID)/profile"
            }
        }
    }
}

function Set-PerceptiveContentGroupToUsers_v2_202306 {
    ##renamed from Add-PerceptiveContentUsersToGroup
    param (
        $baseURL,
        $session,
        $departmentID,
        $groupID,
        $name,
        $description,
        $userArray##looking for two columns... id, and name/userName
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    [System.Collections.ArrayList]$newUserArray = @()
    if ($null -eq $departmentID -or $null -eq $groupID -or $null -eq $name -or $null -eq $description)
    {
        return [PSCustomObject]@{
            status = $false
            message = "Blank departmentID, groupID, name, or description"
        }
    }
    foreach ($user in $userArray)
    {
        $dataObj = [PSCustomObject]@{
            id = $user.id
            name = (Switch-UTFSpecialCharacters -inputText $user.name)
        }
        $newUserArray.Add($dataObj) | Out-Null
    }
    $body = [PSCustomObject]@{
        name = $name
        isGloballyVisible = $true
        description = $description
        departmentId = $departmentID
        users = $newUserArray
    } | ConvertTo-Json -Depth 5
    try
    {
        $connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v2/userGroup/$($groupID)" -Method 'PUT' -Headers $headers -Body $body -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "PUT $($baseURL)/integrationserver/v2/userGroup/$($groupID)"
            }
        }
    }
}

function Add-RemovePerceptiveContentUsersFromGroup_v1_202306 {
    param (
        $baseURL,
        $session,
        $groupID,
        $name,
        $description,
        $userIDsToAdd,##1 column named id for userid
        $userIDsToRemove##1 column named id for userid
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    if ($null -eq $groupID -or $null -eq $name -or $null -eq $description)
    {
        return [PSCustomObject]@{
            status = $false
            message = "Blank groupID, name, or description"
        }
    }
    $nullPSCustomObject = [PSCustomObject]@{
        id = $null
    }
    [System.Collections.ArrayList]$userIDsToAddArray = @()
    [System.Collections.ArrayList]$userIDsToRemoveArray = @()
    if ($null -eq $userIDsToAdd)
    {
        #$userIDsToAddArray.Add($nullPSCustomObject)|Out-Null
    }
    else
    {
        foreach ($item in $userIDsToAdd)
        {
            $userIDsToAddArray.Add($item)|Out-Null
        }
    }
    if ($null -eq $userIDsToRemove)
    {
        #$userIDsToRemoveArray.Add($nullPSCustomObject)|Out-Null
    }
    else
    {
        foreach ($item in $userIDsToRemove)
        {
            $userIDsToRemoveArray.Add($item)|Out-Null
        }
    }
    $body = [PSCustomObject]@{
        name = $name
        isGloballyVisible = $true
        description = $description
        membership = [PSCustomObject]@{
            usersToAdd = $userIDsToAddArray
            usersToRemove = $userIDsToRemoveArray
        }
    } | ConvertTo-Json -Depth 5
    try
    {
        $connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/userGroup/$($groupID)" -Method 'PUT' -Headers $headers -Body $body -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode
    }
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            request = [PSCustomObject]@{
                header = $headers
                body = $body
                url = "PUT $($baseURL)/integrationserver/v1/userGroup/$($groupID)"
            }
        }
    }
}

function Get-PerceptiveContentUserGroup_v1_202306 {
    param (
        $baseURL,
        $session,
        $departmentID
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    if ($null -eq $departmentID)
    {
        $departments = Get-PerceptiveContentDepartment_v1_202306 -baseURL $baseURL -session $session
        ##Write-Information -MessageData "Department Counts $($departments.departments.count)"
        [System.Collections.ArrayList]$allGroups = @()
        foreach($dept in $departments.departments | Where-Object {$_.departmentId -ne "system"})
        {
            $info1 = Get-PerceptiveContentUserGroup_v1_202306 -baseURL $baseURL -session $session -departmentID $dept.id
            ##Write-Information -MessageData "$($dept.name) - Groups [$($info1.groups.count)]"
            foreach ($group in $info1.groups)
            {
                if ($group.id -notin $allGroups.id)
                {
                    $allGroups.Add($group) | Out-Null
                }
            }
        }
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            groups = $allGroups
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v1/userGroup/?departmentId=$($departmentID)"
            }
        }
    }
    else
    {
        try {$connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v1/userGroup/?departmentId=$($departmentID)" -Method 'GET' -Headers $headers -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
        catch {
            $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
            $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
            $httpCode = $_.Exception.Message
            if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
            $status = $false
        }
        finally {
            [PSCustomObject]@{
                header = $responseHeader
                responseBody = $connectionResponse
                httpCode = $httpCode
                status = $status
                message = $message
                isCode = $isErrorCode
                isMessage = $isErrorMessage
                groups = $connectionResponse.userGroups
                request = [PSCustomObject]@{
                    header = $headers
                    body = "None"
                    url = "GET $($baseURL)/integrationserver/v1/userGroup/?departmentId=$($departmentID)"
                }
            }
        }
    }
}

function Get-PerceptiveContentUserGroupInfo_v2_202306 {
    param (
        $baseURL,
        $session,
        $groupID
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    if ($null -eq $groupID) {
        return [PSCustomObject]@{
            status = $false
            message = "No group provided"
        }
    }
    try {$connectionResponse = Invoke-RestMethod "$($baseURL)/integrationserver/v2/userGroup/$($groupID)" -Method 'GET' -Headers $headers -ContentType "application/json" -ResponseHeadersVariable responseHeader -StatusCodeVariable httpCode}
    catch {
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            group = $connectionResponse
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v2/userGroup/$($groupID)"
            }
        }
    }
}

function Get-PerceptiveContentDocPageFile_v2_202306 {
    param (
        $baseURL,
        $session,
        $docID,
        $pageID,
        $extension
    )
    ####not crazy about this as it creates a tmp file even if it's not used
    $tempFilePath = [System.IO.Path]::GetTempPath()
    if ($extension)
    {
        $outFilePath = "$($tempFilePath)$($pageID).$($extension)"
    }
    else {
        $outFilePath = "$($tempFilePath)$($pageID).tmp"
    }
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/octet-stream")
    $headers.Add("X-IntegrationServer-Session-Hash", $session)
    $status = $true; $message = "";
    try{$response = Invoke-RestMethod "$($baseURL)/integrationserver/v2/document/$($docID)/page/$($pageID)/file" -Method 'GET' -Headers $headers -ContentType "application/json" -OutFile $outFilePath -ResponseHeadersVariable reponseHeaders}
    catch{
        $isErrorMessage = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Message"} | Select-Object -ExpandProperty Value
        $isErrorCode = $_.Exception.Response.Headers | Where-Object {$_.Key -eq "X-IntegrationServer-Error-Code"} | Select-Object -ExpandProperty Value
        $httpCode = $_.Exception.Message
        if ($null -eq $isErrorCode){$message += $httpCode}else{$message += "Code [$($isErrorCode)] Message [$($isErrorMessage)]"}
        $status = $false
    }
    finally {
        [PSCustomObject]@{
            header = $responseHeader
            responseBody = $connectionResponse
            httpCode = $httpCode
            status = $status
            message = $message
            isCode = $isErrorCode
            isMessage = $isErrorMessage
            filePath = $outFilePath
            request = [PSCustomObject]@{
                header = $headers
                body = "None"
                url = "GET $($baseURL)/integrationserver/v2/document/$($docID)/page/$($pageID)/file"
            }
        }
    }
}

function Test-PerceptiveContentKeys_202311 {
    param (
        $allDrawers,####Get-PerceptiveContentDrawer_v2_202212
		$allDocTypes,####Get-PerceptiveContentDocType_v1_202310
		$docInfo####below doc format
        ##$propertyArray = @()
        ##$propertyArray += Get-PerceptiveContentPropertyItem -properties $allContentProperties -propName "CP Name" -propValue "CPPropValueHere"
        ##$docData = [PSCustomObject]@{
        ##    info = [PSCustomObject]@{
        ##        name = ""
        ##        locationId = ""
        ##        keys = [PSCustomObject]@{
        ##            drawer = "DrawerName"
        ##            documentType = "DocTypeName"
        ##            field1 = "Test1"
        ##            field2 = "Test2"
        ##            field3 = "Test3"
        ##            field4 = "Test4"
        ##            field5 = "Field5"
        ##        }
        ##    }
        ##    properties = $propertyArray
        ##}
    )
    $messages = ""
    $status = $true
    #################################
	####Drawer logic. If it does not exist in content, error.
	#################################
	if ($docInfo.info.keys.drawer -notin $allDrawers.name)
	{
        $status = $false
		$messages += "Not in Content - Drawer [$($docInfo.drawer)]. "
	}

	#################################
	####Doc Type logic. If it does not exist in content, error.
	#################################
	if ($docInfo.info.keys.documentType -notin $allDocTypes.name)
	{
        $status = $false
        $messages += "Not in Content - Doc Type [$($docInfo.docType)]. "
	}

	#################################
	####Field 1-5 need to be less than 40 characters. Trim if over 40.
	#################################
	if ($docInfo.info.keys.Field1.Length -gt 40)
	{
        $messages += "Field1 greater than 40 - Trimmed to 40. Orig [$($docInfo.info.keys.Field1)]. "
        $docInfo.info.keys.Field1 = ($docInfo.info.keys.Field1).Substring(0,40)
	}
    if ($docInfo.info.keys.Field2.Length -gt 40)
	{
        $messages += "Field2 greater than 40 - Trimmed to 40. Orig [$($docInfo.info.keys.Field2)]. "
        $docInfo.info.keys.Field2 = ($docInfo.info.keys.Field2).SubString(0,40)
	}
    if ($docInfo.info.keys.Field3.Length -gt 40)
	{
        $messages += "Field3 greater than 40 - Trimmed to 40. Orig [$($docInfo.info.keys.Field3)]. "
        $docInfo.info.keys.Field3 = ($docInfo.info.keys.Field3).Substring(0,40)
	}
    if ($docInfo.info.keys.Field4.Length -gt 40)
	{
        $messages += "Field4 greater than 40 - Trimmed to 40. Orig [$($docInfo.info.keys.Field4)]. "
        $docInfo.info.keys.Field4 = ($docInfo.info.keys.Field4).Substring(0,40)
	}
    if ($docInfo.info.keys.Field5.Length -gt 40)
	{
        $messages += "Field5 greater than 40 - Trimmed to 40. Orig [$($docInfo.info.keys.Field5)]. "
        $docInfo.info.keys.Field5 = ($docInfo.info.keys.Field5).Substring(0,40)
	}
    return [PSCustomObject]@{
        status = $status
        messages = $messages
        docInfo = $docInfo
    }
}

function Add-PerceptiveContentStyleLog_202306 {
    param (
        $debugLevel,####similar to iScript STL DEBUG_LEVEL. 0-5. This will only write out logs when the logLevel is at or below this threshold
        $logLevel,####log level for this particlar message
        $message,
        $destFilePath
    )
    ##0 = CRITICAL - severe, cannot continue    [CRITICAL]
    ##1 = ERROR - major error                   [  ERROR ]
    ##2 = WARNING - possible error              [ WARNING]
    ##3 = NOTIFY - possible warning             [ NOTIFY ]
    ##4 = INFO - informational                  [  INFO  ] 
    ##5 = DEBUG - verbose debugging             [  DEBUG ]
    switch ($debugLevel) {
        {($_ -eq "CRITICAL")-or ($_ -eq 0)} {$debugLevelAdjusted = 0; $debugLevelText = "CRITICAL";}
        {($_ -eq "ERROR")   -or ($_ -eq 1)} {$debugLevelAdjusted = 1; $debugLevelText = "ERROR";}
        {($_ -eq "WARNING") -or ($_ -eq 2)} {$debugLevelAdjusted = 2; $debugLevelText = "WARNING";}
        {($_ -eq "NOTIFY")  -or ($_ -eq 3)} {$debugLevelAdjusted = 3; $debugLevelText = "NOTIFY";}
        {($_ -eq "INFO")    -or ($_ -eq 4)} {$debugLevelAdjusted = 4; $debugLevelText = "INFO";}
        {($_ -eq "DEBUG")   -or ($_ -eq 5)} {$debugLevelAdjusted = 5; $debugLevelText = "DEBUG";}
        Default {$debugLevelText = "NOTIFY";$debugLevelAdjusted=3;}
    }
    switch ($logLevel) {
        {($_ -eq "CRITICAL")-or ($_ -eq 0)} {$logLevelAdjusted = 0; $levelText = "[CRITICAL]";}
        {($_ -eq "ERROR")   -or ($_ -eq 1)} {$logLevelAdjusted = 1; $levelText = "[  ERROR ]";}
        {($_ -eq "WARNING") -or ($_ -eq 2)} {$logLevelAdjusted = 2; $levelText = "[ WARNING]";}
        {($_ -eq "NOTIFY")  -or ($_ -eq 3)} {$logLevelAdjusted = 3; $levelText = "[ NOTIFY ]";}
        {($_ -eq "INFO")    -or ($_ -eq 4)} {$logLevelAdjusted = 4; $levelText = "[  INFO  ]";}
        {($_ -eq "DEBUG")   -or ($_ -eq 5)} {$logLevelAdjusted = 5; $levelText = "[  DEBUG ]";}
        Default {$levelText = "[ NOTIFY ]";$logLevelAdjusted=3;}
    }
    $tryCount = 0;$writeSuccess=$true
    $dataToWrite = "$((Get-Date).ToString()) $($levelText) $($message)"
    if ($logLevelAdjusted -le $debugLevelAdjusted)
    {
        do
        {
            try
            {
                $dataToWrite | Out-File $destFilePath -Append -Encoding utf8 -ErrorAction "Stop"
                $writeSuccess=$true
            }
            catch
            {
                if ($tryCount -eq 2)
                {
                    Write-Error -Message "Error writing to log file. Adding To Orphaned Logs. $($dataToWrite)"
                    $dataToWrite | Out-File "$(Split-Path -Path $destFilePath -Parent)\Orphan.log" -Append -Encoding utf8 -ErrorAction "Stop"
                }
                $tryCount++
                $writeSuccess=$false
            }
        }
        while ($writeSuccess -eq $false -and $tryCount -lt 2)
    }
}


function convertToEpochTime{
	param (
        $inputDate
	)
    ####perceptive only accepts what SQL Server datetime accepts, which is from January 1, 1753, through December 31, 9999
    ####based on the iScript STL, they only accept years with 18, 19, 20, 21. So between 1800 and 2100 is good.
    ##$inputDate = "0153-01-01"
    $date2 = Get-Date($inputDate)
    $startDate = Get-Date -Year 1800 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
    $endDate = Get-Date -Year 2100 -Month 12 -Day 31 -Hour 23 -Minute 59 -Second 59
    if ($date2 -lt $startDate -or $date2 -gt $endDate) {
        # If the date is outside the range, default to January 1, 1970
        $date2 = Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
    }
	$date1 = Get-Date -Date "01/01/1970"
	[Int64]$returnDate = (New-TimeSpan -Start $date1 -End $date2).TotalMilliseconds
	##Write-Verbose $inputDate
	return $returnDate
}

function convertFromEpoch {
    param (
        $inputEpoch
    )
    Get-Date -Date ((Get-Date -Date "01-01-1970") + ([System.TimeSpan]::FromMilliseconds($inputEpoch))) -UFormat %Y-%m-%d
}
function convertFromEpochDuration {
    param (
        $inputEpoch
    )
    [System.TimeSpan]::FromMilliseconds($inputEpoch)
}
