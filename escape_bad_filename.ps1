$gl=(Get-Location).Path
Write-Output ${gl}
$rh=Read-Host "�u�����܂��B��낵���ł����H[Y/n]"
if ( $rh -eq "Y" ) {
  Get-ChildItem -Recurse |
    Rename-Item -NewName {
      $_.Name -replace '\s','_' -replace '\(','�i' -replace '\)','�j' -replace '&','��'
    }
  Read-Host "�I������ɂ�Enter�L�[�������ĉ�����..."
}
