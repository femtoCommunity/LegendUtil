#Requires -Version 5.1
<#
.SYNOPSIS
    LegendUtil ビルドスクリプト (PowerShell 版)

.DESCRIPTION
    Scripts/_Build.rdr (プロデル) を PowerShell へ移行したビルドスクリプトです。
    リリースチャンネルに応じたバージョン付与、プロデルプロジェクトのコンパイル、
    インストーラーの作成、リリースブランチへの成果物のプッシュと API への登録を行います。

.NOTES
    起動引数:
      /ReleaseChannel <番号>  0: release, 1: beta, 2: dev, 3: dev_stable, 4: nightly
      /MSStore <0|1>          1 のとき Microsoft Store 用のビルドを行う
    未指定の項目は対話形式で確認します。

.EXAMPLE
    Scripts\_Build.ps1
    Scripts\_Build.ps1 /ReleaseChannel 1 /MSStore 1
#>

$ErrorActionPreference = 'Continue'

$ProgramTitle = 'LegendUtil Builder'
$ScriptVersion = '4.0'

# 作業ディレクトリー (スクリプトの親フォルダー)
$WorkDir = Split-Path -Parent $PSScriptRoot

# ソースファイル (プロデルプロジェクト)
$SourceFile = Join-Path $WorkDir 'LegendUtil.rdrproj'
$SourceBaseName = [System.IO.Path]::GetFileNameWithoutExtension($SourceFile)

# 起動引数の解析 (/ReleaseChannel <番号> /MSStore <0|1>)
$script:releaseChannelArg = $null
$script:storeBuildArg = $null
$argList = @($args)
for ($i = 0; $i -lt $argList.Count; $i++) {
    if ($argList[$i] -eq '/ReleaseChannel') {
        if (($i + 1) -lt $argList.Count) { $script:releaseChannelArg = [string]$argList[$i + 1] }
    }
    elseif ($argList[$i] -eq '/MSStore') {
        if (($i + 1) -lt $argList.Count) { $script:storeBuildArg = [string]$argList[$i + 1] }
    }
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

# プロンプトを表示して入力を受け取る
function Read-Input([string]$Prompt) {
    Write-Host -NoNewline $Prompt
    return Read-Host
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

#============================================================
# コンフィグ (BuilderConfig.ini)
#============================================================

# INI ファイルを読み込み、セクション名とキーのハッシュテーブルを返す
function Read-ConfigFile([string]$Path) {
    $result = @{}
    if (-not (Test-Path -LiteralPath $Path)) { return $result }
    $section = ''
    foreach ($line in [System.IO.File]::ReadAllLines($Path, [System.Text.Encoding]::UTF8)) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\[(.+)\]$') {
            $section = $Matches[1]
            continue
        }
        if ($trimmed -match '^([^=]+)=(.*)$') {
            $key = $Matches[1].Trim()
            if (-not $result.ContainsKey($section)) { $result[$section] = @{} }
            $result[$section][$key] = $Matches[2].Trim()
        }
    }
    return $result
}

# コンフィグ値を取得する (存在しない場合は既定値を返す)
function Get-ConfigValue([string]$Section, [string]$Key, [string]$Default = '') {
    $config = Read-ConfigFile (Join-Path $WorkDir 'BuilderConfig.ini')
    if ($config.ContainsKey($Section) -and ($config[$Section]).ContainsKey($Key)) {
        return $config[$Section][$Key]
    }
    return $Default
}

# コンフィグをチェックし、不足しているキーを追記する
function Update-ConfigFile([string]$Path, [hashtable]$Defaults) {
    $lines = New-Object System.Collections.Generic.List[string]
    if (Test-Path -LiteralPath $Path) {
        foreach ($line in [System.IO.File]::ReadAllLines($Path, [System.Text.Encoding]::UTF8)) {
            $lines.Add($line)
        }
    }

    $existing = Read-ConfigFile $Path

    foreach ($section in $Defaults.Keys) {
        # セクションの範囲を求める
        $sectionStart = -1
        $sectionEnd = $lines.Count
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $trimmed = $lines[$i].Trim()
            if ($sectionStart -lt 0 -and $trimmed -eq "[$section]") {
                $sectionStart = $i
                continue
            }
            if ($sectionStart -ge 0 -and $trimmed.StartsWith('[')) {
                $sectionEnd = $i
                break
            }
        }

        if ($sectionStart -lt 0) {
            # セクションが無ければ末尾へ追加する
            if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -ne '') { $lines.Add('') }
            $lines.Add("[$section]")
            $sectionStart = $lines.Count - 1
            $sectionEnd = $lines.Count
        }

        $insertAt = $sectionEnd
        foreach ($key in $Defaults[$section].Keys) {
            $hasKey = ($existing.ContainsKey($section) -and ($existing[$section]).ContainsKey($key))
            if (-not $hasKey) {
                $lines.Insert($insertAt, ("{0}={1}" -f $key, $Defaults[$section][$key]))
                $insertAt++
            }
        }
    }

    Write-TextFile $Path (($lines -join "`r`n") + "`r`n")
}

#============================================================
# プロジェクト・アプリ情報
#============================================================

# プロデルプロジェクトから名前とバージョンを取得する
function Get-ProjectInfo {
    $xml = New-Object System.Xml.XmlDocument
    $xml.Load($SourceFile)
    return @{
        Name         = $xml.SelectSingleNode('/プロジェクト').GetAttribute('名前')
        VersionParts = @($xml.SelectSingleNode('/プロジェクト/バージョン').GetAttribute('値').Split('.'))
    }
}

# アプリ情報 (バージョン・内部バージョン・リリース番号・チャンネル) を組み立てる
function Get-AppInfo([string]$ReleaseChannel) {
    $projectInfo = Get-ProjectInfo
    $parts = $projectInfo.VersionParts
    $version = "$($parts[0]).$($parts[1]).$($parts[2])"

    $buildVersion = (Read-TextFile (Join-Path $WorkDir 'BuildVersion.txt')) -replace "[\r\n]", ''
    if ($buildVersion.StartsWith('.')) { $buildVersion = $buildVersion.Substring(1) }

    $commitHash = (Read-TextFile (Join-Path $WorkDir 'CommitHash.txt')) -replace "[\r\n]", ''

    if ($ReleaseChannel -like 'dev*') {
        $releaseNumber = $buildVersion
    }
    elseif ($ReleaseChannel -like 'nightly*') {
        $releaseNumber = $commitHash
    }
    else {
        $releaseNumber = [string]$parts[3]
    }

    $internalNumber = "{0}{1}{2}" -f $parts[0], $parts[1].PadLeft(2, '0'), $parts[2].PadLeft(2, '0')
    $internalVersionText = "$internalNumber.$($buildVersion -replace '\.', '')"
    # アプリの内部バージョンは固定小数として扱われるため、先頭ゼロを落とした表記にする
    $internalVersion = [decimal]::Parse($internalVersionText, [System.Globalization.CultureInfo]::InvariantCulture).ToString([System.Globalization.CultureInfo]::InvariantCulture)

    return @{
        Name            = $projectInfo.Name
        Version         = $version
        InternalVersion = $internalVersion
        ReleaseNumber   = $releaseNumber
        Channel         = $ReleaseChannel
    }
}

#============================================================
# ファイル編集 (書式を保つための値の置換)
#============================================================

# JSON の文字列値を置換する (最初の一致のみ)
function Set-JsonStringValue([string]$Text, [string]$Key, [string]$Value) {
    $regex = New-Object System.Text.RegularExpressions.Regex(('("{0}"\s*:\s*")[^"]*(")' -f [regex]::Escape($Key)))
    return $regex.Replace($Text, ('${1}' + $Value + '${2}'), 1)
}

# JSON の真偽値を置換する (最初の一致のみ)
function Set-JsonBoolValue([string]$Text, [string]$Key, [bool]$Value) {
    $boolText = 'false'
    if ($Value) { $boolText = 'true' }
    $regex = New-Object System.Text.RegularExpressions.Regex(('("{0}"\s*:\s*)(true|false)' -f [regex]::Escape($Key)))
    return $regex.Replace($Text, ('${1}' + $boolText), 1)
}

# プロデルプロジェクトのアイコンパスを置換する
function Set-ProjectIcon([string]$Text, [string]$IconPath) {
    $regex = New-Object System.Text.RegularExpressions.Regex('(<項目\s+名前="アイコン"\s+値=")[^"]*(")')
    return $regex.Replace($Text, ('${1}' + $IconPath + '${2}'), 1)
}

# Inno Setup スクリプトの #define 値を置換する
function Set-IssDefine([string]$Text, [string]$Name, [string]$Value) {
    $regex = New-Object System.Text.RegularExpressions.Regex(('(#define\s+{0}\s+")[^"]*(")' -f [regex]::Escape($Name)))
    return $regex.Replace($Text, ('${1}' + $Value + '${2}'), 1)
}

#============================================================
# コンパイル
#============================================================

# ソースファイル (.rdrproj / .iss) をコンパイルする
function Invoke-Compile([string]$File) {
    $extension = [System.IO.Path]::GetExtension($File).TrimStart('.').ToLowerInvariant()

    if ($extension -eq 'rdrproj') {
        Write-Log " $File をコンパイル中"
        $exitCode = Invoke-ExternalCommand -FilePath (Get-ConfigValue 'Main' 'ProduireCompiler_Path') -ArgumentList @($File) -WorkingDirectory $WorkDir
        if ($exitCode -eq 0) {
            Write-Log '- DLLファイルを移動'
            Remove-Item -Path (Join-Path $WorkDir '_Pack\LegendUtil\*.dll') -Force -ErrorAction SilentlyContinue
            Get-ChildItem -Path (Join-Path $WorkDir '*.dll') -File -ErrorAction SilentlyContinue |
                Move-Item -Destination (Join-Path $WorkDir '_Pack\LegendUtil') -Force
            Write-Log "ソースコードのコンパイル完了 - 戻り値: $exitCode"
        }
        else {
            if ($script:sourceCompileAttempts -gt 3) {
                Write-Log "ソースコードのコンパイル失敗 - 戻り値: $exitCode ($($script:sourceCompileAttempts)回目)`n$ProgramTitle を終了します..."
                Start-Sleep -Seconds 3
                exit 1
            }
            else {
                Write-Log "ソースコードのコンパイル失敗 - 戻り値: $exitCode`n1秒後に再試行します..."
                Start-Sleep -Seconds 1
                $script:sourceCompileAttempts++
                Invoke-Compile $File
            }
        }
    }
    elseif ($extension -eq 'iss') {
        Write-Log 'インストーラーをコンパイル中'
        $exitCode = Invoke-ExternalCommand -FilePath (Get-ConfigValue 'Main' 'InstallerCompiler_Path') -ArgumentList @($File) -WorkingDirectory $WorkDir
        if ($exitCode -eq 0) {
            Write-Log "インストーラーのコンパイル完了 - 戻り値: $exitCode"
        }
        else {
            if ($script:installerCompileAttempts -gt 3) {
                Write-Log "インストーラーのコンパイル失敗 - 戻り値: $exitCode ($($script:installerCompileAttempts)回目)`n$ProgramTitle を終了します..."
                Start-Sleep -Seconds 3
                exit 1
            }
            else {
                Write-Log "インストーラーのコンパイル失敗 - 戻り値: $exitCode`n2秒後に再試行します..."
                Start-Sleep -Seconds 2
                $script:installerCompileAttempts++
                Invoke-Compile $File
            }
        }
    }
}

# コンパイルで生成された実行ファイルを _Pack\LegendUtil へ移動する
function Move-BuildOutputs {
    $packFolder = Join-Path $WorkDir '_Pack\LegendUtil'
    $packedExe = Join-Path $packFolder "$SourceBaseName.exe"
    if (Test-Path -LiteralPath $packedExe) {
        Write-Log "実行ファイルを削除 ($packedExe)"
        Remove-Item -LiteralPath $packedExe -Force
    }
    Write-Log "実行ファイルを移動 ($SourceBaseName.exe)"
    Move-Item -LiteralPath (Join-Path $WorkDir "$SourceBaseName.exe") -Destination $packedExe -Force
}

#============================================================
# リリース
#============================================================

# 成果物をリリースブランチへプッシュし、API へ登録する
function Invoke-Release([string]$CommitMessage) {
    if ($null -eq $CommitMessage) { $CommitMessage = '' }

    $releasesBranchFolder = Get-ConfigValue 'Main' 'Dev_Build_Releases_Brunch_Folder'
    if (-not (Test-Path -LiteralPath $releasesBranchFolder -PathType Container)) {
        Write-Log 'リリース処理失敗: フォルダーが見つかりません。'
        return
    }

    $apiKey = Get-ConfigValue 'Main' 'API_Key'
    $apiUrl = Get-ConfigValue 'Main' 'API_URL'
    $channel = $script:releaseChannel

    $releaseName = "$($script:appInfo.Version)-$channel$($script:buildNumber)"
    $releaseFolder = "$($script:releaseParentFolder)$releaseName\"
    $installerFileName = "${SourceBaseName}_Setup.exe"
    $installerSourcePath = Join-Path $WorkDir "_Pack\$installerFileName"
    $installerTargetPath = "$releaseFolder$installerFileName"

    # 最新のリリース情報を取得する
    $latestResponse = Invoke-WebRequestSafe -Uri "$apiUrl/latest?release_channel=$channel" -Headers @{ 'Content-Type' = 'application/json' }

    if ($latestResponse.StatusCode -eq 200) {
        $latest = ($latestResponse.Content | ConvertFrom-Json).data
        Write-Plain '最新リリース'
        Write-Plain "- バージョン: $($latest.version)-$($latest.release_channel)$($latest.build_version)"
        Write-Plain "- 内部バージョン: $($latest.internal_version)"
        Write-Plain '===== 変更履歴 ========================='
        Write-Plain "$($latest.changelog)"
        Write-Plain '========================================'

        # リポジトリーを同期
        Write-Log 'リポジトリーを同期'
        Write-Log "-         ディレクトリー: $releasesBranchFolder"
        Write-Log "- インストーラーファイル: $installerTargetPath"
        Write-Plain ''

        $syncCodes = @(
            (Invoke-GitCommand -WorkingDirectory $releasesBranchFolder -GitArgs @('fetch', 'origin', 'releases/dev')),
            (Invoke-GitCommand -WorkingDirectory $releasesBranchFolder -GitArgs @('checkout', 'releases/dev')),
            (Invoke-GitCommand -WorkingDirectory $releasesBranchFolder -GitArgs @('branch', '--contains')),
            (Invoke-GitCommand -WorkingDirectory $releasesBranchFolder -GitArgs @('pull', 'origin', 'releases/dev'))
        )
        $syncCode = 0
        if (@($syncCodes | Where-Object { $_ -ne 0 }).Count -gt 0) { $syncCode = 1 }

        Write-Plain ''
        Write-Log "終了コード: $syncCode"

        if ($syncCode -ne 0) {
            Write-Log 'リリース処理失敗'
            if (Test-Path -LiteralPath $releaseFolder) { Remove-Item -LiteralPath $releaseFolder -Recurse -Force }
            return
        }
        Write-Plain ''

        # リポジトリーへ成果物をプッシュ
        Write-Log 'リポジトリーへ成果物をプッシュ'
        Write-Plain ''

        try {
            if (-not (Test-Path -LiteralPath $releaseFolder)) {
                Write-Log "フォルダーを作成: $releaseFolder"
                New-Item -ItemType Directory -Path (Join-Path $script:releaseParentFolder $releaseName) -Force | Out-Null
            }
            Write-Log "インストーラーをコピー: $installerTargetPath"
            Copy-Item -LiteralPath $installerSourcePath -Destination $installerTargetPath -Force

            $pushCodes = @(
                (Invoke-GitCommand -WorkingDirectory $releasesBranchFolder -GitArgs @('add', $installerTargetPath)),
                (Invoke-GitCommand -WorkingDirectory $releasesBranchFolder -GitArgs @('commit', '-m', "Version $releaseName", '--', $installerTargetPath)),
                (Invoke-GitCommand -WorkingDirectory $releasesBranchFolder -GitArgs @('push', 'origin', 'releases/dev'))
            )
            $pushCode = 0
            if (@($pushCodes | Where-Object { $_ -ne 0 }).Count -gt 0) { $pushCode = 1 }

            Write-Plain ''
            Write-Log "終了コード: $pushCode"

            if ($pushCode -ne 0) {
                Write-Log 'リリース処理失敗'
                if (Test-Path -LiteralPath $releaseFolder) { Remove-Item -LiteralPath $releaseFolder -Recurse -Force }
                return
            }
            Write-Log '完了'
        }
        catch {
            Write-Log "リリース処理失敗: $($_.Exception.Message)"
            if (Test-Path -LiteralPath $releaseFolder) { Remove-Item -LiteralPath $releaseFolder -Recurse -Force }
            return
        }

        # ビルドを API へ登録
        Write-Log 'ビルドをAPIへ登録'
        $changelog = $CommitMessage.Replace("`r`n", "`n").Replace("`r", "`n").Replace("`n", '\n')
        $payload = [ordered]@{
            version                = [string]$script:appInfo.Version
            internal_version       = [string]$script:appInfo.InternalVersion
            release_channel        = [string]$channel
            build_version          = [string]$script:buildNumber
            installer_download_url = "https://github.com/femtoCommunity/LegendUtil/raw/releases/dev/Pack$($script:uploadFolder)/$releaseName/$installerFileName"
            installer_file_name    = $installerFileName
            changelog              = $changelog
        }
        $payloadJson = $payload | ConvertTo-Json -Depth 5
        $registerResponse = Invoke-WebRequestSafe -Uri "$apiUrl/register/latest?release_channel=$channel" -Method POST -Headers @{ 'Api-Key' = $apiKey } -Body $payloadJson

        if ($registerResponse.StatusCode -eq 200) {
            Write-Plain "- ビルド登録成功: $($registerResponse.StatusCode)"
            Write-Plain "$($registerResponse.Content)"
        }
        else {
            Write-Plain "- ビルド登録失敗: $($registerResponse.StatusCode)"
            if (Test-Path -LiteralPath $releaseFolder) { Remove-Item -LiteralPath $releaseFolder -Recurse -Force }
            return
        }
    }
    else {
        # 正常に取得できなかった場合はフォルダーを削除する
        Write-Plain 'リリース情報取得失敗'
        Write-Plain "- ステータスコード: $($latestResponse.StatusCode)"
        $detail = ''
        try { $detail = ($latestResponse.Content | ConvertFrom-Json).detail } catch { }
        Write-Plain "- 詳細: $detail"
        if (Test-Path -LiteralPath $releaseFolder) { Remove-Item -LiteralPath $releaseFolder -Recurse -Force }
    }
}

#============================================================
# ビルド本体
#============================================================

function Invoke-BuildProcess {
    Write-Log "ビルド開始`n"

    # 現在のコミットのハッシュを取得する
    $commitHash = ''
    $hashLines = @(Invoke-NativeCapture -FilePath 'git' -ArgumentList @('-C', $WorkDir, 'show', '--format=%h', '--no-patch'))
    foreach ($line in $hashLines) {
        $trimmed = ([string]$line).Trim()
        if ($trimmed -ne '') { $commitHash = $trimmed; break }
    }
    Write-TextFile (Join-Path $WorkDir 'CommitHash.txt') $commitHash
    Write-Log "コミットハッシュ: $commitHash`n"

    # リリースチャンネル一覧
    $releaseChannels = [ordered]@{
        '0' = 'release'
        '1' = 'beta'
        '2' = 'dev'
        '3' = 'dev_stable'
        '4' = 'nightly'
    }

    $channelListText = ''
    foreach ($channelKey in $releaseChannels.Keys) {
        $channelListText = $channelListText + (" {0}: {1}`n" -f $channelKey, $releaseChannels[$channelKey])
    }

    # リリースチャンネルの選択
    if ($null -ne $script:releaseChannelArg) {
        $channelNumber = $script:releaseChannelArg.Trim()
    }
    else {
        $channelNumber = (Read-Input ("リリースチャンネルを選択してください`n{0}選択肢: " -f $channelListText)).Trim()
    }
    if (-not $releaseChannels.Contains($channelNumber)) { $channelNumber = '0' }
    $script:releaseChannel = [string]$releaseChannels[$channelNumber]

    # Microsoft Store 用ビルドの確認
    if ($null -ne $script:storeBuildArg) {
        $script:storeBuild = ($script:storeBuildArg -ne '0')
    }
    else {
        $script:storeBuild = ((Read-Input 'Microsoft Store 用のビルドを行いますか？ (y/n): ').Trim() -eq 'y')
    }

    # ビルド情報を編集 (Build.json)
    Write-Log 'ビルド情報を編集'
    $script:buildJsonText = Read-TextFile (Join-Path $WorkDir 'Build.json')
    $script:buildJsonText = Set-JsonStringValue $script:buildJsonText 'ReleaseChannel' $script:releaseChannel

    # チャンネルごとのバージョン・アイコン・インストーラーの決定
    $projectInfo = Get-ProjectInfo
    $projectName = $projectInfo.Name
    $versionParts = $projectInfo.VersionParts

    $script:buildDateTime = Get-Date -Format 'yyyyMMdd.HHmmss'
    $script:buildNumber = '0'
    $script:appDisplayName = $projectName
    $script:installerSourceFile = ''
    $script:uploadFolder = ''
    $script:releaseParentFolder = ''

    $devReleasesBranchFolder = Get-ConfigValue 'Main' 'Dev_Build_Releases_Brunch_Folder'
    $iconPath = 'Resources\Logo\LegendUtil_Icon.ico'

    if ($script:releaseChannel -eq 'beta') {
        $script:buildDateTime = "$($script:buildDateTime).1"
        $script:buildNumber = [string]$versionParts[3]
        $script:installerSourceFile = Join-Path $WorkDir 'Source\_Setup\LegendUtil_Setup.iss'
    }
    elseif ($script:releaseChannel -like 'dev*') {
        $script:appDisplayName = "$projectName Dev Build"
        $script:installerSourceFile = Join-Path $WorkDir 'Source\_Setup\LegendUtil_Setup_Dev.iss'
        $iconPath = 'Resources\Logo\LegendUtil_Dev_Icon.ico'
        if ($script:releaseChannel -like '*_stable') {
            $script:buildDateTime = "$($script:buildDateTime).3"
            $script:uploadFolder = '/Stable'
            $script:releaseParentFolder = "$devReleasesBranchFolder\Pack\Stable\"
        }
        else {
            $script:buildDateTime = "$($script:buildDateTime).2"
            $script:uploadFolder = ''
            $script:releaseParentFolder = "$devReleasesBranchFolder\Pack\"
        }
        $script:buildNumber = $script:buildDateTime
    }
    elseif ($script:releaseChannel -like 'nightly*') {
        $script:appDisplayName = "$projectName Nightly Build"
        $script:buildDateTime = "$($script:buildDateTime).4"
        $script:installerSourceFile = Join-Path $WorkDir 'Source\_Setup\LegendUtil_Setup_Nightly.iss'
        $iconPath = 'Resources\Logo\LegendUtil_Nightly_Icon.ico'
    }
    else {
        $script:buildDateTime = "$($script:buildDateTime).0"
        $script:buildNumber = ''
        $script:installerSourceFile = Join-Path $WorkDir 'Source\_Setup\LegendUtil_Setup.iss'
    }

    if ($script:buildNumber -ne '' -and -not $script:buildNumber.StartsWith('.')) {
        $script:buildNumber = '.' + $script:buildNumber
    }

    # ビルドバージョンをファイルへ保存
    Write-TextFile (Join-Path $WorkDir 'BuildVersion.txt') $script:buildDateTime

    # プロジェクトファイルのアイコン変更と保存
    $projectText = Set-ProjectIcon (Read-TextFile $SourceFile) $iconPath
    Write-TextFile $SourceFile $projectText

    # Build.json の保存
    Write-TextFile (Join-Path $WorkDir 'Build.json') $script:buildJsonText

    # アプリ情報の更新
    $script:appInfo = Get-AppInfo $script:releaseChannel
    Write-Log "リリースチャンネル: $($script:appInfo.Channel)"

    # インストーラーのバージョン情報を更新
    Write-Log 'インストーラーのバージョン情報を更新'
    $issVariables = [ordered]@{
        'MyAppName'           = $script:appDisplayName
        'MyAppVersion'        = [string]$script:appInfo.Version
        'MyAppReleaseChannel' = [string]$script:releaseChannel
        'MyAppReleaseNumber'  = [string]$script:appInfo.ReleaseNumber
        'MyAppVersionText'    = "$($script:appInfo.Version)-$($script:releaseChannel)$($script:buildNumber)"
    }
    $issText = Read-TextFile $script:installerSourceFile
    foreach ($variableName in $issVariables.Keys) {
        $issText = Set-IssDefine $issText $variableName ([string]$issVariables[$variableName])
    }
    Write-TextFile $script:installerSourceFile $issText

    # //// MSStore ////
    if ($script:storeBuild) {
        # Build.json の編集 (MSStore.Release = ○)
        $script:buildJsonText = Set-JsonBoolValue $script:buildJsonText 'Release' $true
        Write-TextFile (Join-Path $WorkDir 'Build.json') $script:buildJsonText

        # ソースのコンパイル
        Invoke-Compile $SourceFile
        Move-BuildOutputs

        Start-Sleep -Milliseconds 100

        # インストーラーのコンパイル
        Invoke-Compile $script:installerSourceFile

        # ストアビルドの場合はインストーラーのファイル名を変更する
        $storeSetupName = "${SourceBaseName}_Setup_v$($script:appInfo.InternalVersion)_MSStore.exe"
        Write-Log "インストーラーをリネーム ($storeSetupName)"
        Rename-Item -LiteralPath (Join-Path $WorkDir "_Pack\${SourceBaseName}_Setup.exe") -NewName $storeSetupName -Force
    }
    # //// MSStore ////

    # //// ISS ////
    # Build.json の編集 (MSStore.Release = ×)
    $script:buildJsonText = Set-JsonBoolValue $script:buildJsonText 'Release' $false
    Write-TextFile (Join-Path $WorkDir 'Build.json') $script:buildJsonText

    # ソースのコンパイル
    Invoke-Compile $SourceFile
    Move-BuildOutputs

    Start-Sleep -Milliseconds 100

    # インストーラーのコンパイル
    Invoke-Compile $script:installerSourceFile
    # //// ISS ////

    Write-Log "Build Version: $($script:buildDateTime) ($($script:buildDateTime -replace '\.', ''))"
    try { Set-Clipboard -Value $script:appInfo.InternalVersion } catch { }
    Write-Log '内部バージョンをクリップボードへコピー'

    # リリース
    if ($script:releaseChannel -like 'dev*') {
        $answer = (Read-Input 'リリースを行う場合は y を入力してください: ').Trim()
        if ($answer -eq 'y') {
            $commitMessage = Read-Input 'コミットメッセージを入力: '
            Invoke-Release ([string]$commitMessage)
        }
    }
}

#============================================================
# メイン処理
#============================================================

Write-Plain $ProgramTitle
Write-Plain "v$ScriptVersion"
Write-Plain ''
Write-Plain "作業ディレクトリー: $WorkDir"
Write-Plain ''

# コンフィグチェック (BuilderConfig.ini)
Update-ConfigFile (Join-Path $WorkDir 'BuilderConfig.ini') @{
    'Info' = [ordered]@{ 'CreatedDate' = (Get-Date -Format 'yyyy/MM/dd HH:mm:ss') }
    'Main' = [ordered]@{
        'ProduireCompiler_Path'            = ''
        'InstallerCompiler_Path'           = ''
        'Dev_Build_Releases_Brunch_Folder' = ''
        'API_URL'                          = ''
        'API_Key'                          = ''
    }
}

# コンパイル試行回数
$script:sourceCompileAttempts = 0
$script:installerCompileAttempts = 0

Invoke-BuildProcess
