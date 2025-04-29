import re
import pandas as pd
from pathlib import Path
import datetime

# Define a function to parse the log file
def parse_test_log(file_path):
    data = []

    # Regular expressions to capture the required information
    suite_pattern = r"Test Suite '(.*?)' (started|passed|failed) at (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+)"
    case_pattern = r"[✓✗]\s+(\w+)\s*(?:\(([\d\.]+) seconds\))?(?:,\s*(.*?) failed: \((.*?)\) is not equal to \((.*?)\))?"

    current_suite = None
    current_date = None

    try:
        with open(file_path, 'r') as file:
            for line in file:
                # Match Test Suite lines
                suite_match = re.search(suite_pattern, line)
                if suite_match:
                    current_suite = suite_match.group(1)
                    current_date = suite_match.group(3)
                    continue

                # Match Test Case lines
                case_match = re.search(case_pattern, line)
                if case_match:
                    test_case = case_match.group(1)
                    duration = case_match.group(2) or ''
                    assertion = case_match.group(3) or ''
                    actual = case_match.group(4) or ''
                    expected = case_match.group(5) or ''
                    result = 'failed' if line.strip().startswith('✗') else 'passed'
                    issue = f"{assertion} failed: ({actual}) != ({expected})" if result == 'failed' else ''
                    data.append([current_suite, test_case, result, current_date, duration, issue])
    except FileNotFoundError:
        print(f"Error: File not found at '{file_path}'. Please check the file path and try again.")
        return None

    return data

# Main script
if __name__ == "__main__":
    # Get the timestamp of the current build
    build_timestamp = datetime.datetime.now().strftime('%Y-%m-%d')

    log_file = Path(f"test_reports/report_{build_timestamp}.txt")
    output_file = Path(f"test_reports/report_{build_timestamp}.xlsx")

    # Parse the log file
    parsed_data = parse_test_log(log_file)

    if parsed_data:
        # Convert the data into a DataFrame
        columns = ['Test Suite', 'Test Case', 'Result', 'Date', 'Duration (s)', 'Issues ( if fail )']
        df = pd.DataFrame(parsed_data, columns=columns)

        # Add an ID column at the beginning
        df.insert(0, 'ID', [f"API-T-{str(i).zfill(2)}" for i in range(1, len(df) + 1)])

        # Save to an Excel file
        try:
            df.to_excel(output_file, index=False)
            print(f"Data successfully extracted and saved to '{output_file}'.")
        except Exception as e:
            print(f"Error saving the file: {e}")