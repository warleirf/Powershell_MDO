# =========================================
# Exchange Online + Defender Health Check
# Autor: SOC Quick Test
# =========================================

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Exchange Online / Defender Health Check " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

function Test-Command {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    try {
        $null = & $Command
        Write-Host "[OK ] $Name" -ForegroundColor Green
    }
    catch {
        Write-Host "[FAIL] $Name" -ForegroundColor Red
    }
}

# -----------------------------------------
Write-Host "Tenant info:" -ForegroundColor Yellow

try {
    $org = Get-OrganizationConfig
    Write-Host "Conectado ao tenant:" $org.Name -ForegroundColor Green
}
catch {
    Write-Host "NAO CONECTADO! Rode Connect-ExchangeOnline primeiro." -ForegroundColor Red
    break
}

Write-Host ""
Write-Host "Testando permissoes..." -ForegroundColor Yellow
Write-Host ""

# -----------------------------------------
# TESTES
# -----------------------------------------

Test-Command "Accepted Domains" {
    Get-AcceptedDomain | Out-Null
}

Test-Command "Listar Mailboxes (Exchange)" {
    Get-EXOMailbox -ResultSize 1 | Out-Null
}

Test-Command "Tenant Allow/Block List (URLs)" {
    Get-TenantAllowBlockListItems -ListType Url -Block | Out-Null
}

Test-Command "Safe Links Policy" {
    Get-SafeLinksPolicy | Out-Null
}

Test-Command "Anti-Phish Policy" {
    Get-AntiPhishPolicy | Out-Null
}

Test-Command "Safe Attachments Policy" {
    Get-SafeAttachmentPolicy | Out-Null
}

Test-Command "Message Trace" {
    Get-MessageTrace -StartDate (Get-Date).AddHours(-1) -EndDate (Get-Date) | Out-Null
}

Test-Command "Quarantine Access" {
    Get-QuarantineMessage -PageSize 1 | Out-Null
}

# -----------------------------------------

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Teste finalizado" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
