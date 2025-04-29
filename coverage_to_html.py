import json
import re
from pathlib import Path
import datetime

# Define which files to exclude based on patterns
EXCLUDE_PATTERNS = [
    # r'/Tests/',             # Test files
    r'/Models/',            # Data models
    r'/DTOs/',              # Data transfer objects
    r'/Extensions/',        # Extensions
    r'/Middlewares/',       # Middlewares
    r'/Jobs/',              # Jobs
    r'/Migrations/',        # Migrations
    r'/Generated/',         # Auto-generated code
    r'\.build/',            # Build artifacts
    r'_generated\.swift$',  # Files ending in _generated.swift
    r'\.g\.swift$',         # Files ending in .g.swift
    r'/\.swiftpm/',         # Swift Package Manager internals
    r'/Packages/',          # Dependencies (if vendored)
]

# Define the folder to start the relative path from (e.g., "Sources")
START_FROM_FOLDER = "Sources"

def should_exclude(file_path):
    return any(re.search(pat, file_path) for pat in EXCLUDE_PATTERNS)

def get_relative_path(file_path):
    # Create a Path object from the file path
    full_path = Path(file_path)
    # Find the part after the 'Sources' folder
    try:
        start_index = next(i for i, part in enumerate(full_path.parts) if part == START_FROM_FOLDER)
        relative_path = Path(*full_path.parts[start_index:])
        return str(relative_path)
    except StopIteration:
        return file_path  # If 'Sources' isn't found, return the full path

# Get the timestamp of the current build
build_timestamp = datetime.datetime.now().strftime('%Y-%m-%d')

# Construct the path to the coverage report JSON file
coverage_file_path = Path(f"test_reports/coverage_{build_timestamp}.json")
with open(coverage_file_path) as f:
    data = json.load(f)

# Load the JSON report
# with open("coverage.json") as f:
    # data = json.load(f)

files = data["data"][0]["files"]

# Begin HTML output
html = """
<html>
<head>
    <title>Code Coverage Report</title>
    <style>
        body { font-family: sans-serif; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { padding: 8px 12px; border: 1px solid #ddd; text-align: left; }
        th { background-color: #f2f2f2; }
        .low { color: red; }
        .med { color: orange; }
        .high { color: green; }
    </style>
</head>
<body>
    <h1>Code Coverage Report</h1>
    <table>
        <tr><th>File</th><th>Coverage %</th></tr>
"""

# Analyze and filter files
included_files = 0
total_segments = 0
executed_segments = 0

for file in files:
    filename = file["filename"]

    if should_exclude(filename):
        continue

    # Convert to relative path starting from the 'Sources' folder
    relative_filename = get_relative_path(filename)

    segments = file["segments"]
    executed = sum(1 for seg in segments if seg[2] > 0)
    total = len(segments)
    if total == 0:
        continue

    coverage = (executed / total) * 100
    coverage_class = "low" if coverage < 50 else "med" if coverage < 80 else "high"

    html += f"<tr><td>{relative_filename}</td><td class='{coverage_class}'>{coverage:.1f}%</td></tr>"
    included_files += 1
    total_segments += total
    executed_segments += executed

html += "</table>"

if included_files == 0:
    html += "<p><em>No files matched the coverage report filters.</em></p>"

# Calculate overall coverage
total_coverage = (executed_segments / total_segments) * 100 if total_segments > 0 else 0
overall_coverage_class = "low" if total_coverage < 50 else "med" if total_coverage < 80 else "high"
html += f"<h2>Total Coverage: {total_coverage:.1f}%</h2>"

# Write HTML to file
Path(f"test_reports/coverage_report_{build_timestamp}.html").write_text(html)
print("✅ coverage_report.html generated!")
