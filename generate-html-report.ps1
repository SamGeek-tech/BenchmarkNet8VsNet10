# Generate HTML Report from Markdown
param(
    [string]$InputFile = "results\final_report.md",
    [string]$OutputFile = "results\final_report.html"
)

Write-Host "Converting $InputFile to $OutputFile..." -ForegroundColor Cyan

# Read markdown
$content = Get-Content $InputFile -Raw

# Create styled HTML
$htmlTemplate = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>.NET 8 vs .NET 10 Performance Benchmark Report</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            line-height: 1.6;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            margin-top: 30px;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 8px;
        }
        h3 {
            color: #7f8c8d;
            margin-top: 20px;
            margin-bottom: 10px;
            font-size: 1.2em;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th {
            background-color: #3498db;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px 12px;
            border-bottom: 1px solid #ecf0f1;
        }
        tr:hover {
            background-color: #f8f9fa;
        }
        .positive { color: #27ae60; font-weight: bold; }
        .negative { color: #e74c3c; }
        ul { line-height: 1.8; }
        strong { color: #2c3e50; }
        hr { border: 0; border-top: 1px solid #ecf0f1; margin: 30px 0; }
    </style>
</head>
<body>
<div class="container">
{CONTENT}
</div>
</body>
</html>
'@

# Convert tables and headers together
$lines = $content -split '\r?\n'
$htmlContent = ""
$inTable = $false
$isHeader = $false

foreach ($line in $lines) {
    # Handle headers
    if ($line -match '^### (.+)') {
        $htmlContent += "<h3>$($matches[1])</h3>`n"
    }
    elseif ($line -match '^## (.+)') {
        $htmlContent += "<h2>$($matches[1])</h2>`n"
    }
    elseif ($line -match '^# (.+)') {
        $htmlContent += "<h1>$($matches[1])</h1>`n"
    }
    # Handle horizontal rules
    elseif ($line -match '^---+$') {
        $htmlContent += "<hr>`n"
    }
    # Handle tables
    elseif ($line -match '^\|') {
        if (-not $inTable) {
            $htmlContent += "<table>`n"
            $inTable = $true
            $isHeader = $true
        }
        
        $cells = $line -split '\|' | Where-Object { $_ -ne '' } | ForEach-Object { $_.Trim() }
        
        # Skip separator line
        if ($line -match '^[\|\s\-]+$') {
            continue
        }
        
        if ($isHeader) {
            $htmlContent += "<thead><tr>`n"
            foreach ($cell in $cells) {
                $htmlContent += "  <th>$cell</th>`n"
            }
            $htmlContent += "</tr></thead><tbody>`n"
            $isHeader = $false
        }
        else {
            $htmlContent += "<tr>`n"
            foreach ($cell in $cells) {
                $cellContent = $cell
                # Format improvements
                $cellContent = $cellContent -replace '\[(\+|-)\]\s*', ''
                $cellContent = $cellContent -replace '\*\*\+(\d+\.?\d*%)\*\*', '<span class="positive"><strong>+$1</strong></span>'
                $cellContent = $cellContent -replace '\+(\d+\.?\d*%)', '<span class="positive">+$1</span>'
                $cellContent = $cellContent -replace '(?<!>)-(\d+\.?\d*%)', '<span class="negative">-$1</span>'
                $cellContent = $cellContent -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
                $htmlContent += "  <td>$cellContent</td>`n"
            }
            $htmlContent += "</tr>`n"
        }
    }
    # Handle lists
    elseif ($line -match '^- (.+)') {
        $htmlContent += "<li>$($matches[1])</li>`n"
    }
    # Handle regular text
    elseif ($line.Trim() -ne '') {
        if ($inTable) {
            $htmlContent += "</tbody></table>`n"
            $inTable = $false
        }
        # Format bold text
        $formattedLine = $line -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
        $htmlContent += "<p>$formattedLine</p>`n"
    }
    else {
        if ($inTable) {
            $htmlContent += "</tbody></table>`n"
            $inTable = $false
        }
    }
}

# Close any open table
if ($inTable) {
    $htmlContent += "</tbody></table>`n"
}

# Replace content in template
$finalHtml = $htmlTemplate -replace '\{CONTENT\}', $htmlContent

# Write output
$finalHtml | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Success! HTML report generated at: $OutputFile" -ForegroundColor Green
