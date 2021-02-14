class FlacConverter {
  # flac.exeの絶対パス
  [String]$PATHTOFLAC = "E:\tools\flacdrop\flac.exe"
  # 圧縮率を指定
  [String]$COMPRESSIONRATE = "-8"
  # flacコマンドの標準出力を極力なくすフラグ
  [String]$SILENTFLAG = "--silent"
  # inputファイルを削除するフラグ
  [String]$DELETEINPUTFLAG = "--delete-input-file"

  [void]Convert([System.IO.FileInfo]$WAVFILEPATH) {
    $command = [System.Collections.Generic.List[string]]::new()
    $command.Add($this.PATHTOFLAC)
    $command.Add("'" + $WAVFILEPATH.FullName + "'")
    $command.Add($this.COMPRESSIONRATE)
    $command.Add($this.SILENTFLAG)
    $command.Add($this.DELETEINPUTFLAG)

    Invoke-Expression $($command -join ' ')
  }
}

class FfmpegConverter {
  # ffmpeg.exeの絶対パス
  [String]$PATHTOFFMPEG = "E:\tools\ffmpeg-4.1-win64-static\bin\ffmpeg.exe"
  # 圧縮率を指定
  [String]$COMPRESSIONRATE = "12"
  # ログレベル
  [String]$LOGLEVEL = "error"

  [void]Convert([System.IO.FileInfo]$WAVFILEPATH) {
    $command = [System.Collections.Generic.List[string]]::new()
    $command.Add($this.PATHTOFFMPEG)
    $command.Add("-i")
    $command.Add("'" + $WAVFILEPATH.FullName + "'")
    $command.Add("-acodec flac")
    $command.Add("-compression_level " + $this.COMPRESSIONRATE)
    $command.Add($WAVFILEPATH.DirectoryName + "\" + $WAVFILEPATH.BaseName + ".flac")
    $command.Add("-loglevel " + $this.LOGLEVEL)

    Invoke-Expression $($command -join ' ')
  }
}

Function GetWavFiles() {
  [OutputType([System.IO.FileInfo])]
  $FILES = Get-ChildItem -include *.wav -Recurse
  if ( $FILES.count -eq 0 ) {
    Write-host "There was no wav file."
    Read-Host  "Please press the enter key..."
    exit
  }

  return $FILES
}

## main
$FILES = GetWavFiles
$FlacConverter   = New-Object FlacConverter
$FfmpegConverter = New-Object FfmpegConverter
foreach ( $f in ${FILES} ) {
  $FlacConverter.Convert(${f})

  if ( $LASTEXITCODE -eq 0) {
    Write-host "[INFO] : Done by flac.exe. ${f}"
  } else {
    Write-host "[NOTICE] : Failed to convert by flac.exe, using ffmpeg.exe. ${f}"
  
    $FfmpegConverter.Convert(${f})
    
    if ( $LASTEXITCODE -eq 0) {
      Write-host "[INFO] : Done by ffmpeg.exe. ${f}"
      Remove-Item ${f}
    } else {
      Write-host "[ERROR] : Failed to convert by ffmpeg.exe. Skkiping, ${f}"
    }
  }
}

Write-host
Read-Host "Please press the enter key..."