import 'dotenv/config';

const REDIS_URL = process.env.REDIS_URL;

async function main() {
  console.log('Ingest worker starting...');
  if (!REDIS_URL) {
    console.warn('REDIS_URL not set. Skipping worker startup (intended in skeleton).');
    return;
  }
  // In V1, we will initialize Queue and Workers here.
  console.log('Ready. (Workers will be added in upcoming tasks)');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

