import pytest


@pytest.fixture(scope="session")
def anyio_backend():
    """Force anyio tests to use asyncio backend."""
    return "asyncio"
