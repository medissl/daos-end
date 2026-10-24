"""Restore synthetic review fixtures; never reads or writes user:// saves."""
from pathlib import Path
import shutil
root=Path(__file__).resolve().parents[1]
output=root/'.verification'
output.mkdir(exist_ok=True)
for source in (root/'tests/fixtures/review').glob('*.json'):
    shutil.copy2(source,output/source.name)
print('Synthetic fixtures available under .verification/. Run earned Jade/Soul scripts before Living UI captures.')
