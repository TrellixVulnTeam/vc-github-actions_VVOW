$ErrorActionPreference = 'Continue'

function Get-GithubPackageUrl {
	param (
		$Versions
	)
	foreach($version in $Versions){
		if($version.PackageUrl[0].Contains("github.com")){
			return $version.PackageUrl[0]
		}
	}
	return $null
}

#Get platform src
git clone https://github.com/VirtoCommerce/vc-platform.git --branch master --single-branch

git clone https://github.com/VirtoCommerce/vc-build.git --branch main --single-branch
Copy-Item -Path "vc-build\docs\CLI-tools\*" -Destination "vc-platform\docs\CLI-tools" -Recurse -Force

# Get all modules from master branch
$modulesv3=Invoke-RestMethod https://raw.githubusercontent.com/VirtoCommerce/vc-modules/master/modules_v3.json
foreach ($module in $modulesv3) {
	$moduleName= Get-GithubPackageUrl -Versions $module.Versions #$module.Versions.PackageUrl[0]
	if($null -eq $moduleName){
		continue
	}
	$substingStartCut="module-"
	$substingEndCut="/releases"
	$substingStartCut=$moduleName.IndexOf($substingStartCut)+$substingStartCut.Length
	$substingEndCut=$moduleName.IndexOf($substingEndCut)-$substingStartCut
	$moduleName=$moduleName.substring($substingStartCut, $substingEndCut)
	$moduleFullName="vc-module-$moduleName"
	if(Test-Path -Path "$moduleFullName"){
        Write-Output "$moduleFullName already exists."
	}
	else{
		git clone https://github.com/VirtoCommerce/vc-module-$moduleName.git --branch master --single-branch
	}
	if(Test-Path -Path "$moduleFullName\docs"){
		Set-Location vc-module-$moduleName
        Copy-Item -Path "docs" -Destination "..\vc-platform\docs\modules\$moduleName" -Recurse -Force
		Set-Location  ..
	}
}