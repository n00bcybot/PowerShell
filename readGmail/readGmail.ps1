
function GetAccessToken{
    while ($null -eq $accessToken)
    {
    # Use the refresh token to get a new access token
    $tokenResponse = Invoke-RestMethod -Method Post -Uri "https://oauth2.googleapis.com/token" `
        -ContentType "application/x-www-form-urlencoded" `
        -Body @{
            refresh_token = $refreshToken
            client_id = $clientId
            client_secret = $clientSecret
            grant_type = "refresh_token"
        }
    }

    # Store the new access token
    $accessToken = $tokenResponse.access_token

    return $accessToken

}

$accessToken = GetAccessToken

# Define the Gmail API URL for fetching messages
$apiUrl = "https://gmail.googleapis.com/gmail/v1/users/me/messages"

# Set the headers with the authorization token
$headers = @{
    "Authorization" = "Bearer $accessToken"
}

# Make the API request to fetch Gmail messages
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# Output the list of message IDs
$response.messages | ForEach-Object {
    Write-Host "Message ID: $_.id"
}
