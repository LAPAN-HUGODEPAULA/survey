"""Entry point for survey worker."""

import asyncio

from app.jobs.clinical_writer import ClinicalWriterJob, run_forever
from app.logging_config import logger


def main() -> None:
    """Start the Clinical Writer worker loop."""
    logger.info("Starting survey worker for Clinical Writer jobs.")
    asyncio.run(run_forever(ClinicalWriterJob()))


if __name__ == "__main__":
    main()

