"""Preserve exact primary license/source pages for the selected recordings."""
from pathlib import Path
from urllib.request import urlopen,Request
from concurrent.futures import ThreadPoolExecutor
root=Path(__file__).resolve().parent.parent/'docs/jade-road/sources/audio'
pages={
 'CC0-1.0-legalcode.txt':'https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt',
 'tozan-asianoriental1.html':'https://opengameart.org/content/asianoriental1',
 'tozan-asianoriental2.html':'https://opengameart.org/content/asianoriental2',
 'spring-mountain.html':'https://opengameart.org/content/birds-and-wind-ambient-birds-wind-and-synth',
 'randommind-river.html':'https://opengameart.org/content/sea-and-river-wave-sounds',
 'qubodup-ignition.html':'https://opengameart.org/content/flare-ignition',
 'transitking-water.html':'https://opengameart.org/content/water-waves'}
def fetch(entry):
 name,url=entry
 with urlopen(Request(url,headers={'User-Agent':'Mozilla/5.0'}),timeout=45) as response:
  data=response.read()
 (root/name).write_bytes(data)
 return name,len(data)
for row in ThreadPoolExecutor(max_workers=4).map(fetch,pages.items()): print(*row)
