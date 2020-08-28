Import-Module AWSPowershell

$bucket = 'cinegyqa-simple-playout-content'
$syncPath = 'd:\'

$bucketPath = 'scripts'
 
$files = Get-S3Object -BucketName $bucket -KeyPrefix $bucketPath

foreach($file in $files) {
    if($file.Size -gt 0){
        Write-Output "Downloading key $($file.Key)"
        Copy-S3Object -SourceBucket $bucket -SourceKey $($file.Key) -LocalFolder $syncPath
    }
}

$bucketPath = 'content'
 
$files = Get-S3Object -BucketName $bucket -KeyPrefix $bucketPath

foreach($file in $files) {
    if($file.Size -gt 0){
        Write-Output "Downloading key $($file.Key)"
        Copy-S3Object -SourceBucket $bucket -SourceKey $($file.Key) -LocalFolder $syncPath
    }
}


Exit
