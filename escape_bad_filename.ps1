$gl=(Get-Location).Path
Write-Output ${gl}
$rh=Read-Host "置換します。よろしいですか？[Y/n]"
if ( $rh -eq "Y" ) {
  Get-ChildItem -Recurse |
    Rename-Item -NewName {
      $_.Name -replace '\s','_' -replace '\(','（' -replace '\)','）' -replace '&','＆'
    }
  Read-Host "終了するにはEnterキーを押して下さい..."
}
