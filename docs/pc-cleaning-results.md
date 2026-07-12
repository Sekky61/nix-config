# PC cleaning thermal results

2026-07-12

Summary of before/after cleaning thermal behavior of Framework laptop 13.
Ambient temperature was not measured.
Both runs used charger power and the `performance` platform profile.

After one year of usage, the paste was dry. There wasn't much dust. I applied MX-4 (paste I had already).

## Results

| Test | Before cleaning | After cleaning | Change |
| --- | --- | --- | --- |
| Idle CPU stable temp | 52.0°C | 52.8°C | Similar; all-sample average improved from 54.5°C to 51.0°C |
| Idle CPU max temp | 58.0°C | 54.8°C | Improved |
| Idle GPU stable temp | 48.0°C | 50.4°C | Similar; all-sample average improved from 50.7°C to 48.5°C |
| Idle GPU max temp | 54.0°C | 55.0°C | Similar |
| CPU stress max temp | 100.0°C | 96.0°C | Improved, but still exceeded the 95°C abort threshold quickly |
| CPU stress GPU temp | 78.9°C stable / 80.0°C max | 59.5°C stable / 67.0°C max | Improved |
| Idle fan behavior | Avg 2453 RPM; final 5m avg 1364 RPM | Avg 86 RPM; final 5m avg 281 RPM | Much quieter idle behavior |
| CPU stress fan max | 6261 RPM | 3233 RPM | Lower fan speed before abort |
| GPU stress | Skipped | Skipped | Skipped because CPU stress exceeded abort threshold |
| Combined stress | Skipped | Skipped | Skipped because CPU stress exceeded abort threshold |

## Verdict

Cleaning/repaste clearly improved idle fan behavior and reduced fan noise. CPU stress thermals improved but remain poor: the CPU still exceeded the 95°C abort threshold quickly, reaching 96°C after cleaning. GPU temperatures under CPU stress improved substantially.

The machine is better after cleaning, especially at idle, but sustained CPU load still needs attention if heavy workloads are expected.
