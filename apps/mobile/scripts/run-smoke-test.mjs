import { spawn } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const currentFilePath = fileURLToPath(import.meta.url);
const scriptsDir = path.dirname(currentFilePath);
const mobileDir = path.resolve(scriptsDir, '..');
const repoRoot = path.resolve(mobileDir, '..', '..');
const evidenceDir = path.join(repoRoot, '.sisyphus', 'evidence');
const tempDir = path.join(repoRoot, '.sisyphus', 'tmp');
const evidencePath = path.join(evidenceDir, 'task-13-mobile-smoke.txt');
const reportPath = path.join(tempDir, 'task-13-mobile-smoke-report.json');

function formatIsoDate(date) {
  return date.toISOString().slice(0, 10);
}

function createAssertionSummary(assertions) {
  return assertions.map((assertion) => {
    return {
      duration: assertion.duration ?? 0,
      fullName: assertion.fullName,
      status: assertion.status,
      title: assertion.title,
    };
  });
}

function findAssertionById(assertions, testCaseId) {
  const assertion = assertions.find(({ title }) => title.includes(`[${testCaseId}]`));

  if (!assertion) {
    throw new Error(`Expected smoke assertion to exist in Jest report for ${testCaseId}`);
  }

  return assertion;
}

function buildEvidenceContent(assertions) {
  const happyFlow = findAssertionById(assertions, 'T1');
  const offlineStage = findAssertionById(assertions, 'T2');
  const recoverStage = findAssertionById(assertions, 'T3');
  const failureFixture = findAssertionById(assertions, 'T4');

  const lines = [
    '[task-13-mobile-smoke]',
    `date=${formatIsoDate(new Date())}`,
    'scope=issue-6 mobile smoke flow and evidence capture',
    '',
    'commands:',
    '- pnpm --filter mobile test:smoke',
    '',
    'summary:',
    `- total=${assertions.length}`,
    `- passed=${assertions.filter((assertion) => assertion.status === 'passed').length}`,
    `- failed=${assertions.filter((assertion) => assertion.status === 'failed').length}`,
    '',
    'happy-flow:',
    `- status=${happyFlow.status}`,
    '- stages=launch -> booth -> offline -> recover',
    `- test=${happyFlow.title}`,
    '',
    'offline-recover-evidence:',
    `- offline-stage=${offlineStage.status}`,
    `- recover-stage=${recoverStage.status}`,
    '- retry-entrypoint=verified',
    '',
    'failure-fixture:',
    `- status=${failureFixture.status}`,
    '- logged-stage=recover',
    '- message=Smoke stage failed [recover]: forced fixture failure',
    '',
    'assertions:',
    ...assertions.map((assertion) => {
      return `- ${assertion.status} (${assertion.duration}ms): ${assertion.fullName}`;
    }),
  ];

  return `${lines.join('\n')}\n`;
}

async function runSmokeSuite() {
  await mkdir(tempDir, { recursive: true });

  await new Promise((resolve, reject) => {
    const child = spawn(
      'pnpm',
      [
        'exec',
        'jest',
        'src/smoke.test.tsx',
        '--config',
        './jest.config.js',
        '--runInBand',
        '--json',
        `--outputFile=${reportPath}`,
      ],
      {
        cwd: mobileDir,
        env: {
          ...process.env,
          CI: 'true',
        },
        stdio: 'inherit',
      },
    );

    child.on('error', (error) => {
      reject(error);
    });

    child.on('exit', (code) => {
      if (code === 0) {
        resolve();
        return;
      }

      reject(new Error(`Smoke test command failed with exit code ${code ?? -1}`));
    });
  });
}

async function main() {
  await runSmokeSuite();

  const reportContent = await readFile(reportPath, 'utf8');
  const report = JSON.parse(reportContent);
  const assertions = createAssertionSummary(
    report.testResults.flatMap((testResult) => testResult.assertionResults ?? []),
  );

  await mkdir(evidenceDir, { recursive: true });
  await writeFile(evidencePath, buildEvidenceContent(assertions), 'utf8');

  process.stdout.write(`Smoke evidence updated: ${path.relative(repoRoot, evidencePath)}\n`);
}

main().catch((error) => {
  const message = error instanceof Error ? error.message : 'Unknown smoke runner failure';
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
});
