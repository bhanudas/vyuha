sfdx force:package:create --name VyuhaForSpire -d "Vyuha Bulk Flow System"  -t Unlocked --path force-app --targetdevhubusername pmfprod -e
sfdx force:package:version:create --package "VyuhaForSpire" --definitionfile config/project-package-def.json --wait 10 -x --targetdevhubusername pmfprod
sfdx force:package:install --package 04t5c0000014PoKAAU -u spiredev
