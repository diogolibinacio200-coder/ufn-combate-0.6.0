"""Original deterministic paddle contact sound; no third-party recordings."""
import math, random, struct, wave
from pathlib import Path
rng = random.Random(61)
rate = 44100
samples = []
for i in range(int(rate * .12)):
    t = i / rate
    envelope = math.exp(-t * 55)
    value = envelope * (.5 * math.sin(2 * math.pi * (780*t-900*t*t)) + .3 * rng.uniform(-1,1))
    samples.append(struct.pack('<h', int(max(-1,min(1,value)) * 22000)))
with wave.open(str(Path(__file__).resolve().parents[1] / 'assets/audio/beach_hit.wav'), 'wb') as out:
    out.setnchannels(1); out.setsampwidth(2); out.setframerate(rate); out.writeframes(b''.join(samples))
