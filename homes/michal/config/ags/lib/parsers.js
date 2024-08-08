/**
 * Parses a string containing power profile information and returns an object
 * with the active profile index and an array of all profiles.
 *
 * The input string should be formatted as follows:
 *
 * ```
 * * performance:
 *     CpuDriver: amd_pstate
 *     PlatformDriver: platform_profile
 *     Degraded: no
 *
 *   balanced:
 *     CpuDriver: amd_pstate
 *     PlatformDriver: platform_profile
 *
 *   power-saver:
 *     CpuDriver: amd_pstate
 *     PlatformDriver: platform_profile
 * ```
 *
 * @param {string} input - The input string containing the power profile information.
 * @returns {object} An object with the active profile index and an array of all profile names.
 */
export function parsePowerProfiles(input) {
  const profiles = [];
  let activeIndex = -1;

  const lines = input.trim().split('\n');

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) {
      continue;
    }

    let [name, ...rest] = line.split(':');
    const isName = rest.length === 1 && rest[0].trim() === '';
    if(!isName) {
      continue;
    }
    const isActive = name.startsWith('*');
    if (isActive) {
      name = name.substring(2);
      activeIndex = profiles.length;
    }

    profiles.push(name);
  }

  return {
    activeIndex,
    profiles,
  };
}
