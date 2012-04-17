# Test no body with sendmail
toAddress=daddavidw@gmail.com

(
echo "From: e4Builder@eclipse.org"
echo "To: ${toAddress}"
echo "MIME-Version: 1.0"
echo "Content-Type: text/plain; charset=utf-8"
echo "Subject: $eclipseStream Build: $buildId canceled. No changes detected (eom)"
echo ""
) | /usr/lib/sendmail -t
