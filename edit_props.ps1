$propPath = $(get-location).Path + "\grpc\vsprojects\global.props"

[xml]$prop = Get-Content $propPath

foreach ($node in $prop.Project.ItemDefinitionGroup.ClCompile) {
	if ($node.DisableSpecificWarnings) {
		# Do something
	}
	else {
		$newElem = $prop.CreateElement("DisableSpecificWarnings", $prop.DocumentElement.NamespaceURI)
		$newElem.set_InnerXML("4267;4819;%(DisableSpecificWarnings)")
		$prop.Project.ItemDefinitionGroup.ClCompile.AppendChild($newElem)
		$prop.Project.ItemDefinitionGroup.ClCompile.RemoveAttribute("xmlns");
	}
}

$prop.Save($propPath)