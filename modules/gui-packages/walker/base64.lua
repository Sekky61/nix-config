Name = "base64"
NamePretty = "Base64"
Icon = "accessories-text-editor"
Cache = false
HideFromProviderlist = false
Description = "Encode or decode Base64 input and copy the result"
Actions = {
    launch = "sh -lc '%VALUE%'",
}

function GetEntries()
    return {
        {
            Text = "Decode Base64 input",
            Subtext = "Open input · copy result to clipboard",
            Value = "@BASE64_DECODE@",
        },
        {
            Text = "Encode Base64 input",
            Subtext = "Open input · copy result to clipboard",
            Value = "@BASE64_ENCODE@",
        },
    }
end
