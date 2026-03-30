# Caminho do arquivo de entrada e saída
$inputFile = "C:\urls\urls.csv"
$logFile   = "C:\urls\log_resultados.csv"

# Lê e normaliza as URLs
$raw = Get-Content $inputFile
$urls = $raw |
    ForEach-Object {
        $_.Trim().ToLower() `
        -replace '^https?://','' `
        -replace '^www\.','' `
        -replace '/.*',''
    } |
    Where-Object {
        $_ -and ($_ -notmatch '^\d+\.\d+\.\d+\.\d+$')
    } |
    Sort-Object -Unique

Write-Host "Dominos validos encontrados:" $urls.Count

# Pega todos os itens já existentes
$existing = Get-TenantAllowBlockListItems -ListType Url
$existingUrls = $existing.Entries

# Cria lista para log
$log = @()

foreach ($url in $urls) {
    if ($existingUrls -contains $url) {
        Write-Host "Ignorado (ja existe): $url"
        $log += [PSCustomObject]@{URL=$url; Status="Ignorado"}
    }
    else {
        Write-Host "Adicionando: $url"
        try {
            New-TenantAllowBlockListItems -ListType Url -Block -Entries $url -NoExpiration -Notes "Importacao IOC via script"
            $log += [PSCustomObject]@{URL=$url; Status="Adicionado"}
        }
        catch {
            Write-Host "Erro ao adicionar: $url"
            $log += [PSCustomObject]@{URL=$url; Status="Erro"}
        }
    }
}

# Exporta log para CSV
$log | Export-Csv -Path $logFile -NoTypeInformation -Encoding UTF8

Write-Host "Processo concluido. Log salvo em $logFile"
