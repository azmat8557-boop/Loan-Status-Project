import pandas as pd
from datetime import datetime
from pathlib import Path
import zipfile


def read_loan_data(file_path="loan_details.xlsx"):
    """Read loan data from Excel and return rows for Robot Framework."""
    df = pd.read_excel(file_path, keep_default_na=False)
    df.columns = [str(col).strip() for col in df.columns]
    return df.to_dict("records")


def save_loan_output(rows, output_path="LoanStatusOutput.xlsx"):
    """Save processed loan rows to a new Excel file."""
    df = pd.DataFrame(rows)
    df.to_excel(output_path, index=False)
    return output_path


def create_report_zip(source_file, output_dir=None):
    """Zip the generated report using dd_MM_yyyy.zip naming."""
    source_path = Path(source_file).resolve()
    target_dir = Path(output_dir).resolve() if output_dir else source_path.parent
    zip_name = f"{datetime.now():%d_%m_%Y}.zip"
    zip_path = target_dir / zip_name

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as archive:
        archive.write(source_path, arcname=source_path.name)

    return str(zip_path)
