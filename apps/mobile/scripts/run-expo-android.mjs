import { accessSync, constants } from 'node:fs';
import { spawn, spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const mobileAppDir = path.resolve(scriptDir, '..');

const androidStudioJavaHomes = [
  '/Applications/Android Studio.app/Contents/jbr/Contents/Home',
  '/Applications/Android Studio Preview.app/Contents/jbr/Contents/Home',
  '/Applications/Android Studio.app/Contents/jre/Contents/Home',
  '/Applications/Android Studio.app/Contents/jre/jdk/Contents/Home',
];

function hasJavaBinary(javaHome) {
  if (!javaHome) {
    return false;
  }

  try {
    accessSync(path.join(javaHome, 'bin', 'java'), constants.X_OK);
    return true;
  } catch {
    return false;
  }
}

function resolveJavaHomeFromMacOsUtility() {
  if (process.platform !== 'darwin') {
    return null;
  }

  const result = spawnSync('/usr/libexec/java_home', [], {
    encoding: 'utf8',
  });

  if (result.status !== 0) {
    return null;
  }

  const javaHome = result.stdout.trim();
  return hasJavaBinary(javaHome) ? javaHome : null;
}

function resolveJavaHome() {
  const configuredJavaHome = process.env.JAVA_HOME;

  if (configuredJavaHome) {
    if (!hasJavaBinary(configuredJavaHome)) {
      throw new Error(
        `JAVA_HOME is set but invalid: ${configuredJavaHome}. Expected an executable at ${path.join(configuredJavaHome, 'bin', 'java')}.`,
      );
    }

    return {
      javaHome: configuredJavaHome,
      source: 'JAVA_HOME',
    };
  }

  const macOsJavaHome = resolveJavaHomeFromMacOsUtility();
  if (macOsJavaHome) {
    return {
      javaHome: macOsJavaHome,
      source: '/usr/libexec/java_home',
    };
  }

  if (process.platform === 'darwin') {
    const androidStudioJavaHome = androidStudioJavaHomes.find(hasJavaBinary);
    if (androidStudioJavaHome) {
      return {
        javaHome: androidStudioJavaHome,
        source: 'Android Studio bundled JBR',
      };
    }
  }

  return {
    javaHome: null,
    source: 'PATH',
  };
}

function createExpoEnvironment() {
  const resolved = resolveJavaHome();

  if (!resolved.javaHome) {
    if (process.platform === 'darwin') {
      throw new Error(
        'No usable Java runtime was found. Set JAVA_HOME, install a macOS JDK discoverable by `/usr/libexec/java_home`, or install Android Studio so the bundled JBR can be reused.',
      );
    }

    return {
      env: process.env,
      source: resolved.source,
    };
  }

  const currentPath = process.env.PATH ?? '';
  const javaBinPath = path.join(resolved.javaHome, 'bin');
  const nextPath = currentPath.startsWith(`${javaBinPath}${path.delimiter}`)
    ? currentPath
    : `${javaBinPath}${path.delimiter}${currentPath}`;

  return {
    env: {
      ...process.env,
      JAVA_HOME: resolved.javaHome,
      PATH: nextPath,
    },
    source: resolved.source,
  };
}

function runExpoAndroid() {
  const { env, source } = createExpoEnvironment();
  console.info(
    `[mobile:android:run] Using Java from ${source}${env.JAVA_HOME ? ` (${env.JAVA_HOME})` : ''}`,
  );

  const child = spawn('pnpm', ['exec', 'expo', 'run:android', ...process.argv.slice(2)], {
    cwd: mobileAppDir,
    env,
    stdio: 'inherit',
    shell: process.platform === 'win32',
  });

  child.on('exit', (code, signal) => {
    if (signal) {
      process.kill(process.pid, signal);
      return;
    }

    process.exit(code ?? 1);
  });

  child.on('error', (error) => {
    console.error('[mobile:android:run] Failed to launch Expo Android build.', error);
    process.exit(1);
  });
}

try {
  runExpoAndroid();
} catch (error) {
  const message = error instanceof Error ? error.message : 'Unknown error';
  console.error(`[mobile:android:run] ${message}`);
  process.exit(1);
}
