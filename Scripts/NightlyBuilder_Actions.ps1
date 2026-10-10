#Requires -Version 5.1
<#
.SYNOPSIS
    LegendUtil Nightly ビルドスクリプト (GitHub Actions 用・PowerShell 版)

.DESCRIPTION
    Scripts/NightlyBuilder_Actions.rdr (プロデル) を PowerShell へ移行した
    GitHub Actions 用のナイトリービルドスクリプトです。
    dev ブランチのソースをビルドフォルダーへコピーしてコンパイルし、
    成果物を Zip にまとめて releases/nightly ブランチへプッシュ、
    最後に Releases API へビルドを登録します。

.PARAMETER ApiKey
    Releases API へ登録する際の API キー。

.PARAMETER DisablePushToRepo
    成果物を releases/nightly ブランチへプッシュしない。

.PARAMETER DisableRegisterToAPI
    ビルドを Releases API へ登録しない。

.PARAMETER ApiUrl
    Releases API の URL。

.PARAMETER ProduireCompilerPath
    プロデルコンパイラー (rdrc.exe) のパス。

.EXAMPLE
    Scripts\NightlyBuilder_Actions.ps1 -ApiKey xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#>

param(
    [string]$ApiKey = '',
    [switch]$DisablePushToRepo,
    [switch]$DisableRegisterToAPI,
    [string]$ApiUrl = 'https://api-legendutil.femtoCommunity.com/releases',
    [string]$ProduireCompilerPath = '\rdr\rdrc.exe'
)

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion.Major -ge 7) {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}

#============================================================
# 共通関数
#============================================================

# タイムスタンプ付きのログ出力
function Write-Log([string]$Message) {
    Write-Host ("[{0}] {1}" -f (Get-Date -Format 'yyyy/MM/dd HH:mm:ss'), $Message)
}

# 素のテキスト出力
function Write-Plain([string]$Message = '') {
    Write-Host $Message
}

# UTF-8 (BOM 無し) でのテキスト読み書き
function Read-TextFile([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}
function Write-TextFile([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

# 外部コマンドを実行し、出力をコンソールへ流して終了コードを返す
function Invoke-ExternalCommand([string]$FilePath, [string[]]$ArgumentList = @(), [string]$WorkingDirectory = '') {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $pushed = $false
    try {
        if ($WorkingDirectory -ne '') {
            Push-Location -LiteralPath $WorkingDirectory
            $pushed = $true
        }
        & $FilePath @ArgumentList | Out-Host
        return $LASTEXITCODE
    }
    finally {
        if ($pushed) { Pop-Location }
        $ErrorActionPreference = $previous
    }
}

# 外部コマンドを実行し、標準出力を返す (標準エラーはコンソールへ表示)
function Invoke-NativeCapture([string]$FilePath, [string[]]$ArgumentList = @()) {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $FilePath @ArgumentList
    }
    finally {
        $ErrorActionPreference = $previous
    }
}

# git コマンドを実行し、終了コードを返す
function Invoke-GitCommand([string]$WorkingDirectory, [string[]]$GitArgs) {
    Write-Host ("> git " + ($GitArgs -join ' '))
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & git -C $WorkingDirectory @GitArgs | Out-Host
        return $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previous
    }
}

# HTTP 要求を実行し、ステータスコードと本文を返す
function Invoke-WebRequestSafe {
    param(
        [string]$Uri,
        [string]$Method = 'GET',
        [hashtable]$Headers = @{},
        [string]$Body = ''
    )
    try {
        $parameters = @{
            Uri              = $Uri
            Method           = $Method
            Headers          = $Headers
            UseBasicParsing  = $true
        }
        if ($Body -ne '') {
            $parameters['Body'] = [System.Text.Encoding]::UTF8.GetBytes($Body)
            $parameters['ContentType'] = 'application/json'
        }
        $response = Invoke-WebRequest @parameters
        return @{ StatusCode = [int]$response.StatusCode; Content = [string]$response.Content }
    }
    catch {
        $statusCode = 0
        $content = ''
        $webResponse = $_.Exception.Response
        try {
            if ($null -ne $webResponse) {
                try { $statusCode = [int]$webResponse.StatusCode } catch { }
                $stream = $null
                try { $stream = $webResponse.GetResponseStream() } catch { }
                if ($null -ne $stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $content = $reader.ReadToEnd()
                    $reader.Dispose()
                }
            }
            if ($content -eq '' -and $_.ErrorDetails -and $_.ErrorDetails.Message) {
                $content = [string]$_.ErrorDetails.Message
            }
        }
        catch { }
        return @{ StatusCode = $statusCode; Content = $content }
    }
}

# JSON の文字列値を置換する (最初の一致のみ)
function Set-JsonStringValue([string]$Text, [string]$Key, [string]$Value) {
    $regex = New-Object System.Text.RegularExpressions.Regex(('("{0}"\s*:\s*")[^"]*(")' -f [regex]::Escape($Key)))
    return $regex.Replace($Text, ('${1}' + $Value + '${2}'), 1)
}

# プロデルプロジェクトのアイコンパスを置換する
function Set-ProjectIcon([string]$Text, [string]$IconPath) {
    $regex = New-Object System.Text.RegularExpressions.Regex('(<項目\s+名前="アイコン"\s+値=")[^"]*(")')
    return $regex.Replace($Text, ('${1}' + $IconPath + '${2}'), 1)
}

#============================================================
# メイン処理
#============================================================

try {
    if (-not $env:GITHUB_WORKSPACE) { throw 'GITHUB_WORKSPACE 環境変数が設定されていません。' }
    if (-not $env:RUNNER_TEMP) { throw 'RUNNER_TEMP 環境変数が設定されていません。' }

    # ソースフォルダー (dev ブランチ)
    $sourceFolder = Join-Path $env:GITHUB_WORKSPACE 'Source'
    # リリースフォルダー (releases/nightly ブランチ)
    $releaseFolder = Join-Path $env:GITHUB_WORKSPACE 'Releases'
    # ビルド用一時フォルダー
    $buildFolder = (New-Item -ItemType Directory -Path (Join-Path $env:RUNNER_TEMP 'BuildTemp') -Force).FullName
    # ビルド成果フォルダー
    $artifactFolder = (New-Item -ItemType Directory -Path (Join-Path $env:RUNNER_TEMP 'Build') -Force).FullName

    Write-Plain 'フォルダー情報'
    Write-Plain "- ソースフォルダー: $sourceFolder"
    Write-Plain "- ビルドフォルダー: $buildFolder"
    Write-Plain "- 　成果フォルダー: $artifactFolder"
    Write-Plain ''

    # ビルド用一時フォルダーへソースをコピーする
    Copy-Item -Path (Join-Path $sourceFolder '*') -Destination $buildFolder -Recurse -Force

    # 現在のコミットのハッシュを取得する
    $commitHash = ''
    $hashLines = @(Invoke-NativeCapture -FilePath 'git' -ArgumentList @('-C', $sourceFolder, 'show', '--format=%h', '--no-patch'))
    foreach ($line in $hashLines) {
        $trimmed = ([string]$line).Trim()
        if ($trimmed -ne '') { $commitHash = $trimmed; break }
    }
    Write-TextFile (Join-Path $buildFolder 'CommitHash.txt') $commitHash

    # コミット情報を取得する
    $commitInfo = (@(Invoke-NativeCapture -FilePath 'git' -ArgumentList @('-C', $sourceFolder, 'show', '--no-patch', '--notes', '--date=iso')) -join "`n")
    Write-TextFile (Join-Path $buildFolder 'CommitInfo.txt') $commitInfo

    # ビルド情報を編集 (Build.json)
    Write-Log 'ビルド情報を編集'
    $buildJsonPath = Join-Path $buildFolder 'Build.json'
    Write-TextFile $buildJsonPath (Set-JsonStringValue (Read-TextFile $buildJsonPath) 'ReleaseChannel' 'nightly')

    # バージョン情報の編集
    $projectPath = Join-Path $buildFolder 'LegendUtil.rdrproj'
    $xml = New-Object System.Xml.XmlDocument
    $xml.Load($projectPath)
    $versionParts = @($xml.SelectSingleNode('/プロジェクト/バージョン').GetAttribute('値').Split('.'))
    $version = "$($versionParts[0]).$($versionParts[1]).$($versionParts[2])"
    $buildVersion = "$(Get-Date -Format 'yyyyMMdd.HHmmss').4" # 4=Nightly
    $internalNumber = "{0}{1}{2}" -f $versionParts[0], $versionParts[1].PadLeft(2, '0'), $versionParts[2].PadLeft(2, '0')
    $internalVersion = "$internalNumber.$($buildVersion -replace '\.', '')"

    # 実行ファイルのアイコンを変更
    Write-TextFile $projectPath (Set-ProjectIcon (Read-TextFile $projectPath) 'Resources\Logo\LegendUtil_Nightly_Icon.ico')

    # ビルドバージョンをファイルへ保存
    Write-TextFile (Join-Path $buildFolder 'BuildVersion.txt') $buildVersion
    Write-Plain ''

    # ソースコードをコンパイル
    Write-Log 'ソースコードをコンパイル'
    $compileExitCode = Invoke-ExternalCommand -FilePath $ProduireCompilerPath -ArgumentList @($projectPath) -WorkingDirectory $buildFolder
    if ($compileExitCode -ne 0) {
        throw "ソースコードのコンパイルに失敗しました - 戻り値: $compileExitCode"
    }

    # 生成されたファイルを移動
    $packAppFolder = Join-Path $buildFolder '_Pack\LegendUtil'
    $packedExe = Join-Path $packAppFolder 'LegendUtil.exe'
    if (Test-Path -LiteralPath $packedExe) { Remove-Item -LiteralPath $packedExe -Force }
    Move-Item -LiteralPath (Join-Path $buildFolder 'LegendUtil.exe') -Destination $packedExe -Force

    Remove-Item -Path (Join-Path $packAppFolder '*.dll') -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path (Join-Path $buildFolder '*.dll') -File -ErrorAction SilentlyContinue |
        Move-Item -Destination $packAppFolder -Force
    Write-Plain ''

    # 成果物を圧縮
    Write-Log '成果物を圧縮'
    Remove-Item -Path (Join-Path $artifactFolder 'LegendUtil_v*-nightly.*.zip') -Force -ErrorAction SilentlyContinue
    $zipName = "LegendUtil_v$version-nightly.$commitHash.zip"
    $zipPath = Join-Path $artifactFolder $zipName
    if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
    Compress-Archive -Path (Join-Path $packAppFolder '*') -DestinationPath $zipPath -CompressionLevel Optimal -Force
    Write-Plain ''

    # 成果物をリポジトリーへプッシュ
    if (-not $DisablePushToRepo) {
        Write-Log '成果物をリポジトリーへプッシュ'
        $targetZip = Join-Path $releaseFolder 'Pack\LegendUtil_nightly_latest.zip'
        Copy-Item -LiteralPath $zipPath -Destination $targetZip -Force

        $checkoutCode = Invoke-GitCommand -WorkingDirectory $releaseFolder -GitArgs @('checkout', 'releases/nightly')
        $null = Invoke-GitCommand -WorkingDirectory $releaseFolder -GitArgs @('add', $targetZip)
        # 差分が無い場合 (再実行時など) はコミットできないため、終了コードは確認しない
        $null = Invoke-GitCommand -WorkingDirectory $releaseFolder -GitArgs @('commit', '-m', "Version $version-nightly.$commitHash")
        $pushCode = Invoke-GitCommand -WorkingDirectory $releaseFolder -GitArgs @('push', 'origin', 'releases/nightly')

        if ($checkoutCode -ne 0 -or $pushCode -ne 0) {
            throw "成果物のプッシュに失敗しました (checkout: $checkoutCode, push: $pushCode)"
        }
        Write-Plain ''
    }

    # ビルドを API へ登録
    if (-not $DisableRegisterToAPI) {
        Write-Log 'ビルドをAPIへ登録'
        $payload = [ordered]@{
            version                = $version
            internal_version       = $internalVersion
            release_channel        = 'nightly'
            build_version          = ".$commitHash"
            installer_download_url = 'https://github.com/femtoCommunity/LegendUtil/raw/releases/nightly/Setup/LegendUtil_Setup.exe'
            installer_file_name    = 'LegendUtil_Setup.exe'
            changelog              = $commitInfo
        }
        $payloadJson = $payload | ConvertTo-Json -Depth 5
        $registerResponse = Invoke-WebRequestSafe -Uri "$ApiUrl/register/latest?release_channel=nightly" -Method POST -Headers @{ 'Api-Key' = $ApiKey } -Body $payloadJson

        if ($registerResponse.StatusCode -eq 200) {
            Write-Plain "- ビルド登録成功: $($registerResponse.StatusCode)"
        }
        else {
            Write-Plain "- ビルド登録失敗: $($registerResponse.StatusCode)"
            throw "ビルド登録失敗: $($registerResponse.StatusCode)"
        }
        Write-Plain "$($registerResponse.Content)"
        Write-Plain ''
    }

    Write-Log '処理終了'
    Write-Plain ''
    exit 0
}
catch {
    Write-Log '======================================='
    Write-Log "処理に失敗しました。`n`n$($_.Exception.Message)"
    Write-Log '======================================'
    exit 1
}
