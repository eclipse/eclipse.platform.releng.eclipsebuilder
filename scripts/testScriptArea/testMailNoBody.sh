# need the EOF, even if nothing to add, or it'll wait
mail -q testMailContent.txt -s "build failed (eom)"  daddavidw@gmail.com <<EOF
 
EOF