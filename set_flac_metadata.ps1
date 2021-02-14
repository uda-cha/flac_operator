class FlacMetaEditor {
  # metaflac.exeのへの絶対パス
  [String]$metaflac = "E:\tools\flacdrop\metaflac.exe"

  [void]SetPicture([System.IO.FileInfo]$flac, [System.IO.FileInfo]$picture) {
    $this.DeletePicture($flac)
    $this.ImportPicture($flac, $picture)
  }

  [void]DeletePicture([System.IO.FileInfo]$flac) {
    $rmBlkCommand = [System.Collections.Generic.List[string]]::new()
    $rmBlkCommand.Add($this.metaflac)
    $rmBlkCommand.Add("--remove")
    $rmBlkCommand.Add("--block-type=PICTURE,PADDING")
    $rmBlkCommand.Add($flac.FullName)

    Invoke-Expression $($rmBlkCommand -join ' ')

    if ( $LASTEXITCODE -ne 0) {
      Write-host "[ERROR]: Failed to delete picture block." $flac.Directory.Name $flac.Name
      Read-Host
      exit
    }

    $rmTagCommand = [System.Collections.Generic.List[string]]::new()
    $rmTagCommand.Add($this.metaflac)
    $rmTagCommand.Add("--remove-tag=COVERART")
    $rmTagCommand.Add("--dont-use-padding")
    $rmTagCommand.Add($flac.FullName)

    Invoke-Expression $($rmTagCommand -join ' ')

    if ( $LASTEXITCODE -ne 0) {
      Write-host "[ERROR]: Failed to delete picture tag." $flac.Directory.Name $flac.Name
      Read-Host
      exit
    }
  }

  [void]ImportPicture([System.IO.FileInfo]$flac, [System.IO.FileInfo]$picture) {
    $command = [System.Collections.Generic.List[string]]::new()
    $command.Add($this.metaflac)
    $command.Add("--import-picture-from=" + $picture.FullName)
    $command.Add($flac.FullName)

    Invoke-Expression $($command -join ' ')

    if ( $LASTEXITCODE -ne 0) {
      Write-host "[ERROR]: Failed to import picture." $flac.Directory.Name $flac.Name
      Read-Host
      exit
    }
  }

  [void]SetAlbum([System.IO.FileInfo]$flac) {
    $command = [System.Collections.Generic.List[string]]::new()
    $command.Add($this.metaflac)
    $command.Add("--remove-tag=ALBUM")
    $command.Add("--set-tag=ALBUM=" + $flac.Directory.Name)
    $command.Add($flac.FullName)

    Invoke-Expression $($command -join ' ')

    if ( $LASTEXITCODE -ne 0) {
      Write-host "[ERROR]: Failed to set album name." $flac.Directory.Name $flac.Name
      Read-Host
      exit
    }
  }

  [void]SetTitle([System.IO.FileInfo]$flac) {
    $command = [System.Collections.Generic.List[string]]::new()
    $command.Add($this.metaflac)
    $command.Add("--remove-tag=TITLE")
    $command.Add("--set-tag=TITLE=" + $flac.Name)
    $command.Add($flac.FullName)

    Invoke-Expression $($command -join ' ')

    if ( $LASTEXITCODE -ne 0) {
      Write-host "[ERROR]: Failed to set title." $flac.Directory.Name $flac.Name
      Read-Host
      exit
    }
  }

  [void]SetTruckNumber([System.IO.FileInfo]$flac) {
    $res = $flac.Name -match '^\d+'
    if ( -Not $res ) {
      Write-host "[INFO]: Skipped setting truck number." $flac.Name
      return
    }

    $truckNumber = $Matches[0].TrimStart("0")
    $command = [System.Collections.Generic.List[string]]::new()
    $command.Add($this.metaflac)
    $command.Add("--remove-tag=TRACKNUMBER")
    $command.Add("--set-tag=TRACKNUMBER=" + $truckNumber)
    $command.Add($flac.FullName)

    Invoke-Expression $($command -join ' ')

    if ( $LASTEXITCODE -ne 0) {
      Write-host "[ERROR]: Failed to set title." $flac.Directory.Name $flac.Name
      Read-Host
      exit
    }
  }
}

Function GetCoverFileAtSameDir([System.IO.FileInfo]$file) {
  [OutputType([System.IO.FileInfo])]
  $cover = ( Get-ChildItem ( $file.DirectoryName + "\*.*" ) -include cover.* )
  if ( ${cover}.Count -ne 1 ){
    Write-host "[ERROR]: only one cover.* file must be placed in the same directory."
    Write-host "At:   " $f.FullName
    Write-host "Found:" ${cover}.Count
    Read-Host
    exit
  }

  return $cover
}

#作業ディレクトリ以下にあるファイル一覧を格納
$files = Get-ChildItem -include *.flac -Recurse
$editor = New-Object FlacMetaEditor
Write-host "Importing picture to flacs..."

foreach ( $f in ${files} ) {
  if ( $f.FullName -match '[()&\s]') {
    Write-host "[ERROR]: Invalid file name." $f.FullName
    Read-Host
    exit
  }

  $cover = GetCoverFileAtSameDir($f)
  $editor.SetPicture($f, $cover)
  $editor.SetAlbum($f)
  $editor.SetTitle($f)
  $editor.SetTruckNumber($f)
  Write-host "[INFO]: Done." $f.Directory.Name $f.Name
}

Read-Host "Please press the enter key..."