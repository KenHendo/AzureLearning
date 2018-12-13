Function Publish-KHAzureRunbook {
    
    # DONE Check whether runbook already exists
    # DONE Create new runbook if it doesn't exist
    # DONE import runbook code to new runbook if blank
    # DONE Import runbook code to new runbook if -force switch is used
    # output success or failure status

    [CmdletBinding()]
    Param(
        
        # The name of the Resoure Group that contains the runbook and Azure automation account
        [Parameter( Mandatory = $true,
            Position = 0)]
        [String]
        $ResourceGroupName,

        # The name of the automation account that will contain the runbook
        [Parameter( Mandatory = $true,
            Position = 1)]
        [string]
        $AutomationAccountName,

        # Name of the Runbook
        [Parameter( Mandatory = $true,
            Position = 2)]
        [string]
        $name,

        # Path to the folder containing the ps1 file that contains the code for the new runbook
        [Parameter( Mandatory = $true,
            Position = 3)]
        [string]
        $Path,

        # If an existing runbook is found with the selected name, the 'Force' switch will overwrite the existing runbook code with the code 
        # from the ps1 file referenced via the 'path' parameter.
        [Parameter()]
        [switch]
        $Force
    )


    $RBExists = $null

    $Params = @{
        ResourceGroupName     = $ResourceGroupName;
        AutomationAccountName = $AutomationAccountName;
        Name                  = $Name
    }


    $RBExists = Test-KHAzureRunbook @Params
    write-verbose "Testing whether runbook already exists."

    If ($RBExists) {

        Switch ($PSBoundParameters.ContainsKey('Force')) {

            True {
                write-verbose "Runbook exists and -force switch has been selected: overwrite code content of the existing Runbook"
                
                $params += @{
                    type = 'PowerShell'
                    path = $Path
                    force = $true
                }
                
                Import-AzureRmAutomationRunbook @params
            }
            
            False {
                Write-Verbose "Runbook exists and -force switch has not been selected: do not modify the existing Runbook"
                Write-Warning "Runbook $name already exists.  Use the -force parameter if you want to overwrite the existing runbook code."
            }
        }
    }
    
    Else {
        Write-Verbose "Creating new RunBook: $name"
        New-AzureRMAutomationRunbook @params
        
        $params += @{
            type = 'PowerShell'
            path = $path
        }
        
        Write-Verbose "Importing runbook code from $path to $name"
        Import-AzureRmAutomationRunbook @params
    }
}

Function Test-KHAzureRunbook {
    #Verifies whether a given Azure Runbook exists

    [CmdletBinding()]
    Param(

        [Parameter(Mandatory = $true)]
        [String]
        $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]
        $AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [string]
        $name

    )

    Try {
        $Runbook = Get-AzureRmAutomationRunbook -ResourceGroupName $RGName -AutomationAccountName $automationAcctName -Name $name -ErrorAction SilentlyContinue
    }

    Catch {}

    If ($Runbook) {
        Write-Verbose "Runbook Found: $name"
        Return $true
    }

    Else {
        Write-Verbose "Runbook Not Found: $name"
        Return $False
    }
}
